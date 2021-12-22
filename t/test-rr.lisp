(in-package #:cl-pairings.test)


(define-test rr-pair-suite)

(define-test rr-pair-all-players-t
  :parent rr-pair-suite
  (let* ((pair-list-no-bye (rr:pair 10 1))
	 (pair-list-bye (rr:pair 11 1)))
    (is = 5 (length pair-list-no-bye))
    (is = 6 (length pair-list-bye))
    (true (not (loop for game in pair-list-no-bye do (when (is-bye? game) (return t)))))
    (true (loop for game in pair-list-bye do (when (is-bye? game) (return t))))))

(define-test rr-pair-same-games-odd-t
  :parent rr-pair-suite
  (let* ((n 11)
	 (num-legs 1)
	 (rnds (* num-legs n))
	 (pair-list (apply #'append (loop for r from 1 to rnds collect (rr:pair n r))))
	 (num-player-games (loop for p from 1 to n collect 0))
	 (num-player-whites (loop for p from 1 to n collect 0))
	 (num-player-blacks (loop for p from 1 to n collect 0))
	 (num-player-byes (loop for p from 1 to n collect 0)))
    (loop for game in pair-list
	  do (if (is-bye? game)
		 (incf (nth (get-pl game) num-player-byes))
		 (progn
		   (let* ((pair (get-pair game))
			  (white (get-white pair))
			  (black (get-black pair)))
		     (incf (nth white num-player-games))
		     (incf (nth black num-player-games))
		     (incf (nth white num-player-whites))
		     (incf (nth black num-player-blacks))))))
    (loop for i from 0 to (1- n) do (is = (- rnds num-legs) (nth i num-player-games)))
    (loop for i from 0 to (1- n) do (is = 1 (nth i num-player-byes)))
    (loop for i from 0 to (1- n) do (is = (/ (- rnds num-legs) 2) (nth i num-player-whites)))
    (loop for i from 0 to (1- n) do (is = (/ (- rnds num-legs) 2) (nth i num-player-blacks)))))

(define-test rr-pair-same-games-even-t
  :parent rr-pair-suite
  (let* ((n 12)
	 (num-legs 1)
	 (rnds (* num-legs (1- n)))
	 (pair-list (apply #'append (loop for r from 1 to rnds collect (rr:pair n r))))
	 (num-player-games (loop for p from 1 to n collect 0))
	 (num-player-whites (loop for p from 1 to n collect 0))
	 (num-player-blacks (loop for p from 1 to n collect 0))
	 (num-player-byes (loop for p from 1 to n collect 0)))
    (loop for game in pair-list
	  do (if (is-bye? game)
		 (incf (nth (get-pl game) num-player-byes))
		 (progn
		   (let* ((pair (get-pair game))
			  (white (get-white pair))
			  (black (get-black pair)))
		     (incf (nth white num-player-games))
		     (incf (nth black num-player-games))
		     (incf (nth white num-player-whites))
		     (incf (nth black num-player-blacks))))))
    (loop for i from 0 to (1- n) do (is = rnds (nth i num-player-games)))
    (loop for i from 0 to (1- n) do (is = 0 (nth i num-player-byes)))
    (loop for i from 0 to (1- n) do (true (<= (abs (- (/ (- rnds num-legs) 2) (nth i num-player-whites))) 1)))
    (loop for i from 0 to (1- n) do (true (<= (abs (- (/ (- rnds num-legs) 2) (nth i num-player-blacks))) 1)))))

(define-test rr-pair-same-games-odd-double-t
  :parent rr-pair-suite
  (let* ((n 11)
	 (num-legs 2)
	 (rnds (* num-legs n))
	 (pair-list (apply #'append (loop for r from 1 to rnds collect (rr:pair n r))))
	 (num-player-games (loop for p from 1 to n collect 0))
	 (num-player-whites (loop for p from 1 to n collect 0))
	 (num-player-blacks (loop for p from 1 to n collect 0))
	 (num-player-byes (loop for p from 1 to n collect 0)))
    (loop for game in pair-list
	  do (if (is-bye? game)
		 (incf (nth (get-pl game) num-player-byes))
		 (progn
		   (let* ((pair (get-pair game))
			  (white (get-white pair))
			  (black (get-black pair)))
		     (incf (nth white num-player-games))
		     (incf (nth white num-player-whites))
		     (incf (nth black num-player-games))
		     (incf (nth black num-player-blacks))))))
    (loop for i from 0 to (1- n) do (is = (- rnds num-legs) (nth i num-player-games)))
    (loop for i from 0 to (1- n) do (is = 2 (nth i num-player-byes)))
    (loop for i from 0 to (1- n) do (is = (/ (- rnds num-legs) 2) (nth i num-player-whites)))
    (loop for i from 0 to (1- n) do (is = (/ (- rnds num-legs) 2) (nth i num-player-blacks)))))

(define-test rr-pair-same-games-even-double-t
  :parent rr-pair-suite
  (let* ((n 12)
	 (num-legs 2)
	 (rnds (* num-legs (1- n)))
	 (pair-list (apply #'append (loop for r from 1 to rnds collect (rr:pair n r))))
	 (num-player-games (loop for p from 1 to n collect 0))
	 (num-player-whites (loop for p from 1 to n collect 0))
	 (num-player-blacks (loop for p from 1 to n collect 0))
	 (num-player-byes (loop for p from 1 to n collect 0)))
    (loop for game in pair-list
	  do (if (is-bye? game)
		 (incf (nth (get-pl game) num-player-byes))
		 (progn
		   (let* ((pair (get-pair game))
			  (white (get-white pair))
			  (black (get-black pair)))
		     (incf (nth white num-player-games))
		     (incf (nth black num-player-games))
		     (incf (nth white num-player-whites))
		     (incf (nth black num-player-blacks))))))
    (loop for i from 0 to (1- n) do (is = rnds (nth i num-player-games)))
    (loop for i from 0 to (1- n) do (is = 0 (nth i num-player-byes)))
    (loop for i from 0 to (1- n) do (is = (/ rnds 2) (nth i num-player-whites)))
    (loop for i from 0 to (1- n) do (is = (/ rnds 2) (nth i num-player-blacks)))))
