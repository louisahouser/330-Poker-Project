(defpackage :poker.hands
  (:use :cl :poker.deck)
  (:export :evaluate-hand
           :hand-type
           :hand-order
           :player-hand
           :hand-cards
	   :compare-hands))

(in-package :poker.hands)

;; Ensures input is a list, converting single items to single-item lists
(defun ensure-list (x)
  (if (listp x) x (list x)))

;; Represents a player's poker hand
;; cards: List of card objects in the hand
;; hand-type: String describing the type of hand (e.g., "Full House")
;; order: Integer ranking of hand type (1-10, where 1 is best)
(defclass player-hand ()
  ((cards :initarg :cards
          :accessor hand-cards)
   (hand-type :initform "High Card"
              :accessor hand-type)
   (order :initform 10
          :accessor hand-order)))

;; Helper Functions for Hand Analysis

;; Counts occurrences of each card rank in a hand
(defun get-rank-counts (hand)
  (let ((counts (make-hash-table)))
    (dolist (card (hand-cards hand))
      (incf (gethash (face-to-value (card-face card)) counts 0)))
    counts))

;; Counts occurrences of each suit in a collection of cards
(defun count-suits (cards)
  (let ((counts (make-hash-table :test #'equal)))
    (loop for card in (ensure-list cards)
          do (incf (gethash (card-suit card) counts 0)))
    counts))

;; Counts occurrences of each rank in a collection of cards
(defun count-ranks (cards)
  (let ((counts (make-hash-table)))
    (loop for card in (ensure-list cards)
          do (let ((value (face-to-value (card-face card))))
               (incf (gethash value counts 0))))
    counts))

;; Hand Type Checking Functions

;; Checks if hand is a flush (all same suit)
(defun is-flush-p (cards)
  (loop for count being the hash-values of (count-suits cards)
        thereis (= count 5)))

;; Checks if hand is a straight (consecutive values)
;; Also handles special case of Ace-low straight (A,2,3,4,5)
(defun is-straight-p (cards)
  (let* ((values (sort (loop for card in cards
                            collect (face-to-value (card-face card)))
                      #'<))
         (min-val (first values))
         (max-val (car (last values))))
    (or (equal values (loop for i from min-val to max-val collect i))
        (equal values '(2 3 4 5 14)))))

;; Checks if hand is a royal straight (10,J,Q,K,A of same suit)
(defun is-royal-p (cards)
  (let ((values (mapcar (lambda (card)
                         (face-to-value (card-face card)))
                       cards)))
    (every (lambda (v) (member v values))
           '(10 11 12 13 14))))

;; Finds numbers of four-of-a-kinds, three-of-a-kinds, and pairs in a hand
(defun find-pairs (cards)
  (let ((counts (count-ranks cards)))
    (values (loop for count being the hash-values of counts count (= count 4))
            (loop for count being the hash-values of counts count (= count 3))
            (loop for count being the hash-values of counts count (= count 2)))))

;; Hand Analysis Helper Functions

;; Gets highest card value in hand
(defun get-high-card (hand)
  (loop for card in (hand-cards hand)
        maximize (face-to-value (card-face card))))

;; Gets suit of highest single card (for tie breaking)
(defun get-high-card-with-suit (hand)
  (let* ((counts (get-rank-counts hand))
         (singles (loop for card in (hand-cards hand)
                       for value = (face-to-value (card-face card))
                       when (= (gethash value counts) 1)
                       collect card))
         (highest-single (loop for card in singles
                             maximize (face-to-value (card-face card)))))
     (loop for card in singles
           when (= (face-to-value (card-face card)) highest-single)
           return (card-suit card))))

;; Converts suit to numeric value for comparison
(defun rank-suit (suit)
  (case (char suit 0)
    (#\D 1)
    (#\C 2)
    (#\H 3)
    (#\S 4)
    (t 0)))

;; Gets rank of highest pair in hand
(defun get-pair-rank (hand)
  (let ((counts (get-rank-counts hand)))
    (loop for rank being the hash-keys of counts
          when (= (gethash rank counts) 2)
          maximize rank)))

;; Gets value of highest single card (kicker)
(defun get-kicker (hand)
  (let ((counts (get-rank-counts hand)))
    (loop for card in (hand-cards hand)
          for value = (face-to-value (card-face card))
          when (= (gethash value counts) 1)
          maximize value)))

;; Gets suit of highest kicker card
(defun get-kicker-suit (hand)
  (let* ((counts (get-rank-counts hand))
         (kicker-cards (loop for card in (hand-cards hand)
                           for value = (face-to-value (card-face card))
                           when (= (gethash value counts) 1)
                           collect card))
         (max-value (loop for card in kicker-cards
                         maximize (face-to-value (card-face card)))))
     (loop for card in kicker-cards
           when (= (face-to-value (card-face card)) max-value)
           return (card-suit card))))

;; Gets all kicker values excluding specified ranks
(defun get-kickers (hand exclude-ranks)
  (sort
    (loop for card in (hand-cards hand)
          for value = (face-to-value (card-face card))
          unless (member value exclude-ranks)
          collect value)
    #'>))

;; Gets rank of three-of-a-kind
(defun get-three-of-kind-rank (hand)
  (let ((counts (get-rank-counts hand)))
    (loop for rank being the hash-keys of counts
          when (= (gethash rank counts) 3)
          maximize rank)))

;; Gets rank of four-of-a-kind
(defun get-four-of-kind-rank (hand)
  (let ((counts (get-rank-counts hand)))
    (loop for rank being the hash-keys of counts
          when (= (gethash rank counts) 4)
          return rank)))

;; Gets ranks of both pairs in two pair hand, sorted high to low
(defun get-two-pair-ranks (hand)
  (let ((counts (get-rank-counts hand))
        (pairs nil))
      (loop for rank being the hash-keys of counts
            when (= (gethash rank counts) 2)
            do (push rank pairs))
      (sort pairs #'>)))

;; Breaks ties between hands of same type
;; Returns T if hand1 wins, NIL if hand2 wins
(defun break-tie (hand1 hand2)
  (let ((type (hand-type hand1)))
    (cond 
      ;; Royal Straight Flush - always tie
      ((string= type "Royal Straight Flush")
       nil)

      ;; Straight Flush - higher straight wins
      ((string= type "Straight Flush")
       (> (get-high-card hand1) (get-high-card hand2)))

      ;; Four of a Kind - compare quad rank, then kicker
      ((string= type "Four of a Kind")
       (let ((rank1 (get-four-of-kind-rank hand1))
             (rank2 (get-four-of-kind-rank hand2)))
         (if (= rank1 rank2)
             (> (get-kicker hand1) (get-kicker hand2))
             (> rank1 rank2))))

      ;; Full House - compare three of a kind rank, then pair rank
      ((string= type "Full House")
       (let ((three1 (get-three-of-kind-rank hand1))
             (three2 (get-three-of-kind-rank hand2)))
         (if (= three1 three2)
             (> (get-pair-rank hand1) (get-pair-rank hand2))
             (> three1 three2))))

      ;; Flush - compare each card in descending order
      ((string= type "Flush")
       (let ((vals1 (get-kickers hand1 nil))
             (vals2 (get-kickers hand2 nil)))
         (loop for v1 in vals1
               for v2 in vals2
               when (/= v1 v2)
               return (> v1 v2))))

      ;; Straight - compare high card
      ((string= type "Straight")
       (> (get-high-card hand1) (get-high-card hand2)))

      ;; Three of a Kind - compare trips rank, then kickers
      ((string= type "Three of a Kind")
       (let ((rank1 (get-three-of-kind-rank hand1))
             (rank2 (get-three-of-kind-rank hand2)))
         (if (= rank1 rank2)
             (let ((kickers1 (get-kickers hand1 (list rank1)))
                   (kickers2 (get-kickers hand2 (list rank2))))
               (loop for k1 in kickers1
                     for k2 in kickers2
                     when (/= k1 k2)
                     return (> k1 k2)))
             (> rank1 rank2))))

      ;; Two Pair - compare high pair, then low pair, then kicker
      ((string= type "Two Pair")
       (let ((pairs1 (get-two-pair-ranks hand1))
             (pairs2 (get-two-pair-ranks hand2)))
          (cond ((> (first pairs1) (first pairs2)) t)     ; Compare high pairs
                ((< (first pairs1) (first pairs2)) nil)
                ((> (second pairs1) (second pairs2)) t)    ; Compare low pairs
                ((< (second pairs1) (second pairs2)) nil)
                (t (> (get-kicker hand1) (get-kicker hand2))))))  ; Compare kickers

      ;; One Pair - compare pair rank, then kickers in order
      ((string= type "Pair")
       (let ((pair1 (get-pair-rank hand1))
             (pair2 (get-pair-rank hand2)))
         (if (= pair1 pair2)
             (let ((kickers1 (get-kickers hand1 (list pair1)))
                   (kickers2 (get-kickers hand2 (list pair2))))
               (loop for k1 in kickers1
                     for k2 in kickers2
                     when (/= k1 k2)
                     return (> k1 k2)))
             (> pair1 pair2))))

      ;; High Card - compare each card in descending order
      (t (let ((vals1 (get-kickers hand1 nil))
               (vals2 (get-kickers hand2 nil)))
           (loop for v1 in vals1
                 for v2 in vals2
                 when (/= v1 v2)
                 return (> v1 v2)))))))

;; Compares two hands to determine winner
;; Returns T if hand1 wins, NIL if hand2 wins
;; First compares hand types, then breaks ties if needed
(defun compare-hands (hand1 hand2)
  (let ((order1 (hand-order hand1))
        (order2 (hand-order hand2)))
    (if (= order1 order2)
        (break-tie hand1 hand2)
        (< order1 order2))))

;; Main hand evaluation function
;; Takes a list of cards and returns a player-hand object
;; Sets the hand type and order based on poker hand rankings
(defun evaluate-hand (cards)
  (let ((hand (make-instance 'player-hand :cards cards)))
    (multiple-value-bind (four-count three-count pair-count)
        (find-pairs cards)
        (cond
          ;; Royal Straight Flush: A-K-Q-J-10 of same suit
          ((and (is-flush-p cards) (is-straight-p cards) (is-royal-p cards))
           (setf (hand-type hand) "Royal Straight Flush"
                 (hand-order hand) 1))
          ;; Straight Flush: Five consecutive cards of same suit
          ((and (is-flush-p cards) (is-straight-p cards))
           (setf (hand-type hand) "Straight Flush"
                 (hand-order hand) 2))
          ;; Four of a Kind: Four cards of same rank
          ((= four-count 1)
           (setf (hand-type hand) "Four of a Kind"
                 (hand-order hand) 3))
          ;; Full House: Three of a kind plus a pair
          ((and (= three-count 1) (= pair-count 1))
           (setf (hand-type hand) "Full House"
                 (hand-order hand) 4))
          ;; Flush: Five cards of same suit
          ((is-flush-p cards)
           (setf (hand-type hand) "Flush"
                 (hand-order hand) 5))
          ;; Straight: Five consecutive cards
          ((is-straight-p cards)
           (setf (hand-type hand) "Straight"
                 (hand-order hand) 6))
          ;; Three of a Kind: Three cards of same rank
          ((= three-count 1)
           (setf (hand-type hand) "Three of a Kind"
                 (hand-order hand) 7))
          ;; Two Pair: Two different pairs
          ((= pair-count 2)
           (setf (hand-type hand) "Two Pair"
                 (hand-order hand) 8))
          ;; One Pair: Two cards of same rank
          ((= pair-count 1)
           (setf (hand-type hand) "Pair"
                 (hand-order hand) 9))
          ;; High Card: No other hand type matches
          (t
           (setf (hand-type hand) "High Card"
                 (hand-order hand) 10))))
    hand))
