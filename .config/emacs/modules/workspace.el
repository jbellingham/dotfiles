;; Perspective Workspaces

;; Perspective provides VS Code-like workspace isolation:


;;; workspace.el --- Workspace and session management -*- lexical-binding: t; -*-

;;; Commentary:
;; Workspace management with perspective and session persistence.
;; Provides VS Code-like workspace isolation and session restoration.

;;; Code:

;; Perspective - Workspace management
(use-package perspective
  :bind (("C-c w k" . persp-kill-buffer*)         ; Workspace kill buffer
         ("C-c w b" . persp-switch-to-buffer*)    ; Workspace buffer switch
         ("C-c w l" . persp-list-buffers)         ; Workspace list buffers
         ("C-c w s" . persp-switch)               ; Workspace switch
         ("C-c w n" . persp-next)                 ; Workspace next
         ("C-c w p" . persp-prev)                 ; Workspace previous
         ("C-c w r" . persp-rename)               ; Workspace rename
         ("C-c w x" . persp-kill)                 ; Workspace kill
         ("C-c w a" . persp-add-buffer)           ; Workspace add buffer
         ("C-c w A" . persp-set-buffer)           ; Workspace set buffer
         ("C-c w i" . persp-import)               ; Workspace import
         ("s-{" . persp-prev)                     ; Command+{ previous workspace
         ("s-}" . persp-next))                    ; Command+} next workspace
  :custom
  (persp-mode-prefix-key (kbd "C-c w"))
  :config
  ;; Fix for "Unprintable entity" errors in perspective
  (setq persp-auto-save-opt 0  ; Disable auto-save that can cause issues
        persp-sort 'name
        persp-interactive-completion-function #'completing-read)

  ;; Create default workspaces
  (defun my/setup-default-workspaces ()
    "Set up default workspaces for common tasks."
    (persp-switch "*scratch*")
    (persp-switch "config")
    (persp-switch "main"))

  ;; Patch persp-maybe-kill-buffer to handle errors gracefully
  (defadvice persp-maybe-kill-buffer (around handle-persp-errors activate)
    "Handle perspective buffer errors gracefully."
    (condition-case err
        ad-do-it
      (error
       (unless (string-match-p "Wrong type argument: hash-table-p\\|Unprintable entity"
                              (error-message-string err))
         (signal (car err) (cdr err))))))

  ;; Project-aware workspace switching
  (defun my/workspace-for-project ()
    "Create or switch to workspace for current project."
    (interactive)
    (when (projectile-project-p)
      (let ((project-name (projectile-project-name)))
        (persp-switch project-name))))

  ;; Workspace creation
  (defun my/create-workspace (name)
    "Create a new workspace with NAME and switch to it."
    (interactive "sWorkspace name: ")
    (persp-switch name)
    (when (and (projectile-project-p)
               (y-or-n-p "Add current project to workspace? "))
      (my/workspace-for-project)))

  ;; Workspace functions migrated to SPC w (see evil config section)

  :init
  (persp-mode))

;; Session Management

;; Desktop save mode for persistent sessions:


;; Session management (desktop)
(use-package desktop
  :ensure nil
  :config
  (setq desktop-dirname user-emacs-directory
        desktop-base-file-name "desktop"
        desktop-base-lock-name "desktop.lock"
        desktop-path (list desktop-dirname)
        desktop-save t
        desktop-files-not-to-save "^$"
        desktop-load-locked-desktop nil
        desktop-auto-save-timeout 30        ; Auto-save every 30 seconds
        desktop-restore-forces-onscreen t   ; Ensure windows are visible
        desktop-restore-in-current-display t
        desktop-restore-reuses-frames t)

  ;; Exclude problematic window types from session saving
  (add-to-list 'desktop-minor-mode-table '(treemacs-mode . nil))

  ;; Filter out side windows and special buffers from desktop saving
  (setq desktop-buffers-not-to-save
        (concat "\\("
                "^nn\\.a[0-9]+\\|^\\*.*\\*\\|"
                "^magit\\|^COMMIT_EDITMSG\\|"
                "\\*Treemacs\\*\\|\\*Messages\\*\\|"
                "\\*compilation\\*\\|\\*Completions\\*"
                "\\)"))

  ;; Save additional variables
  (setq desktop-globals-to-save
        (append '((extended-command-history . 30)
                  (file-name-history        . 100)
                  (grep-history             . 30)
                  (compile-history          . 30)
                  (minibuffer-history       . 50)
                  (query-replace-history    . 60)
                  (read-expression-history  . 60)
                  (regexp-history           . 60)
                  (regexp-search-ring       . 20)
                  (search-ring              . 20)
                  (shell-command-history    . 50)
                  tags-file-name
                  register-alist)
                desktop-globals-to-save))

  ;; Custom desktop save/restore with side window handling
  (defun my/desktop-save-safe ()
    "Save desktop while handling side windows properly."
    (interactive)
    ;; Close treemacs before saving to avoid window conflicts
    (when (treemacs-current-visibility)
      (treemacs-kill-buffer))
    (desktop-save-in-desktop-dir)
    (message "Session saved safely!"))

  (defun my/desktop-restore-safe ()
    "Restore desktop and properly handle side windows."
    (interactive)
    (when (and (file-exists-p (desktop-full-file-name))
               (y-or-n-p "Restore previous session? "))
      ;; Close any existing treemacs before restoring
      (when (treemacs-current-visibility)
        (treemacs-kill-buffer))
      (desktop-read)
      ;; Brief delay before reopening treemacs to avoid conflicts
      (run-with-timer 0.5 nil (lambda ()
                                (when (bound-and-true-p treemacs-mode)
                                  (treemacs))))
      (message "Session restored safely!")))

  ;; Legacy functions for compatibility
  (defun my/save-session ()
    "Save current session with confirmation."
    (interactive)
    (when (y-or-n-p "Save current session? ")
      (my/desktop-save-safe)))

  (defun my/restore-session ()
    "Restore previous session with confirmation."
    (interactive)
    (my/desktop-restore-safe))

  ;; Auto-save session on exit (use safe version)
  (add-hook 'kill-emacs-hook #'my/desktop-save-safe)

  ;; Session keybindings (Changed from C-c s to C-c S to avoid conflict with search)
  ;; Session management migrated to SPC w s/r (see evil config section)

  ;; Enable desktop save mode
  (desktop-save-mode 1))

;; Emergency Window Management

;; Functions to handle problematic window states:


;; Debug function to see window properties
(defun my/debug-windows ()
  "Show information about all windows for debugging."
  (interactive)
  (let ((debug-info '()))
    (dolist (window (window-list))
      (let* ((buffer (window-buffer window))
             (buffer-name (buffer-name buffer))
             (side-param (window-parameter window 'window-side))
             (window-slot (window-parameter window 'window-slot))
             (treemacs-window (treemacs-is-treemacs-window? window)))
        (push (format "Window %s: buffer=%s, side=%s, slot=%s, treemacs=%s"
                      window buffer-name side-param window-slot treemacs-window)
              debug-info)))
    (with-current-buffer (get-buffer-create "*Window Debug*")
      (erase-buffer)
      (insert (mapconcat 'identity (reverse debug-info) "\n"))
      (display-buffer (current-buffer)))))

;; Fixed emergency window cleanup functions
(defun my/kill-all-side-windows ()
  "Kill all side windows to resolve conflicts."
  (interactive)
  (let ((killed-count 0))
    (dolist (window (window-list))
      (let* ((buffer (window-buffer window))
             (buffer-name (buffer-name buffer))
             (side-param (window-parameter window 'window-side))
             (is-treemacs (and (boundp 'treemacs-is-treemacs-window?)
                              (treemacs-is-treemacs-window? window))))
        (when (or side-param is-treemacs
                  (string-match-p "\\*Treemacs" buffer-name))
          (condition-case err
              (progn
                (delete-window window)
                (setq killed-count (1+ killed-count)))
            (error
             (message "Could not delete window %s: %s" window err))))))
    (message "Closed %d side windows" killed-count)))

(defun my/reset-window-layout ()
  "Emergency reset of window layout when things get broken."
  (interactive)
  (when (y-or-n-p "Reset entire window layout? This will close all windows except current buffer. ")
    (message "Starting window layout reset...")

    ;; First, try to close treemacs properly
    (condition-case err
        (when (and (fboundp 'treemacs-current-visibility)
                   (treemacs-current-visibility))
          (treemacs-kill-buffer)
          (message "Treemacs closed"))
      (error (message "Could not close treemacs properly: %s" err)))

    ;; Force close any remaining treemacs windows by buffer name
    (dolist (window (window-list))
      (let ((buffer-name (buffer-name (window-buffer window))))
        (when (string-match-p "\\*Treemacs" buffer-name)
          (condition-case err
              (delete-window window)
            (error nil)))))

    ;; Clear winner history to prevent restoration conflicts
    (when (bound-and-true-p winner-mode)
      (setq winner-ring nil))

    ;; Kill all other windows using a more aggressive approach
    (condition-case err
        (delete-other-windows)
      (error
       ;; If delete-other-windows fails, try more aggressive cleanup
       (let ((current-window (selected-window)))
         (dolist (window (window-list))
           (unless (eq window current-window)
             (condition-case nil
                 (delete-window window)
               (error nil)))))))

    ;; Force refresh display
    (redraw-display)
    (message "Window layout reset complete")))

(defun my/fix-empty-windows ()
  "Find and kill empty or problematic windows."
  (interactive)
  (let ((killed-count 0))
    (dolist (window (window-list))
      (let ((buffer (window-buffer window)))
        (when (or
               ;; Empty buffers
               (string-match-p "^\\s-*$" (buffer-name buffer))
               ;; Buffers with problematic names
               (string-match-p "^\\*.*\\*$" (buffer-name buffer))
               ;; Very small windows that might be artifacts
               (< (window-height window) 3))
          (unless (one-window-p)
            (delete-window window)
            (setq killed-count (1+ killed-count))))))
    (message "Cleaned up %d problematic windows" killed-count)))

;; Nuclear option for frameset errors
(defun my/fix-frameset-conflicts ()
  "Fix frameset conflicts by completely resetting window state."
  (interactive)
  (message "Fixing frameset conflicts...")

  ;; Disable desktop-save temporarily to prevent saving broken state
  (let ((desktop-save-backup desktop-save))
    (setq desktop-save nil)

    ;; Kill all treemacs buffers first
    (dolist (buffer (buffer-list))
      (when (string-match-p "\\*Treemacs" (buffer-name buffer))
        (kill-buffer buffer)))

    ;; Clear all window parameters that might cause conflicts
    (dolist (window (window-list))
      (set-window-parameter window 'window-side nil)
      (set-window-parameter window 'window-slot nil)
      (set-window-parameter window 'delete-window nil)
      (set-window-parameter window 'delete-other-windows nil))

    ;; Reset to single window
    (delete-other-windows)

    ;; Clear winner mode ring
    (when (bound-and-true-p winner-mode)
      (setq winner-ring nil))

    ;; Force display refresh
    (redraw-display)

    ;; Restore desktop-save setting
    (setq desktop-save desktop-save-backup)

    (message "Frameset conflicts resolved")))

(defun my/emergency-window-recovery ()
  "Complete emergency window recovery procedure."
  (interactive)
  (message "Starting emergency window recovery...")
  (my/fix-frameset-conflicts)
  (sit-for 0.5)
  (my/kill-all-side-windows)
  (sit-for 0.5)
  (my/fix-empty-windows)
  (sit-for 0.5)
  (my/reset-window-layout)
  (message "Emergency window recovery complete"))

;; Workspace Keybindings

;; Additional window management utilities and comprehensive keybindings:


;; Window management enhancements
(defun my/split-window-sensibly ()
  "Split window based on available space."
  (interactive)
  (if (> (window-width) 120)
      (split-window-right)
    (split-window-below)))

(defun my/kill-other-buffers ()
  "Kill all buffers except current one."
  (interactive)
  (when (y-or-n-p "Kill all other buffers? ")
    (mapc 'kill-buffer (delq (current-buffer) (buffer-list)))
    (message "Killed all other buffers")))

;; Window management keybindings
;; Window management operations migrated to SPC w (see evil config section)

;; Winner mode for undo/redo window configurations
(use-package winner
  :ensure nil
  :config
  (winner-mode 1))

;; Which-key descriptions for workspace management
(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    ;; Workspace commands
    "C-c w" "Workspace"
    "C-c w s" "Switch Workspace"
    "C-c w k" "Kill Buffer"
    "C-c w r" "Rename Workspace"
    "C-c w a" "Add Buffer"
    "C-c w A" "Set Buffer"
    "C-c w b" "Switch Buffer"
    "C-c w i" "Import Workspace"
    "C-c w n" "Next Workspace"
    "C-c w p" "Previous Workspace"
    "C-c w l" "List Buffers"
    "C-c w c" "Create Workspace"
    "C-c w P" "Project Workspace"
    "C-c w x" "Kill Workspace"

    ;; Window management
    "C-c w d" "Delete Window"
    "C-c w v" "Split Vertical"
    "C-c w h" "Split Horizontal"
    "C-c w m" "Maximize Window"
    "C-c w o" "Other Window"
    "C-c w u" "Winner Undo"
    "C-c w U" "Winner Redo"
    "C-c w 2" "Smart Split"
    "C-c w K" "Kill Other Buffers"

    ;; Session management (Changed to C-c S to avoid conflict with search)
    "C-c S" "Session"
    "C-c S s" "Save Session"
    "C-c S r" "Restore Session"

    ;; Global workspace shortcuts
    "s-{" "Previous Workspace"
    "s-}" "Next Workspace"))

(provide 'workspace)
;;; workspace.el ends here
