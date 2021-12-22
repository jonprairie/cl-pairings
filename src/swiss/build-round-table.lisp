(in-package #:swiss)


(defun get-pd-by-index (index round-table)
  (nth index round-table))

(defun basic-player-detail (i rating bye)
  (list :index i :color-pref 0 :color-seq nil :bye nil :rating rating :opps nil :score 0 :is-bye bye))

(defun handle-bye (b player-details has-bye bye-index)
  (let* ((p-n (get-pl b))
	 (result (get-result-b b))
	 (pd (aref player-details p-n)))
    (setf (getf pd :bye) t)
    (econd
     ((eql result :white-win) (incf (getf pd :score)))
     ((eql result :draw) (incf (getf pd :score) .5)))
    (when has-bye
      (pushnew bye-index (getf pd :opps))
      (pushnew  p-n (getf (aref player-details bye-index) :opps)))))

(defun handle-game-by-player (g color player-details)
  (let* ((result (get-result-g g))
	 (pairing (get-pair g))
	 (p-n (econd ((eql color :white) (get-white pairing))
		     ((eql color :black) (get-black pairing))))
	 (opp-n (econd ((eql color :white) (get-black pairing))
		       ((eql color :black) (get-white pairing))))
	 (pd (aref player-details p-n)))
    (pushnew opp-n (getf pd :opps))
    (cond
      ((eql result :draw)
       (incf (getf pd :score) .5))
      ((and (eql result :white-win)
	    (eql color :white))
       (incf (getf pd :score)))
      ((and (eql result :black-win)
	    (eql color :black))
       (incf (getf pd :score))))
    (econd
     ((eql color :white) (incf (getf pd :color-pref)))
     ((eql color :black) (decf (getf pd :color-pref))))
    (push color (getf pd :color-seq))))

(defun handle-game (g player-details)
  (handle-game-by-player g :white player-details)
  (handle-game-by-player g :black player-details))

;; TODO: implement not-playing-list
(defun build-round-table (player-list game-list not-playing-list)
  (let* ((player-list-length (length player-list))
	 (bye-index player-list-length)
	 (has-bye (oddp (- player-list-length (length not-playing-list))))
	 (final-length (if has-bye (1+ player-list-length) player-list-length))
	 (player-details (make-array final-length :initial-element nil)))
    (loop for i from 0 to (1- final-length)
	  for pd across player-details
	  do (let* ((is-bye-index? (and has-bye (= i (1- final-length))))
		    (rating (if is-bye-index? 0 (get-rating (nth i player-list)))))
	       (setf (aref player-details i) (basic-player-detail i rating is-bye-index?))))
    (loop for g in game-list
	  do (econd
	      ((is-bye? g) (handle-bye g player-details has-bye bye-index))
	      ((is-game? g) (handle-game g player-details))))
    (loop for pd across player-details collect pd)))
