(in-package #:cl-pairings.test)


(define-test build-round-table-suite)

(define-test game-t
  :parent build-round-table-suite
  (let ((g (s:game 0 1 :white-win))
	(r (list :draw :white-win :black-win)))
    (true (s:is-game? g))
    (false (s:is-bye? g))
    (true (member (s:get-result-g g) r))
    (is = 0 (s:get-white (s:get-pair g)))
    (is = 1 (s:get-black (s:get-pair g)))))

(define-test bye-t
  :parent build-round-table-suite
  (let ((b (s:bye 0 :white-win))
	(r (list :draw :white-win :black-win)))
    (true (s:is-bye? b))
    (false (s:is-game? b))
    (true (member (s:get-result-b b) r))
    (is = 0 (s:get-pl b))))

(define-test player-t
  :parent build-round-table-suite
  (let ((pl (s:player 0 2500)))
    (is = 0 (s:get-index-pl pl))
    (is = 2500 (s:get-rating pl))))

(define-test build-round-table-t
  :parent build-round-table-suite)

;; I'm not sure we should test this since it's an internal implementation detail...
(define-test brt-happy-path
  :parent build-round-table-t
  (let* ((max-pl 11) 			; no bye
	 (pl (loop for pl from 0 to max-pl collect (s:player pl 2500)))
	 (gl (append (loop for pl from 0 to max-pl collect (s:game pl (mod (1+ pl) (1+ max-pl)) :white-win))))
	 (rt (s::build-round-table pl gl nil))
	 (rt-len (length rt)))
    ;; each player should have one white and one black game, so color-pref should be 0
    (loop for pd in rt do (is = 0 (getf pd :color-pref)))
    ;; player 0's latest game is as black, every other player's latest game is as white
    (loop for pd in rt
	  do (if (= (getf pd :index) 0)
		 (is eql :black (first (getf pd :color-seq)))
		 (is eql :white (first (getf pd :color-seq))))) 
    ;; no byes
    (loop for pd in rt do
      (false (getf pd :bye))
      (false (getf pd :is-bye)))
    ;; every player has played against the previous and next player
    (loop for i from 0 to (1- (length rt))
	  do (let ((pd (nth i rt)))
	       (true (member (mod (1+ i) rt-len) (getf pd :opps)))
	       (true (member (mod (1- i) rt-len) (getf pd :opps)))))
    ;; every player's rating is 2500
    (loop for pd in rt do (is = 2500 (getf pd :rating)))
    ;; every player's score is 1
    (loop for pd in rt do (is = 1 (getf pd :score)))))
