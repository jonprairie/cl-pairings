(in-package #:cl-pairings.test)


(define-test swiss-pair-suite)

(define-test swiss-pair-all-players-t
  :parent swiss-pair-suite
  (let* ((max-pl 12)
	 (player-list (loop for pl from 0 to max-pl collect (player pl 2500)))
	 (game-list (append (loop for pl from 0 to max-pl collect (game pl (mod (1+ pl) (1+ max-pl)) :white-win))))
	 (pair-list (s:pair game-list player-list nil)))
    (is >= 1 (count t pair-list :key #'is-bye?))
    (is = 7 (length pair-list))))

(define-test swiss-pair-same-scores-t
  :parent swiss-pair-suite
  (let* ((player-list (loop for pl from 0 to 3 collect (player pl 2500)))
	 (p1 (first player-list))
	 (p2 (second player-list))
	 (p3 (third player-list))
	 (p4 (fourth player-list))
	 (game-list (list (game (get-index-pl p1) (get-index-pl p3) :white-win)
			  (game (get-index-pl p2) (get-index-pl p4) :white-win)))
	 (pair-list (s:pair game-list player-list nil)))
    (true (loop for game in pair-list
		do (when (and (player-in-game (get-index-pl p1) game)
			      (player-in-game (get-index-pl p2) game))
		     (return t))))
    (true (loop for game in pair-list
		do (when (and (player-in-game (get-index-pl p3) game)
			      (player-in-game (get-index-pl p4) game))
		     (return t))))))
