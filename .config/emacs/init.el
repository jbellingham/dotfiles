;;; init.el --- Modern Emacs Configuration for Ruby on Rails Development -*- lexical-binding: t; -*-

;; Author: Generated Configuration
;; Version: 1.0
;; Package-Requires: ((emacs "29.1"))

;;; Commentary:
;; A modern, modular Emacs configuration optimized for Ruby on Rails development.
;; Features organized modules, use-package for clean configuration, and Rails-specific tooling.

;;; Code:

;; Performance optimizations for startup
(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)
(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.6)

;; Restore after startup
(defun restore-post-init-settings ()
  "Restore settings after initialization."
  (setq file-name-handler-alist file-name-handler-alist-original)
  (setq gc-cons-threshold (* 2 1000 1000))
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

;; Optional modules (uncomment as needed)
;; (load-config-module "org")
;; (load-config-module "markdown")

(provide 'init)
;;; init.el ends here