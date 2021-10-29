(in-package #:lib.lemon-graph)


(pushnew (host:get-lib-path "lemon-graph/lib/") cffi:*foreign-library-directories*)
(defparameter *lemon-library* nil)


(defun setup-lemon-library ()
  (unless *lemon-library*
    (cffi:define-foreign-library liblemonc
      (t (:default "liblemonc")))
    (setf *lemon-library* (cffi:use-foreign-library liblemonc))))

(defun save-graph (graph)
  "GRAPH is a string in lemon graph format with an EDGES column labeled WEIGHTS"
  (with-open-file (s (host:get-install-path "test_graph.lgf") :direction :output :if-exists :supersede)
    (format s "~a" graph))
  graph)

(defun build-lgf (node-num edges)
  (format nil "@nodes~%label~%~{~a~%~}~%@edges~%        weights~%~{~{~3a ~3a ~$~}~%~}"
	  (loop for n from 0 to (1- node-num) collect n)
	  edges))

(defun build-lgf% (node-num edges)
  (save-graph (build-lgf node-num edges)))

(defun get-max-weighted-matching (lgf)
  "call out to liblemonc to calculate maximum weighted matching"
  (setup-lemon-library)
  (let ((list1 (cffi:foreign-alloc :pointer))
	(list2 (cffi:foreign-alloc :pointer))
	(len (cffi:foreign-alloc :pointer)))
    (cffi:foreign-funcall "getMatching" :pointer list1 :pointer list2 :pointer len :string lgf)
    (prog1 
	(loop for i from 0 to (1- (cffi:mem-ref len :int))
	      collect (list
		       (cffi:mem-aref (cffi:mem-ref list1 :pointer) :int i)
		       (cffi:mem-aref (cffi:mem-ref list2 :pointer) :int i)))
      (cffi:foreign-free (cffi:mem-ref list1 :pointer))
      (cffi:foreign-free list1)
      (cffi:foreign-free (cffi:mem-ref list2 :pointer))
      (cffi:foreign-free list2)
      (cffi:foreign-free len))))
