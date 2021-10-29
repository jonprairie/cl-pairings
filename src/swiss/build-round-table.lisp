(in-package #:swiss)

(defun game (p1-n p2-n result)
  (list :game (cons p1 p2) result))

(defun bye (p result)
  (list :bye result))

(defun player (p-n rating)
  (list p-n rating))

(defun is-game? (g)
  (eql first :game))

(defun is-bye? (b)
  (eql first :bye))

(defun basic-player-detail (i)
  (list :index i :color-pref 0 :color-seq nil :bye nil :rating 0 :opps nil :score 0 :is-bye nil))

(defun handle-bye (b player-details has-bye bye-index)
  (let* ((p-n (second b))
	 (result (third b))
	 (pd (aref player-details p-n)))
    (setf (getf pd :bye) t)
    (econd
     ((eql result :white-win) (incf (getf pd :score)))
     ((eql result :draw) (incf (getf pd :score) .5)))
    (when has-bye
      (pushnew (getf pd :opps) bye-index)
      (pushnew (getf (aref player-details bye-index) :opps) p-n))))

(defun handle-game-player (g color player-details)
  (let* ((result (third g))
	 (pairing (second g))
	 (p-n (econd ((eql color :white) (car pairing))
		     ((eql color :black) (cdr pairing))))
	 (pd (aref player-details p-n)))
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
  (handle-game-player g :white player-details)
  (handle-game-player g :black player-details))

(defun build-round-table (player-list game-list not-playing-list)
  (let* ((player-list-length (length player-list))
	 (bye-index player-list-length)
	 (has-bye (oddp (- player-list-length (length not-playing-list))))
	 (final-length (if has-bye (1+ player-list-length) player-list-length))
	 (player-details (make-array final-length :initial-element nil)))
    (loop for i from 0 to final-length
	  for pd across player-details
	  do (setf (aref player-details i) (basic-player-detail i)))
    (when has-bye
      (setf (getf (aref player-details bye-index) :is-bye) t))
    (loop for g in game-list
	  do (econd
	      ((is-bye? g) (handle-bye g player-details has-bye bye-index))
	      ((is-game? g) (handle-game g player-details))))
    (loop for pd across player-details collect pd)))
