(in-package #:deb-package)

(ftype get-item list symbol list)
(defun get-item (list keyword)
  (rest
   (find-if #'(lambda (item)
                (getf item keyword))
            list)))

(defmacro define-deb-package (name &body forms)
  `(let ((changelog-entries
          (make-array
           ,(length (get-item forms :changelog))
           :initial-contents (list ,@(mapcar
                                      #'(lambda (entry)
                                          `(make-instance 'changelog-entry ,@entry))
                                      (get-item forms :changelog))))))
     (generate (make-instance 'deb-package
                              :name ',name
                              :changelog changelog-entries))))

(defclass changelog-entry ()
  ((version :initarg :version
            :type string
            :initform (error "Version required."))
   (author :initarg :author
           :type string
           :initform (error "Author required."))
   (message :initarg :message
            :type string
            :initform (error "Message required.")))
  (:documentation "A single changelog entry."))

(defclass deb-package ()
  ((name :initarg :name
         :type symbol
         :reader name
         :initform (error "Name required."))
   (changelog :initarg :changelog
              :type (vector changelog-entry)
              :reader changelog
              :initform (error "Changelog required.")))
  (:documentation "Holds all the data required to generate a debian package."))

(ftype generate deb-package null)
(defun generate (package)
  "Generates a debian package."
  (format t "~A: ~A"
          (string-downcase (symbol-name (name package)))
          (changelog package)))
