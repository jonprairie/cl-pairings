(in-package #:lib.swiss)


(defparameter *max-weight* 10000)
(defparameter *diff-score-factor* 100)
(defparameter *score-diff-factor* 10)
(defparameter *ranking-diff-factor* (/ -1  1000))
(defparameter *prev-played-factor* 3000)
(defparameter *prev-bye-factor* 4000)
(defparameter *strong-color-mismatch-factor* 2000)
(defparameter *weak-color-mismatch-factor* 2)
(defparameter *strong-color-streak-factor* 1000)
(defparameter *weak-color-streak-factor* 1)

(defun assign-weights (data-table)
  (let ((pairing-weights))
    (map-combinations
     (lambda (p)
       (let ((f (first p))
	     (s (second p)))
	 (push (list (getf f :index) (getf s :index) (assign-weight f s))
	       pairing-weights)))
     data-table
     :length 2)
    pairing-weights))

(defun assign-weight (p1 p2)
  (- *max-weight*
     (+ (* *diff-score-factor* (get-diff-score p1 p2))
	(* *score-diff-factor* (get-score-diff p1 p2))
	(* *ranking-diff-factor* (get-ranking-diff p1 p2))
	(* *prev-played-factor* (get-prev-played p1 p2))
	(* *prev-bye-factor* (get-prev-bye p1 p2))
	(* *strong-color-mismatch-factor* (get-strong-color-mismatch p1 p2))
	(* *weak-color-mismatch-factor* (get-weak-color-mismatch p1 p2))
	(* *strong-color-streak-factor* (get-strong-color-streak p1 p2))
	(* *weak-color-streak-factor* (get-weak-color-streak p1 p2)))))

(defun get-diff-score (p1 p2)
  (if (= (getf p1 :score) (getf p2 :score)) 0 1))

(defun get-score-diff (p1 p2)
  (abs (- (getf p1 :score) (getf p2 :score))))

(defun get-ranking-diff (p1 p2)
  (abs (- (getf p1 :rating) (getf p2 :rating))))

(defun get-prev-played (p1 p2)
  (if (member (getf p1 :index) (getf p2 :opps)) 1 0))

;; this currently is being handled by an extra player entry passed into the data-table
;; representing the bye. the bye "player" has the appropriate :opps entries set so
;; the get-prev-played weight should apply.
(defun get-prev-bye (p1 p2) 0)

(defun get-strong-color-mismatch (p1 p2)
  (if (or (and (>= (getf p1 :color-pref) 2)
	       (>= (getf p2 :color-pref) 2))
	  (and (<= (getf p1 :color-pref) -2)
	       (<= (getf p2 :color-pref) -2)))
      1 0))

(defun get-weak-color-mismatch (p1 p2)
  (if (or (and (>= (getf p1 :color-pref) 1)
	       (>= (getf p2 :color-pref) 1))
	  (and (<= (getf p1 :color-pref) -1)
	       (<= (getf p2 :color-pref) -1)))
      1 0))

(defun get-strong-color-streak (p1 p2) 0)

(defun get-weak-color-streak (p1 p2) 0)
