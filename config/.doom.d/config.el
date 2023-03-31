;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "André Stylianos Ramos"
      user-mail-address "andre.stylianos@protonmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!
(setq doom-font (font-spec :family "Iosevka" :size 15 :weight 'bold))


;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(add-to-list 'default-frame-alist '(fullscreen . maximized))

(setq evil-kill-on-visual-paste nil)

(setq
 mode-line-default-help-echo nil
 show-help-function nil
 projectile-enable-caching nil
 doom-localleader-key ","
 tab-always-indent t)

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;
;;

(setq  cider-refresh-before-fn "integrant.repl/suspend")
(setq  cider-refresh-after-fn "integrant.repl/resume")

(defun my-kill-cider-repls ()
  (interactive)
  (kill-matching-buffers my-cider-repl-name-rx nil t))

(setq my-cider-repl-name-rx (rx (seq bol "*cider-repl " (1+ not-newline) "*")))

(defun my-cider-start-system ()
  (interactive)
  (my-kill-cider-repls)
  (cider-connect-clj)
  (cider-insert-in-repl "(start-system)" t)
  (cider-connect-sibling-clj '())
  (cider-repl-switch-to-other)
  (cider-insert-in-repl "(start-client)" t))

(defun my-cider-reset ()
  (interactive)
  (projectile-save-project-buffers)
  (cider-interactive-eval "(do (in-ns 'user) (restart-system))"))

(defun my-cider-reset-all ()
  (interactive)
  (projectile-save-project-buffers)
  (cider-interactive-eval "(do (in-ns 'user) (restart-all-system))"))


;; def portal to the dev namespace to allow dereferencing via @dev/portal
(defun portal.api/open ()
  (interactive)
  (cider-nrepl-sync-request:eval
    "(do (ns dev)
       ((requiring-resolve 'portal.api/close))
       (def portal ((requiring-resolve 'portal.api/open))) (add-tap (requiring-resolve 'portal.api/submit)))"))

(defun portal.api/clear ()
  (interactive)
  (cider-nrepl-sync-request:eval "(portal.api/clear)"))

(defun portal.api/close ()
  (interactive)
  (cider-nrepl-sync-request:eval "(portal.api/close)"))

(use-package! cider
  :after clojure-mode
  :config
  (setq ;cider-show-error-buffer t ;'only-in-repl
        cider-prompt-for-symbol nil
        clojure-toplevel-inside-comment-form t
        cider-save-file-on-load t
        cider-print-fn 'puget
        cider-repl-buffer-size-limit 100000)

  (set-popup-rule! "*cider-test-report*" :side 'right :width 0.4 :slot 3 :quit 'current)
  (set-popup-rule! "*cider-error*" :side 'right :width 0.4 :slot 2 :quit t)
  (set-popup-rule! "*cider-result*" :side 'right :width 0.4 :slot 1 :quit t)
  (set-popup-rule! "^\\*cider-repl" :side 'right :width 0.4 :slot 0 :quit nil :ttl nil))

(map! :after cider-mode
      :map cider-mode-map
      :localleader
      (:prefix ("r" . "repl")
               "r" #'my-cider-reset
               "R" #'my-cider-reset-all
               "s" #'my-cider-start-system)

      (:prefix ("p" . "print")
               "o" #'portal.api/open
               "c" #'portal.api/clear))



;; PACKAGE CONFIGURATIONS
(use-package! evil-cleverparens
  :hook (clojure-mode . evil-cleverparens-mode)
  :hook (clojurescript-mode . evil-cleverparens-mode)
  :hook (clojurec-mode . evil-cleverparens-mode)
  :hook (emacs-lisp-mode . evil-cleverparens-mode)
  ;; Always enable smartparens-strict-mode
  :hook (evil-cleverparens-mode . smartparens-strict-mode))

(use-package! aggressive-indent
  :hook (clojure-mode . aggressive-indent-mode))

(use-package! lsp-nix
  :ensure lsp-mode
  :after (lsp-mode)
  :demand t
  :custom (lsp-nix-nil-formatter ["alejandra"]))

(use-package! nix-mode
  :ensure t
  :hook (nix-mode . lsp-deferred))

(add-hook 'clojure-mode-hook (lambda () (define-clojure-indent
  ;; Fulcro
  (>defn :defn)
  (defmutation [1 :form :form [1]])
  ;; (pc/defmutation [2 :form :form [1]])

  ;; Fulcro-spec
  (specification [1])
  (component [1])
  (behavior [1])
  (when-mocking '(0))
  (assertions [0])

  (thrown-with-data? [1])
  (not-thrown-with-data? [1])

  ;; Datomic
  (not-join 1)

  ;; JRA
  (system/let [1])
  (clet [1])
  (sp/collected? 1)
  (sp/cond-path :defn)
  (sp/if-path :defn)
  (sp/recursive-path :defn)
  (load-marker-utils/capture-load-marker-states 1)

  (swap!-> [1])

  (comment :defn)

  (m/search 1)

  ;; compojure
  (context 2)
  (POST 2)
  (GET 2)
  (PUT 2))))

(after! smartparens

  (smartparens-global-strict-mode)

  ;; https://github.com/Fuco1/smartparens/blob/master/smartparens.el#L300
  (sp-use-smartparens-bindings)

  ;; undo the damage done by
  ;; https://github.com/hlissner/doom-emacs/blob/develop/modules/config/default/config.el#L97
  ;; to double-quote autopairing - so we always get matching quotes
  (let ((unless-list '()))
    (sp-pair "\"" nil :unless unless-list))

  ;; undo the damage done by
  ;; https://github.com/hlissner/doom-emacs/blob/develop/modules/config/default/config.el#L107
  ;; so we get matching parens when point is before a word again
  (dolist (brace '("(" "{" "["))
    (sp-pair brace nil
             :post-handlers '(("||\n[i]" "RET") ("| " "SPC"))
             :unless '())))
