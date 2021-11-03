(asdf:defsystem #:cl-pairings
  :name "cl-pairings"
  :depends-on (:alexandria :serapeum :cffi)
  :in-order-to ((asdf:test-op (asdf:test-op :cl-pairings/test)))
  :pathname "src/"
  :serial t
  :components
  ((:file "package")
   (:file "cl-pairings")
   (:module
    "lemon-graph"
    :components ((:file "package")
    		 (:file "algos")))
   (:module
    "swiss"
    :components ((:file "package")
		 (:file "build-round-table")
		 (:file "swiss-weights")
		 (:file "swiss")))
   (:module
    "round-robin"
    :components ((:file "package")
    		 (:file "round-robin")))
   ))

(asdf:defsystem #:cl-pairings/test
  :name "cl-pairings/test"
  :depends-on (:cl-pairings :parachute)
  :perform (asdf:test-op (op c) (uiop:symbol-call :parachute :test :cl-pairings.test))
  :pathname "t/"
  :serial t
  :components
  ((:file "package")
   (:file "test-build-round-table")
   (:file "test-swiss")))
