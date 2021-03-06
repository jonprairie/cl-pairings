(in-package #:swiss)


(defparameter *max-weight* 10000)
(defparameter *diff-score-factor* 100)
(defparameter *score-diff-factor* 10)
(defparameter *ranking-diff-factor* (/ -1  1000))
(defparameter *prev-played-factor* 3000)
(defparameter *prev-bye-factor* 4000)
(defparameter *strong-color-mismatch-factor* 1000)
(defparameter *weak-color-mismatch-factor* 2)
(defparameter *strong-color-streak-factor* 500)
(defparameter *weak-color-streak-factor* 1)

(defun assign-weights (data-table)
  (let ((pairing-weights))
    (map-combinations 
     (lambda (p)
       (let* ((f (first p))
	      (s (second p))
	      (w1 (assign-weight f s))
	      (w2 (assign-weight s f))
	      (final-weight (if (> w1 w2) w1 w2)))
	 (push (list (getf f :index) (getf s :index) final-weight)
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
	(* *weak-color-streak-factor* (get-weak-color-streak p1 p2))
	)))

(defun get-diff-score (p1 p2)
  (if (= (getf p1 :score) (getf p2 :score)) 0 1))

(defun get-score-diff (p1 p2)
  (abs (- (getf p1 :score) (getf p2 :score))))

(defun get-ranking-diff (p1 p2)
  (abs (- (getf p1 :rating) (getf p2 :rating))))

(defun get-prev-played (p1 p2)
  (if (and (not (getf p1 :is-bye))
	   (not (getf p2 :is-bye))
	   (member (getf p1 :index) (getf p2 :opps)))
      1 0))

(defun get-prev-bye (p1 p2)
  (if (or (and (getf p1 :is-bye)
	       (getf p2 :bye))
	  (and (getf p2 :is-bye)
	       (getf p1 :bye)))
      1 0))

(defun get-strong-color-mismatch (p1 p2)
  (+ (if (>= (getf p1 :color-pref) 2) 1 0)
     (if (<= (getf p2 :color-pref) -2) 1 0)))

(defun get-weak-color-mismatch (p1 p2)
  (+ (if (= (getf p1 :color-pref) 1) 1 0)
     (if (= (getf p2 :color-pref) -1) 1 0)))

(defun get-strong-color-streak (p1 p2)
  (let ((p1-seq (getf p1 :color-seq))
	(p2-seq (getf p2 :color-seq)))
    (+ (if (and p1-seq
		(eql (first p1-seq) :white)
		(eql (second p1-seq) :white))
	   1 0)
       (if (and p2-seq
		(eql (first p2-seq) :black)
		(eql (second p2-seq) :black))
	   1 0))))

(defun get-weak-color-streak (p1 p2)
  (+ (if (eql (first (getf p1 :color-seq)) :white) 1 0)
     (if (eql (first (getf p2 :color-seq)) :black) 1 0)))
