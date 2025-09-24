;; Native Compilation


(when (featurep 'native-compile)
  (setq native-comp-speed 2                    ; Moderate optimization
        native-comp-debug 0                    ; No debug info for speed
        native-comp-async-jobs-number 4       ; Parallel compilation
        native-comp-async-report-warnings-errors 'silent)) ; Reduce noise

;; Performance measurement tools
(defun je/benchmark-startup ()
  "Benchmark Emacs startup time."
  (interactive)
  (message "Emacs startup time: %.2f seconds with %d garbage collections."
           (float-time (time-subtract after-init-time before-init-time))
           gcs-done))

(defun je/native-comp-status ()
  "Show native compilation status."
  (interactive)
  (if (featurep 'native-compile)
      (let ((total-files 0)
            (compiled-files 0))
        (dolist (dir load-path)
          (when (file-directory-p dir)
            (dolist (file (directory-files dir t "\\.el$"))
              (setq total-files (1+ total-files))
              (when (file-exists-p (comp-el-to-eln-filename file))
                (setq compiled-files (1+ compiled-files))))))
        (message "Native compilation: %d/%d files compiled (%.1f%%)"
                 compiled-files total-files
                 (* 100.0 (/ compiled-files (float total-files)))))
    (message "Native compilation not available")))

;; Performance Benchmarking

;; Tools to measure and compare performance impact:


;; Advanced performance profiling
(defun je/profile-startup (&optional runs)
  "Profile Emacs startup time over multiple runs."
  (interactive "p")
  (setq runs (or runs 5))
  (message "Profiling startup over %d runs..." runs)
  (let ((times '())
        (process-environment (cons "EMACS_STARTUP_PROFILING=1" process-environment)))
    (dotimes (i runs)
      (let* ((output (shell-command-to-string
                     "emacs --batch --eval='(message \"Startup: %.3f seconds\" (float-time (time-subtract after-init-time before-init-time)))'"))
             (time (when (string-match "Startup: \\([0-9.]+\\)" output)
                     (string-to-number (match-string 1 output)))))
        (when time (push time times))))
    (when times
      (let ((avg (/ (apply '+ times) (length times)))
            (min-time (apply 'min times))
            (max-time (apply 'max times)))
        (message "Startup times over %d runs: avg=%.3fs, min=%.3fs, max=%.3fs"
                 runs avg min-time max-time)))))

(defun je/compare-function-performance (func &optional iterations)
  "Compare performance of a function with and without native compilation."
  (interactive "aFunction to test: \nnIterations (default 1000): ")
  (setq iterations (or iterations 1000))
  (let ((start-time (current-time))
        (i 0))
    (while (< i iterations)
      (funcall func)
      (setq i (1+ i)))
    (let ((elapsed (float-time (time-subtract (current-time) start-time))))
      (message "Function %s: %.3f seconds for %d iterations (%.6f per call)"
               func elapsed iterations (/ elapsed iterations)))))

;; Show native compilation cache info
(defun je/show-native-comp-cache ()
  "Show native compilation cache information."
  (interactive)
  (when (featurep 'native-compile)
    (let ((cache-dir (file-name-as-directory comp-native-load-path)))
      (if (file-directory-p cache-dir)
          (let* ((eln-files (directory-files-recursively cache-dir "\\.eln$"))
                 (total-size (apply '+ (mapcar (lambda (f)
                                                (file-attribute-size
                                                 (file-attributes f)))
                                              eln-files))))
            (message "Native compilation cache: %d files, %.2f MB in %s"
                     (length eln-files)
                     (/ total-size 1048576.0)
                     cache-dir))
        (message "Native compilation cache directory not found: %s" cache-dir)))))

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

;; Auto-tangle disabled due to org-src editing conflicts
;; Use M-x org-babel-tangle or SPC m b t to tangle manually
(add-hook 'after-save-hook #'auto-tangle-config-org)

(provide 'performance)
;;; performance.el ends here
