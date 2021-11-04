(in-package #:swiss)


(defun pair (game-list player-list not-playing-list)
  (mvlet* ((round-table (build-round-table player-list game-list not-playing-list))
	   (pair-weights (assign-weights round-table))
	   (lgf (lemon-graph:build-lgf (length round-table) pair-weights)))
    (~> (lemon-graph:get-max-weighted-matching lgf)
	(make-games-from-pairs _ round-table))))

(defun make-games-from-pairs (pair-list round-table)
  (loop for pair in pair-list
	collect (make-game-from-pair pair round-table)))

(defun make-game-from-pair (pair round-table)
  (let* ((index1 (get-white pair))
	 (index2 (get-black pair))
	 (pd1 (get-pd-by-index index1 round-table))
	 (pd2 (get-pd-by-index index2 round-table))
	 (is-bye-1 (getf pd1 :is-bye))
	 (is-bye-2 (getf pd2 :is-bye)))
    (cond
      (is-bye-1 (bye index2 nil))
      (is-bye-2 (bye index1 nil))
      (t (game index1 index2 nil)))))
