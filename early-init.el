;;; early-init.el -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil
      frame-inhibit-implied-resize t)

(defvar jf/orig-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist jf/orig-file-name-handler-alist
                  gc-cons-threshold (* 64 1024 1024)
                  gc-cons-percentage 0.15)))

(set-face-background 'default "#000000")
;;(push '(fullscreen . maximized) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
(push '(left-fringe . 0) default-frame-alist)
(push '(right-fringe . 0) default-frame-alist)
(push '(mode-line-format . none) initial-frame-alist)
(push '(mode-line-format . none) default-frame-alist)
(setq-default mode-line-format nil)

(setq inhibit-startup-screen t
      inhibit-startup-message t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)
