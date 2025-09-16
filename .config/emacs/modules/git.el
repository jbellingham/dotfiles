;;; git.el --- Git integration configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Git integration with Magit and related tools.

;;; Code:

;; Magit - Git interface
(use-package magit
  :bind (("C-x g" . magit-status)
         ("C-x M-g" . magit-dispatch)
         ("C-c g c" . magit-clone)
         ("C-c g s" . magit-status)
         ("C-c g b" . magit-blame)
         ("C-c g l" . magit-log-buffer-file)
         ("C-c g p" . magit-pull))
  :config
  (setq magit-completing-read-function 'completing-read
        magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1
        magit-repository-directories '(("~/dev" . 2) ("~/projects" . 2))
        magit-save-repository-buffers 'as-needed
        magit-diff-refine-hunk t
        magit-revision-show-gravatars '("^Author:     " . "^Commit:     ")
        magit-log-arguments '("--graph" "--decorate" "--color")
        magit-log-section-commit-count 20))

;; Git gutter - Show changes in fringe
(use-package git-gutter
  :hook (prog-mode . git-gutter-mode)
  :config
  (setq git-gutter:update-interval 0.1
        git-gutter:modified-sign "~"
        git-gutter:added-sign "+"
        git-gutter:deleted-sign "-")
  :bind (("C-x v =" . git-gutter:popup-hunk)
         ("C-x v p" . git-gutter:previous-hunk)
         ("C-x v n" . git-gutter:next-hunk)
         ("C-x v s" . git-gutter:stage-hunk)
         ("C-x v r" . git-gutter:revert-hunk)))

;; Git gutter fringe - Use fringe instead of margin
(use-package git-gutter-fringe
  :after git-gutter
  :config
  (define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240] nil nil 'bottom))

;; Git timemachine - Browse file history
(use-package git-timemachine
  :bind ("C-x v t" . git-timemachine-toggle))

;; Magit forge - GitHub/GitLab integration
(use-package forge
  :after magit
  :config
  (setq forge-owned-accounts '(("your-username"))
        forge-database-file (expand-file-name "forge-database.sqlite" user-emacs-directory)))

;; Git messenger - Show last commit message
(use-package git-messenger
  :bind ("C-x v m" . git-messenger:popup-message)
  :config
  (setq git-messenger:show-detail t
        git-messenger:use-magit-popup t))

;; Diff highlight - Better diff colors
(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (vc-dir-mode . diff-hl-dir-mode)
         (dired-mode . diff-hl-dired-mode))
  :config
  (setq diff-hl-draw-borders nil
        diff-hl-side 'left)
  :bind (("C-x v [" . diff-hl-previous-hunk)
         ("C-x v ]" . diff-hl-next-hunk)
         ("C-x v =" . diff-hl-show-hunk))
  :hook (magit-pre-refresh . diff-hl-magit-pre-refresh)
  :hook (magit-post-refresh . diff-hl-magit-post-refresh))

;; Magit Delta - Better diffs with delta
(use-package magit-delta
  :hook (magit-mode . magit-delta-mode))

;; Git auto-commit for specific files
(use-package git-auto-commit-mode
  :defer t
  :config
  (setq gac-automatically-push-p t
        gac-debounce-interval 10))

;; Browse at remote - Open files in browser
(use-package browse-at-remote
  :bind ("C-c g r" . browse-at-remote))

;; GitHub review
(use-package github-review
  :defer t)

;; Git link - Get GitHub/GitLab links
(use-package git-link
  :bind (("C-c g L" . git-link)
         ("C-c g C" . git-link-commit)
         ("C-c g H" . git-link-homepage))
  :config
  (setq git-link-open-in-browser t
        git-link-use-commit t))

;; Blamer - Inline git blame
(use-package blamer
  :bind (("C-c g i" . blamer-show-commit-info)
         ("C-c g d" . blamer-show-posframe-commit-info))
  :defer 20
  :custom
  (blamer-idle-time 0.3)
  (blamer-min-offset 70)
  :custom-face
  (blamer-face ((t :foreground "#7a88cf"
                   :background nil
                   :height 140
                   :italic t)))
  :config
  (global-blamer-mode 1))

;; Vc (built-in version control)
(use-package vc
  :ensure nil
  :config
  (setq vc-follow-symlinks t
        vc-make-backup-files t))

;; Ediff configuration
(use-package ediff
  :ensure nil
  :config
  (setq ediff-window-setup-function 'ediff-setup-windows-plain
        ediff-split-window-function 'split-window-horizontally
        ediff-diff-options "-w"))

(provide 'git)
;;; git.el ends here