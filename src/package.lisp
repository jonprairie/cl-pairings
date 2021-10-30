(defpackage #:cl-pairings
  (:use #:cl
	#:alexandria
	#:serapeum)
  (:export #:game
	   #:is-game?
	   #:get-pair
	   #:get-white
	   #:get-black
	   #:get-result-g
	   #:bye
	   #:is-bye?
	   #:get-pl
	   #:get-result-b
	   #:player
	   #:get-index-pl
	   #:get-rating))
