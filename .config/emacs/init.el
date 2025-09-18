;;; init.el --- Modern Emacs Configuration for Development -*- lexical-binding: t; -*-

;; Author: Generated Configuration (Improved)
;; Version: 2.0
;; Package-Requires: ((emacs "29.1"))

;;; Commentary:
;; A modern, modular Emacs configuration optimized for development.
;; Features focused modules, consistent keybindings, and VS Code-like experience.
;;
;; Module Organization:
;; - Core: Essential Emacs settings and performance optimizations
;; - Completion: Unified completion and search system (telescope-like)
;; - File Explorer: Treemacs file tree and project dashboard
;; - Project Management: Projectile and project-aware operations
;; - Navigation: Buffer, window, and bookmark management
;; - Workspace: Session and workspace management with perspective
;; - Git: Version control tools and integrations
;; - Language-specific: Ruby, React Native, etc.
;; - UI: Themes, fonts, and visual enhancements

;;; Code:

;; Performance optimizations for startup (Apple Silicon optimized)
;; ===============================================================

(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)
(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.6)

;; Apple Silicon specific performance settings
(setq read-process-output-max (* 2 1024 1024)) ; 2MB for faster LSP
(setq process-adaptive-read-buffering nil)

;; Restore after startup
(defun restore-post-init-settings ()
  "Restore settings after initialization."
  (setq file-name-handler-alist file-name-handler-alist-original)
  ;; Higher GC threshold for Apple Silicon's ample memory
  (setq gc-cons-threshold (* 20 1000 1000))
  (setq gc-cons-percentage 0.1))

(add-hook 'emacs-startup-hook #'restore-post-init-settings)

;; Package management setup
;; ========================

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(package-initialize)

;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t
      use-package-expand-minimally t
      use-package-compute-statistics t
      use-package-verbose t)

;; Configuration modules setup
;; ===========================

(defconst config-modules-dir (expand-file-name "modules/" user-emacs-directory)
  "Directory containing configuration modules.")

(defun load-config-module (module)
  "Load configuration MODULE from modules directory."
  (let ((module-file (expand-file-name (format "%s.el" module) config-modules-dir)))
    (if (file-exists-p module-file)
        (progn
          (message "Loading module: %s" module)
          (load module-file))
      (message "Warning: Module %s not found at %s" module module-file))))

(defun load-config-modules (modules)
  "Load a list of MODULES."
  (dolist (module modules)
    (load-config-module module)))

;; Module loading order (dependencies matter)
;; ==========================================

(message "Starting Emacs configuration...")

;; 1. Core settings (must be first)
(load-config-module "core")

;; 2. Core functionality modules
(load-config-modules '("completion-unified"   ; Unified completion and search
                      "navigation"            ; Buffer and window management
                      "file-explorer"         ; Treemacs and dashboard
                      "project-management"    ; Projectile and project tools
                      "workspace"             ; Perspective and session management
                      "git"))                 ; Version control

;; 3. Language-specific modules
(load-config-modules '("ruby"                ; Ruby and Rails development
                      "react-native"))       ; React Native development

;; 4. UI and visual enhancements
(load-config-module "ui")

;; 5. Optional modules (automatically loaded if they exist)
(defvar optional-modules '("lsp"              ; Language Server Protocol
                          "org"               ; Org mode configuration
                          "markdown"          ; Markdown support
                          "docker"            ; Docker integration
                          "kubernetes"        ; Kubernetes tools
                          "ai-tools"          ; AI assistance tools
                          "email"             ; Email client
                          "rss"               ; RSS reader
                          "notes"             ; Note-taking system
                          "personal"))        ; Personal customizations

(message "Loading optional modules...")
(dolist (module optional-modules)
  (let ((module-file (expand-file-name (format "%s.el" module) config-modules-dir)))
    (when (file-exists-p module-file)
      (message "Loading optional module: %s" module)
      (load-config-module module))))

;; Post-initialization setup
;; =========================

(defun post-init-setup ()
  "Setup tasks to run after all modules are loaded."
  (message "Running post-initialization setup...")

  ;; Display startup time
  (let ((startup-time (float-time (time-subtract after-init-time before-init-time))))
    (message "Emacs started in %.2f seconds with %d packages loaded"
             startup-time (length package-activated-list)))

  ;; Setup which-key for better discoverability
  (when (featurep 'which-key)
    (which-key-mode 1)
    (message "Which-key mode enabled"))

  ;; Enable recent file tracking
  (when (featurep 'recentf)
    (recentf-mode 1))

  ;; Show dashboard if available
  (when (featurep 'dashboard)
    (dashboard-refresh-buffer))

  ;; Ensure macOS window controls are visible (final check)
  (when (eq system-type 'darwin)
    (set-frame-parameter nil 'ns-transparent-titlebar nil)
    (set-frame-parameter nil 'undecorated-round nil)
    (menu-bar-mode 1))

  ;; Final message
  (message "Emacs configuration loaded successfully!"))

(add-hook 'after-init-hook #'post-init-setup)

;; Emergency fallback functions
;; ============================

(defun emergency-fallback ()
  "Minimal configuration fallback if modules fail to load."
  (interactive)
  (message "Loading emergency fallback configuration...")

  ;; Basic editing settings
  (setq-default indent-tabs-mode nil
                tab-width 2
                fill-column 80)

  ;; Basic keybindings
  (global-set-key (kbd "C-x C-b") #'list-buffers)
  (global-set-key (kbd "C-c C-c") #'comment-or-uncomment-region)

  ;; Enable basic modes
  (show-paren-mode 1)
  (electric-pair-mode 1)
  (global-auto-revert-mode 1)

  (message "Emergency fallback loaded. Some features may not be available."))

;; Development helpers
;; ===================

(defun reload-config ()
  "Reload the entire Emacs configuration."
  (interactive)
  (when (y-or-n-p "Reload Emacs configuration? ")
    (load user-init-file)))

(defun edit-config ()
  "Open the main configuration file."
  (interactive)
  (find-file user-init-file))

(defun find-config-module (module)
  "Find and open a specific configuration MODULE."
  (interactive (list (completing-read "Module: "
                                     (directory-files config-modules-dir nil "\\.el$"))))
  (find-file (expand-file-name module config-modules-dir)))

;; Global keybindings for configuration management
(global-set-key (kbd "C-c C-r") #'reload-config)
(global-set-key (kbd "C-c C-e") #'edit-config)
(global-set-key (kbd "C-c C-m") #'find-config-module)

;; Module information
;; ==================

(defun show-loaded-modules ()
  "Show information about loaded modules."
  (interactive)
  (with-current-buffer (get-buffer-create "*Module Info*")
    (erase-buffer)
    (insert "Emacs Configuration Modules\n")
    (insert "===========================\n\n")

    (insert "Core Modules:\n")
    (dolist (module '("core" "completion-unified" "navigation" "file-explorer"
                     "project-management" "workspace" "git"))
      (insert (format "  ✓ %s\n" module)))

    (insert "\nLanguage Modules:\n")
    (dolist (module '("ruby" "react-native"))
      (insert (format "  ✓ %s\n" module)))

    (insert "\nUI Module:\n")
    (insert "  ✓ ui\n")

    (insert "\nOptional Modules:\n")
    (dolist (module optional-modules)
      (let ((module-file (expand-file-name (format "%s.el" module) config-modules-dir)))
        (if (file-exists-p module-file)
            (insert (format "  ✓ %s (loaded)\n" module))
          (insert (format "  ○ %s (not found)\n" module)))))

    (insert (format "\nTotal packages loaded: %d\n" (length package-activated-list)))
    (insert (format "Configuration directory: %s\n" config-modules-dir))

    (goto-char (point-min))
    (pop-to-buffer (current-buffer))))

(global-set-key (kbd "C-c C-i") #'show-loaded-modules)

;; Custom variables (keep at end)
;; ==============================

(provide 'init)
;;; init.el ends here

;; Custom settings (auto-generated)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ruby-constant-face ((t (:foreground "#F4D03F"))))
 '(ruby-heredoc-delimiter-face ((t (:foreground "#5DADE2"))))
 '(ruby-op-face ((t (:foreground "#EC7063"))))
 '(ruby-string-delimiter-face ((t (:foreground "#58D68D")))))
