(in-package #:cl-pairings)


(defun game (p1-n p2-n result)
  (list :game (cons p1-n p2-n) result))

(defun is-game? (g) (eql (first g) :game))
(defun get-pair (g) (second g))
(defmethod get-result-g (g) (third g))
(defun player-in-game (p-n g)
  (or (= p-n (get-white (get-pair g)))
      (= p-n (get-black (get-pair g)))))

(defun bye (p result)
  (list :bye p result))

(defun is-bye? (b) (eql (first b) :bye))
(defun get-pl (b) (second b))
(defun get-result-b (b) (third b))

(defun player (p-n rating)
  (list p-n rating))

(defun get-index-pl (pl) (first pl))
(defun get-rating (pl) (second pl))

(defun make-pair (pl1 pl2) (cons pl1 pl2))
(defun get-white (pair) (car pair))
(defun get-black (pair) (cdr pair))

(defun get-score-from-games (pl games)
  (let ((score 0))
  (loop for g in games
        do (cond
             ((= pl (get-white (get-pair g)))
              (cond
               ((eql (get-result-g g) :white-win)
                (incf score 1))
               ((eql (get-result-g g) :draw)
                (incf score .5))))
             ((= pl (get-black (get-pair g)))
              (cond
               ((eql (get-result-g g) :black-win)
                (incf score 1))
               ((eql (get-result-g g) :draw)
                (incf score .5))))))
        score))

(defun print-pairings-detail (pairings gl)
  (loop for g in pairings do
    (let* ((pair (get-pair g))
           (w (get-white pair))
           (b (get-black  pair)))
      (format t "~a vs ~a, ~a ~a~%" w b (get-score-from-games w gl) (get-score-from-games b gl))
      pairings)))
