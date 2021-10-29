(defpackage #:ctj.lib.swiss
  (:nicknames #:lib.swiss)
  (:use #:cl
	#:alexandria
	#:serapeum
	#:cl-permutation)
  (:shadowing-import-from :alexandria "COMPOSE")
  (:export #:pair
	   #:pair2))
