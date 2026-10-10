;; Windows maximizes the outer window without resizing Emacs's text area
;; unless the frame is created pixelwise and already maximized.
;; install.ps1 appends this to ~/.emacs.d/early-init.el. Spacemacs reads
;; that file before .spacemacs, and a Spacemacs update can replace it.
(when (eq system-type 'windows-nt)
  (setq frame-resize-pixelwise t
        window-resize-pixelwise t)
  (dolist (param '((fullscreen . maximized)
                   (background-color . "#292b2e")
                   (foreground-color . "#b2b2b2")
                   (vertical-scroll-bars . nil)
                   (tool-bar-lines . 0)
                   (menu-bar-lines . 0)))
    (add-to-list 'default-frame-alist param)
    (add-to-list 'initial-frame-alist param)))
