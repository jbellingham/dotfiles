;; Projectile Setup

;; Projectile provides intelligent project detection and management:


;;; project.el --- Project management with Projectile -*- lexical-binding: t; -*-

;;; Commentary:
;; Project management functionality using Projectile.
;; Provides VS Code-like project detection and management.

;;; Code:

;; Projectile - Project management
(use-package projectile
  :init
  (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :config
  (setq projectile-completion-system 'default
        projectile-enable-caching t
        projectile-cache-file (expand-file-name ".projectile-cache" user-emacs-directory)
        projectile-known-projects-file (expand-file-name ".projectile-bookmarks" user-emacs-directory)
        projectile-project-search-path '("~/dev/" "~/projects/" "~/dotfiles/")
        projectile-switch-project-action #'projectile-dired
        projectile-require-project-root nil
        projectile-auto-discover t
        projectile-indexing-method 'alien)

  ;; Project type specific settings
  (add-to-list 'projectile-project-root-files "package.json")      ; Node.js
  (add-to-list 'projectile-project-root-files "Cargo.toml")       ; Rust
  (add-to-list 'projectile-project-root-files "go.mod")           ; Go
  (add-to-list 'projectile-project-root-files "Gemfile")          ; Ruby/Rails
  (add-to-list 'projectile-project-root-files "config.ru")       ; Rails
  (add-to-list 'projectile-project-root-files "pyproject.toml")   ; Python
  (add-to-list 'projectile-project-root-files "pubspec.yaml")     ; Flutter/Dart
  (add-to-list 'projectile-project-root-files-bottom-up "Gemfile")

  ;; Ignore patterns for common project types
  (setq projectile-globally-ignored-directories
        (append projectile-globally-ignored-directories
                '("log" "tmp" "coverage" ".bundle" "vendor/bundle"
                  "node_modules" ".npm" ".yarn" "dist" "build"
                  ".git" ".svn" ".hg" "target" ".cargo"
                  "__pycache__" ".pytest_cache" ".venv" "venv"
                  ".gradle" ".idea" ".vscode")))

  (setq projectile-globally-ignored-files
        (append projectile-globally-ignored-files
                '("*.log" "*.tmp" "*.pid" "*.lock" "*.min.js" "*.min.css"
                  "*.pyc" "*.pyo" "*.class" "*.o" "*.so" "*.dll"))))

;; Project Functions

;; Enhanced project management functions:


;; Project functions
(defun my/project-switch-with-treemacs ()
  "Switch project and show it in treemacs."
  (interactive)
  (call-interactively #'projectile-switch-project)
  (when (and (featurep 'treemacs) (projectile-project-p))
    (treemacs-add-and-display-current-project)))

(defun my/project-find-file-dwim ()
  "Smart project file finding with fallback."
  (interactive)
  (cond
   ((projectile-project-p)
    (projectile-find-file))
   ((vc-root-dir)
    (project-find-file))
   (t
    (find-file (read-file-name "Find file: ")))))

;; Project Keybindings


;; Project-specific keybindings
(with-eval-after-load 'projectile
  (define-key projectile-command-map (kbd "s") #'my/project-switch-with-treemacs)
  ;; Note: Removed F binding to avoid conflict with F12 global key
  ;; (define-key projectile-command-map (kbd "F") #'my/project-find-file-dwim)
  )

;; Global project bindings
(global-set-key (kbd "s-p") #'my/project-find-file-dwim)  ; Command+P like VS Code
(global-set-key (kbd "s-P") #'my/project-switch-with-treemacs)  ; Command+Shift+P

;; Which-key descriptions for project management
(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    ;; Project commands
    "C-c p" "Project"
    "C-c p !" "Run Command"
    "C-c p &" "Async Command"
    "C-c p a" "Find Other File"
    "C-c p b" "Switch to Buffer"
    "C-c p C" "Configure Project"
    "C-c p c" "Compile Project"
    "C-c p D" "Find Directory"
    "C-c p d" "Find Directory"
    "C-c p E" "Edit .dir-locals"
    "C-c p e" "Recent File"
    "C-c p F" "Find File DWIM"
    "C-c p f" "Find File"
    "C-c p g" "Find File (Git)"
    "C-c p I" "Ibuffer"
    "C-c p i" "Invalidate Cache"
    "C-c p j" "Find Tag"
    "C-c p k" "Kill Buffers"
    "C-c p o" "Multi-occur"
    "C-c p P" "Test Project"
    "C-c p p" "Switch Project"
    "C-c p q" "Switch Open Project"
    "C-c p R" "Regenerate Tags"
    "C-c p r" "Replace"
    "C-c p S" "Save Project Buffers"
    "C-c p s" "Project with Treemacs"
    "C-c p T" "Find Test File"
    "C-c p t" "Toggle Impl/Test"
    "C-c p u" "Run Project"
    "C-c p v" "Browse Dirty"
    "C-c p x" "Remove Known Project"
    "C-c p z" "Cache Current File"

    ;; Global project shortcuts
    "s-p" "Find Files"
    "s-P" "Switch Project"))

(provide 'project)
;;; project.el ends here
