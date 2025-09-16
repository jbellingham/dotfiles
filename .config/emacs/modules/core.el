;;; core.el --- Core Emacs settings -*- lexical-binding: t; -*-

;;; Commentary:
;; Essential Emacs settings and behavior modifications.

;;; Code:

;; Basic settings
(setq-default
 indent-tabs-mode nil              ; Use spaces instead of tabs
 tab-width 2                       ; 2-space tabs for Ruby
 fill-column 120                   ; Longer line length for modern screens
 truncate-lines t                  ; Don't wrap lines
 sentence-end-double-space nil     ; Single space after periods
 require-final-newline t           ; Always end files with newline
 delete-trailing-lines t)          ; Remove trailing blank lines

;; Encoding
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; Backup and auto-save files
(setq backup-directory-alist `(("." . ,(expand-file-name "backups" user-emacs-directory)))
      auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-saves/" user-emacs-directory) t))
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 5
      kept-old-versions 2
      version-control t)

;; Create directories if they don't exist
(make-directory (expand-file-name "backups" user-emacs-directory) t)
(make-directory (expand-file-name "auto-saves" user-emacs-directory) t)

;; Better defaults
(setq ring-bell-function 'ignore     ; Disable bell
      inhibit-startup-screen t       ; Skip startup screen
      initial-scratch-message nil    ; Empty scratch buffer
      auto-revert-verbose nil        ; Less verbose auto-revert
      global-auto-revert-non-file-buffers t) ; Auto-revert dired and other buffers

;; Enable useful modes
(global-auto-revert-mode 1)          ; Auto-reload changed files
(delete-selection-mode 1)            ; Replace selected text when typing
(show-paren-mode 1)                  ; Highlight matching parentheses
(electric-pair-mode 1)               ; Auto-insert matching brackets
(savehist-mode 1)                    ; Save minibuffer history
(save-place-mode 1)                  ; Remember cursor position

;; Smooth scrolling
(setq scroll-conservatively 10000
      scroll-preserve-screen-position t
      auto-window-vscroll nil)

;; Yes/no prompts become y/n
(fset 'yes-or-no-p 'y-or-n-p)

;; Better uniquify for buffer names
(use-package uniquify
  :ensure nil
  :config
  (setq uniquify-buffer-name-style 'forward
        uniquify-separator "/"
        uniquify-after-kill-buffer-p t
        uniquify-ignore-buffers-re "^\\*"))

;; Recent files
(use-package recentf
  :ensure nil
  :config
  (setq recentf-max-saved-items 50
        recentf-max-menu-items 15
        recentf-auto-cleanup 'never)
  (recentf-mode 1))

;; Window management
(use-package windmove
  :ensure nil
  :config
  (windmove-default-keybindings))

;; Dired improvements
(use-package dired
  :ensure nil
  :config
  (setq dired-listing-switches "-alh"
        dired-dwim-target t
        dired-auto-revert-buffer t))

(provide 'core)
;;; core.el ends here