(defpackage #:cl-pairings
  (:use #:cl
	#:alexandria
	#:serapeum)
  (:export #:game
	   #:is-game?
	   #:make-pair
	   #:get-pair
	   #:get-white
	   #:get-black
	   #:get-result-g
	   #:player-in-game
	   #:bye
	   #:is-bye?
	   #:get-pl
	   #:get-result-b
	   #:player
	   #:get-index-pl
	   #:get-rating))
