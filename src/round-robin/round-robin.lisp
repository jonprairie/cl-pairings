(in-package #:round-robin)

(defun pair (n rnd)
  (mvlet* ((normalized-n bye? (even-up n))
	   (bye-index (1- normalized-n)))
    (loop for pair in (pair-players normalized-n (1- rnd))
	  collect (make-game-from-pair pair bye? bye-index))))

(defun make-game-from-pair (pair bye? bye-index)
  (if (and bye? (rr-is-bye? pair bye-index))
      (make-bye pair bye-index)
      (game (get-white pair) (get-black pair) nil)))

(defun rr-is-bye? (pair bye-index)
  (or (= (get-white pair) bye-index)
      (= (get-black pair) bye-index)))

(defun make-bye (pair bye-index)
  (let ((p1 (get-white pair))
	(p2 (get-black pair)))
    (cond
      ((eql p1 bye-index)
       (bye p2 nil))
      ((eql p2 bye-index)
       (bye p1 nil))
      (t (error "oh boy")))))

(defun pair-players (n rnd)
  (when (not (divides-p 2 n))
    (error "ah crap"))
  (let* ((pre-players (rotate (loop for p from 0 to (- n 2) collect p) (1- rnd)))
	 (players (append1 pre-players (1- n))))
    (loop for pair-n from 0 to (1- (/ n 2))
	  collect (let ((index1 (if (flip-pair pair-n rnd n) pair-n (- n pair-n 1)))
			(index2 (if (flip-pair pair-n rnd n) (- n pair-n 1) pair-n)))
		    (cons (nth index1 players) (nth index2 players))))))

(defun flip-pair (pair-n rnd n)
  (let ((num-legs (floor (/ rnd (- n 1)))))
    (or (and (= pair-n 0)
	     (evenp rnd))
	(and (> pair-n 0)
	     (evenp (+ pair-n num-legs))))))

(defun divides-p (divisor dividend)
  (= (mod dividend divisor) 0))

(defun even-up (n)
  (if (divides-p 2 n)
      n
      (values (1+ n) t)))
