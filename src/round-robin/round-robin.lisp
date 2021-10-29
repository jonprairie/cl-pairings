(in-package #:lib.round-robin)

(defun pair (n rnd)
  (partition
   #'game-p
   (mvlet ((normalized-n oddp (even-up n)))
     (loop for pair in (pair-players normalized-n)
	   collect (mapcar (op (set-bye (inc-player _ rnd normalized-n) oddp n))
			   pair)))))

(defun pair-players (n)
  (when (not (divides-p 2 n))
    (error "ah crap"))
  (loop for i from 0 to (1- (/ n 2))
	collect (list i (- n i 1))))

(defun inc-player (k i n)
  ;;increment pairing k by i rounds in an n-player pool
  (let* ((naive-val (+ k i))
	 (num-passes (floor (/ naive-val n))))
    (if (= k 0)
	0
	(mod (+ naive-val num-passes) n))))

(defun divides-p (divisor dividend)
  (= (mod dividend divisor) 0))

(defun even-up (n)
  (if (divides-p 2 n)
      n
      (values (1+ n) t)))

(defun set-bye (k set-bye n)
  (if (and set-bye (= k n))
      nil
      k))

(defun bye-p (pair)
  (or (null (first pair))
      (null (second pair))))

(defun game-p (pair)
  (not (bye-p pair)))
