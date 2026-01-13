;;; init.el -*- lexical-binding: t; -*-

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file 'noerror))

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org"   . "https://orgmode.org/elpa/")
                         ("elpa"  . "https://elpa.gnu.org/packages/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default standard-indent 4)
(setq-default electric-indent-inhibit nil)

(setq use-short-answers t
      vc-follow-symlinks t
      calendar-week-start-day 1
      large-file-warning-threshold (* 200 1024 1024)
      read-process-output-max (* 1024 1024)
      ring-bell-function 'ignore
      file-name-shadow-mode 1
      confirm-kill-emacs 'y-or-no-p)

(add-hook 'server-after-make-frame-hook
          (lambda ()
            (unless (get-buffer "*vterm*")
              (vterm))
            (switch-to-buffer "*vterm*")))

(recentf-mode 1)
(setq recentf-max-menu-items 25
      recentf-max-saved-items 100
      recentf-auto-cleanup 'never)

(setq jit-lock-stealth-time 2
      jit-lock-chunk-size 8000
      jit-lock-defer-time 0.1)

(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode 1)
(add-hook 'conf-mode-hook #'display-line-number-mode 1)

(use-package gcmh
  :diminish
  :hook (emacs-startup . gcmh-mode)
  :config
  (setq gcmh-idle-delay 2.0
        gcmh-high-cons-threshold (* 128 1024 1024)
        gcmh-verbose nil))

(use-package so-long
  :config (global-so-long-mode 1))

(use-package vertico
  :init
  (vertico-mode))

(use-package marginalia
  :init
  (marginalia-mode))

(use-package consult
  :bind (("C-x b" . consult-buffer)
         ("M-y"   . consult-yank-pop)
         ("C-s"   . consult-line)   
         ("M-g g" . consult-goto-line)
         ("M-g i" . consult-imenu)
         ("M-g r" . consult-grep)))

(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install nil)
  :config
  (setq treesit-font-lock-level 4)
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package eglot
  :ensure nil
  :hook ((python-ts-mode . eglot-ensure)
         (rust-ts-mode . eglot-ensure))
  :config
  (setq eglot-events-buffer-config '(:size 0 :format full))
  (defun my/eglot-capf ()
    (setq-local completion-at-point-functions
		(list (cape-capf-super
                       #'eglot-completion-at-point
                       #'cape-dabbrev
                       #'cape-file))))
  (add-hook 'eglot-managed-mode-hook #'my/eglot-capf)
  (setq eglot-autoshutdown t)
  (add-to-list 'eglot-stay-out-of 'company)
  (defun my/eglot-lsp-booster (orig-fun &rest args)
    (let ((res (apply orig-fun args)))
      (if (and (listp res) (not (string-prefix-p "emacs-lsp-booster" (car res))))
          (cons "emacs-lsp-booster" res)
	res)))

  (with-eval-after-load 'eglot
    (advice-add 'eglot--contact :around #'jf/eglot-lsp-booster)))

(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)                 
  (corfu-auto-delay 1.0)         
  (corfu-auto-prefix 2)          
  (corfu-cycle t)
  :init
  (global-corfu-mode))

(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package which-key
  :defer 1
  :diminish which-key-mode
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 0.5))

(use-package all-the-icons
  :if (display-graphic-p))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-minor-modes nil
        doom-modeline-buffer-encoding nil
        doom-modeline-indent-info nil
        doom-modeline-vcs nil
        vc-handled-backends nil
        doom-modeline-env-version nil
        doom-modeline-github nil
        doom-modeline-buffer-file-name-style 'buffer-name
        display-time-default-load-average nil 
        display-time-format "%H:%M"           
        doom-modeline-time-icon nil
        doom-modeline-time t)
  (display-time-mode 1))

(use-package visual-fill-column
  :custom (visual-fill-column-center-text t)
  :hook ((org-mode . jf/visual-fill-org)
         (org-agenda-mode . jf/visual-fill-agenda)))

(defun jf/visual-fill-org ()
  "Center org buffers in a readable column width."
  (setq visual-fill-column-width 72)
  (visual-fill-column-mode 1))

(defun jf/visual-fill-agenda ()
  "Center agenda buffers in a wider column."
  (setq visual-fill-column-width 100)
  (visual-fill-column-mode 1))

(defun jf/apply-fonts (&optional frame)
  (set-face-attribute 'default frame :font "JetBrainsMono Nerd Font" :height 160)
  (set-face-attribute 'fixed-pitch frame :font "JetBrainsMono Nerd Font" :height 160)
  (set-face-attribute 'variable-pitch frame :font "JetBrainsMono Nerd Font" :height 160 :weight 'regular))

(add-hook 'after-make-frame-functions #'jf/apply-fonts)
(jf/apply-fonts)

(use-package org
  :ensure nil
  :hook ((org-mode . visual-line-mode)
         (org-mode . org-fold-hide-drawer-all))
  :custom-face
  (org-level-1 ((t (:height 1.8 :weight bold))))
  (org-level-2 ((t (:height 1.4 :weight bold))))
  (org-level-3 ((t (:height 1.2 :weight bold))))
  :config
  (setq org-directory "~/org/"
        org-hide-leading-stars nil
        org-agenda-files '("~/org/tasks.org" "~/org/people.org")
        org-todo-keywords '((sequence "TODO(t)" "WAIT(w!)" "|" "CANCELLED(c!)" "DONE(d!)"))
        org-ellipsis " ▾"
        org-hide-emphasis-markers t
        org-startup-truncated nil
        org-return-follows-link t
        org-agenda-window-setup 'current-window
        org-M-RET-may-split-line '((default . nil))
        org-insert-heading-respect-content t
        org-log-done 'time
        org-log-into-drawer t
        org-tags-column 0)
  
  (remove-hook 'org-mode-hook #'jf/org-hide-stars-hard)
  (remove-hook 'org-mode-hook #'jf/org-hide-stars-completely)
  (remove-hook 'org-mode-hook #'jf/org-hide-stars-physically)

  (with-eval-after-load 'ol
    (setf (cdr (assq 'file org-link-frame-setup)) #'find-file)))

(use-package org-roam
  :defer t
  :bind (("C-c r f" . org-roam-node-find)
         ("C-c r c" . org-roam-capture)
         ("C-c r i" . org-roam-node-insert)
         ("C-c r I" . jf/org-roam-node-insert-immediate)
         ("C-c r b" . org-roam-buffer-toggle)
         ("C-c r u" . org-roam-ui-open)
         ("C-c r d" . org-roam-dailies-goto-date)
         ("C-c r t" . org-roam-tag-add))
  :config
  (defun jf/org-roam-node-insert-immediate (arg &rest args)
    "Insert a node and finish capture immediately."
    (interactive "P")
    (let ((args (cons arg args))
          (org-roam-capture-templates
           (list (append (car org-roam-capture-templates)
                         '(:immediate-finish t)))))
      (apply #'org-roam-node-insert args)))

  (setq org-roam-directory (file-truename "~/org/roam/")
        org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :draft:\n")
           :unnarrowed t)))
  (add-to-list 'display-buffer-alist
               '("\\*org-roam\\*"
                 (display-buffer-in-direction)
                 (direction . right)
                 (window-width . 0.33)
                 (window-height . fit-window-to-buffer)))
  (org-roam-db-autosync-mode 1))
 
(use-package org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start nil))

(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :magic ("%PDF" . pdf-view-mode)
  :config
  (pdf-tools-install :no-query)
  (setq pdf-view-use-scaling t
        pdf-view-continuous t
        pdf-view-display-size 'fit-width
        pdf-view-resize-factor 1.1        
        pdf-cache-image-limit 128         
        pdf-cache-prefetch-delay 0.1)     
  (setq-default pdf-view-use-unicode-lighter nil)
  (add-hook 'pdf-view-mode-hook
            (lambda ()
              (pdf-cache-prefetch-minor-mode 1)
              (display-line-numbers-mode -1)
              (blink-cursor-mode -1)
              (auto-revert-mode -1)
              (cursor-sensor-mode -1))))

(use-package vterm
  :commands vterm
  :config
  (setq vterm-shell "/run/current-system/sw/bin/bash")) 

(use-package alert
  :commands (alert)
  :config
  (setq alert-default-style 'libnotify))

(use-package ewal
  :init
  (setq ewal-use-built-in-always-p t)
  (setq ewal-json-file "~/.cache/wal/colors.json")
  :config
  (ewal-load-colors))

(use-package ewal-doom-themes
  :config
  (defun jf/apply-ewal-theme (&optional frame)
    "Applies the ewal-doom-one theme to the current or new frame."
    (with-selected-frame (or frame (selected-frame))
      (load-theme 'ewal-doom-one t)))

  (jf/apply-ewal-theme)
  (add-hook 'after-make-frame-functions #'jf/apply-ewal-theme))

(set-frame-parameter nil 'alpha-background 80)
(add-to-list 'default-frame-alist '(alpha-background . 80))

(defun jf/pick-pdf ()
  "Select a PDF from common folders using completing-read, then open it."
  (interactive)
  (let* ((dirs "~/college ~/library ~/downloads")
         (cmd (format "find -L %s -type f -name '*.pdf' -not -path '*/.*'" dirs))
         (files (split-string (shell-command-to-string cmd) "\n" t))
         (choice (completing-read "Select PDF: " files nil t)))
    (when choice
      (find-file choice))))

(use-package undo-fu
  :ensure t)

(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-undo-system 'undo-fu)
  (setq evil-echo-state nil)
  :config
  (evil-mode 1)
  (define-key evil-motion-state-map (kbd "C-u") 'evil-scroll-up)
  (define-key evil-motion-state-map (kbd "j") 'evil-next-visual-line)
  (define-key evil-motion-state-map (kbd "k") 'evil-previous-visual-line))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package evil-org
  :after org
  :config
  (add-hook 'org-agenda-mode-hook 'evil-org-mode)
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(global-set-key (kbd "C-x C-r") #'consult-recent-file)
(global-set-key (kbd "C-x C-b") #'ibuffer)
(global-set-key (kbd "C-x k") #'kill-current-buffer)
(global-set-key (kbd "C-c p") #'jf/pick-pdf)
(global-set-key (kbd "C-c w") #'org-agenda-list)
(global-set-key (kbd "C-c <return>") #'vterm)
(global-set-key (kbd "C-c f s") #'org-anki-sync-entry)
(global-set-key (kbd "C-<space>") #'evil-switch-to-windows-last-buffer)
(global-set-key (kbd "C-c f a") #'org-anki-sync-all)
