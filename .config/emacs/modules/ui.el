;; UI Cleanup

;; Clean, modern interface optimized for development:


;;; ui.el --- UI and theme configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; User interface improvements, themes, and visual enhancements.

;;; Code:

;; Disable startup elements
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message t
      inhibit-splash-screen t
      initial-scratch-message nil)

;; Clean UI - but keep menu bar on macOS for window controls
(when (and (fboundp 'menu-bar-mode) (not (eq system-type 'darwin)))
  (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; Frame settings
(setq frame-title-format '("Emacs - " (:eval (if (buffer-file-name)
                                                  (abbreviate-file-name (buffer-file-name))
                                                "%b")))
      frame-resize-pixelwise t
      window-resize-pixelwise t)

;; Font Configuration

;; Optimized for Apple Silicon Macs with high-DPI displays:


;; Font configuration optimized for M4 MacBook
(defun setup-fonts ()
  "Setup fonts with fallbacks for different systems."
  (let ((mono-font (cond
                    ((find-font (font-spec :name "SF Mono")) "SF Mono")
                    ((find-font (font-spec :name "Monaco")) "Monaco")
                    ((find-font (font-spec :name "Menlo")) "Menlo")
                    (t "monospace")))
        (variable-font (cond
                        ((find-font (font-spec :name "SF Pro Display")) "SF Pro Display")
                        ((find-font (font-spec :name "Helvetica Neue")) "Helvetica Neue")
                        ((find-font (font-spec :name "Arial")) "Arial")
                        (t "sans-serif")))
        ;; Adjust height for high-DPI M4 MacBook displays
        (font-height (if (> (display-pixel-width) 2560) 130 140)))

    (set-face-attribute 'default nil
                        :family mono-font
                        :height font-height
                        :weight 'normal)

    (set-face-attribute 'fixed-pitch nil
                        :family mono-font
                        :height font-height)

    (set-face-attribute 'variable-pitch nil
                        :family variable-font
                        :height font-height)))

;; Setup fonts after frame creation
(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (select-frame frame)
                (setup-fonts)))
  (setup-fonts))

;; Line numbers
(use-package display-line-numbers
  :ensure nil
  :config
  (global-display-line-numbers-mode 1)
  (setq display-line-numbers-type 'relative
        display-line-numbers-width 3
        display-line-numbers-widen t))

;; Theme & Modeline


;; Theme
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config)
  (doom-themes-neotree-config)
  (doom-themes-treemacs-config)
  (doom-themes-org-config)

  ;; Ensure window controls remain visible after theme load
  (when (eq system-type 'darwin)
    (set-frame-parameter nil 'ns-transparent-titlebar nil)
    (set-frame-parameter nil 'undecorated-round nil)
    (menu-bar-mode 1)))

;; Modeline
(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode)
  :config
  ;; Prevent recursion during reloads by ensuring clean state
  (when (and (fboundp 'doom-modeline-mode)
             (not doom-modeline-mode))
    ;; Increase eval depth temporarily for complex modeline setup
    (let ((max-lisp-eval-depth (max max-lisp-eval-depth 3000)))
      (doom-modeline-mode 1)))

  ;; Safe configuration with recursion protection
  (setq doom-modeline-height 25
        doom-modeline-bar-width 3
        doom-modeline-project-detection 'projectile
        doom-modeline-buffer-file-name-style 'truncate-upto-project
        doom-modeline-icon (display-graphic-p)
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode-color-icon t
        doom-modeline-buffer-state-icon t
        doom-modeline-buffer-modification-icon t
        doom-modeline-unicode-fallback nil
        doom-modeline-minor-modes nil
        doom-modeline-enable-word-count nil
        doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode)
        doom-modeline-buffer-encoding t
        doom-modeline-indent-info nil
        doom-modeline-checker-simple-format t
        doom-modeline-number-limit 99
        doom-modeline-vcs-max-length 12
        doom-modeline-persp-name t
        doom-modeline-display-default-persp-name nil
        doom-modeline-lsp t
        doom-modeline-github nil
        doom-modeline-github-interval (* 30 60)
        doom-modeline-modal-icon t
        doom-modeline-mu4e nil
        doom-modeline-gnus t
        doom-modeline-gnus-timer 2
        doom-modeline-irc t
        doom-modeline-irc-stylize 'identity
        doom-modeline-env-version t
        doom-modeline-env-enable-python t
        doom-modeline-env-enable-ruby t
        doom-modeline-env-enable-perl t
        doom-modeline-env-enable-go t
        doom-modeline-env-enable-elixir t
        doom-modeline-env-enable-rust t
        doom-modeline-env-python-executable "python"
        doom-modeline-env-ruby-executable "ruby"
        doom-modeline-env-perl-executable "perl"
        doom-modeline-env-go-executable "go"
        doom-modeline-env-elixir-executable "iex"
        doom-modeline-env-rust-executable "rustc"
        doom-modeline-env-load-string "..."))

;; All the icons
(use-package all-the-icons
  :if (display-graphic-p)
  :config
  (unless (find-font (font-spec :name "all-the-icons"))
    (all-the-icons-install-fonts t)))

;; Icons for dired
(use-package all-the-icons-dired
  :if (display-graphic-p)
  :hook (dired-mode . all-the-icons-dired-mode))

;; Visual Enhancements

;; Beautiful visual enhancements for better coding experience:


;; Rainbow delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Rainbow mode for colors
(use-package rainbow-mode
  :hook ((css-mode scss-mode sass-mode) . rainbow-mode))

;; Highlight current line
(use-package hl-line
  :ensure nil
  :hook (after-init . global-hl-line-mode))

;; Whitespace visualization with dots
(use-package whitespace
  :ensure nil
  :hook ((prog-mode text-mode) . whitespace-mode)
  :config
  (setq whitespace-style '(face spaces trailing space-mark)
        whitespace-display-mappings
        '((space-mark ?\s [?\·] [?.])    ; spaces as middle dot
          (tab-mark ?\t [?\▷ ?\t] [?\\ ?\t]))) ; tabs as triangle
  ;; Make whitespace marks subtle
  (set-face-attribute 'whitespace-space nil
                      :background nil
                      :foreground "#555555")
  (set-face-attribute 'whitespace-trailing nil
                      :background "#444444"
                      :foreground nil))

;; Indent guides
(use-package indent-guide
  :hook (prog-mode . indent-guide-mode)
  :config
  (setq indent-guide-char "│"
        indent-guide-delay 0.1))

;; Smooth scrolling
(use-package pixel-scroll
  :ensure nil
  :config
  (pixel-scroll-precision-mode 1))

;; Beacon - Highlight cursor on window switch
(use-package beacon
  :config
  (setq beacon-color "#f1c40f"
        beacon-size 20
        beacon-blink-delay 0.2
        beacon-blink-duration 0.3)
  (beacon-mode 1))

;; Solaire mode - Distinguish file buffers
(use-package solaire-mode
  :config
  (solaire-global-mode +1))

;; Custom faces for Ruby
(custom-set-faces
 '(ruby-heredoc-delimiter-face ((t (:foreground "#5DADE2"))))
 '(ruby-string-delimiter-face ((t (:foreground "#58D68D"))))
 '(ruby-constant-face ((t (:foreground "#F4D03F"))))
 '(ruby-op-face ((t (:foreground "#EC7063")))))

;; VS Code-like Buffer Tabs

;; Buffer tabs across the top with VS Code-like appearance and middle-click to close:


;; Centaur tabs - VS Code-like buffer tabs
(use-package centaur-tabs
  :ensure t
  :demand t
  :config
  ;; Enable centaur-tabs globally
  (centaur-tabs-mode t)

  ;; VS Code-like appearance
  (setq centaur-tabs-style "bar"
        centaur-tabs-height 32
        centaur-tabs-set-icons t
        centaur-tabs-show-navigation-buttons t
        centaur-tabs-set-modified-marker t
        centaur-tabs-modified-marker "*"
        centaur-tabs-show-count t
        centaur-tabs-set-close-button t
        centaur-tabs-close-button "×"
        centaur-tabs-set-bar 'left
        centaur-tabs-gray-out-icons 'buffer
        centaur-tabs-plain-icons t
        centaur-tabs-cycle-scope 'tabs
        ;; Enable mouse support properly
        centaur-tabs-close-button-function #'kill-buffer)

  ;; Group tabs by project/directory
  (centaur-tabs-group-by-projectile-project)

  ;; Buffer grouping rules
  (defun centaur-tabs-buffer-groups ()
    "Buffer groups for centaur-tabs."
    (list
     (cond
      ;; Special buffers
      ((string-match-p "^\\*.*\\*$" (buffer-name))
       "System")
      ;; Magit buffers
      ((string-match-p "^magit.*" (buffer-name))
       "Magit")
      ;; Help buffers
      ((string-match-p "^\\*Help\\|\\*info\\|\\*Man\\|\\*woman" (buffer-name))
       "Help")
      ;; Project files
      ((and (projectile-project-p)
            (not (string-match-p "^\\*.*\\*$" (buffer-name))))
       (projectile-project-name))
      ;; Default group
      (t "Common"))))

  ;; Exclude certain buffers from tabs
  (defun centaur-tabs-hide-tab (x)
    "Hide certain buffers from tabs."
    (let ((name (format "%s" x)))
      (or
       ;; Hide these specific buffers
       (string-prefix-p "*epc" name)
       (string-prefix-p "*helm" name)
       (string-prefix-p "*Compile-Log*" name)
       (string-prefix-p "*lsp" name)
       (string-prefix-p "*company" name)
       (string-prefix-p "*Flycheck" name)
       (string-prefix-p "*Warnings" name)
       (string-prefix-p "*flycheck" name)
       (string-prefix-p "*Backtrace" name)
       (string-prefix-p "*Messages" name)
       (string-prefix-p "*scratch" name)
       (string-prefix-p "*dashboard" name)
       (string-prefix-p "*doom" name)
       (string-prefix-p "*Treemacs" name)
       ;; Hide Treemacs buffers (covers all variations)
       (string-match-p "^.*Treemacs.*" name)
       ;; Hide by buffer mode (more reliable for treemacs)
       (condition-case nil
           (with-current-buffer x
             (or (derived-mode-p 'treemacs-mode)
                 (eq major-mode 'treemacs-mode)))
         (error nil))
       ;; Hide buffers with certain modes
       (and (string-prefix-p "*" name)
            (not (string-equal "*vterm*" name))
            (not (string-prefix-p "*magit" name))))))

  ;; Enable built-in mouse support with manual configuration
  (setq centaur-tabs-enable-key-bindings t)

  ;; Additional configuration for proper tab functionality
  (setq ;; Prevent aggressive window management
        centaur-tabs-adjust-buffer-order nil)

  ;; Configure centaur-tabs native mouse support
  (setq centaur-tabs-enable-click t
        centaur-tabs-enable-key-bindings t)

  ;; Override centaur-tabs close functions to use our working approach
  (defun centaur-tabs-buffer-close-tab (tab)
    "Function for closing TAB using our working kill-buffer method."
    (let ((buffer (centaur-tabs-tab-value tab)))
      (with-current-buffer buffer
        (my/safe-kill-current-buffer))
      (centaur-tabs-buffer-update-groups)
      (centaur-tabs-display-update)))

  (defun centaur-tabs-close-tab ()
    "Close current tab using our working kill-buffer method."
    (interactive)
    (my/safe-kill-current-buffer))

  ;; Custom mouse close handler for middle-click
  (defun my/centaur-tabs-mouse-close (event)
    "Close tab on middle mouse click."
    (interactive "e")
    (when (display-graphic-p)
      (let* ((posn (event-start event))
             (window (posn-window posn)))
        (when window
          (with-selected-window window
            (my/safe-kill-current-buffer))))))

  ;; Set up mouse bindings for centaur-tabs
  (when (display-graphic-p)
    ;; Middle-click anywhere on tab bar to close current buffer
    (global-set-key [header-line mouse-2] #'my/centaur-tabs-mouse-close)
    ;; Also bind to the centaur-tabs specific mouse events
    (define-key centaur-tabs-mode-map [header-line mouse-2] #'my/centaur-tabs-mouse-close))


  ;; Keybindings for tab navigation
  :bind
  (("C-<prior>" . centaur-tabs-backward)
   ("C-<next>" . centaur-tabs-forward)
   ("s-[" . centaur-tabs-backward)
   ("s-]" . centaur-tabs-forward)
   ("s-t" . centaur-tabs-switch-group)))

;; Global keybindings for buffer management (outside use-package to avoid conflicts)
(defun my/safe-kill-current-buffer ()
  "Safely kill current buffer without window management conflicts."
  (interactive)
  (let* ((current-buf (current-buffer))
         (buffer-name (buffer-name))
         (buffer-count-before (length (buffer-list))))
    (cond
     ;; Don't kill special buffers like dashboard, scratch, etc.
     ((string-match-p "^\\*\\(dashboard\\|scratch\\|Messages\\|Warnings\\)\\*$" buffer-name)
      (message "Cannot close special buffer: %s" buffer-name))
     ;; Safe to kill regular buffers
     (t
      (let ((kill-buffer-query-functions nil)  ; Disable kill confirmations
            (kill-buffer-hook nil))             ; Disable kill hooks temporarily
        (message "Attempting to kill buffer: %s" buffer-name)
        (condition-case err
            (progn
              ;; Force kill without any protections
              (set-buffer-modified-p nil)  ; Mark as unmodified to avoid save prompts
              (kill-buffer (buffer-name))
              (let ((buffer-count-after (length (buffer-list))))
                (if (< buffer-count-after buffer-count-before)
                    (message "Successfully closed buffer: %s" buffer-name)
                  (message "Buffer still exists after kill attempt: %s (hooks disabled)" buffer-name))))
          (error
           (message "Error killing buffer %s: %s" buffer-name (error-message-string err)))))))))

;; Test function to verify s-w binding works
(defun my/test-s-w ()
  "Test function for s-w binding."
  (interactive)
  (message "s-w binding is working!"))

;; Debug function to test kill-buffer directly
(defun my/debug-kill-buffer ()
  "Debug function to test if kill-buffer works at all."
  (interactive)
  (let* ((current-buf (current-buffer))
         (buffer-name (buffer-name))
         (buffer-modified (buffer-modified-p))
         (buffer-file (buffer-file-name))
         (buffer-type (type-of current-buf))
         (buffer-live (buffer-live-p current-buf))
         (buffer-count-before (length (buffer-list))))
    (message "Debug: Buffer=%s, Type=%s, Live=%s, Modified=%s, File=%s"
             buffer-name buffer-type buffer-live buffer-modified buffer-file)
    (condition-case err
        (progn
          (kill-buffer nil) ; Use nil instead of current-buf
          (message "kill-buffer with nil succeeded"))
      (error
       (message "kill-buffer failed: %s" (error-message-string err))))
    ;; Try alternative method
    (condition-case err
        (progn
          (kill-buffer (buffer-name))
          (let ((buffer-count-after (length (buffer-list))))
            (message "kill-buffer with buffer-name: %s (count: %d -> %d)"
                     (if (< buffer-count-after buffer-count-before) "SUCCESS" "FAILED")
                     buffer-count-before buffer-count-after)))
      (error
       (message "kill-buffer with buffer-name failed: %s" (error-message-string err))))))

;; Alternative approach using bury-buffer
(defun my/bury-current-buffer ()
  "Bury current buffer instead of killing it."
  (interactive)
  (let ((buffer-name (buffer-name)))
    (bury-buffer)
    (message "Buried buffer: %s" buffer-name)))

;; Set the actual binding
(global-set-key (kbd "s-w") #'my/safe-kill-current-buffer)

;; Also add an alternative test binding for verification
(global-set-key (kbd "s-W") #'my/test-s-w)

;; Temporary debug binding
(global-set-key (kbd "s-D") #'my/debug-kill-buffer)

;; Temporary bury-buffer alternative
(global-set-key (kbd "s-B") #'my/bury-current-buffer)

(provide 'ui)
;;; ui.el ends here
