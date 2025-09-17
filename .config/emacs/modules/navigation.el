;;; navigation.el --- Enhanced navigation and buffer management -*- lexical-binding: t; -*-

;;; Commentary:
;; Comprehensive navigation system for buffers, windows, and projects.
;; Provides VS Code-like navigation experience with intelligent buffer management.

;;; Code:

;; Core navigation packages
;; =======================

;; Ace Window - Quick window switching
(use-package ace-window
  :bind ("s-o" . ace-window)
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)
        aw-dispatch-always t
        aw-minibuffer-flag t
        aw-scope 'frame)

  ;; Custom ace-window actions
  (setq aw-dispatch-alist
        '((?x aw-delete-window "Delete Window")
          (?m aw-swap-window "Swap Windows")
          (?M aw-move-window "Move Window")
          (?c aw-copy-window "Copy Window")
          (?j aw-switch-buffer-in-window "Select Buffer")
          (?n aw-flip-window)
          (?u aw-switch-buffer-other-window "Switch Buffer Other Window")
          (?c aw-split-window-fair "Split Fair Window")
          (?v aw-split-window-vert "Split Vert Window")
          (?h aw-split-window-horz "Split Horz Window")
          (?o delete-other-windows "Delete Other Windows")
          (?? aw-show-dispatch-help))))

;; Buffer management
;; ================

;; IBuffer for advanced buffer management
(use-package ibuffer
  :ensure nil
  :bind (("C-c b l" . ibuffer)
         ("C-x C-b" . ibuffer))
  :config
  (setq ibuffer-saved-filter-groups
        '(("default"
           ("Dired" (mode . dired-mode))
           ("Org" (mode . org-mode))
           ("Programming" (or
                          (mode . emacs-lisp-mode)
                          (mode . python-mode)
                          (mode . ruby-mode)
                          (mode . javascript-mode)
                          (mode . typescript-mode)
                          (mode . rust-mode)
                          (mode . go-mode)))
           ("Config" (or
                     (filename . ".emacs.d")
                     (filename . "dotfiles")))
           ("Web" (or
                  (mode . html-mode)
                  (mode . css-mode)
                  (mode . scss-mode)
                  (mode . web-mode)))
           ("Magit" (name . "^magit"))
           ("Help" (or
                   (mode . help-mode)
                   (mode . Info-mode)
                   (mode . woman-mode)
                   (mode . man-mode)))
           ("System" (name . "^\\*")))))

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
        '((mark modified read-only " "
                (name 20 20 :left :elide)
                " "
                (size-h 9 -1 :right)
                " "
                (mode 16 16 :left :elide)
                " "
                filename-and-process))))

;; Recent files with recentf
(use-package recentf
  :ensure nil
  :init
  (recentf-mode 1)
  :config
  (setq recentf-max-menu-items 25
        recentf-max-saved-items 100
        recentf-exclude '("/tmp/" "/ssh:" "/sudo:" "recentf$" "company-statistics-cache.el$"
                         ".git/" "node_modules/" ".cache/"))

  ;; Save recent files every 5 minutes
  (run-at-time nil (* 5 60) 'recentf-save-list))

;; Enhanced buffer switching
;; =========================

(defun my/kill-other-buffers ()
  "Kill all buffers except current one and important system buffers."
  (interactive)
  (let ((important-buffers '("*scratch*" "*Messages*" "*dashboard*")))
    (when (y-or-n-p "Kill all other buffers except important ones? ")
      (dolist (buffer (buffer-list))
        (unless (or (eq buffer (current-buffer))
                   (member (buffer-name buffer) important-buffers)
                   (string-prefix-p " " (buffer-name buffer))) ; Skip hidden buffers
          (kill-buffer buffer)))
      (message "Killed other buffers"))))

(defun my/kill-all-buffers ()
  "Kill all buffers except *scratch*."
  (interactive)
  (when (y-or-n-p "Kill ALL buffers except *scratch*? ")
    (dolist (buffer (buffer-list))
      (unless (string-equal (buffer-name buffer) "*scratch*")
        (kill-buffer buffer)))
    (switch-to-buffer "*scratch*")
    (message "Killed all buffers except *scratch*")))

(defun my/new-empty-buffer ()
  "Create a new empty buffer."
  (interactive)
  (let ((buffer (generate-new-buffer "untitled")))
    (switch-to-buffer buffer)
    (text-mode)
    (setq buffer-offer-save t)))

(defun my/duplicate-buffer ()
  "Duplicate current buffer."
  (interactive)
  (let ((new-buffer (clone-buffer nil t)))
    (switch-to-buffer new-buffer)))

(defun my/switch-to-previous-buffer ()
  "Switch to the previous buffer."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

(defun my/rename-current-buffer ()
  "Rename current buffer."
  (interactive)
  (let ((new-name (read-string "New buffer name: " (buffer-name))))
    (rename-buffer new-name)))

;; Smart buffer switching
(defun my/smart-switch-buffer ()
  "Smart buffer switching - prefer project buffers if in project."
  (interactive)
  (if (and (projectile-project-p) (featurep 'consult))
      (consult-project-buffer)
    (if (featurep 'consult)
        (consult-buffer)
      (switch-to-buffer (other-buffer)))))

;; Bookmarks enhancement
;; ====================

(use-package bookmark
  :ensure nil
  :config
  (setq bookmark-default-file (expand-file-name "bookmarks" user-emacs-directory)
        bookmark-save-flag 1))

;; Window and frame management
;; ===========================

(defun my/split-window-sensibly ()
  "Split window based on available space and content."
  (interactive)
  (if (> (window-width) 120)
      (split-window-right)
    (split-window-below)))

(defun my/toggle-window-split ()
  "Toggle between horizontal and vertical window split."
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
             (next-win-buffer (window-buffer (next-window)))
             (this-win-edges (window-edges (selected-window)))
             (next-win-edges (window-edges (next-window)))
             (this-win-2nd (not (and (<= (car this-win-edges)
                                        (car next-win-edges))
                                     (<= (cadr this-win-edges)
                                        (cadr next-win-edges)))))
             (splitter
              (if (= (car this-win-edges)
                     (car (window-edges (next-window))))
                  'split-window-horizontally
                'split-window-vertically)))
        (delete-other-windows)
        (let ((first-win (selected-window)))
          (funcall splitter)
          (if this-win-2nd (other-window 1))
          (set-window-buffer (selected-window) this-win-buffer)
          (set-window-buffer (next-window) next-win-buffer)
          (select-window first-win)
          (if this-win-2nd (other-window 1))))))

;; Navigation keybindings
;; =====================

;; Buffer operations
(global-set-key (kbd "C-c b b") #'my/smart-switch-buffer)
(global-set-key (kbd "C-c b r") #'recentf-open-files)
(global-set-key (kbd "C-c b s") #'scratch-buffer)
(global-set-key (kbd "C-c b n") #'my/new-empty-buffer)
(global-set-key (kbd "C-c b d") #'my/duplicate-buffer)
(global-set-key (kbd "C-c b k") #'kill-current-buffer)
(global-set-key (kbd "C-c b K") #'my/kill-other-buffers)
(global-set-key (kbd "C-c b A") #'my/kill-all-buffers)
(global-set-key (kbd "C-c b R") #'my/rename-current-buffer)
(global-set-key (kbd "C-c b l") #'ibuffer)

;; Window operations
(global-set-key (kbd "C-c w d") #'delete-window)
(global-set-key (kbd "C-c w o") #'delete-other-windows)
(global-set-key (kbd "C-c w v") #'split-window-right)
(global-set-key (kbd "C-c w h") #'split-window-below)
(global-set-key (kbd "C-c w 2") #'my/split-window-sensibly)
(global-set-key (kbd "C-c w t") #'my/toggle-window-split)
(global-set-key (kbd "C-c w =") #'balance-windows)

;; Navigation shortcuts
(global-set-key (kbd "s-[") #'my/switch-to-previous-buffer)  ; Command+[
(global-set-key (kbd "s-]") #'next-buffer)                   ; Command+]
(global-set-key (kbd "s-w") #'kill-current-buffer)           ; Command+W
(global-set-key (kbd "s-n") #'my/new-empty-buffer)           ; Command+N

;; Quick window switching with numbers
(use-package winum
  :config
  (winum-mode 1)
  :bind
  (("s-1" . winum-select-window-1)
   ("s-2" . winum-select-window-2)
   ("s-3" . winum-select-window-3)
   ("s-4" . winum-select-window-4)
   ("s-5" . winum-select-window-5)
   ("s-6" . winum-select-window-6)
   ("s-7" . winum-select-window-7)
   ("s-8" . winum-select-window-8)
   ("s-9" . winum-select-window-9)))

;; Bookmarks
(global-set-key (kbd "C-c j m") #'bookmark-set)
(global-set-key (kbd "C-c j j") #'bookmark-jump)
(global-set-key (kbd "C-c j l") #'bookmark-bmenu-list)
(global-set-key (kbd "C-c j d") #'bookmark-delete)

;; Which-key descriptions
;; ======================

(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    ;; Buffer operations
    "C-c b" "Buffer"
    "C-c b b" "Switch Buffer"
    "C-c b r" "Recent Files"
    "C-c b s" "Scratch Buffer"
    "C-c b n" "New Buffer"
    "C-c b d" "Duplicate Buffer"
    "C-c b k" "Kill Buffer"
    "C-c b K" "Kill Other Buffers"
    "C-c b A" "Kill All Buffers"
    "C-c b R" "Rename Buffer"
    "C-c b l" "List Buffers (IBuffer)"

    ;; Window operations
    "C-c w" "Window"
    "C-c w d" "Delete Window"
    "C-c w o" "Delete Other Windows"
    "C-c w v" "Split Vertical"
    "C-c w h" "Split Horizontal"
    "C-c w 2" "Smart Split"
    "C-c w t" "Toggle Split"
    "C-c w =" "Balance Windows"

    ;; Jump/Bookmark operations
    "C-c j" "Jump"
    "C-c j m" "Set Bookmark"
    "C-c j j" "Jump to Bookmark"
    "C-c j l" "List Bookmarks"
    "C-c j d" "Delete Bookmark"

    ;; Global navigation shortcuts
    "s-[" "Previous Buffer"
    "s-]" "Next Buffer"
    "s-w" "Kill Buffer"
    "s-n" "New Buffer"
    "s-o" "Switch Window"
    "s-1" "Window 1"
    "s-2" "Window 2"
    "s-3" "Window 3"
    "s-4" "Window 4"
    "s-5" "Window 5"
    "s-6" "Window 6"
    "s-7" "Window 7"
    "s-8" "Window 8"
    "s-9" "Window 9"))

(provide 'navigation)
;;; navigation.el ends here