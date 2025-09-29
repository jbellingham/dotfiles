;; Configuration Management

;; Finally, let's update the init.el file to properly load our literate configuration:


;;; init.el --- Modern Emacs Configuration Entry Point -*- lexical-binding: t; -*-

;;; Commentary:
;; A modern, modular Emacs configuration optimized for development.
;; This init.el loads the literate configuration from config.org.

;;; Code:

;; Performance optimization during startup
(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)
(setq gc-cons-threshold most-positive-fixnum)

;; Load org-babel and tangle config.org
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(package-initialize)

;; Bootstrap use-package if not installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Load org to use org-babel-load-file
(require 'org)

;; Auto-tangle function for org files in modules directory
(defun je/auto-tangle-config-files ()
  "Auto-tangle all .org configuration files in the modules directory."
  (interactive)
  (let ((modules-dir (expand-file-name "modules" user-emacs-directory))
        (org-files '("performance.org" "core.org" "evil.org" "completion.org"
                     "navigation.org" "explorer.org" "project.org" "workspace.org"
                     "git.org" "development.org" "ui.org" "focus.org")))
    (dolist (file org-files)
      (let ((full-path (expand-file-name file modules-dir)))
        (when (file-exists-p full-path)
          (message "Tangling %s..." full-path)
          (with-current-buffer (find-file-noselect full-path)
            (org-babel-tangle)
            (kill-buffer)))))))

;; Hook to auto-tangle when any org file is saved
(defun je/setup-auto-tangle-hooks ()
  "Set up auto-tangle hooks for org files in modules directory."
  (add-hook 'after-save-hook
            (lambda ()
              (when (and buffer-file-name
                         (string-match-p "/modules/.*\\.org$" buffer-file-name))
                (message "Auto-tangling %s..." buffer-file-name)
                (org-babel-tangle)))
            nil t))

(add-hook 'org-mode-hook #'je/setup-auto-tangle-hooks)


;; Load modular configuration from modules directory
(let ((modules-dir (expand-file-name "modules" user-emacs-directory)))
  (when (file-directory-p modules-dir)
    ;; Load modules in dependency order
    (dolist (module '("performance" "core" "evil" "completion" "navigation"
                     "explorer" "project" "workspace" "git" "development" "ui" "focus"))
      (let ((org-file (expand-file-name (concat module ".org") modules-dir))
            (el-file (expand-file-name (concat module ".el") modules-dir)))
        ;; Tangle if org file exists and is newer than el file
        (when (and (file-exists-p org-file)
                   (or (not (file-exists-p el-file))
                       (file-newer-than-file-p org-file el-file)))
          (message "Tangling %s..." org-file)
          (with-current-buffer (find-file-noselect org-file)
            (org-babel-tangle)
            (kill-buffer)))
        ;; Load the el file
        (when (file-exists-p el-file)
          (message "Loading %s..." el-file)
          (load-file el-file))))))

;; Restore normal GC settings after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist file-name-handler-alist-original)
            (setq gc-cons-threshold (* 20 1000 1000))))

(provide 'init)

;;; init.el ends here
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
