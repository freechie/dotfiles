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

(spacemacs/defer-until-after-user-config
 (lambda ()
   (require 'auto-dark nil t)
   (when (featurep 'auto-dark)
     (setq auto-dark-themes '((spacemacs-dark) (spacemacs-light)))
     (auto-dark-mode 1))))
