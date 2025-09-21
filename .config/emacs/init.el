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

;; Load the literate configuration
(let ((config-org (expand-file-name "config.org" user-emacs-directory)))
  (when (file-exists-p config-org)
    (org-babel-load-file config-org)))

;; Load individual modules if config.org doesn't exist (fallback)
(unless (file-exists-p (expand-file-name "config.org" user-emacs-directory))
  (let ((modules-dir (expand-file-name "modules" user-emacs-directory)))
    (when (file-directory-p modules-dir)
      (dolist (module '("core" "completion-unified" "navigation" "file-explorer"
                       "project-management" "workspace" "git" "ruby" "react-native"
                       "ui" "focus-mode"))
        (let ((module-file (expand-file-name (concat module ".el") modules-dir)))
          (when (file-exists-p module-file)
            (load-file module-file)))))))

;; Restore normal GC settings after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist file-name-handler-alist-original)
            (setq gc-cons-threshold (* 20 1000 1000))))

(provide 'init)

;;; init.el ends here
