;;; focus-mode.el --- Toggleable focus mode for distraction-free editing -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides a toggleable focus mode that centers the current buffer
;; in the window for distraction-free editing.

;;; Code:

;; Focus mode state variables
(defvar my/focus-mode-active nil
  "Whether focus mode is currently active.")

(defvar my/focus-mode-window-config nil
  "Stored window configuration before entering focus mode.")

(defvar my/focus-mode-margins nil
  "Stored original margin values before focus mode.")

;; Customizable options
(defgroup focus-mode nil
  "Toggleable focus mode for distraction-free editing."
  :group 'convenience
  :prefix "my/focus-mode-")

(defcustom my/focus-mode-width 320
  "Target width for the focused buffer in columns."
  :type 'integer
  :group 'focus-mode)

(defcustom my/focus-mode-enable-margins t
  "Whether to use visual margins for centering."
  :type 'boolean
  :group 'focus-mode)

(defcustom my/focus-mode-margin-color "#1a1a1a"
  "Background color for focus mode margins."
  :type 'string
  :group 'focus-mode)

(defcustom my/focus-mode-preserve-modeline t
  "Whether to keep the modeline visible in focus mode."
  :type 'boolean
  :group 'focus-mode)

;; Core focus mode functions
(defun my/focus-mode-calculate-margins ()
  "Calculate margin widths to center the buffer."
  (let* ((window-width (window-width))
         (target-width my/focus-mode-width)
         (margin-width (max 0 (/ (- window-width target-width) 2))))
    ;; Debug: uncomment next line for margin calculation debugging
    ;; (message "Focus: window-width=%d target-width=%d margin-width=%d"
    ;;          window-width target-width margin-width)
    (when (> window-width target-width)
      margin-width)))

(defun my/focus-mode-enter ()
  "Enter focus mode by centering the current buffer."
  (interactive)
  (unless my/focus-mode-active
    ;; Store current window configuration
    (setq my/focus-mode-window-config (current-window-configuration))

    ;; Store current margins
    (setq my/focus-mode-margins (list (car (window-margins))
                                     (cdr (window-margins))))

    ;; Delete other windows to focus on current buffer
    (delete-other-windows)
    ;; Force refresh after window changes
    (sit-for 0)

    ;; Apply centering margins if enabled
    (when my/focus-mode-enable-margins
      (let ((margin-width (my/focus-mode-calculate-margins)))
        (when margin-width
          ;; Set margins to center the text
          (set-window-margins nil margin-width margin-width)

          ;; Set margin background color if supported
          (when (display-graphic-p)
            (set-face-background 'fringe my/focus-mode-margin-color))

          ;; Force immediate visual update after margin setting
          (redraw-display)
          (force-window-update)
          (sit-for 0))))

    ;; Update state
    (setq my/focus-mode-active t)

    ;; Final window refresh to ensure everything is visible
    (redraw-display)
    (recenter)  ; Recenter view
    (sit-for 0)  ; Force Emacs to process display updates

    ;; Visual feedback
    (message "Focus mode enabled - press %s to exit"
             (key-description (where-is-internal 'my/focus-mode-toggle nil t)))))

(defun my/focus-mode-exit ()
  "Exit focus mode and restore window configuration."
  (interactive)
  (when my/focus-mode-active
    ;; Restore margins
    (when my/focus-mode-margins
      (set-window-margins nil
                         (car my/focus-mode-margins)
                         (cadr my/focus-mode-margins)))

    ;; Restore window configuration
    (when my/focus-mode-window-config
      (set-window-configuration my/focus-mode-window-config))

    ;; Reset fringe background if we changed it
    (when (and my/focus-mode-enable-margins (display-graphic-p))
      (set-face-background 'fringe nil))

    ;; Clear state
    (setq my/focus-mode-active nil
          my/focus-mode-window-config nil
          my/focus-mode-margins nil)

    ;; Force window refresh to show changes immediately
    (redraw-display)
    (force-window-update)
    (recenter)  ; Recenter view
    (sit-for 0)  ; Force Emacs to process display updates

    ;; Visual feedback
    (message "Focus mode disabled")))

(defun my/focus-mode-toggle ()
  "Toggle focus mode on/off."
  (interactive)
  (if my/focus-mode-active
      (my/focus-mode-exit)
    (my/focus-mode-enter)))

;; Auto-adjust margins when window size changes
(defun my/focus-mode-adjust-margins ()
  "Adjust margins when window size changes in focus mode."
  (when (and my/focus-mode-active my/focus-mode-enable-margins)
    (let ((margin-width (my/focus-mode-calculate-margins)))
      (when margin-width
        (set-window-margins nil margin-width margin-width)
        ;; Force immediate visual update
        (redraw-display)
        (sit-for 0)))))

;; Hook to adjust margins on window size changes
(add-hook 'window-size-change-functions
          (lambda (frame)
            (when (eq frame (selected-frame))
              (my/focus-mode-adjust-margins))))

;; Additional utility functions
(defun my/focus-mode-status ()
  "Show current focus mode status."
  (interactive)
  (message "Focus mode: %s (width: %d, margins: %s)"
           (if my/focus-mode-active "ACTIVE" "inactive")
           my/focus-mode-width
           (window-margins)))

(defun my/focus-mode-debug ()
  "Debug focus mode settings and window state."
  (interactive)
  (message "=== Focus Mode Debug ===\nActive: %s\nWidth setting: %d\nWindow width: %d\nMargins: %s\nEnable margins: %s"
           my/focus-mode-active
           my/focus-mode-width
           (window-width)
           (window-margins)
           my/focus-mode-enable-margins))

(defun my/focus-mode-enter-debug ()
  "Debug version of focus mode enter with verbose output."
  (interactive)
  (unless my/focus-mode-active
    (message "1. Starting focus mode enter...")

    ;; Store current window configuration
    (setq my/focus-mode-window-config (current-window-configuration))
    (message "2. Stored window configuration")

    ;; Store current margins
    (setq my/focus-mode-margins (list (car (window-margins))
                                     (cdr (window-margins))))
    (message "3. Stored margins: %s" my/focus-mode-margins)

    ;; Delete other windows to focus on current buffer
    (delete-other-windows)
    (message "4. Deleted other windows, window width now: %d" (window-width))
    (sit-for 0.1)  ; Longer pause to see intermediate state

    ;; Apply centering margins if enabled
    (when my/focus-mode-enable-margins
      (let ((margin-width (my/focus-mode-calculate-margins)))
        (message "5. Calculated margin width: %s" margin-width)
        (when margin-width
          ;; Set margins to center the text
          (set-window-margins nil margin-width margin-width)
          (message "6. Set margins to: %s" (window-margins))

          ;; Force immediate visual update after margin setting
          (redraw-display)
          (force-window-update)
          (sit-for 0.1))))

    ;; Update state
    (setq my/focus-mode-active t)
    (message "7. Focus mode activated")

    ;; Final window refresh
    (redraw-display)
    (recenter)
    (sit-for 0.1)
    (message "8. Final refresh complete")))

(defun my/focus-mode-increase-width ()
  "Increase focus mode width."
  (interactive)
  (setq my/focus-mode-width (min 400 (+ my/focus-mode-width 10)))
  (when my/focus-mode-active
    (my/focus-mode-adjust-margins))
  (message "Focus width: %d columns" my/focus-mode-width))

(defun my/focus-mode-decrease-width ()
  "Decrease focus mode width."
  (interactive)
  (setq my/focus-mode-width (max 60 (- my/focus-mode-width 10)))
  (when my/focus-mode-active
    (my/focus-mode-adjust-margins))
  (message "Focus width: %d columns" my/focus-mode-width))

;; Quick configuration presets
(defun my/focus-mode-narrow ()
  "Set focus mode to narrow width (160 columns)."
  (interactive)
  (setq my/focus-mode-width 160)
  (when my/focus-mode-active
    (my/focus-mode-adjust-margins))
  (message "Focus mode: narrow (160 columns)"))

(defun my/focus-mode-medium ()
  "Set focus mode to medium width (240 columns)."
  (interactive)
  (setq my/focus-mode-width 240)
  (when my/focus-mode-active
    (my/focus-mode-adjust-margins))
  (message "Focus mode: medium (240 columns)"))

(defun my/focus-mode-wide ()
  "Set focus mode to wide width (320 columns) - default."
  (interactive)
  (setq my/focus-mode-width 320)
  (when my/focus-mode-active
    (my/focus-mode-adjust-margins))
  (message "Focus mode: wide (320 columns) - default"))

(defun my/focus-mode-ultrawide ()
  "Set focus mode to ultra-wide width (400 columns) - maximum."
  (interactive)
  (setq my/focus-mode-width 400)
  (when my/focus-mode-active
    (my/focus-mode-adjust-margins))
  (message "Focus mode: ultra-wide (400 columns) - maximum"))

;; Integration with other modes
(defun my/focus-mode-safe-toggle ()
  "Safely toggle focus mode, avoiding conflicts with special modes."
  (interactive)
  (cond
   ;; Don't activate in minibuffer
   ((minibufferp)
    (message "Cannot enter focus mode in minibuffer"))
   ;; Don't activate in special buffers
   ((string-match-p "^\\*" (buffer-name))
    (message "Focus mode not recommended for special buffers"))
   ;; Safe to toggle
   (t (my/focus-mode-toggle))))

;; Global keybindings
(global-set-key (kbd "C-c f f") #'my/focus-mode-toggle)
(global-set-key (kbd "C-c f s") #'my/focus-mode-status)
(global-set-key (kbd "C-c f d") #'my/focus-mode-debug)
(global-set-key (kbd "C-c f D") #'my/focus-mode-enter-debug)
(global-set-key (kbd "C-c f +") #'my/focus-mode-increase-width)
(global-set-key (kbd "C-c f -") #'my/focus-mode-decrease-width)
(global-set-key (kbd "C-c f 1") #'my/focus-mode-narrow)
(global-set-key (kbd "C-c f 2") #'my/focus-mode-medium)
(global-set-key (kbd "C-c f 3") #'my/focus-mode-wide)
(global-set-key (kbd "C-c f 4") #'my/focus-mode-ultrawide)

;; Single-keystroke focus toggle (avoid prefix sequences)
(global-set-key (kbd "<f11>") #'my/focus-mode-toggle)     ; F11 (if not captured by macOS)
(global-set-key (kbd "<f12>") #'my/focus-mode-toggle)     ; F12 alternative
(global-set-key (kbd "<pause>") #'my/focus-mode-toggle)   ; Pause/Break key
(global-set-key (kbd "C-z") #'my/focus-mode-toggle)       ; Override suspend (immediate)

;; Removed C-c F to avoid conflicts with projectile-find-file-dwim
;; Use C-c f f for focus mode toggle instead

;; Which-key descriptions
(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    ;; Focus mode commands
    "C-c f" "Focus Mode"
    "C-c f f" "Toggle Focus"
    "C-c f s" "Focus Status"
    "C-c f d" "Debug Focus"
    "C-c f D" "Debug Enter (Verbose)"
    "C-c f +" "Increase Width"
    "C-c f -" "Decrease Width"
    "C-c f 1" "Narrow (160 cols)"
    "C-c f 2" "Medium (240 cols)"
    "C-c f 3" "Wide (320 cols) - Default"
    "C-c f 4" "Ultra-wide (400 cols) - Max"
    "<f11>" "Focus Toggle (F11)"
    "<f12>" "Focus Toggle (F12)"
    "<pause>" "Focus Toggle (Pause)"
    "C-z" "Focus Toggle (Ctrl+Z)"))

;; Mode line indicator (optional)
(defun my/focus-mode-modeline-indicator ()
  "Return focus mode indicator for modeline."
  (when my/focus-mode-active
    " [FOCUS]"))

;; Add to mode line if desired
(when my/focus-mode-preserve-modeline
  (add-to-list 'mode-line-misc-info
               '(:eval (my/focus-mode-modeline-indicator))))

(provide 'focus-mode)
;;; focus-mode.el ends here