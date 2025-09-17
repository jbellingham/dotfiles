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

;; Fix for process sentinel errors
(defun filter-process-sentinel-errors (orig-fun &rest args)
  "Filter out 'Unprintable entity' errors from process sentinels."
  (let ((inhibit-message t))
    (condition-case err
        (apply orig-fun args)
      (error
       (unless (string-match-p "Unprintable entity\\|Wrong type argument: hash-table-p"
                              (error-message-string err))
         (signal (car err) (cdr err)))))))

(advice-add 'internal-default-process-sentinel :around #'filter-process-sentinel-errors)

;; Global error handler for "Unprintable entity" issues
(defun suppress-unprintable-entity-errors (orig-fun &rest args)
  "Suppress unprintable entity errors across all functions."
  (condition-case err
      (apply orig-fun args)
    (error
     (let ((err-msg (error-message-string err)))
       (unless (or (string-match-p "Unprintable entity" err-msg)
                   (string-match-p "Wrong type argument: hash-table-p.*Unprintable entity" err-msg))
         (signal (car err) (cdr err)))))))

;; Apply to common error-prone functions
(advice-add 'process-send-string :around #'suppress-unprintable-entity-errors)
(advice-add 'process-send-region :around #'suppress-unprintable-entity-errors)

;; Set safer process defaults
(setq process-adaptive-read-buffering nil
      read-process-output-max (* 1024 1024)) ; 1MB for all processes

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

;; Mac keyboard settings
;;(when (eq system-type 'darwin)
  ;;(setq mac-command-modifier 'meta)    ; Command key as Meta
  ;;(setq mac-option-modifier 'super))   ; Option key as Super

;; Config management functions
(defun reload-config ()
  "Reload Emacs configuration."
  (interactive)
  (load-file user-init-file)
  (message "Config reloaded!"))

(defun open-config ()
  "Open Emacs configuration file."
  (interactive)
  (find-file user-init-file))

;; Claude Code integration
(defun claude-code ()
  "Launch Claude Code in current directory."
  (interactive)
  (let ((default-directory (or (projectile-project-root) default-directory)))
    (shell-command "claude" "*Claude Code*")))

(defun claude-code-terminal ()
  "Open terminal with Claude Code."
  (interactive)
  (let ((default-directory (or (projectile-project-root) default-directory)))
    (term "/bin/zsh")
    (term-send-string (get-buffer-process (current-buffer)) "claude\n")))

;; Custom keybindings
(global-set-key (kbd "C-c w d") 'delete-window)  ; Window delete
(global-set-key (kbd "C-c c r") 'reload-config) ; C-c c r to reload config
(global-set-key (kbd "C-c c e") 'open-config)   ; C-c c e to edit config
(global-set-key (kbd "C-c c c") 'claude-code)   ; C-c c c to launch Claude Code
(global-set-key (kbd "C-c c t") 'claude-code-terminal) ; C-c c t for Claude terminal

;; Dired improvements
(use-package dired
  :ensure nil
  :config
  (setq dired-listing-switches "-alh"
        dired-dwim-target t
        dired-auto-revert-buffer t))

(provide 'core)
;;; core.el ends here
