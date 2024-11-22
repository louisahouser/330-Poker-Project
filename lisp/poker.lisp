#!/usr2/local/sbcl/bin/sbcl --script

(load "deck.lisp")
(load "hands.lisp")

(defpackage :poker
	(:use :cl :poker.deck :poker.hands)
	(:export :main))

(in-package :poker)

;; Global hash table to track seen cards for duplicate detection
(defvar *seen-cards* (make-hash-table :test #'equal))

;; Validation Functions

;; Checks for duplicate cards in the deck
;; Throws error if duplicate is found
(defun validate-no-duplicates (card)
  (let ((card-key (card-to-string card)))
    (when (gethash card-key *seen-cards*)
      (error "*** ERROR - DUPLICATE CARD FOUND IN DECK ***~%*** DUPLICATE: ~A ***" card-key))
    (setf (gethash card-key *seen-cards*) t)))

;; Validates that card suits are uppercase
;; Throws error if lowercase or invalid suit is found
(defun validate-suit-case (input-str)
  (let* ((trimmed-str (string-trim " " input-str))
         (suit-char (char trimmed-str (1- (length trimmed-str)))))
    (unless (and (char= (char-upcase suit-char) suit-char)
                 (member suit-char '(#\D #\C #\H #\S)))
      (error "*** ERROR - SUITS MUST BE UPPERCASE ***~%*** INVALID CARD: ~A ***" trimmed-str))))

;; Validates card string format
;; Ensures proper spacing and length for different card values
(defun validate-card-format (card-str)
  (let* ((card (string-trim "," card-str))
         (no-spaces (string-trim " " card)))
    
    ;; Special handling for 10 cards
    (if (and (>= (length no-spaces) 3) 
             (string= (subseq no-spaces 0 2) "10"))
        (if (and (> (length card) 0)
                (char= (char card 0) #\Space))
            (error "*** ERROR - CARDS MUST BE 3 CHARACTERS LONG ***~%*** INVALID CARD LENGTH: ~A ***" no-spaces)
            card)
        ;; All other cards must have leading space
        (progn 
          (when (and (= (length no-spaces) 2)
                    (or (< (length card) 1)
                        (not (char= (char card 0) #\Space))))
            (error "*** ERROR - CARDS MUST BE 3 CHARACTERS LONG ***~%*** INVALID CARD LENGTH: ~A ***" no-spaces))
          card))))

;; File Reading Functions

;; Reads and parses a test file containing poker hands
;; Returns list of hands (each hand is a list of cards)
(defun read-test-file (filename)
  (clrhash *seen-cards*)  ; Clear seen cards at start of each file
  (with-open-file (stream filename)
    (loop for line = (read-line stream nil nil)
          while line
          when (> (length (string-trim " ," line)) 0)
          collect (parse-test-hand line))))

;; Parses a single line from test file into a hand
;; Validates card format and creates card objects
(defun parse-test-hand (line)
  (let ((cards (split-string line)))
    (loop for card-str in cards
          when (> (length (string-trim " ," card-str)) 0)
          collect
          (let* ((card-str (validate-card-format card-str))
                 (no-spaces (string-trim " " card-str))
                 (len (length no-spaces))
                 (face (if (string= (subseq no-spaces 0 2) "10")
                          "10"
                          (string (char no-spaces 0))))
                 (suit (subseq no-spaces (1- len))))
            (validate-suit-case no-spaces)
            (let ((card (make-instance 'card :face face :suit suit)))
              (validate-no-duplicates card)
              card)))))

;; Utility function to split string on commas
;; Returns list of substrings
(defun split-string (string &optional (separators '(#\,)))
  (let ((len (length string))
        (start 0)
        (words nil))
    (dotimes (i len)
      (when (member (char string i) separators)
        (let ((word (string-trim "," (subseq string start i))))
          (when (> (length (string-trim " ," word)) 0)
            (push word words)))
        (setf start (1+ i))))
    
    (let ((last-word (string-trim "," (subseq string start))))
      (when (> (length(string-trim " ," last-word)) 0)
        (push last-word words)))
    (nreverse words)))

;; Ensures consistent card string formatting
;; Handles special case for 10 cards
(defmethod card-to-string ((card card))
  (if (string= (card-face card) "10")
      (format nil "~A~A" (card-face card) (card-suit card))
      (format nil " ~A~A" (card-face card) (card-suit card))))

;; Main Program Function

;; Main entry point for the program
;; Handles command line arguments and program flow
(defun main ()
  (let ((argv (cdr sb-ext:*posix-argv*))) ; Skip the script name
    (handler-case
        (if argv
            ;; Process test file if provided
            (let ((filename (car argv)))
              (unless (probe-file filename)
                (error "File not found: ~A" filename))
              (format t " *** P O K E R   H A N D   A N A L Y Z E R ***~%~%")
              (format t "*** USING TEST DECK ***~%")
              (format t "*** File: ~A~%" filename)
              (let* ((hands (read-test-file filename))
                     (evaluated-hands (mapcar #'evaluate-hand hands)))
                (when (null hands)
                  (error "No valid hands found in file"))
                (format t "~%*** Here are the six hands...~%")
                (dolist (hand hands)
                  (format t "~{~A ~}~%" (mapcar #'card-to-string hand)))
                (format t "~%--- WINNING HAND ORDER ---~%")
                (dolist (hand (sort evaluated-hands #'compare-hands))
                  (format t "~{~A ~}- ~A~%"
                          (mapcar #'card-to-string (hand-cards hand))
                          (hand-type hand)))))
            ;; Run with shuffled deck if no file provided
            (progn
              (format t "*** POKER HAND ANALYZER ***~%~%")
              (let ((deck (make-deck)))
                (shuffle-deck deck)
                (format t "*** Shuffled 52 card deck: ~%")
                (loop for card in (deck-cards deck)
                      for i from 1
                      do (format t "~A " (card-to-string card))
                      when (zerop (mod i 13))
                      do (format t "~%"))
                (deal-hands deck)
                (format t "~%")
                (print-hands deck)
                (format t "~%")
                (print-remaining-cards deck)
                (let ((evaluated-hands
                       (loop for hand across (dealt-hands deck)
                             collect (evaluate-hand hand))))
                  (format t "~%--- WINNING HAND ORDER ---~%")
                  (dolist (hand (sort evaluated-hands #'compare-hands))
                    (format t "~{~A ~}- ~A~%"
                            (mapcar #'card-to-string (hand-cards hand))
                            (hand-type hand)))))))
      ;; Error handling
      (error (e)
        (format t "~A~%" e)
        (sb-ext:exit :code 1)))))
 
(main)
