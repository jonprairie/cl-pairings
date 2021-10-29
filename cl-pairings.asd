(asdf:defsystem #:ctj
  :name "Chess: The Journey"
  :depends-on (:alexandria :serapeum :bknr.datastore :sqlite :defclass-std :cl-uci :queen :jonathan :cl-randist :ppath :cl-permutation :verbose :cl-ini :cl-csv :cl-geocode :cffi) ;simple-tasks? :bordeaux-threads? :opticl? :yason? :qtools :qtcore :qtgui 
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
		 (:file "swiss")
		 (:file "swiss-weights")
		 (:file "swiss2")))
   (:module
    "round-robin"
    :components ((:file "package")
		 (:file "round-robin")))))
