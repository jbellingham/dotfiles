;; Auto-tangling Configuration


;; Auto-tangle configuration for all org files in this directory
(defun je/auto-tangle-config-files ()
  "Auto-tangle all .org configuration files in the config directory."
  (interactive)
  (let ((config-dir (file-name-directory (or load-file-name buffer-file-name)))
        (org-files '("modules/performance.org" "modules/core.org" "modules/evil.org" "modules/completion.org"
                     "modules/navigation.org" "modules/explorer.org" "modules/project.org" "modules/workspace.org"
                     "modules/git.org" "modules/development.org" "modules/ui.org" "modules/focus.org")))
    (dolist (file org-files)
      (let ((full-path (expand-file-name file config-dir)))
        (when (file-exists-p full-path)
          (with-current-buffer (find-file-noselect full-path)
            (org-babel-tangle)
            (kill-buffer)))))))

;; Hook to auto-tangle when any config org file is saved
(defun je/setup-auto-tangle-hooks ()
  "Set up auto-tangle hooks for config files."
  (add-hook 'after-save-hook
            (lambda ()
              (when (and buffer-file-name
                         (string-match-p "/\\.config/emacs/.*\\.org$" buffer-file-name))
                (org-babel-tangle)))
            nil t))

;; Auto-tangling disabled due to org-src editing conflicts
;; (add-hook 'org-mode-hook #'je/setup-auto-tangle-hooks)

;; Module Loading

;; Load all configuration modules in the correct order:


;; Load configuration modules in dependency order
(let ((config-dir (file-name-directory (or load-file-name buffer-file-name))))
  (dolist (module '("modules/performance"
                    "modules/core"
                    "modules/evil"
                    "modules/completion"
                    "modules/navigation"
                    "modules/explorer"
                    "modules/project"
                    "modules/workspace"
                    "modules/git"
                    "modules/development"
                    "modules/ui"
                    "modules/focus"))
    (let ((module-path (expand-file-name (concat module ".el") config-dir)))
      (when (file-exists-p module-path)
        (load module-path)))))
