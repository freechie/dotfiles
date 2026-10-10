;; -*- lexical-binding: t; -*-
;; Windows Spacemacs settings. macOS loads emacs/darwin.el instead.
;; Loaded from user-init, before Spacemacs applies the default font and
;; before package-user-dir points at the develop elpa directory.

(setq dotspacemacs-default-font '("Source Code Pro"
                                  :size 13.0
                                  :weight normal
                                  :width normal)
      dotspacemacs-enable-load-hints t
      dotspacemacs-enable-package-quickstart t
      dotspacemacs-loading-progress-bar nil
      frame-resize-pixelwise t
      window-resize-pixelwise t)

;; package-quickstart does not fill package-alist. Loading descriptors
;; before package-user-dir is set misses org and transient, so Spacemacs
;; installs and byte-compiles them on every startup.
(add-hook 'configuration-layer-pre-load-hook
          (lambda ()
            (when (and package-user-dir
                       (file-directory-p package-user-dir)
                       (not (assq 'org package-alist)))
              (require 'package)
              (package-load-all-descriptors))))

(defun dotfiles/windows-refit-frame ()
  "Re-apply maximized after the startup font change."
  (when (display-graphic-p)
    (set-frame-parameter nil 'fullscreen nil)
    (set-frame-parameter nil 'fullscreen 'maximized)))

(defun dotfiles/enable-auto-dark ()
  "Follow the Windows app theme. winreg is not available on macOS."
  (require 'auto-dark)
  (setq auto-dark-themes '((spacemacs-dark) (spacemacs-light))
        auto-dark-detection-method 'winreg
        auto-dark-polling-interval-seconds 5)
  (auto-dark-mode 1))

(defun dotfiles/windows-after-startup ()
  "Refit the frame and follow the Windows app theme.
This runs after Spacemacs loads `spacemacs-dark`. A timer started from
user-init fires before that load and the day/night theme does not stick."
  (dotfiles/windows-refit-frame)
  (dotfiles/enable-auto-dark))

;; user-init runs before `spacemacs/setup-startup-hook', which prepends its
;; own function. Appending here keeps this one after the delayed theme load.
(add-hook 'emacs-startup-hook #'dotfiles/windows-after-startup t)
