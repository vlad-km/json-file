;;; -*- mode:lisp; coding:utf-8 -*-

;;; Lisp JSON file primitives
;;; This file is part of the :json-file package
;;; Copyright © 2018 Vladimir Mezentsev
;;;

;;;
;;; Intended for moren environment/electron
;;;

(in-package :json-file)

;;;
;;; Async read json file
;;;
;;; (json-file:read-from
;;;      "/tmp/config/some.json"
;;;      (jso:mk "encoding" "window-1251" "throw" t)
;;;      (lambda (errmsg readed-object) ))
;;;
;;; Return: none
(defun read-from (path opt &optional cb)
    (let ((catchit)
          (options opt))
        (unless cb
            (setq cb opt options (jscl::new)))
        (if (stringp options)
            (setq options (jso:mk "encoding" options)))
        (setq catchit (jso:_get (options "throw")))
        (#j:Fs:readFile
         path
         options
         (lambda (err &optional data)
             (let ((obj)
                   (errcond))
                 (handler-case
                     (progn
                         (cond ((jscl::js-null-p err)
                                (setq obj (#j:JSON:parse data)))
                               (t
                                (if catchit (setq errcond err)) )))
                   (error (msg)
                       (if catchit (setq errcond msg))))
                 (funcall cb errcond obj))))
        (values)))


;;; Sync read json file
;;;
;;; (json-file:read-from "/tmp/config/some.json" "window-1251" )
;;;
;;; Return: deserialized object from file or nil | string
;;;         if error condition
;;;
(defun read-sync-from (path opt)
    (let ((catchit)
          (options opt)
          (data))
        (if (stringp opt)
            (setq options (jso:mk "encoding" opt)))
        (setq catchit (jso:_get (options "throw")))
        (handler-case
            (progn
                (setq data (#j:Fs:readFileSync path options))
                (cond ((jscl::js-null-p data)
                       (setq data nil))
                      (t
                       (setq data (#j:JSON:parse data)))))
          (error (msg)
              (setq data nil)
              (if catchit
                  (error msg))))
        data))


;;; Async write object to file

(defun write-to (path obj opt &optional cb)
    (let ((catchit)
          (options opt)
          (data)
          (stream))
        (unless cb
            (setq cb opt options (jscl::new)))
        (if (stringp options)
            (setq options (jso:mk "encoding" options)))
        (handler-case
            (progn
                (setq stream (#j:Fs:createWriteStream path opt))
                (setq data (stringify obj options))
                (jso:mcall (stream "write") data)
                (jso:mcall (stream "end"))
                (funcall cb (jso:_get (stream "bytesWritten"))))
          (error (msg)
              (jso:mcall (stream "end"))
              (funcall cb nil)))))


;;; Sync write object to file
(defun write-sync-to (path obj opt)
    (let ((options))
        (if (stringp opt)
            (setq options (jso:mk "encoding" options)))
        (handler-case
            (progn
                (#j:Fs:writeFileSync path (stringify obj options) options))
          (error (msg)
              (error msg)))))

(defun stringify (object opt)
    (let ((spaces (jso:_get (opt "spaces"))))
        (concat
         (setq data (if spaces
                        (#j:JSON:stringify object "" spaces)
                        (#j:JSON:stringify object)))
         #\newline )))


(in-package :cl-user)

;;; EOF
