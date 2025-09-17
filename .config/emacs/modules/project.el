;;; project.el --- Project management configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Project management with Projectile and related tools.

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
        projectile-project-search-path '("~/dev/" "~/projects/")
        projectile-switch-project-action #'projectile-dired
        projectile-require-project-root nil
        projectile-auto-discover t)

  ;; Ruby/Rails specific settings
  (add-to-list 'projectile-project-root-files "Gemfile")
  (add-to-list 'projectile-project-root-files "config.ru")
  (add-to-list 'projectile-project-root-files-bottom-up "Gemfile")

  ;; Ignore patterns for Rails projects
  (setq projectile-globally-ignored-directories
        (append projectile-globally-ignored-directories
                '("log" "tmp" "coverage" ".bundle" "vendor/bundle" "node_modules")))

  (setq projectile-globally-ignored-files
        (append projectile-globally-ignored-files
                '("*.log" "*.tmp" "*.pid" "*.lock"))))

;; Treemacs - File tree sidebar
(use-package treemacs
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "s-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs 3
          treemacs-deferred-git-apply-delay 0.5
          treemacs-directory-name-transformer #'identity
          treemacs-display-in-side-window t
          treemacs-eldoc-display t
          treemacs-file-event-delay 5000
          treemacs-file-extension-regex treemacs-last-period-regex-value
          treemacs-file-follow-delay 0.2
          treemacs-follow-after-init t
          treemacs-git-command-pipe ""
          treemacs-goto-tag-strategy 'refetch-index
          treemacs-indentation 2
          treemacs-indentation-string " "
          treemacs-is-never-other-window nil
          treemacs-max-git-entries 5000
          treemacs-missing-project-action 'ask
          treemacs-no-png-images nil
          treemacs-no-delete-other-windows t
          treemacs-project-follow-cleanup nil
          treemacs-persist-file (expand-file-name ".treemacs-persist" user-emacs-directory)
          treemacs-position 'left
          treemacs-recenter-distance 0.1
          treemacs-recenter-after-file-follow nil
          treemacs-recenter-after-tag-follow nil
          treemacs-recenter-after-project-jump 'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-show-cursor nil
          treemacs-show-hidden-files t
          treemacs-silent-filewatch nil
          treemacs-silent-refresh nil
          treemacs-sorting 'alphabetic-asc
          treemacs-space-between-root-nodes t
          treemacs-tag-follow-cleanup t
          treemacs-tag-follow-delay 1.5
          treemacs-width 35
          treemacs-width-increment 1
          treemacs-wide-toggle-width-threshold 70
          treemacs-show-hidden-files t)

    ;; Ensure proper side window behavior
    (setq treemacs-display-in-side-window t
          treemacs-position 'left
          treemacs-is-never-other-window nil
          treemacs-no-delete-other-windows t)

    ;; Configure display buffer for treemacs
    (add-to-list 'display-buffer-alist
                 '("\\*Treemacs-.*\\*"
                   (display-buffer-in-side-window)
                   (side . left)
                   (slot . 0)
                   (window-width . 35)
                   (dedicated . t)
                   (preserve-size . (t . nil))))

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))

  ;; Custom toggle function to ensure proper initialization
  (defun my/treemacs-toggle ()
    "Toggle treemacs with proper project initialization."
    (interactive)
    (if (treemacs-current-visibility)
        (treemacs-quit)
      (progn
        ;; First, ensure treemacs is open
        (treemacs)
        ;; Then add current project or default directory
        (cond
         ((and (projectile-project-p) (projectile-project-root))
          (treemacs-add-and-display-current-project))
         (default-directory
          (treemacs-add-project-to-workspace default-directory))
         (t
          (treemacs-add-project-to-workspace "~/")))
        ;; Refresh to show content
        (treemacs-refresh))))

  :bind
  (:map global-map
        ("s-0" . treemacs-select-window)
        ("C-c e t" . my/treemacs-toggle)                          ; Explorer toggle
        ("C-c e T" . treemacs-add-and-display-current-project)    ; Explorer add project
        ("C-c e 1" . treemacs-delete-other-windows)              ; Explorer delete others
        ("C-c e b" . treemacs-bookmark)                          ; Explorer bookmark
        ("C-c e f" . treemacs-find-file)                         ; Explorer find file
        ("C-c e g" . treemacs-find-tag)))                        ; Explorer find tag

;; Treemacs-Projectile integration
(use-package treemacs-projectile
  :after (treemacs projectile)
  :config
  (setq treemacs-project-follow-cleanup t))

;; Treemacs magit integration
(use-package treemacs-magit
  :after (treemacs magit))

;; Treemacs icons
(use-package treemacs-all-the-icons
  :after (treemacs all-the-icons)
  :config (treemacs-load-theme "all-the-icons"))

;; Neotree alternative (lighter option)
;; (use-package neotree
;;   :bind (("C-x t n" . neotree-toggle))
;;   :config
;;   (setq neo-theme 'icons
;;         neo-smart-open t
;;         neo-show-hidden-files t
;;         neo-window-width 32
;;         neo-window-fixed-size nil))

;; Dashboard for startup
(use-package dashboard
  :config
  (setq dashboard-startup-banner 'logo
        dashboard-center-content t
        dashboard-show-shortcuts nil
        dashboard-items '((recents  . 5)
                         (bookmarks . 5)
                         (projects . 5)
                         (agenda . 5)
                         (registers . 5))
        dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-banner-logo-title "Welcome to Emacs - Ruby on Rails Development")
  (dashboard-setup-startup-hook))

;; Workspace management
(use-package perspective
  :bind (("C-c w k" . persp-kill-buffer*)      ; Workspace kill buffer
         ("C-c w b" . persp-switch-to-buffer*)   ; Workspace buffer switch
         ("C-c w l" . persp-list-buffers))       ; Workspace list buffers
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))
  :config
  ;; Fix for "Unprintable entity" errors in perspective
  (setq persp-auto-save-opt 0) ; Disable auto-save that can cause issues

  ;; Patch persp-maybe-kill-buffer to handle errors gracefully
  (defadvice persp-maybe-kill-buffer (around handle-persp-errors activate)
    "Handle perspective buffer errors gracefully."
    (condition-case err
        ad-do-it
      (error
       (unless (string-match-p "Wrong type argument: hash-table-p\\|Unprintable entity"
                              (error-message-string err))
         (signal (car err) (cdr err))))))

  :init
  (persp-mode))

;; Session management (disabled auto-save to prevent errors)
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
        desktop-auto-save-timeout nil) ; Disable auto-save
  ;; Don't start desktop-save-mode automatically to prevent issues
  ;; Uncomment the line below once errors are resolved:
  ;; (desktop-save-mode 1)
  )

(provide 'project)
;;; project.el ends here