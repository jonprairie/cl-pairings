(asdf:defsystem #:cl-pairings
  :name "cl-pairings"
  :depends-on (:alexandria :serapeum :cffi)
  :pathname "src/"
  :serial t
  :components
  ((:module
    "lemon-graph"
    :components ((:file "package")
		 (:file "algos")))
   (:module
    "swiss"
    :components ((:file "package")
		 (:file "swiss-weights")
		 (:file "swiss")))
   (:module
    "round-robin"
    :components ((:file "package")
		 (:file "round-robin")))))
