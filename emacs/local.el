;; -*- lexical-binding: t; -*-
;; Loads the Spacemacs file for this operating system.
;; darwin.el and windows.el sit next to this file, both in the repo and
;; in ~/.spacemacs.d after install.

(let* ((dir (file-name-directory
             (or load-file-name
                 (buffer-file-name)
                 (expand-file-name "~/.spacemacs.d/local.el"))))
       (name (cond ((eq system-type 'windows-nt) "windows.el")
                   ((eq system-type 'darwin) "darwin.el")))
       (file (and name (expand-file-name name dir))))
  (when (and file (file-readable-p file))
    (load file nil t)))
