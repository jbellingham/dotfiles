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
  :hook (prog-mode . display-line-numbers-mode)
  :config
  (setq display-line-numbers-type 'relative
        display-line-numbers-width 3
        display-line-numbers-widen t))

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
  :init (doom-modeline-mode 1)
  :config
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

;; Highlight indentation
(use-package highlight-indentation
  :hook ((ruby-mode enh-ruby-mode) . highlight-indentation-mode)
  :config
  (set-face-background 'highlight-indentation-face "#e3e3d3")
  (set-face-background 'highlight-indentation-current-column-face "#c3b3b3"))

;; Smooth scrolling
(use-package pixel-scroll
  :ensure nil
  :config
  (pixel-scroll-precision-mode 1))

;; Window management
(use-package ace-window
  :bind ("s-o" . ace-window)
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)
        aw-dispatch-always t
        aw-dispatch-alist
        '((?x aw-delete-window "Delete Window")
          (?m aw-swap-window "Swap Windows")
          (?M aw-move-window "Move Window")
          (?c aw-copy-window "Copy Window")
          (?j aw-switch-buffer-in-window "Select Buffer")
          (?n aw-flip-window)
          (?u aw-switch-buffer-other-window "Switch Buffer Other Window")
          (?c aw-split-window-fair "Split Fair Window")
          (?v aw-split-window-vert "Split Vert Window")
          (?b aw-split-window-horz "Split Horz Window")
          (?o delete-other-windows "Delete Other Windows")
          (?? aw-show-dispatch-help))))

;; Centered window mode
(use-package centered-window
  :config
  (setq cwm-centered-window-width 120))

;; Dimmer - Dim unfocused windows
(use-package dimmer
  :config
  (setq dimmer-fraction 0.20
        dimmer-adjustment-mode :foreground
        dimmer-use-colorspace :rgb
        dimmer-watch-frame-focus-events nil)
  (dimmer-configure-which-key)
  (dimmer-configure-magit)
  (dimmer-configure-org)
  (dimmer-mode t))

;; Page break lines
(use-package page-break-lines
  :hook (after-init . global-page-break-lines-mode))

;; Pretty symbols
(use-package prettify-symbols-mode
  :ensure nil
  :hook ((ruby-mode enh-ruby-mode) . prettify-symbols-mode)
  :config
  (setq prettify-symbols-unprettify-at-point 'right-edge))

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

;; Dashboard customizations
(setq dashboard-banner-logo-title "Ruby on Rails Development Environment"
      dashboard-startup-banner 'logo
      dashboard-center-content t
      dashboard-items '((recents  . 10)
                       (projects . 5)
                       (bookmarks . 5))
      dashboard-set-heading-icons t
      dashboard-set-file-icons t
      dashboard-show-shortcuts nil)

;; Custom faces for Ruby
(custom-set-faces
 '(ruby-heredoc-delimiter-face ((t (:foreground "#5DADE2"))))
 '(ruby-string-delimiter-face ((t (:foreground "#58D68D"))))
 '(ruby-constant-face ((t (:foreground "#F4D03F"))))
 '(ruby-op-face ((t (:foreground "#EC7063")))))


(provide 'ui)
;;; ui.el ends here