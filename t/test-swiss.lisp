(in-package #:cl-pairings.test)


(define-test swiss-pair-suite)

(define-test swiss-pair-t
  :parent swiss-pair-suite
  (let* ((max-pl 12)
	 (player-list (loop for pl from 0 to max-pl collect (player pl 2500)))
	 (game-list (append (loop for pl from 0 to max-pl collect (game pl (mod (1+ pl) (1+ max-pl)) :white-win))))
	 (pair-list (s:pair game-list player-list nil)))
    (is >= 1 (count t pair-list :key #'is-bye?))
    (is = 7 (length pair-list))
    ))
