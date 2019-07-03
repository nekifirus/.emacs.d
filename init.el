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
 '(calendar-week-start-day 1)
 '(copy-as-format-default "slack" t)
 '(face-font-family-alternatives (quote (("Consolas" "Monaco" "Monospace"))))
 '(google-translate-default-source-language "en" t)
 '(google-translate-default-target-language "ru" t)
 '(no-littering-var-directory "/Users/Nekifirus/.emacs.d/data/" t)
 '(projectile-completion-system (quote ivy))
 '(send-mail-function (quote mailclient-send-it))
 '(show-paren-delay 0.0)
 '(system-packages-noconfirm t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(trailing-whitespace ((t (:background "dim gray")))))
(put 'narrow-to-region 'disabled nil)
