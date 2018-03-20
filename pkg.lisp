;;; -*- mode:lisp; coding:utf-8 -*-

;;; Lisp JSON file primitives
;;; This file is part of the :json-file package
;;; Copyright © 2018 Vladimir Mezentsev
;;;


(eval-when (:compile-toplevel :load-toplevel :execute)
    (unless (find :json-file *features*)
        (push :json-file *features*)))

(defpackage #:json-file
  (:use #:cl)
  (:export #:check-file-exists
           #:read-from #:read-sync-from
           #:write-to #:write-sync-to))


;;; EOF
