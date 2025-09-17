;;; init.el --- Modern Emacs Configuration for Ruby on Rails Development -*- lexical-binding: t; -*-

;; Author: Generated Configuration
;; Version: 1.0
;; Package-Requires: ((emacs "29.1"))

;;; Commentary:
;; A modern, modular Emacs configuration optimized for Ruby on Rails development.
;; Features organized modules, use-package for clean configuration, and Rails-specific tooling.

;;; Code:

;; Performance optimizations for startup (M4 MacBook optimized)
(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)
(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.6)

;; M4 MacBook specific performance settings
(setq read-process-output-max (* 1024 1024)) ; 1MB for faster LSP
(setq process-adaptive-read-buffering nil)

;; Restore after startup
(defun restore-post-init-settings ()
  "Restore settings after initialization."
  (setq file-name-handler-alist file-name-handler-alist-original)
  ;; Higher GC threshold for M4 MacBook's ample memory
  (setq gc-cons-threshold (* 16 1000 1000))
  (setq gc-cons-percentage 0.1))

(add-hook 'emacs-startup-hook #'restore-post-init-settings)

;; Package management setup
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
      use-package-compute-statistics t)

;; Configuration modules directory
(defconst config-modules-dir (expand-file-name "modules/" user-emacs-directory)
  "Directory containing configuration modules.")

;; Helper function to load modules
(defun load-config-module (module)
  "Load configuration MODULE from modules directory."
  (load (expand-file-name (format "%s.el" module) config-modules-dir)))

;; Core settings
(load-config-module "core")

;; Development tools
(load-config-module "completion")
(load-config-module "project")
(load-config-module "git")

;; Language support
(load-config-module "ruby")

;; UI and themes
(load-config-module "ui")

;; Which-key descriptions
(load-config-module "which-key-config")

;; Optional modules (uncomment as needed)
;; (load-config-module "org")
;; (load-config-module "markdown")

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
