(setq user-full-name "Nikita Mistyukov"
      user-mail-address "nekifirus@gmail.com")

(eval-and-compile
  (setq gc-cons-threshold 402653184
        gc-cons-percentage 0.6))

(setq byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))

(eval-and-compile
  (setq load-prefer-newer t
        package-user-dir "~/.emacs.d/elpa"
        package--init-file-ensured t
        package-enable-at-startup nil)

  (unless (file-directory-p package-user-dir)
    (make-directory package-user-dir t)))

(require 'use-package)
(setq use-package-always-defer t
      use-package-verbose t)

(eval-and-compile
  (setq load-path (append load-path (directory-files package-user-dir t "^[^.]" t))))

(eval-when-compile
  (require 'package)

  (unless (assoc-default "melpa" package-archives)
    (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t))
  (unless (assoc-default "org" package-archives)
    (add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t))

  (package-initialize)
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
  (require 'use-package)
  (setq use-package-always-ensure t))

(use-package evil
  :demand t
  :config
  (evil-mode 1))

(use-package which-key
  ;:diminish which-key-mode
  :config
  (which-key-mode))

(use-package ivy
  :demand t)

(use-package counsel-projectile)
(use-package counsel
  :demand t)

(use-package swiper
  :commands (swiper swiper-all))

(use-package magit
  :bind (("SPC-g s" . magit-status))
  :commands (magit-status magit-blame magit-log-buffer-file magit-log-all))

(use-package projectile
  :demand t)

(use-package org
  :ensure org-plus-contrib
  :pin org
  :defer t)

;; Ensure ELPA org is prioritized above built-in org.
(require 'cl)
(setq load-path (remove-if (lambda (x) (string-match-p "org$" x)) load-path))

(use-package toc-org
  :after org
  :init (add-hook 'org-mode-hook #'toc-org-enable))

(use-package custom
  :ensure nil
  :custom
  (custom-safe-themes t))

(use-package gruvbox-theme
  :config
  (load-theme 'gruvbox-dark-medium))

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  :custom
  (initial-buffer-choice '(lambda ()
                            (setq initial-buffer-choice nil)
                            (get-buffer "*dashboard*")))
  (dashboard-items '((recents  . 5)
                     (bookmarks . 5)
                     (projects . 5)
                     (agenda . 5)
                     (registers . 5))))

(use-package rainbow-delimiters
  :commands (rainbow-delimiters-mode)
  :init
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(custom-set-variables '(show-paren-delay 0.0))
(show-paren-mode t)

(defun my/buf-show-trailing-whitespace ()
  (interactive)
  (setq show-trailing-whitespace t))
(add-hook 'prog-mode-hook #'my/buf-show-trailing-whitespace)
(custom-set-faces '(trailing-whitespace ((t (:background "dim gray")))))

(setq-default indent-tabs-mode nil)

(global-auto-revert-mode t)

(use-package smartparens
  :demand t
  :config
  (setq sp-autowrap-region nil) ; let evil-surround handle this

  (require 'smartparens-config)

  ;; disable smartparens in evil-mode's replace state (they conflict)
  (add-hook 'evil-replace-state-entry-hook #'turn-off-smartparens-mode)
  (add-hook 'evil-replace-state-exit-hook  #'turn-on-smartparens-mode)

  (sp-local-pair '(xml-mode nxml-mode php-mode) "<!--" "-->"
                 :post-handlers '(("| " "SPC")))

  ;; disable global pairing for `
  (sp-pair "`" nil :actions :rem)

  (smartparens-global-mode))

(eval-and-compile
  (defvar my-leader-key "SPC"
    "The leader prefix key, for global commands.")

  (defvar my-localleader-key "SPC m"
    "The localleader prefix key, for major-mode specific commands."))

(defmacro after! (feature &rest forms)
  "A smart wrapper around `with-eval-after-load'. Supresses warnings during
compilation."
  (declare (indent defun) (debug t))
  `(,(if (or (not (bound-and-true-p byte-compile-current-file))
             (if (symbolp feature)
                 (require feature nil :no-error)
               (load feature :no-message :no-error)))
         #'progn
       #'with-no-warnings)
    (with-eval-after-load ',feature ,@forms)))

(eval-and-compile
  (defun bmacs-enlist (exp)
    "Return EXP wrapped in a list, or as-is if already a list."
    (if (listp exp) exp (list exp)))

  (defun doom-unquote (exp)
    "Return EXP unquoted."
    (while (memq (car-safe exp) '(quote function))
      (setq exp (cadr exp)))
    exp)

  (defvar bmacs-evil-state-alist
    '((?n . normal)
      (?v . visual)
      (?i . insert)
      (?e . emacs)
      (?o . operator)
      (?m . motion)
      (?r . replace))
    "A list of cons cells that map a letter to a evil state symbol.")

  ;; Register keywords for proper indentation (see `map!')
  (put ':after        'lisp-indent-function 'defun)
  (put ':desc         'lisp-indent-function 'defun)
  (put ':leader       'lisp-indent-function 'defun)
  (put ':local        'lisp-indent-function 'defun)
  (put ':localleader  'lisp-indent-function 'defun)
  (put ':map          'lisp-indent-function 'defun)
  (put ':map*         'lisp-indent-function 'defun)
  (put ':mode         'lisp-indent-function 'defun)
  (put ':prefix       'lisp-indent-function 'defun)
  (put ':textobj      'lisp-indent-function 'defun)
  (put ':unless       'lisp-indent-function 'defun)
  (put ':when         'lisp-indent-function 'defun)

;; specials
  (defvar bmacs--keymaps nil)
  (defvar bmacs--prefix  nil)
  (defvar bmacs--defer   nil)
  (defvar bmacs--local   nil)

(defun bmacs--keybind-register (key desc &optional modes)
  "Register a description for KEY with `which-key' in MODES.

  KEYS should be a string in kbd format.
  DESC should be a string describing what KEY does.
  MODES should be a list of major mode symbols."
  (if modes
      (dolist (mode modes)
        (which-key-add-major-mode-key-based-replacements mode key desc))
    (which-key-add-key-based-replacements key desc)))

(defun bmacs--keyword-to-states (keyword)
  "Convert a KEYWORD into a list of evil state symbols.

For example, :nvi will map to (list 'normal 'visual 'insert). See
`bmacs-evil-state-alist' to customize this."
  (cl-loop for l across (substring (symbol-name keyword) 1)
           if (cdr (assq l bmacs-evil-state-alist))
             collect it
           else
             do (error "not a valid state: %s" l)))

(defmacro map! (&rest rest)
  "A nightmare of a key-binding macro that will use `evil-define-key*',
`define-key', `local-set-key' and `global-set-key' depending on context and
plist key flags (and whether evil is loaded or not). It was designed to make
binding multiple keys more concise, like in vim.

If evil isn't loaded, it will ignore evil-specific bindings.

States
    :n  normal
    :v  visual
    :i  insert
    :e  emacs
    :o  operator
    :m  motion
    :r  replace

    These can be combined (order doesn't matter), e.g. :nvi will apply to
    normal, visual and insert mode. The state resets after the following
    key=>def pair.

    If states are omitted the keybind will be global.

    This can be customized with `bmacs-evil-state-alist'.

    :textobj is a special state that takes a key and two commands, one for the
    inner binding, another for the outer.

Flags
    (:mode [MODE(s)] [...])    inner keybinds are applied to major MODE(s)
    (:map [KEYMAP(s)] [...])   inner keybinds are applied to KEYMAP(S)
    (:map* [KEYMAP(s)] [...])  same as :map, but deferred
    (:prefix [PREFIX] [...])   assign prefix to all inner keybindings
    (:after [FEATURE] [...])   apply keybinds when [FEATURE] loads
    (:local [...])             make bindings buffer local; incompatible with keymaps!

Conditional keybinds
    (:when [CONDITION] [...])
    (:unless [CONDITION] [...])

Example
    (map! :map magit-mode-map
          :m \"C-r\" 'do-something           ; assign C-r in motion state
          :nv \"q\" 'magit-mode-quit-window  ; assign to 'q' in normal and visual states
          \"C-x C-r\" 'a-global-keybind

          (:when IS-MAC
           :n \"M-s\" 'some-fn
           :i \"M-o\" (lambda (interactive) (message \"Hi\"))))"
  (let ((bmacs--keymaps bmacs--keymaps)
        (bmacs--prefix  bmacs--prefix)
        (bmacs--defer   bmacs--defer)
        (bmacs--local   bmacs--local)
        key def states forms desc modes)
    (while rest
      (setq key (pop rest))
      (cond
       ;; it's a sub expr
       ((listp key)
        (push (macroexpand `(map! ,@key)) forms))

       ;; it's a flag
       ((keywordp key)
        (cond ((eq key :leader)
               (push 'bmacs-leader-key rest)
               (setq key :prefix
                     desc "<leader>"))
              ((eq key :localleader)
               (push 'bmacs-localleader-key rest)
               (setq key :prefix
                     desc "<localleader>")))
        (pcase key
          (:when    (push `(if ,(pop rest)       ,(macroexpand `(map! ,@rest))) forms) (setq rest '()))
          (:unless  (push `(if (not ,(pop rest)) ,(macroexpand `(map! ,@rest))) forms) (setq rest '()))
          (:after   (push `(after! ,(pop rest)   ,(macroexpand `(map! ,@rest))) forms) (setq rest '()))
          (:desc    (setq desc (pop rest)))
          (:map*    (setq bmacs--defer t) (push :map rest))
          (:map
            (setq bmacs--keymaps (bmacs-enlist (pop rest))))
          (:mode
            (setq modes (bmacs-enlist (pop rest)))
            (unless bmacs--keymaps
              (setq bmacs--keymaps
                    (cl-loop for m in modes
                             collect (intern (format "%s-map" (symbol-name m)))))))
          (:textobj
            (let* ((key (pop rest))
                   (inner (pop rest))
                   (outer (pop rest)))
              (push (macroexpand `(map! (:map evil-inner-text-objects-map ,key ,inner)
                                        (:map evil-outer-text-objects-map ,key ,outer)))
                    forms)))
          (:prefix
            (let ((def (pop rest)))
              (setq bmacs--prefix `(vconcat ,bmacs--prefix (kbd ,def)))
              (when desc
                (push `(bmacs--keybind-register ,(key-description (eval bmacs--prefix))
                                                ,desc ',modes)
                      forms)
                (setq desc nil))))
          (:local
           (setq bmacs--local t))
          (_ ; might be a state bmacs--prefix
           (setq states (bmacs--keyword-to-states key)))))

       ;; It's a key-def pair
       ((or (stringp key)
            (characterp key)
            (vectorp key)
            (symbolp key))
        (unwind-protect
            (catch 'skip
              (when (symbolp key)
                (setq key `(kbd ,key)))
              (when (stringp key)
                (setq key (kbd key)))
              (when bmacs--prefix
                (setq key (append bmacs--prefix (list key))))
              (unless (> (length rest) 0)
                (user-error "map! has no definition for %s key" key))
              (setq def (pop rest))
              (when desc
                (push `(bmacs--keybind-register ,(key-description (eval key))
                                              ,desc ',modes)
                      forms))
              (cond ((and bmacs--local bmacs--keymaps)
                     (push `(lwarn 'bmacs-map :warning
                                   "Can't local bind '%s' key to a keymap; skipped"
                                   ,key)
                           forms)
                     (throw 'skip 'local))
                    ((and bmacs--keymaps states)
                     (dolist (keymap bmacs--keymaps)
                       (push `(,(if bmacs--defer 'evil-define-key 'evil-define-key*)
                               ',states ,keymap ,key ,def)
                             forms)))
                    (states
                     (dolist (state states)
                       (push `(define-key
                                ,(intern (format "evil-%s-state-%smap" state (if bmacs--local "local-" "")))
                                ,key ,def)
                             forms)))
                    (bmacs--keymaps
                     (dolist (keymap bmacs--keymaps)
                       (push `(define-key ,keymap ,key ,def) forms)))
                    (t
                     (push `(,(if bmacs--local 'local-set-key 'global-set-key) ,key ,def)
                           forms))))
          (setq states '()
                bmacs--local nil
                desc nil)))

       (t (user-error "Invalid key %s" key))))
    `(progn ,@(nreverse forms)))))

(eval-and-compile
  (defun bmacs--resolve-hook-forms (hooks)
    (cl-loop with quoted-p = (eq (car-safe hooks) 'quote)
             for hook in (bmacs-enlist (doom-unquote hooks))
             if (eq (car-safe hook) 'quote)
              collect (cadr hook)
             else if quoted-p
              collect hook
             else collect (intern (format "%s-hook" (symbol-name hook)))))

  (defvar bmacs--transient-counter 0)
  (defmacro add-transient-hook! (hook &rest forms)
    "Attaches transient forms to a HOOK.

  HOOK can be a quoted hook or a sharp-quoted function (which will be advised).

  These forms will be evaluated once when that function/hook is first invoked,
  then it detaches itself."
    (declare (indent 1))
    (let ((append (eq (car forms) :after))
          (fn (intern (format "bmacs-transient-hook-%s" (cl-incf bmacs--transient-counter)))))
      `(when ,hook
         (fset ',fn
               (lambda (&rest _)
                 ,@forms
                 (cond ((functionp ,hook) (advice-remove ,hook #',fn))
                       ((symbolp ,hook)   (remove-hook ,hook #',fn)))
                 (unintern ',fn nil)))
         (cond ((functionp ,hook)
                (advice-add ,hook ,(if append :after :before) #',fn))
               ((symbolp ,hook)
                (add-hook ,hook #',fn ,append)))))))

(defmacro add-hook! (&rest args)
  "A convenience macro for `add-hook'. Takes, in order:

  1. Optional properties :local and/or :append, which will make the hook
     buffer-local or append to the list of hooks (respectively),
  2. The hooks: either an unquoted major mode, an unquoted list of major-modes,
     a quoted hook variable or a quoted list of hook variables. If unquoted, the
     hooks will be resolved by appending -hook to each symbol.
  3. A function, list of functions, or body forms to be wrapped in a lambda.

Examples:
    (add-hook! 'some-mode-hook 'enable-something)
    (add-hook! some-mode '(enable-something and-another))
    (add-hook! '(one-mode-hook second-mode-hook) 'enable-something)
    (add-hook! (one-mode second-mode) 'enable-something)
    (add-hook! :append (one-mode second-mode) 'enable-something)
    (add-hook! :local (one-mode second-mode) 'enable-something)
    (add-hook! (one-mode second-mode) (setq v 5) (setq a 2))
    (add-hook! :append :local (one-mode second-mode) (setq v 5) (setq a 2))

Body forms can access the hook's arguments through the let-bound variable
`args'."
  (declare (indent defun) (debug t))
  (let ((hook-fn 'add-hook)
        append-p local-p)
    (while (keywordp (car args))
      (pcase (pop args)
        (:append (setq append-p t))
        (:local  (setq local-p t))
        (:remove (setq hook-fn 'remove-hook))))
    (let ((hooks (bmacs--resolve-hook-forms (pop args)))
          (funcs
           (let ((val (car args)))
             (if (memq (car-safe val) '(quote function))
                 (if (cdr-safe (cadr val))
                     (cadr val)
                   (list (cadr val)))
               (list args))))
          forms)
      (dolist (fn funcs)
        (setq fn (if (symbolp fn)
                     `(function ,fn)
                   `(lambda (&rest _) ,@args)))
        (dolist (hook hooks)
          (push (cond ((eq hook-fn 'remove-hook)
                       `(remove-hook ',hook ,fn ,local-p))
                      (t
                       `(add-hook ',hook ,fn ,append-p ,local-p)))
                forms)))
      `(progn ,@(nreverse forms)))))

(defmacro remove-hook! (&rest args)
  "Convenience macro for `remove-hook'. Takes the same arguments as
`add-hook!'."
  `(add-hook! :remove ,@args))

(defmacro quiet! (&rest forms)
  "Run FORMS without making any noise."
  `(if nil
       (progn ,@forms)
 (fset 'doom--old-write-region-fn (symbol-function 'write-region))
      (cl-letf ((standard-output (lambda (&rest _)))
                ((symbol-function 'load-file) (lambda (file) (load file nil t)))
                ((symbol-function 'message) (lambda (&rest _)))
                ((symbol-function 'write-region)
                 (lambda (start end filename &optional append visit lockname mustbenew)
                   (unless visit (setq visit 'no-message))
                   (doom--old-write-region-fn
                    start end filename append visit lockname mustbenew)))
                (inhibit-message t)
                (save-silently t))
        ,@forms)))

(defvar doom-memoized-table (make-hash-table :test 'equal :size 10)
  "A lookup table containing memoized functions. The keys are argument lists,
and the value is the function's return value.")

(defun doom-memoize (name)
  "Memoizes an existing function. NAME is a symbol."
  (let ((func (symbol-function name)))
    (put name 'function-documentation
         (concat (documentation func) " (memoized)"))
    (fset name
          `(lambda (&rest args)
             (let ((key (cons ',name args)))
               (or (gethash key doom-memoized-table)
                   (puthash key (apply ',func args)
                            doom-memoized-table)))))))

(defmacro def-memoized! (name arglist &rest body)
  "Create a memoize'd function. NAME, ARGLIST, DOCSTRING and BODY
have the same meaning as in `defun'."
  (declare (indent defun) (doc-string 3))
  `(,(if (bound-and-true-p byte-compile-current-file)
         'with-no-warnings
       'progn)
     (defun ,name ,arglist ,@body)
     (doom-memoize ',name)))

(defmacro λ! (&rest body)
  "A shortcut for inline interactive lambdas."
  (declare (doc-string 1))
  `(lambda () (interactive) ,@body))

(defvar doom-menu-display-fn #'doom-menu-read-default
  "The method to use to prompt the user with the menu. This takes two arguments:
PROMPT (a string) and COMMAND (a list of command plists; see `def-menu!').")

(defvar-local doom-menu-last-command nil
  "TODO")

(defun doom-menu-read-default (prompt commands)
  "Default method for displaying a completion-select prompt."
  (completing-read prompt (mapcar #'car commands) nil nil nil nil (car doom-menu-last-command)))

(defun doom--menu-read (prompt commands)
  (if-let* ((choice (funcall doom-menu-display-fn prompt commands)))
      (assoc choice commands)
    (user-error "Aborted")))

(defun doom--menu-exec (plist)
  (save-selected-window
    (let ((command (plist-get plist :exec))
          (cwd     (plist-get plist :cwd)))
      (let ((default-directory
              (cond ((eq cwd t) (bmacs-project-root))
                    ((stringp cwd) cwd)
                    ((functionp cwd) (funcall cwd))
                    (t default-directory))))
        (cond ((stringp command)
               (let (buf)
                 (compile command)
                 (setq buf next-error-last-buffer)
                 (unless buf
                   (error "Couldn't create compilation buffer"))
                 (with-current-buffer buf
                   (setq header-line-format
                         (concat (propertize "$ " 'face 'font-lock-doc-face)
                                 (propertize command 'face 'font-lock-preprocessor-face))))))
              ((or (symbolp command)
                   (functionp command))
               (call-interactively command))
              ((and command (listp command))
               (eval command t))
              (t
               (error "Not a valid command: %s" command)))))))

(defmacro def-menu! (name desc commands &rest plist)
  "Defines a menu and returns a function symbol for invoking it.

A dispatcher is an interactive command named NAME (a symbol). When called, this
dispatcher prompts you to select a command to run. This list is filtered
depending on its properties. Each command is takes the form of:

  (DESCRIPTION :exec COMMAND &rest PROPERTIES)

PROPERTIES accepts the following properties:

  :when FORM
  :unless FORM
  :region BOOL
  :cwd BOOL|PATH|FUNCTION
  :project BOOL|PATH|FUNCTION

COMMAND can be a string (a shell command), a symbol (an elisp function) or a
lisp form.

`def-menu!'s PLIST supports the following properties:

  :prompt STRING"
  (declare (indent defun) (doc-string 2))
  (let ((commands-var (intern (format "%s-commands" name)))
        (prop-prompt (or (plist-get plist :prompt) "> "))
        (prop-sort   (plist-get plist :sort)))
    `(progn
       (defconst ,commands-var
         ,(if prop-sort
              `(cl-sort ,commands #'string-lessp :key #'car)
            commands)
         ,(format "Menu for %s" name))
       (defun ,name (arg command)
         ,(concat
           (if (stringp desc) (concat desc "\n\n"))
           "This is a command dispatcher. It will rerun the last command on\n"
           "consecutive executions. If ARG (universal argument) is non-nil\n"
           "then it always prompt you.")
         (declare (interactive-only t))
         (interactive
          (list current-prefix-arg
                (progn
                  (unless ,commands-var
                    (user-error "The '%s' menu is empty" ',name))
                  (doom--menu-read
                   ,prop-prompt
                   (or (cl-remove-if-not
                        (let ((project-root (bmacs-project-root)))
                          (lambda (cmd)
                            (let ((plist (cdr cmd)))
                              (and (cond ((not (plist-member plist :region)) t)
                                         ((plist-get plist :region) (use-region-p))
                                         (t (not (use-region-p))))
                                   (let ((when (plist-get plist :when))
                                         (unless (plist-get plist :unless))
                                         (project (plist-get plist :project)))
                                     (when (functionp project)
                                       (setq project (funcall project)))
                                     (or (or (not when) (eval when))
                                         (or (not unless) (not (eval unless)))
                                         (and (stringp project)
                                              (file-in-directory-p (or buffer-file-name default-directory)
                                                                   project-root))))))))
                        ,commands-var)
                       (user-error "No commands available here"))))))
         (doom--menu-exec
          (cdr (or (when arg doom-menu-last-command)
                   (setq doom-menu-last-command command)
                   (user-error "No command selected"))))))))

(setq gc-cons-threshold 16777216
      gc-cons-percentage 0.1)
