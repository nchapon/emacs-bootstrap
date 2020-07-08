;; To create a file, visit it with <open> and enter text in its buffer.


(defconst is-mac (equal system-type 'darwin))
(defconst is-linux (equal system-type 'gnu/linux))
(defconst is-windows (equal system-type 'windows-nt))

(defconst has-gui (display-graphic-p))



(package-initialize)
(add-to-list 'package-archives
         '("melpa" . "https://melpa.org/packages/")
             '("elpy" . "http://jorgenschaefer.github.io/packages/"))

(when (not package-archive-contents)
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

(defconst private-dir  (expand-file-name "private" user-emacs-directory))
(defconst temp-dir (format "%s/cache" private-dir)
  "Hostname-based elisp temp directories")

;; Core settings
;; UTF-8 please
(set-charset-priority 'unicode)
(setq locale-coding-system   'utf-8)   ; pretty
(set-terminal-coding-system  'utf-8)   ; pretty
(set-keyboard-coding-system  'utf-8)   ; pretty
(set-selection-coding-system 'utf-8)   ; please
(prefer-coding-system        'utf-8)   ; with sugar on top
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))

;; Emacs customizations
(setq confirm-kill-emacs                  'y-or-n-p
      confirm-nonexistent-file-or-buffer  t
      save-interprogram-paste-before-kill t
      mouse-yank-at-point                 t
      require-final-newline               t
      visible-bell                        nil
      ring-bell-function                  'ignore
      custom-file                         "~/.emacs.d/.custom.el"
      ;; http://ergoemacs.org/emacs/emacs_stop_cursor_enter_prompt.html
      minibuffer-prompt-properties
      '(read-only t point-entered minibuffer-avoid-prompt face minibuffer-prompt)

      ;; Disable non selected window highlight
      cursor-in-non-selected-windows     nil
      highlight-nonselected-windows      nil
      ;; PATH
      exec-path                          (append exec-path '("/usr/local/bin/"))
      indent-tabs-mode                   nil
      inhibit-startup-message            t
      fringes-outside-margins            t
      x-select-enable-clipboard          t
      use-package-always-ensure          t)

;; Bookmarks
(setq
 ;; persistent bookmarks
 bookmark-save-flag                      t
 bookmark-default-file              (concat temp-dir "/bookmarks"))

;; Backups enabled, use nil to disable
(setq
 history-length                     1000
 backup-inhibited                   nil
 make-backup-files                  t
 auto-save-default                  t
 auto-save-list-file-name           (concat temp-dir "/autosave")
 create-lockfiles                   nil
 backup-directory-alist            `((".*" . ,(concat temp-dir "/backup/")))
 auto-save-file-name-transforms    `((".*" ,(concat temp-dir "/auto-save-list/") t)))

(unless (file-exists-p (concat temp-dir "/auto-save-list"))
               (make-directory (concat temp-dir "/auto-save-list") :parents))

(fset 'yes-or-no-p 'y-or-n-p)
(global-auto-revert-mode t)

;; Disable toolbar & menubar
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (  fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

(show-paren-mode 1)

;; Need to load custom file to avoid being overwritten
;; more at https://www.gnu.org/software/emacs/manual/html_node/emacs/Saving-Customizations.html
(load custom-file)

;; Delete trailing whitespace before save

(use-package ace-jump-mode
  :bind
  ("C-c SPC" . ace-jump-mode))


(use-package company
  :defer t
  :diminish ""
  :bind (("M-/" . company-complete)
         ("C-c C-y" . company-yasnippet)
         :map company-active-map
         ("C-p" . company-select-previous)
         ("C-n" . company-select-next)
         ("TAB" . company-complete-common-or-cycle)
         ("<tab>" . company-complete-common-or-cycle)
         ("C-d" . company-show-doc-buffer))
  :init (global-company-mode)
  :config
  (progn
    (setq company-idle-delay 0.1
          ;; min prefix of 1 chars
          company-minimum-prefix-length 2
          company-selection-wrap-around t
          company-show-numbers t
          company-dabbrev-downcase nil
          company-dabbrev-code-everywhere t
          company-transformers '(company-sort-by-occurrence))))


(use-package ediff
  :config
  (setq ediff-window-setup-function 'ediff-setup-windows-plain)
  (setq-default ediff-highlight-all-diffs 'nil)
  (setq ediff-diff-options "-w"))

(use-package exec-path-from-shell
  :config
  ;; Add GOPATH to shell
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-copy-env "GOPATH")
    (exec-path-from-shell-copy-env "PYTHONPATH")
    (exec-path-from-shell-initialize)))

(use-package expand-region
  :bind
  ("C-=" . er/expand-region))

(use-package flycheck)



(use-package helm
  :init
  (require 'helm-config)
  :config
  (setq helm-split-window-in-side-p t
        helm-split-window-default-side 'below
    helm-idle-delay 0.0
    helm-input-idle-delay 0.01
    helm-quick-update t
    helm-ff-skip-boring-files t)
  (helm-mode 1)
  :bind (("C-x b" . helm-mini)
     ("M-x" . helm-M-x)
         ("C-x C-m" . helm-M-x)
         ("C-x C-f" . helm-find-files)
     ("C-x C-r" . helm-recentf)
         ("C-x v" . helm-projectile)
         ("C-x c o" . helm-occur)
         ("C-x c p" . helm-projectile-ag)
         ("M-y" . helm-show-kill-ring)
         :map helm-map
         ("<tab>" . helm-execute-persistent-action)))

(use-package helm-ag)

(use-package helm-git-grep)

(use-package helm-projectile)

(use-package helm-swoop
  :bind
  ("C-x c s" . helm-swoop))


(use-package key-chord
     :init
     (key-chord-mode 1)
     (key-chord-define-global "jj" 'ace-jump-word-mode)
     (key-chord-define-global "jl" 'ace-jump-line-mode)
     (key-chord-define-global "jk" 'ace-jump-char-mode)
     (key-chord-define-global "FF" 'projectile-find-file)
     (key-chord-define-global "GG" 'helm-projectile-ag)
     ;;(key-chord-define-global "HH" 'nc/helm-org-rifle-agenda-files)
     (key-chord-define-global "DD" 'delete-region)
     (key-chord-define-global "OO" 'helm-occur)
     ;;(key-chord-define-global "??" 'nc/helm-do-grep-notes)
     (key-chord-define-global "BB" 'beginning-of-buffer)
     ;;(key-chord-define-global "WW" 'nc/swap-windows)
     (key-chord-define-global "$$" 'end-of-buffer)
     (key-chord-define-global "kk" 'kill-this-buffer))

(use-package magit
  :config

  (setq magit-completing-read-function 'ivy-completing-read)

  :bind
  ;; Magic
  ("C-x g s" . magit-status)
  ("C-x g x" . magit-checkout)
  ("C-x g c" . magit-commit)
  ("C-x g p" . magit-push)
  ("C-x g u" . magit-pull)
  ("C-x g e" . magit-ediff-resolve)
  ("C-x g r" . magit-rebase-interactive))

(use-package magit-popup)

(use-package multiple-cursors
  :bind
  ("C-S-c C-S-c" . mc/edit-lines)
  ("C->" . mc/mark-next-like-this)
  ("C-<" . mc/mark-previous-like-this)
  ("C-c C->" . mc/mark-all-like-this))

(use-package no-littering)

(use-package projectile
  :config
  (setq projectile-known-projects-file
        (expand-file-name "projectile-bookmarks.eld" temp-dir))

  (projectile-global-mode))


(use-package recentf
  :config
  (setq recentf-auto-cleanup 'never
        recentf-max-saved-items 1000
        recentf-save-file (recentf-expand-file-name "~/.emacs.d/private/cache/recentf"))
  (recentf-mode t)
  :diminish nil)



(use-package smartparens)

(use-package smex)

(use-package undo-tree
  :config
  ;; Remember undo history
  (setq
   undo-tree-auto-save-history nil
   undo-tree-history-directory-alist `(("." . ,(concat temp-dir "/undo/"))))
  (global-undo-tree-mode 1))

(use-package which-key
  :config
  (which-key-mode))

(use-package windmove
  :bind
  ("C-x <up>" . windmove-up)
  ("C-x <down>" . windmove-down)
  ("C-x <left>" . windmove-left)
  ("C-x <right>" . windmove-right))

(use-package wgrep)

(use-package yasnippet
  :config
  (yas-global-mode 1))



;;; MacOS
(when is-mac
     (setq mac-command-modifier 'meta)    ; make cmd key do Meta
     (setq mac-option-modifier 'super)    ; make opt key do Super
     (setq mac-control-modifier 'control) ; make Control key do Control
     (setq ns-function-modifier 'hyper)   ; make Fn key do Hyper
   )

(when is-mac
     (setq-default mac-right-option-modifier nil))

(when is-mac
     (set-locale-environment "fr_FR.UTF-8"))

;; gls

(if (executable-find "gls")
       (progn
         (setq insert-directory-program "gls")
         (setq dired-listing-switches "-lFaGh1v --group-directories-first"))
     (setq dired-listing-switches "-ahlF"))


;;; Theme

(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-one t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)

  ;; Enable custom neotree theme (all-the-icons must be installed!)
  ;;(doom-themes-neotree-config)
  ;; or for treemacs users
  ;;(setq doom-themes-treemacs-theme "doom-colors") ; use the colorful treemacs theme
  ;;(doom-themes-treemacs-config)

  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))



;;; Font

(defun nc/setup-font ()
    "Set up font height"
    (interactive)
    (when is-linux
      (set-frame-font "Input Mono-12" nil t))
    (when is-mac
      (set-frame-font "Monaco 15" nil t))
    (when is-windows
      (set-frame-font "Lucida Console-12" nil t)))

  (when has-gui
    (add-hook 'after-init-hook #'nc/setup-font))
