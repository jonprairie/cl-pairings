(in-package #:swiss)


(defun pair (data-table n)
  (mvlet* ((final-table bye-index (add-bye data-table))
	   (pair-weights (assign-weights final-table))
	   (lgf (lib.lemon-graph:build-lgf (length final-table) pair-weights)))
    (~> (lib.lemon-graph:get-max-weighted-matching lgf)
	(mapcar (op (modify-bye _1 bye-index)) _)
	(partition #'is-not-bye _))))

;; this needs to happen here because when we build a matching later we don't account
;; for the "leftover" player if they've already had a bye
(defun add-bye (data-table)
  "add an entry to data-table for the bye if the number of players is odd,
modifying each row's :opps value to include the bye index if they've previously had a bye."
  (if (oddp (length data-table))
      (let ((player-index (length data-table))
	    (opps)
	    (color-pref 0)
	    (bye)
	    (rating 2000)
	    (score 0))
	(loop for p in data-table
	      do (when (getf p :bye)
		   (setf opps (append1 opps (getf p :index)))))
	(values
	 (append1
	  (loop for p in data-table
		collect
		(let ((new-opps (getf p :opps)))
		  (when (getf p :bye)
		    (setf (getf p :opps) (append1 new-opps player-index)))
		  p))
	  (list :index player-index
		:color-pref color-pref
		:bye bye
		:rating rating
		:opps opps
		:score score
		:is-bye t))
	 player-index))
      data-table))

(defun modify-bye (pair bye-index)
  (if bye-index
      (cond
	((= (first pair) bye-index)
	 (list (second pair) nil))
	((= (second pair) bye-index)
	 (list (first pair) nil))
	(t pair))
      pair))

(defun is-not-bye (pair)
  (and (first pair) (second pair)))
