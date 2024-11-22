(defpackage :poker.deck
	(:use :cl)
	;; Export all public symbols that other packages will need to access
	(:export :make-card
		 :card-suit
		 :card-face
		 :make-deck
		 :shuffle-deck
		 :deal-hands
		 :card-to-string
		 :face-to-value
		 :card
		 :deck
		 :deck-cards
		 :dealt-hands
		 :print-hands
		 :print-remaining-cards))

(in-package :poker.deck)

;;;;; CARD CLASS DEFINITION AND METHODS

(defclass card ()
	;; Define slots for a card's suit and face value
	((suit :initarg :suit      ; The card's suit (D, C, H, S)
	       :accessor card-suit
	       :type string)
	 (face :initarg :face      ; The card's face value (A, 2-10, J, Q, K)
	       :accessor card-face
	       :type string)))

;; Convert a card object to its string representation
(defmethod card-to-string ((card card))
	(format nil "~A~A" (card-face card) (card-suit card)))

;; Convert face card values to their numerical equivalents
;; This is used for comparing card values in poker hands
(defun face-to-value (face)
	(cond ((string= face "A") 14)    ; Ace high
	      ((string= face "K") 13)    ; King
	      ((string= face "Q") 12)    ; Queen
	      ((string= face "J") 11)    ; Jack
	      ((string= face "10") 10)   ; 10
	      ((stringp face) (parse-integer face :junk-allowed nil)) ; Numbers 2-9
	      (t face)))                 ; Pass through if already numeric


;;;;;;;; DECK CLASS DEFINITION AND METHODS

(defclass deck ()
	;; Define slots for the deck's cards and dealt hands
	((cards :initform nil           ; List of all cards in the deck
		:accessor deck-cards)
	 (dealt-hands :initform (make-array 6 :initial-element nil)  ; Array of 6 hands
		      :accessor dealt-hands)))

;; Create a new deck of 52 cards
;; Optional test parameter allows creation of empty deck for testing
(defun make-deck (&optional test)
	(let ((deck (make-instance 'deck)))
		(unless test  ; If not a test deck, populate with 52 cards
			(let ((suits '("D" "C" "H" "S"))
			      (faces '("A" "2" "3" "4" "5" "6" "7" "8" "9" "10" "J" "Q" "K")))
			(setf (deck-cards deck)
				(loop for suit in suits
					nconc (loop for face in faces
						collect (make-instance 'card :suit suit :face face))))))
	deck))

;; Shuffle the deck using Fisher-Yates algorithm
(defmethod shuffle-deck ((deck deck))
	;; Create a new random state for true randomization
	(setf *random-state* (make-random-state t))

	;; Implement Fisher-Yates shuffle
	(setf (deck-cards deck)
	      (loop with cards = (deck-cards deck)
		    with len = (length cards)
		    for i from (1- len) downto 1
		    for j = (random (1+ i))
		    do (rotatef (nth i cards) (nth j cards))
		    finally (return cards))))

;; Deal 5 cards each to 6 players
(defmethod deal-hands ((deck deck))
	(let ((hands (make-array 6 :initial-element nil)))
		(loop for i from 0 below 30        ; Deal 30 cards total (5 to each of 6 players)
			for card in (deck-cards deck)
			for hand-index = (mod i 6)     ; Cycle through players 0-5
			do (push card (aref hands hand-index)))
		(setf (dealt-hands deck) hands)))

;; Print all dealt hands
(defmethod print-hands ((deck deck))
	(format t "*** Here are the six hands...~%")
	(loop for hand across (dealt-hands deck)
		do (format t "~{~A ~}~%" (mapcar #'card-to-string (reverse hand)))))

;; Print remaining cards in deck after dealing
(defmethod print-remaining-cards ((deck deck))
	(format t "*** Here is what remains in the deck...~%")
	(loop for card in (nthcdr 30 (deck-cards deck))  ; Skip first 30 cards (dealt ones)
		do (format t "~A " (card-to-string card)))
	(format t "~%"))


