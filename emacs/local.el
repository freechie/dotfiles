;; -*- lexical-binding: t; -*-
(setq org-agenda-files '("/Users/what/Sites/beyond/notes/STUDY.org"))
(setq org-capture-templates
      '(("p" "Post-mortem" entry
         (file+headline "/Users/what/Sites/beyond/notes/log.org" "Post-mortems")
         (file "/Users/what/Sites/beyond/notes/org-templates/post-mortem.org"))
        ("o" "Outreach" entry
         (file "/Users/what/Sites/beyond/notes/companies.org")
         (file "/Users/what/Sites/beyond/notes/org-templates/outreach.org"))))
