;; Garbage Collection Tuning

;; We start by optimizing Emacs' garbage collection and file handling for faster startup, especially important on Apple Silicon Macs with abundant memory.


;;; performance.el --- Performance optimizations -*- lexical-binding: t; -*-

;;; Commentary:
;; Performance optimizations for Emacs startup and runtime.

;;; Code:

;; Performance optimizations for startup (Apple Silicon optimized)
;; ===============================================================

(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)
(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.6)

;; Apple Silicon Optimizations

;; Apple Silicon Macs have different memory and processing characteristics that we can optimize for:


;; Apple Silicon specific performance settings
(setq read-process-output-max (* 2 1024 1024)) ; 2MB for faster LSP
(setq process-adaptive-read-buffering nil)

;; Post-initialization Cleanup

;; After startup, we restore reasonable garbage collection settings optimized for Apple Silicon's ample memory:


;; Restore after startup
(defun restore-post-init-settings ()
  "Restore settings after initialization."
  (setq file-name-handler-alist file-name-handler-alist-original)
  ;; Higher GC threshold for Apple Silicon's ample memory
  (setq gc-cons-threshold (* 20 1000 1000))
  (setq gc-cons-percentage 0.1))

(add-hook 'emacs-startup-hook #'restore-post-init-settings)

;; Auto-tangle Configuration

;; Automatically tangle config.org when saved to keep config.el synchronized:


;; Auto-tangle config.org on save
(defun auto-tangle-config-org ()
  "Automatically tangle config.org when saved."
  (when (and buffer-file-name
             (string= (file-name-nondirectory buffer-file-name) "config.org")
             (or
              ;; Direct path match
              (string= (file-name-directory buffer-file-name)
                       (expand-file-name user-emacs-directory))
              ;; Symlink or dotfiles path - check if it resolves to emacs dir (with recursion protection)
              (condition-case nil
                  (let ((max-lisp-eval-depth (max max-lisp-eval-depth 3000)))
                    (string= (file-truename (file-name-directory buffer-file-name))
                             (file-truename (expand-file-name user-emacs-directory))))
                (error nil))))
    (let ((org-confirm-babel-evaluate nil))
      (message "Auto-tangling config.org...")
      (org-babel-tangle)
      (message "Auto-tangle complete!"))))

(add-hook 'after-save-hook #'auto-tangle-config-org)

(provide 'performance)
;;; performance.el ends here
