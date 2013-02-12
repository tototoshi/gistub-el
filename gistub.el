;;; gistub.el

;; Copyright (C) 2013 Toshiyuki Takahashi

;; Author: Toshiyuki Takahashi (@tototoshi)
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Usage:
;;;
;;; (require 'gistub)
;;;
;;; M-x gistub-demo-post
;;;   post current buffer to http://gistub-demo.seratch.net/
;;;
;;; Code:

(require 'http-get)

(defun gistub-string-join (lst &optional separator)
  (mapconcat 'identity lst separator))

(defvar gistub-demo-url "http://gistub-demo.seratch.net/")
(defvar gistub-demo-post-url "http://gistub-demo.seratch.net/gists")

(defun gistub-demo-get-authenticity-token ()
  (with-temp-buffer
    (insert
     (shell-command-to-string (concat "curl " gistub-demo-url)))
    (beginning-of-buffer)
    (re-search-forward "<input name=\"authenticity_token\" type=\"hidden\" value=\"\\(.*\\)\" />")
    (match-string 1)))

(defun gistub-construct-post-data (params)
  (gistub-string-join
   (mapcar '(lambda (x) (concat "-d " (car x) "=" (cdr x)))
           (mapcar '(lambda (x) `(,(http-url-encode (car x) 'utf-8) . ,(http-url-encode (cdr x) 'utf-8)))  params))
   " "))

(defun gistub-input-description ()
  (read-from-minibuffer "Gist description...: "))

(defun gistub-input-filename ()
  (read-from-minibuffer "Name this file...: "))

(defun gistub-demo-post ()
  (interactive)
  (let* ((description (gistub-input-description))
         (filename (gistub-input-filename))
         (token (gistub-demo-get-authenticity-token))
         (params `(("utf8" . "✓")
                   ("gist[title]" . ,description)
                   ("gist_file_names[]" . ,filename)
                   ("gist_file_bodies[]" . ,(buffer-substring-no-properties (point-min) (point-max)))
                   ("authenticity_token" . ,token))))
    (shell-command
     (concat "curl -X POST " (gistub-construct-post-data params) " " gistub-demo-post-url))))

(provide 'gistub)
