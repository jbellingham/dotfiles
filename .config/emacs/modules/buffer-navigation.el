;;; buffer-navigation.el --- Visual buffer navigation and management -*- lexical-binding: t; -*-

;;; Commentary:
;; Modern visual buffer navigation and management tools.

;;; Code:

;; IBuffer - Enhanced buffer list with grouping and filtering
(use-package ibuffer
  :ensure nil
  :bind ("C-c b l" . ibuffer)  ; Buffer list
  :config
  (setq ibuffer-saved-filter-groups
        '(("default"
           ("Programming" (or (derived-mode . prog-mode)
                             (mode . ess-mode)
                             (mode . compilation-mode)))
           ("React Native" (or (mode . typescript-mode)
                              (mode . typescript-ts-mode)
                              (mode . tsx-ts-mode)
                              (mode . js2-mode)
                              (mode . js-ts-mode)
                              (mode . jsx-ts-mode)))
           ("Ruby/Rails" (or (mode . ruby-mode)
                            (mode . enh-ruby-mode)
                            (filename . "\\.rb$")
                            (filename . "\\.rake$")))
           ("Config" (or (filename . "\\.ya?ml$")
                        (filename . "\\.json$")
                        (filename . "\\.toml$")
                        (filename . "\\.*rc$")))
           ("Text" (or (mode . text-mode)
                      (mode . markdown-mode)
                      (mode . org-mode)))
           ("Dired" (mode . dired-mode))
           ("Help" (or (name . "\\*Help\\*")
                      (name . "\\*Apropos\\*")
                      (name . "\\*info\\*"))))))

  (add-hook 'ibuffer-mode-hook
            (lambda ()
              (ibuffer-auto-mode 1)
              (ibuffer-switch-to-saved-filter-groups "default")))

  ;; Use human readable Size column instead of original one
  (define-ibuffer-column size-h
    (:name "Size" :inline t)
    (cond
     ((> (buffer-size) 1000000) (format "%7.1fM" (/ (buffer-size) 1000000.0)))
     ((> (buffer-size) 1000) (format "%7.1fk" (/ (buffer-size) 1000.0)))
     (t (format "%8d" (buffer-size)))))

  ;; Modify the default ibuffer-formats
  (setq ibuffer-formats
        '((mark modified read-only locked " "
                (name 25 25 :left :elide)
                " "
                (size-h 9 -1 :right)
                " "
                (mode 16 16 :left :elide)
                " " filename-and-process)
          (mark " "
                (name 16 -1)
                " " filename))))

;; Ivy/Counsel for buffer switching with preview
(use-package ivy
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t
        ivy-count-format "(%d/%d) "
        ivy-display-style 'fancy))

(use-package counsel
  :after ivy
  :bind (("C-c b b" . counsel-switch-buffer)      ; Buffer switch
         ("C-c f b" . counsel-buffer-or-recentf))  ; Find buffers
  :config
  (setq counsel-switch-buffer-preview-virtual-buffers nil))

;; All the Icons Ivy Rich - Beautiful buffer list with icons
(use-package all-the-icons-ivy-rich
  :after (ivy all-the-icons)
  :config
  (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
  :after (ivy all-the-icons-ivy-rich)
  :config
  (ivy-rich-mode 1)
  (setq ivy-rich-path-style 'abbrev
        ivy-rich-parse-remote-buffer nil))

;; Centaur Tabs - Visual tab bar for buffers
(use-package centaur-tabs
  :config
  (centaur-tabs-mode t)
  (setq centaur-tabs-style "bar"
        centaur-tabs-height 32
        centaur-tabs-set-icons t
        centaur-tabs-show-new-tab-button t
        centaur-tabs-set-modified-marker t
        centaur-tabs-show-navigation-buttons t
        centaur-tabs-set-bar 'under
        centaur-tabs-show-count nil
        centaur-tabs-label-fixed-length 12
        centaur-tabs-gray-out-icons 'buffer
        centaur-tabs-plain-icons t
        centaur-tabs-left-edge-margin nil)

  ;; Group tabs by project
  (centaur-tabs-group-by-projectile-project)

  ;; Hide tabs for certain buffers
  (defun centaur-tabs-hide-tab (x)
    "Do not show buffer X in tabs."
    (let ((name (format "%s" x)))
      (or
       ;; Current window is not dedicated window.
       (window-dedicated-p (selected-window))
       ;; Buffer name starts with space.
       (string-prefix-p " " name)
       ;; Buffer name starts with *
       (and (string-prefix-p "*" name)
            (not (string= "*scratch*" name)))
       ;; Is not magit buffer.
       (and (string-prefix-p "magit" name)
            (not (file-name-extension name))))))

  :bind (("C-<prior>" . centaur-tabs-backward)
         ("C-<next>" . centaur-tabs-forward)
         ("C-c w k" . centaur-tabs-kill-other-buffers-in-current-group) ; Window kill others
         ("C-c w p" . centaur-tabs-group-by-projectile-project)      ; Window project group
         ("C-c w g" . centaur-tabs-group-buffer-groups))             ; Window group buffers
  )

;; Buffer Move - Move buffers between windows
(use-package buffer-move
  :bind (("<C-S-up>" . buf-move-up)
         ("<C-S-down>" . buf-move-down)
         ("<C-S-left>" . buf-move-left)
         ("<C-S-right>" . buf-move-right)))

;; Ace Window - Quick window switching
(use-package ace-window
  :bind ("C-c w o" . ace-window)  ; Window switch
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)
        aw-scope 'frame
        aw-background t))

;; Popwin - Better popup window management
(use-package popwin
  :config
  (popwin-mode 1)
  (setq popwin:popup-window-height 0.3)

  ;; Configure which buffers should be popups
  (push '("*compilation*" :height 0.3 :noselect t) popwin:special-display-config)
  (push '("*Completions*" :height 0.3 :noselect t) popwin:special-display-config)
  (push '("*Messages*" :height 0.3 :noselect t) popwin:special-display-config)
  (push '("*Apropos*" :height 0.3 :noselect t) popwin:special-display-config)
  (push '("*Buffer List*" :height 0.3) popwin:special-display-config))

;; Recent files with visual interface
(use-package recentf
  :ensure nil
  :config
  (recentf-mode 1)
  (setq recentf-max-menu-items 100
        recentf-max-saved-items 100))

;; Perspective - Workspace management like IDE tabs
(use-package perspective
  :bind (("C-c w l" . persp-list-buffers)  ; Workspace list buffers
         ("C-c w s" . persp-switch)
         ("C-c w k" . persp-kill)
         ("C-c w r" . persp-rename)
         ("C-c w a" . persp-add-buffer)
         ("C-c w A" . persp-set-buffer)
         ("C-c w b" . persp-switch-to-buffer)
         ("C-c w i" . persp-import)
         ("C-c w n" . persp-next)
         ("C-c w p" . persp-prev))
  :custom
  (persp-initial-frame-name "Main")
  (persp-suppress-no-prefix-key-warning t)
  :config
  (persp-mode))

;; Helpful functions
(defun switch-to-scratch-buffer ()
  "Switch to the *scratch* buffer, creating it if necessary."
  (interactive)
  (let ((scratch-buffer (get-buffer "*scratch*")))
    (unless scratch-buffer
      (setq scratch-buffer (generate-new-buffer "*scratch*"))
      (with-current-buffer scratch-buffer
        (lisp-interaction-mode)))
    (switch-to-buffer scratch-buffer)))

(defun kill-other-buffers ()
  "Kill all buffers except current one."
  (interactive)
  (mapc 'kill-buffer
        (delq (current-buffer)
              (cl-remove-if-not 'buffer-file-name (buffer-list))))
  (message "Killed all other file buffers"))

(defun kill-all-buffers ()
  "Kill all buffers."
  (interactive)
  (mapc 'kill-buffer (buffer-list))
  (message "Killed all buffers"))

;; Key bindings for buffer management - B prefix (Buffer)
(global-set-key (kbd "C-c b k") 'kill-other-buffers)      ; Buffer kill others
(global-set-key (kbd "C-c b K") 'kill-all-buffers)        ; Buffer Kill all
(global-set-key (kbd "C-c b s") 'switch-to-scratch-buffer) ; Buffer scratch
(global-set-key (kbd "C-c b r") 'counsel-recentf)         ; Buffer recent

(provide 'buffer-navigation)
;;; buffer-navigation.el ends here