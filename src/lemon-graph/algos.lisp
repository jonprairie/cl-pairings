(in-package #:lemon-graph)


(defparameter *lemon-library* nil)

(defun setup-lemon-library ()
  (unless *lemon-library*
    (cffi:define-foreign-library (liblemonc :search-path (merge-pathnames "src/lemon-graph/lib/" (asdf:system-source-directory :cl-pairings)))
      (t (:default "liblemonc")))
    (let ((path (uiop:getcwd))) 	; this is a weird hack to resolve an issue with SLIME not being able to load the DLL on Windows
      (uiop:chdir "/")
      (cffi:use-foreign-library liblemonc)
      (uiop:chdir path))
    (setf *lemon-library* t)))

(defun build-lgf (node-num edges)
  (format nil "@nodes~%label~%~{~a~%~}~%@edges~%        weights~%~{~{~3a ~3a ~$~}~%~}"
	  (loop for n from 0 to (1- node-num) collect n)
	  edges))

(defun get-max-weighted-matching (lgf)
  "call out to liblemonc to calculate maximum weighted matching"
  (setup-lemon-library)
  (let ((list1 (cffi:foreign-alloc :pointer))
	(list2 (cffi:foreign-alloc :pointer))
	(len (cffi:foreign-alloc :pointer)))
    (cffi:foreign-funcall "getMatching" :pointer list1 :pointer list2 :pointer len :string lgf)
    (prog1 
	(loop for i from 0 to (1- (cffi:mem-ref len :int))
	      collect (cons
		       (cffi:mem-aref (cffi:mem-ref list1 :pointer) :int i)
		       (cffi:mem-aref (cffi:mem-ref list2 :pointer) :int i)))
      (cffi:foreign-free (cffi:mem-ref list1 :pointer))
      (cffi:foreign-free list1)
      (cffi:foreign-free (cffi:mem-ref list2 :pointer))
      (cffi:foreign-free list2)
      (cffi:foreign-free len))))
