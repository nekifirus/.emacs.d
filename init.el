;;; Package --- Summary

;;; Commentary:
;; Emacs init file responsible for either loading a pre-compiled configuration file
;; or tangling and loading a literate org configuration file.

;;; Code:

;; Don't attempt to find/apply special file handlers to files loaded during startup.
(let ((file-name-handler-alist nil))
  ;; If config is pre-compiled, then load that
  (if (file-exists-p (expand-file-name "README.elc" user-emacs-directory))
      (load-file (expand-file-name "README.elc" user-emacs-directory))
    ;; Otherwise use org-babel to tangle and load the configuration
    (require 'org)
    (org-babel-load-file (expand-file-name "README.org" user-emacs-directory))))

;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ag-highlight-search t)
 '(all-the-icons-ivy-buffer-commands nil)
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(aw-keys '(97 115 100 102 103 104 106 107 108))
 '(aw-scope 'frame)
 '(calendar-week-start-day 1)
 '(display-time-24hr-format t)
 '(display-time-default-load-average nil)
 '(face-font-family-alternatives
   '(("Monaco" "Iosevka Light" "Source Code Pro Light" "Ubuntu" "Monaco" "Consolas" "Monospace")))
 '(message-kill-buffer-on-exit t)
 '(mu4e-enable-mode-line t t)
 '(mu4e-enable-notifications t t)
 '(mu4e-get-mail-command "mbsync -a")
 '(mu4e-maildir "~/Maildir" t)
 '(mu4e-maildir-shortcuts t)
 '(mu4e-org-link-query-in-headers-mode nil t)
 '(mu4e-update-interval 300)
 '(mu4e-use-fancy-chars t)
 '(mu4e-view-prefer-html t)
 '(mu4e-view-show-addresses t)
 '(mu4e-view-show-images t)
 '(no-littering-var-directory "/home/nekifirus/.emacs.d/data/" t)
 '(notmuch-saved-searches
   '((:name "inbox" :query "tag:inbox" :key "i")
     (:name "unread" :query "tag:unread" :key "u")
     (:name "flagged" :query "tag:flagged" :key "f")
     (:name "sent" :query "tag:sent" :key "t")
     (:name "drafts" :query "tag:draft" :key "d")
     (:name "all mail" :query "*" :key "a")
     (:name "Unread" :query "tag:unread")
     (:name ":unread" :query "tag:unread")))
 '(org-agenda-files
   '("/home/nekifirus/org/gtd/emacs.org" "/home/nekifirus/org/gtd/cb.org" "/home/nekifirus/org/gtd/english.org" "/home/nekifirus/org/gtd/gtd.org" "/home/nekifirus/org/gtd/nix.org" "/home/nekifirus/org/gtd/obzvon.org" "/home/nekifirus/org/gtd/refile.org" "/home/nekifirus/org/gtd/someday.org" "/home/nekifirus/org/gtd/workflow.org"))
 '(package-selected-packages
   '(try yasnippet-snippets xresources-theme whole-line-or-region which-key wakatime-mode vue-mode use-package-ensure-system-package toc-org smartparens smart-comment reverse-im restart-emacs rainbow-mode rainbow-identifiers rainbow-delimiters python-mode py-isort py-autopep8 plantuml-mode org-plus-contrib org-bullets no-littering nix-mode multiple-cursors modus-vivendi-theme magit-popup magit lua-mode ibuffer-vc ibuffer-projectile htmlize haskell-mode haml-mode google-translate google-this gitignore-mode gist frames-only-mode flycheck exwm expand-region exec-path-from-shell eredis elpy dockerfile-mode docker-compose-mode docker direnv dired-du diminish diff-hl darkroom csv-mode counsel-tramp counsel-projectile copy-as-format company-statistics company-lsp clojure-snippets clojure-mode-extra-font-locking cider base16-theme avy-zap all-the-icons-ivy all-the-icons-dired alchemist ag ace-window))
 '(projectile-completion-system 'ivy)
 '(send-mail-function 'smtpmail-send-it)
 '(show-paren-delay 0.0)
 '(system-packages-noconfirm t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(trailing-whitespace ((t (:background "dim gray")))))
(put 'narrow-to-region 'disabled nil)
