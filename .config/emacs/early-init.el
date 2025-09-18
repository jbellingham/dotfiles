;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-

;;; Commentary:
;; Early initialization file for Emacs 27+
;; This file is loaded before the package manager and regular init.el

;;; Code:

;; Increase the GC threshold for faster startup
;; The default is 800 kilobytes. Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;; Prefer loading from source files over compiled ones
(setq load-prefer-newer noninteractive)

;; Disable package.el in favor of straight.el or manual management in init.el
;; Comment this out if you want to use package.el
;; (setq package-enable-at-startup nil)

;; Prevent unwanted runtime compilation
(setq comp-deferred-compilation nil)

;; Remove some UI elements early to prevent flashing
;; Note: Keeping menu-bar for macOS window controls
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; Disable startup screen
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)
(setq initial-scratch-message nil)

;; Set frame parameters for new frames (optimized for M4 MacBook)
(setq default-frame-alist
      '((fullscreen . nil)
        (background-color . "#282c34")
        (ns-appearance . dark)
        (ns-transparent-titlebar . nil)
        ;; M4 MacBook specific optimizations
        (inhibit-double-buffering . t)
        (undecorated-round . nil)))

;; Native compilation settings (for Emacs 28+)
(when (and (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (setq native-comp-async-report-warnings-errors nil)
  (setq native-comp-deferred-compilation t))

;;; early-init.el ends here