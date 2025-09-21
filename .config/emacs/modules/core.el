;; Garbage Collection Tuning

;; We start by optimizing Emacs' garbage collection and file handling for faster startup, especially important on Apple Silicon Macs with abundant memory.


;;; core.el --- Core Emacs settings -*- lexical-binding: t; -*-

;;; Commentary:
;; Essential Emacs settings and behavior modifications.

;;; Code:

;; Performance optimizations for startup (Apple Silicon optimized)
;; ===============================================================

(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)
(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.6)

;; Apple Silicon Optimizations

;; Apple Silicon Macs have different memory and processing characteristics that we can optimize for:


;; Apple Silicon specific performance settings
(setq read-process-output-max (* 2 1024 1024)) ; 2MB for faster LSP
(setq process-adaptive-read-buffering nil)

;; Post-initialization Cleanup

;; After startup, we restore reasonable garbage collection settings optimized for Apple Silicon's ample memory:


;; Restore after startup
(defun restore-post-init-settings ()
  "Restore settings after initialization."
  (setq file-name-handler-alist file-name-handler-alist-original)
  ;; Higher GC threshold for Apple Silicon's ample memory
  (setq gc-cons-threshold (* 20 1000 1000))
  (setq gc-cons-percentage 0.1))

(add-hook 'emacs-startup-hook #'restore-post-init-settings)



;; Let me create a proper init.el that tangles from the org file:


;; Package management setup
;; ========================

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(package-initialize)

;; Use-package Bootstrap

;; Use-package provides a clean, declarative way to configure packages:


;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t
      use-package-expand-minimally t
      use-package-compute-statistics t
      use-package-verbose t)

;; Basic Editing Behavior

;; These settings establish sane defaults for modern development:


;; Basic settings
(setq-default
 indent-tabs-mode nil              ; Use spaces instead of tabs
 tab-width 2                       ; 2-space tabs for Ruby
 fill-column 120                   ; Longer line length for modern screens
 truncate-lines t                  ; Don't wrap lines
 sentence-end-double-space nil     ; Single space after periods
 require-final-newline t           ; Always end files with newline
 delete-trailing-lines t)          ; Remove trailing blank lines

;; Encoding Configuration

;; Ensure consistent UTF-8 encoding across all operations:


;; Encoding
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; File Management & Backups

;; Configure backup and auto-save files to avoid cluttering project directories:


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

;; Better Defaults

;; Improve Emacs' default behavior for modern development:


;; Better defaults
(setq ring-bell-function 'ignore     ; Disable bell
      inhibit-startup-screen t       ; Skip startup screen
      initial-scratch-message nil    ; Empty scratch buffer
      auto-revert-verbose nil        ; Less verbose auto-revert
      global-auto-revert-non-file-buffers t) ; Auto-revert dired and other buffers

;; Error Handling & Process Fixes

;; Handle common process errors that can occur with LSP and other external processes:


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

;; PATH Configuration

;; Ensure Emacs can find tools installed via Homebrew and other package managers:


;; Ensure proper PATH setup for shell commands (fixes mcfly/jump errors)
(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize))
  ;; Copy additional environment variables from shell
  (when (daemonp)
    (exec-path-from-shell-copy-envs '("SHELL" "PATH"))))

;; Fallback: Ensure Homebrew paths are available to Emacs (for mcfly, jump, etc.)
(when (eq system-type 'darwin)
  (let ((homebrew-bin "/opt/homebrew/bin")
        (homebrew-sbin "/opt/homebrew/sbin"))
    (when (file-directory-p homebrew-bin)
      (setenv "PATH" (concat homebrew-bin ":" homebrew-sbin ":" (getenv "PATH")))
      (setq exec-path (append (list homebrew-bin homebrew-sbin) exec-path)))))

;; Essential Modes

;; Enable helpful built-in modes for better editing experience:


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

;; Utility Packages

;; Configure essential utility packages for better buffer and file management:


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

;; Development Helpers

;; Useful functions for configuration management and development workflow:


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

;; Helper function to show all Command key bindings
(defun show-command-keybindings ()
  "Show all Command (Super) key bindings in a help buffer."
  (interactive)
  (with-output-to-temp-buffer "*Command Key Bindings*"
    (princ "Command Key Bindings (macOS Style)\n")
    (princ "====================================\n\n")
    (princ "File Operations:\n")
    (princ "  Cmd+P     Find Files (Fuzzy)\n")
    (princ "  Cmd+Shift+F  Search Project\n\n")
    (princ "Buffer Management:\n")
    (princ "  Cmd+B     Switch Buffer\n")
    (princ "  Cmd+W     Kill Buffer\n")
    (princ "  Cmd+N     New Buffer\n")
    (princ "  Cmd+[     Previous Buffer\n")
    (princ "  Cmd+]     Next Buffer\n\n")
    (princ "Window/File Explorer:\n")
    (princ "  Cmd+0     Toggle File Explorer\n")
    (princ "  Cmd+O     Switch Window\n")
    (princ "  Cmd+1-9   Select Window by Number\n\n")
    (princ "Workspace Management:\n")
    (princ "  Cmd+{     Previous Workspace\n")
    (princ "  Cmd+}     Next Workspace\n\n")
    (princ "Tip: These bindings also appear in which-key when you press them.\n")))

;; Custom keybindings
(global-set-key (kbd "C-c c r") 'reload-config) ; C-c c r to reload config
(global-set-key (kbd "C-c c e") 'open-config)   ; C-c c e to edit config
(global-set-key (kbd "C-c c c") 'claude-code)   ; C-c c c to launch Claude Code
(global-set-key (kbd "C-c c t") 'claude-code-terminal) ; C-c c t for Claude terminal
(global-set-key (kbd "C-c c k") 'show-command-keybindings) ; C-c c k to show Command key bindings

;; Open Emacs keybinding reference
(defun open-emacs-reference ()
  "Open the Emacs keybinding reference document in a read-only buffer in a new window split."
  (interactive)
  (let ((reference-file (expand-file-name "docs/emacs-keybinding-reference.md" user-emacs-directory)))
    (if (file-exists-p reference-file)
        (progn
          (split-window-right)
          (other-window 1)
          (find-file reference-file)
          (read-only-mode 1)
          (message "Opened Emacs keybinding reference (read-only)"))
      (message "Reference file not found: %s" reference-file))))

(global-set-key (kbd "C-c c h") 'open-emacs-reference) ; C-c c h for help/reference

;; Which-key for discoverability
(use-package which-key
  :init
  (which-key-mode 1)
  :config
  (setq which-key-idle-delay 0.5
        which-key-idle-secondary-delay 0.05
        which-key-popup-type 'side-window
        which-key-side-window-location 'bottom
        which-key-side-window-max-height 0.25
        which-key-max-description-length 30
        which-key-allow-imprecise-window-fit t
        which-key-separator " → "
        which-key-sort-order 'which-key-prefix-then-key-order
        which-key-sort-uppercase-first nil)

  ;; Add descriptions for Command key bindings to make them discoverable
  (which-key-add-key-based-replacements
    "s-p" "Find Files (Fuzzy)"
    "s-P" "Search Project"
    "s-b" "Switch Buffer"
    "s-0" "Toggle File Explorer"
    "s-o" "Switch Window"
    "s-w" "Kill Buffer"
    "s-n" "New Buffer"
    "s-[" "Previous Buffer"
    "s-]" "Next Buffer"
    "s-1" "Select Window 1"
    "s-2" "Select Window 2"
    "s-3" "Select Window 3"
    "s-4" "Select Window 4"
    "s-5" "Select Window 5"
    "s-6" "Select Window 6"
    "s-7" "Select Window 7"
    "s-8" "Select Window 8"
    "s-9" "Select Window 9"
    "s-{" "Previous Workspace"
    "s-}" "Next Workspace"
    "s-t" "Toggle Impl/Test"
    "C-c c" "Claude Config"
    "C-c c k" "Show Command Keys"
    "C-c c h" "Emacs Reference"))

;; Dired improvements
(use-package dired
  :ensure nil
  :config
  (setq dired-listing-switches "-alh"
        dired-dwim-target t
        dired-auto-revert-buffer t))

(provide 'core)
;;; core.el ends here
