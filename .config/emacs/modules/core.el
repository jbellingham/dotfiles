;; Basic Editing Behavior

;; These settings establish sane defaults for modern development:


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


;; Better defaults with eval depth protection
(setq ring-bell-function 'ignore     ; Disable bell
      inhibit-startup-screen t       ; Skip startup screen
      initial-scratch-message nil    ; Empty scratch buffer
      auto-revert-verbose nil        ; Less verbose auto-revert
      global-auto-revert-non-file-buffers t ; Auto-revert dired and other buffers
      ;; Increase eval depth limits to prevent recursion errors
      max-lisp-eval-depth 3000       ; Increase from default 1600
      max-specpdl-size 5000)          ; Increase for complex operations

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

;; Enable horizontal mouse scrolling
(when (display-graphic-p)
  ;; Enable mouse wheel support
  (mouse-wheel-mode 1)

  ;; Configure horizontal scroll speed (characters per scroll)
  ;; Adjust this value to make scrolling faster (higher) or slower (lower)
  ;; Default Emacs scroll-left/scroll-right uses current window width/2
  ;; Values: 1=very slow, 3=moderate, 5=fast, 8=very fast
  (defvar my/horizontal-scroll-amount 3
    "Number of characters to scroll horizontally per mouse wheel event.")

  ;; Custom horizontal scroll functions with configurable speed
  (defun my/scroll-left-slow ()
    "Scroll left by a small amount."
    (interactive)
    (scroll-left my/horizontal-scroll-amount))

  (defun my/scroll-right-slow ()
    "Scroll right by a small amount."
    (interactive)
    (scroll-right my/horizontal-scroll-amount))

  ;; Horizontal scrolling with mouse wheel
  (global-set-key [wheel-left] 'my/scroll-right-slow)
  (global-set-key [wheel-right] 'my/scroll-left-slow)

  ;; Alternative bindings for shift+wheel (common on some mice/trackpads)
  (global-set-key [S-wheel-up] 'my/scroll-right-slow)
  (global-set-key [S-wheel-down] 'my/scroll-left-slow)

  ;; Also bind double-wheel events that some mice send
  (global-set-key [double-wheel-left] 'my/scroll-right-slow)
  (global-set-key [double-wheel-right] 'my/scroll-left-slow))

;; Function to adjust horizontal scroll speed interactively
(defun my/set-horizontal-scroll-speed (amount)
  "Set the horizontal scroll amount to AMOUNT characters.
Useful for fine-tuning scroll speed without restarting Emacs."
  (interactive "nHorizontal scroll amount (1-10): ")
  (setq my/horizontal-scroll-amount (max 1 (min 10 amount)))
  (message "Horizontal scroll speed set to %d characters" my/horizontal-scroll-amount))

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
  "Safely reload Emacs configuration with eval depth protection."
  (interactive)
  (let ((max-lisp-eval-depth (max max-lisp-eval-depth 3000))
        (max-specpdl-size (max max-specpdl-size 5000)))
    ;; Clean up potential problematic state before reload
    (when (fboundp 'doom-modeline-mode)
      (doom-modeline-mode -1))

    ;; Reload configuration
    (condition-case err
        (progn
          (load-file user-init-file)
          (message "Config reloaded successfully!"))
      (error
       (message "Config reload failed: %s" (error-message-string err))
       ;; Attempt to restore basic functionality
       (when (fboundp 'doom-modeline-mode)
         (doom-modeline-mode 1))))))

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
;; Config management keybindings migrated to SPC c (see evil config section)

;; Open Emacs keybinding reference
(defun open-emacs-reference ()
  "Open the Emacs keybinding reference document in a read-only buffer in a new window split."
  (interactive)
  (let ((reference-file (expand-file-name "docs/emacs-keybinding-reference.org" user-emacs-directory)))
    (if (file-exists-p reference-file)
        (progn
          (split-window-right)
          (other-window 1)
          (find-file reference-file)
          (read-only-mode 1)
          ;; Enable org-mode features for better navigation
          (when (derived-mode-p 'org-mode)
            (org-overview)  ; Start with overview (folded)
            (goto-char (point-min)))
          (message "Opened Emacs keybinding reference (read-only)"))
      (message "Reference file not found: %s" reference-file))))

;; C-c c h migrated to SPC c h (see evil config section)

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
    "s-[" "Previous Tab"
    "s-]" "Next Tab"
    "s-1" "Select Window 1"
    "s-2" "Select Window 2"
    "s-3" "Select Window 3"
    "s-4" "Select Window 4"
    "s-5" "Select Window 5"
    "s-6" "Select Window 6"
    "s-7" "Select Window 7"
    "s-8" "Select Window 8"
    "s-9" "Select Window 9"
    "s-t" "Switch Tab Group"
    "s-j" "Jump Impl/Test"
    "C-c c" "Claude Config"
    "C-c c k" "Show Command Keys"
    "C-c c h" "Emacs Reference"
    ;; Evil leader (SPC) bindings
    "SPC c" "Config"
    "SPC c r" "Reload Config"
    "SPC c e" "Edit Config"
    "SPC c c" "Claude Code"
    "SPC c t" "Claude Terminal"
    "SPC c k" "Show Command Keys"
    "SPC c h" "Emacs Reference"
    "SPC f" "Files"
    "SPC f f" "Find Project Files"
    "SPC f s" "Search Project"
    "SPC f g" "Find Git Files"
    "SPC b" "Buffers"
    "SPC b b" "Switch Buffer"
    "SPC b p" "Project Buffers"
    "SPC b r" "Recent Files"
    "SPC b s" "Scratch Buffer"
    "SPC b n" "New Buffer"
    "SPC b d" "Duplicate Buffer"
    "SPC b k" "Kill Buffer"
    "SPC b K" "Kill Other Buffers"
    "SPC b A" "Kill All Buffers"
    "SPC b R" "Rename Buffer"
    "SPC b l" "List Buffers"
    "SPC g" "Go to"
    "SPC g i" "Find Implementation"
    "SPC g t" "Go to Test"
    "SPC g T" "Toggle Impl/Test"
    "SPC g g" "Git Status"
    "SPC w" "Window/Workspace"
    "SPC w c" "Create Workspace"
    "SPC w P" "Workspace for Project"
    "SPC w d" "Delete Window"
    "SPC w v" "Split Right"
    "SPC w h" "Split Below"
    "SPC w m" "Delete Other Windows"
    "SPC w o" "Other Window"
    "SPC w u" "Winner Undo"
    "SPC w U" "Winner Redo"
    "SPC w 2" "Split Sensibly"
    "SPC w K" "Kill Other Buffers"
    "SPC w s" "Save Session"
    "SPC w r" "Restore Session"
    "SPC z" "Focus/Zen"
    "SPC z z" "Toggle Focus Mode"
    "SPC z s" "Focus Status"
    "SPC z +" "Increase Width"
    "SPC z -" "Decrease Width"
    "SPC z 1" "Narrow (50%)"
    "SPC z 2" "Medium (60%)"
    "SPC z 3" "Wide (75%)"
    "SPC z 4" "Ultrawide (90%)"
    "SPC j" "Bookmarks"
    "SPC j m" "Set Bookmark"
    "SPC j j" "Jump to Bookmark"
    "SPC j l" "List Bookmarks"
    "SPC j d" "Delete Bookmark"
    "SPC p" "Project"
    "SPC p p" "Switch Project"
    "SPC p f" "Find File"
    "SPC t" "Test/Toggle"
    "SPC t t" "Toggle Impl/Test"))

;; Org-src editing configuration - completely disable separate buffer editing
;; Nuclear option: make org-edit-special do nothing to prevent all conflicts
(setq org-src-window-setup 'current-window
      org-src-strip-leading-and-trailing-blank-lines t
      org-edit-src-content-indentation 0
      org-src-fontify-natively t           ; Syntax highlighting in org buffer
      org-src-preserve-indentation t       ; Keep your indentation
      org-src-tab-acts-natively t)         ; Language-specific tab behavior

;; Nuclear fix: completely disable org-edit-special to prevent any separate buffers
(with-eval-after-load 'org
  (defun org-edit-special (&optional arg)
    "Disabled: Use direct editing in org buffer instead."
    (interactive "P")
    (message "Direct editing enabled - edit source blocks directly in this buffer"))

  ;; Also disable related functions that might trigger separate editing
  (defun org-edit-src-code (&optional code edit-buffer-name)
    "Disabled: Use direct editing in org buffer instead."
    (interactive)
    (message "Direct editing enabled - edit source blocks directly in this buffer")))

(use-package org
  :defer t
  :config

  ;; Option 2: Keep separate buffer editing but with conflict protection
  ;; Disabled in favor of direct in-buffer editing above
  ;; (with-eval-after-load 'org-src
  ;;   (defun org-src--safe-save-buffer (orig-fun &rest args)
  ;;     "Disable after-save-hook during org-src buffer saves to prevent auto-tangle conflicts."
  ;;     (if (and (boundp 'org-src--beg-marker) org-src--beg-marker)
  ;;         (let ((after-save-hook nil))
  ;;           (apply orig-fun args))
  ;;       (apply orig-fun args)))
  ;;   (advice-add 'save-buffer :around #'org-src--safe-save-buffer))
  )

;; Dired improvements
(use-package dired
  :ensure nil
  :config
  (setq dired-listing-switches "-alh"
        dired-dwim-target t
        dired-auto-revert-buffer t))

(provide 'core)
;;; core.el ends here
