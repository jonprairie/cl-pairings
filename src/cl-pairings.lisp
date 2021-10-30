(in-package #:cl-pairings)


(defun game (p1-n p2-n result)
  (list :game (cons p1-n p2-n) result))

(defun is-game? (g) (eql (first g) :game))
(defun get-pair (g) (second g))
(defmethod get-result-g (g) (third g))

(defun bye (p result)
  (list :bye p result))

(defun is-bye? (b) (eql (first b) :bye))
(defun get-pl (b) (second b))
(defun get-result-b (b) (third b))

(defun player (p-n rating)
  (list p-n rating))

(defun get-index-pl (pl) (first pl))
(defun get-rating (pl) (second pl))

(defun pair (pl1 pl2) (cons pl1 pl2))
(defun get-white (pair) (car pair))
(defun get-black (pair) (cdr pair))
