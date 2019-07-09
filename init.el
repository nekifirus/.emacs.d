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
 '(ag-highlight-search t t)
 '(calendar-week-start-day 1)
 '(copy-as-format-default "slack" t)
 '(face-font-family-alternatives (quote (("Consolas" "Monaco" "Monospace"))))
 '(google-translate-default-source-language "en")
 '(google-translate-default-target-language "ru")
 '(no-littering-var-directory "/home/nekifirus/.emacs.d/data/" t)
 '(package-selected-packages
   (quote
    (smart-comment ace-window avy-zap avy expand-region whole-line-or-region smartparens rainbow-mode rainbow-identifiers rainbow-delimiters cider clojure-snippets clojure-mode-extra-font-locking clojure-mode flycheck-mix alchemist elixir-mode company-statistics company all-the-icons-ivy all-the-icons-dired all-the-icons base16-theme google-translate google-this darkroom plantuml-mode copy-as-format yasnippet-snippets yasnippet haml-mode direnv htmlize no-littering docker-compose-mode dockerfile-mode docker ag csv-mode markdown-mode reverse-im wakatime-mode restart-emacs exec-path-from-shell toc-org org-plus-contrib gist magit-gh-pulls diff-hl gitignore-mode counsel-projectile ivy which-key diminish use-package-ensure-system-package system-packages use-package nix-mode magit)))
 '(projectile-completion-system (quote ivy))
 '(show-paren-delay 0.0)
 '(system-packages-noconfirm t)
 '(wakatime-cli-path "wakatime")
 '(wakatime-python-bin nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(trailing-whitespace ((t (:background "dim gray")))))
(put 'narrow-to-region 'disabled nil)
