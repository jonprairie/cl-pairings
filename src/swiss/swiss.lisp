(in-package #:swiss)


(defun pair (game-list player-list not-playing-list)
  (let* ((round-table (build-round-table player-list game-list not-playing-list))
	 (pair-weights (assign-weights round-table))
	 (lgf (lemon-graph:build-lgf (length round-table) pair-weights)))
    (~> (lemon-graph:get-max-weighted-matching lgf)
	(make-games-from-pairs _ round-table))))

(defun make-games-from-pairs (pair-list round-table)
  (loop for pair in pair-list
	collect (make-game-from-pair pair round-table)))

(defun make-game-from-pair (pair round-table)
  (mvlet* ((index1 (get-white pair))
	   (index2 (get-black pair))
	   (pd1 (get-pd-by-index index1 round-table))
	   (pd2 (get-pd-by-index index2 round-table))
	   (white-idx black-idx (choose-white-black pd1 pd2))
	   (is-bye-1 (getf pd1 :is-bye))
	   (is-bye-2 (getf pd2 :is-bye)))
    (cond
      (is-bye-1 (bye index2 nil))
      (is-bye-2 (bye index1 nil))
      (t (game white-idx black-idx nil)))))

;; we do the max-weighted-matching on an undirected graph (directed graphs not supported for mwm in lemon)
;; so we have to disambiguate the color of the pairing here.
(defun choose-white-black (pd1 pd2)
  (let ((w1 (assign-weight pd1 pd2))
	(w2 (assign-weight pd2 pd1)))
    (if (> w1 w2)
	(values (getf pd1 :index) (getf pd2 :index))
	(values (getf pd2 :index) (getf pd1 :index)))))
