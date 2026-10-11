;; -*- lexical-binding: t; -*-
;; macOS Spacemacs settings. Windows loads emacs/windows.el instead.
;; auto-dark picks its own detector here (NS / AppleScript). Do not set
;; auto-dark-detection-method to winreg.

(setq org-agenda-files
      '("/Users/what/Sites/intro-to-algorithms/study/STUDY.org"))
(setq org-capture-templates
      '(("p" "Post-mortem" entry
         (file+headline "/Users/what/Sites/intro-to-algorithms/study/log.org" "Post-mortems")
         (file "/Users/what/Sites/intro-to-algorithms/notes/org-templates/post-mortem.org"))
        ("o" "Outreach" entry
         (file "/Users/what/Sites/intro-to-algorithms/notes/companies.org")
         (file "/Users/what/Sites/intro-to-algorithms/notes/org-templates/outreach.org"))
        ("d" "6.006 day" entry
         (file+headline "/Users/what/Sites/intro-to-algorithms/study/log.org" "Progress")
         (file "/Users/what/Sites/intro-to-algorithms/study/org-templates/day.org"))))

(defun dotfiles/enable-auto-dark ()
  "Follow the macOS appearance. Must run after Spacemacs loads its theme."
  (require 'auto-dark nil t)
  (when (featurep 'auto-dark)
    (setq auto-dark-themes '((spacemacs-dark) (spacemacs-light)))
    (auto-dark-mode 1)))

;; user-init runs before `spacemacs/setup-startup-hook', which prepends its
;; own function. Appending here keeps this one after the delayed theme load.
;; `spacemacs/defer-until-after-user-config' is too early: that hook runs
;; before Spacemacs applies `spacemacs--delayed-user-theme'.
(add-hook 'emacs-startup-hook #'dotfiles/enable-auto-dark t)
