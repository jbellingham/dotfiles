;; Treemacs Configuration

;; Treemacs provides a VS Code-like file tree sidebar:


;;; file-explorer.el --- File tree and project dashboard -*- lexical-binding: t; -*-

;;; Commentary:
;; File tree management with treemacs and startup dashboard.
;; Provides VS Code-like file explorer experience.

;;; Code:

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
  ;; Explorer keybindings with which-key descriptions
  (("s-0" . treemacs-select-window)
   ("C-c e t" . my/treemacs-toggle)
   ("C-c e T" . treemacs-add-and-display-current-project)
   ("C-c e 1" . treemacs-delete-other-windows)
   ("C-c e b" . treemacs-bookmark)
   ("C-c e f" . treemacs-find-file)
   ("C-c e g" . treemacs-find-tag)))

;; Treemacs Integrations

;; Integration with projectile, magit, and icon themes:


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

;; Startup Dashboard

;; A welcoming dashboard with recent files and projects:


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
        dashboard-banner-logo-title "Welcome to Emacs - Development Environment")
  (dashboard-setup-startup-hook))

;; Which-key descriptions for file explorer
(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    ;; Explorer commands
    "C-c e" "File Explorer"
    "C-c e t" "Toggle Explorer"
    "C-c e T" "Add Project"
    "C-c e 1" "Delete Other Windows"
    "C-c e b" "Bookmark"
    "C-c e f" "Find File"
    "C-c e g" "Find Tag"

    ;; Global Command key bindings
    "s-0" "Select Explorer"))

(provide 'file-explorer)
;;; file-explorer.el ends here
