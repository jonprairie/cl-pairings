(in-package #:lib.swiss)


(defparameter +max-color-pref+ 2)
(defparameter +max-calc-depth+ 1000000)
(defparameter *calc-depth* nil)
(defparameter *force-accept* nil)

;; todo: backtrack if more than one leftover bye
;; todo: fail pairings if player already has a bye and is given another one
;; todo: polynomial time algorithm? or other performance enhancements?

(defun pair (data-table n)
  (setf *calc-depth* 0)
  (setf *force-accept* nil)
  (mvlet* ((players (iota n))
	   (brackets (build-brackets data-table players))
	   (potential-pairings (pair-brackets data-table brackets)))
    (if (> *calc-depth* +max-calc-depth+)
	(progn
	  (setf *force-accept* t)
	  (pair-brackets data-table brackets))
	potential-pairings)))

(defun build-brackets (data-table players)
  (assort players :key (op (get-score data-table _))))

(defun pair-brackets (data-table brackets)
  (let ((pairings)
	(down-floaters))
    (loop for bracket in brackets do
      (mvlet ((bracket-pairings bracket-down-floaters (pair-bracket bracket down-floaters data-table)))
	(setf pairings (cons bracket-pairings pairings))
	(setf down-floaters bracket-down-floaters)))
    (values (apply #'append pairings) down-floaters)))

(defun pair-bracket (residents down-floaters data-table)
  (v:trace :swiss "pairing bracket: ~a, ~a" residents down-floaters)
  (if down-floaters
      (pair-heterogeneous residents down-floaters data-table)
      (pair-homogeneous residents data-table)))

(defun pair-homogeneous (residents data-table)
  "find a valid set of pairings and down-floaters for a given group of players, assuming they're homogeneous (same score). if no such set exists, return nil."
  (let ((ranked-players (rank-players data-table residents)))
    (v:trace :swiss "pairing homogeneous group: ~a" ranked-players)
    (pair-players ranked-players data-table)))

(defun pair-heterogeneous (residents down-floaters data-table)
  (let* ((ranked-players (rank-players data-table (append down-floaters residents))))
    (v:trace :swiss "pairing heterogeneous group: ~a, ~a" down-floaters residents)
    (pair-players ranked-players data-table)))

(defun rank-players (data-table players)
  (declare (optimize speed))
  (~> players
      (rank-players-by-score data-table _)
      (assort _ :key (op (get-score data-table _)))
      (mapcar (op (rank-players-by-rating data-table _)) _)
      (apply #'append _)))

(defun rank-players-by-score (data-table players)
  (sort players #'> :key (op (get-score data-table _))))

(defun rank-players-by-rating (data-table players)
  (sort players #'> :key (op (get-rating data-table _))))

(defun pair-players (players data-table)
  (mvlet ((pairings down-floaters (find-pairings players data-table)))
    (if pairings
	(values pairings down-floaters)
	(progn
	  (v:trace :swiss "no valid pairings: ~a" players)
	  (values nil players)))))

(defun find-pairings (players data-table)
  (declare (optimize speed)
	   (inline permute))
  (let* ((player-len (length players))
	 (player-mid (floor (/ player-len 2))))
    (doperms (p player-len)
      (mvlet* ((permuted-players (permute p players))
	       (group-1 group-2 (split-players permuted-players player-mid))
	       (pairings down-floaters (naive-pair-players data-table group-1 group-2))
	       (score (score-pairings pairings data-table)))
	(if score
	    (progn (v:trace :swiss "pairing accepted: ~a, ~a" pairings down-floaters)
		   (return (values pairings down-floaters)))
	    (v:trace :swiss "pairing rejected: ~a, ~a" pairings down-floaters))))))

(declaim (inline naive-pair-players))
(defun naive-pair-players (data-table group-1 group-2)
  (declare (optimize speed))
  (let* ((len-1 (length group-1))
	 (len-2 (length group-2))
	 (longer (longer group-1 group-2))
	 (other-len (if (<= len-1 len-2) len-1 len-2))
	 (leftovers (slice longer other-len)))
    (values (mapcar (op (make-pair data-table _ _)) group-1 group-2) leftovers)))

(declaim (inline make-pair))
(defun make-pair (data-table p1 p2)
  (declare (optimize speed))
  (let ((white)
	(black))
    (if (<= (get-color-pref data-table p1)
	    (get-color-pref data-table p2))
	(setf white p1 black p2)
	(setf white p2 black p1))
    (list white black)))

(declaim (inline split-players))
(defun split-players (players group-1-end)
  (declare (optimize speed))
  (let* ((group-1 (slice players 0 group-1-end))
	 (group-2 (slice players group-1-end)))
    (values group-1 group-2)))

(declaim (inline score-pairings))
(defun score-pairings (pairings data-table)
  (declare (optimize speed))
  (incf *calc-depth*)
  (if (or *force-accept*
	  (> *calc-depth* +max-calc-depth+))
      t
      (loop
	for pair in pairings
	do
	   (let ((p1 (first pair))
		 (p2 (second pair)))
	     (when (or (has-played-p p1 p2 data-table)
		       (color-mismatch-p p1 p2 data-table))
	       (return nil)))
	finally (return t))))

(defun has-played-p (p1 p2 data-table)
  (declare (optimize speed))
  (let ((previous-opps (get-opponents data-table p1)))
    (member p2 previous-opps)))

(defun color-mismatch-p (p1 p2 data-table)
  (declare (optimize speed))
  (let ((pref-1 (get-color-pref data-table p1))
	(pref-2 (get-color-pref data-table p2))
	(min-color-pref (* -1 +max-color-pref+)))
    (or (and (>= pref-1 +max-color-pref+)
	     (>= pref-2 +max-color-pref+))
	(and (<= pref-1 min-color-pref)
	     (<= pref-2 min-color-pref)))))

(defun get-opponents (data-table p)
  (getf (nth p data-table) :opps))

(defun get-score (data-table p)
  (getf (nth p data-table) :score))

(defun get-rating (data-table p)
  (getf (nth p data-table) :rating))

(defun get-color-pref (data-table p)
  (getf (nth p data-table) :color-pref))

(defun get-test-table ()
  (list
   (list :index 0 :color-pref 1 :bye nil :rating 2790 :opps (list 1 2) :score 2)
   (list :index 1 :color-pref 1 :bye nil :rating 2780 :opps (list 0 2) :score 1)
   (list :index 2 :color-pref 2 :bye nil :rating 2770 :opps (list 0 1) :score 0)
   (list :index 3 :color-pref 1 :bye nil :rating 2760 :opps (list 4 5) :score 1)
   (list :index 4 :color-pref 0 :bye nil :rating 2750 :opps (list 3 5) :score 1.5)
   (list :index 5 :color-pref 0 :bye nil :rating 2740 :opps (list 3 4) :score .5)
   (list :index 6 :color-pref 0 :bye nil :rating 2740 :opps (list 7 8) :score 2)
   (list :index 7 :color-pref 0 :bye nil :rating 2730 :opps (list 6 8) :score .5)
   (list :index 8 :color-pref -1 :bye nil :rating 2720 :opps (list 6 7) :score .5)
   (list :index 9 :color-pref -1 :bye nil :rating 2710 :opps (list 10 11) :score 2)
   (list :index 10 :color-pref -2 :bye nil :rating 2710 :opps (list 9 11) :score 1)
   (list :index 11 :color-pref 2 :bye nil :rating 2700 :opps (list 9 10) :score 0)
   (list :index 12 :color-pref 1 :bye t :rating 2600 :opps (list 13) :score 1)
   (list :index 13 :color-pref 0 :bye nil :rating 2600 :opps (list 12 14) :score 1)
   (list :index 14 :color-pref -1 :bye t :rating 2550 :opps (list 13) :score 0)))
