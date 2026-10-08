;; -*- lexical-binding: t; -*-
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
