;; Evil Mode Configuration


;;; evil.el --- Vim emulation configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Comprehensive Vim emulation using evil-mode with evil-collection for
;; package integrations. Maintains compatibility with existing keybindings.

;;; Code:

;; Core evil-mode
(use-package evil
  :ensure t
  :init
  ;; Pre-load configuration
  (setq evil-want-integration t       ; Load evil-integration
        evil-want-keybinding nil      ; Disable default keybindings (evil-collection handles this)
        evil-want-C-u-scroll t        ; Use C-u for scrolling up
        evil-want-C-i-jump t          ; Use C-i for jump forward
        evil-want-Y-yank-to-eol t     ; Make Y behave like D and C
        evil-respect-visual-line-mode t ; Respect visual-line-mode
        evil-undo-system 'undo-redo)  ; Use built-in undo-redo system
  :config
  (evil-mode 1)

  ;; Configure evil states
  (setq evil-insert-state-cursor '(bar . 2)
        evil-normal-state-cursor '(box . 2)
        evil-visual-state-cursor '(hollow . 2)
        evil-replace-state-cursor '(hbar . 2)
        evil-operator-state-cursor '(evil-half-cursor . 2))

  ;; Keep some Emacs bindings in insert mode
  (define-key evil-insert-state-map (kbd "C-a") 'beginning-of-line)
  (define-key evil-insert-state-map (kbd "C-e") 'end-of-line)
  (define-key evil-insert-state-map (kbd "C-k") 'kill-line)
  (define-key evil-insert-state-map (kbd "C-d") 'delete-char)
  (define-key evil-insert-state-map (kbd "C-n") 'next-line)
  (define-key evil-insert-state-map (kbd "C-p") 'previous-line)

  ;; Keep our custom C-c bindings in all states
  (define-key evil-normal-state-map (kbd "C-c") nil)
  (define-key evil-insert-state-map (kbd "C-c") nil)
  (define-key evil-visual-state-map (kbd "C-c") nil)
  (define-key evil-motion-state-map (kbd "C-c") nil)

  ;; Resolve C-z conflict - evil will use C-z for suspend/switch states
  ;; Our focus-mode-toggle moves to C-c f z to maintain mnemonic pattern

  ;; Use standard evil leader key for additional vim-style bindings
  (evil-set-leader '(normal visual) (kbd "SPC"))

  ;; Some useful leader bindings that complement our C-c system
  (evil-define-key '(normal visual) 'global
    ;; Config management (migrated from C-c c)
    (kbd "<leader>cr") 'reload-config
    (kbd "<leader>ce") 'open-config
    (kbd "<leader>cc") 'claude-code
    (kbd "<leader>ct") 'claude-code-terminal
    (kbd "<leader>ck") 'show-command-keybindings
    (kbd "<leader>ch") 'open-emacs-reference
    ;; Project and file operations (migrated from C-c f/s/p)
    (kbd "<leader>ff") 'my/find-project-files    ; was C-c f p
    (kbd "<leader>fg") 'my/find-git-files        ; was C-c f g
    ;; Search operations (migrated from C-c s)
    (kbd "<leader>ss") 'consult-line             ; was C-c s s
    (kbd "<leader>sm") 'consult-line-multi       ; was C-c s m
    (kbd "<leader>sg") 'consult-grep             ; was C-c s g
    (kbd "<leader>sr") 'consult-ripgrep          ; was C-c s r
    (kbd "<leader>sl") 'consult-locate           ; was C-c s l
    (kbd "<leader>sp") 'my/search-project        ; was C-c s p
    ;; Buffer management (migrated from C-c b)
    (kbd "<leader>bb") 'my/smart-switch-buffer   ; was C-c b b
    (kbd "<leader>bp") 'my/project-buffers       ; was C-c b p
    (kbd "<leader>br") 'recentf-open-files       ; was C-c b r
    (kbd "<leader>bs") 'scratch-buffer           ; was C-c b s
    (kbd "<leader>bn") 'my/new-empty-buffer      ; was C-c b n
    (kbd "<leader>bd") 'my/duplicate-buffer      ; was C-c b d
    (kbd "<leader>bk") 'kill-current-buffer      ; was C-c b k
    (kbd "<leader>bK") 'my/kill-other-buffers    ; was C-c b K
    (kbd "<leader>bA") 'my/kill-all-buffers      ; was C-c b A
    (kbd "<leader>bR") 'my/rename-current-buffer ; was C-c b R
    (kbd "<leader>bl") 'ibuffer                  ; was C-c b l
    ;; Navigation (migrated from C-c g)
    (kbd "<leader>gi") 'my/find-implementation   ; was C-c g i
    (kbd "<leader>gt") 'my/goto-test             ; was C-c g t
    (kbd "<leader>gT") 'my/toggle-between-implementation-and-test ; was C-c g T
    (kbd "<leader>gg") 'magit-status
    ;; Window/Workspace management (migrated from C-c w/S)
    (kbd "<leader>wc") 'my/create-workspace         ; was C-c w c
    (kbd "<leader>wP") 'my/workspace-for-project   ; was C-c w P
    (kbd "<leader>wd") 'delete-window              ; was C-c w d
    (kbd "<leader>wv") 'split-window-right         ; was C-c w v
    (kbd "<leader>wh") 'split-window-below         ; was C-c w h
    (kbd "<leader>wm") 'delete-other-windows       ; was C-c w m
    (kbd "<leader>wo") 'other-window               ; was C-c w o
    (kbd "<leader>wu") 'winner-undo                ; was C-c w u
    (kbd "<leader>wU") 'winner-redo                ; was C-c w U
    (kbd "<leader>w2") 'my/split-window-sensibly   ; was C-c w 2
    (kbd "<leader>wK") 'my/kill-other-buffers      ; was C-c w K
    (kbd "<leader>ws") 'my/save-session            ; was C-c S s
    (kbd "<leader>wr") 'my/restore-session         ; was C-c S r
    ;; Focus/Zen mode (migrated from C-c f)
    (kbd "<leader>zz") 'my/focus-mode-toggle       ; was C-c f f/z
    (kbd "<leader>zs") 'my/focus-mode-status       ; was C-c f s
    (kbd "<leader>z+") 'my/focus-mode-increase-width ; was C-c f +
    (kbd "<leader>z-") 'my/focus-mode-decrease-width ; was C-c f -
    (kbd "<leader>z1") 'my/focus-mode-narrow       ; was C-c f 1
    (kbd "<leader>z2") 'my/focus-mode-medium       ; was C-c f 2
    (kbd "<leader>z3") 'my/focus-mode-wide         ; was C-c f 3
    (kbd "<leader>z4") 'my/focus-mode-ultrawide    ; was C-c f 4
    ;; Bookmarks (migrated from C-c j)
    (kbd "<leader>jm") 'bookmark-set               ; was C-c j m
    (kbd "<leader>jj") 'bookmark-jump              ; was C-c j j
    (kbd "<leader>jl") 'bookmark-bmenu-list        ; was C-c j l
    (kbd "<leader>jd") 'bookmark-delete            ; was C-c j d
    (kbd "<leader>pp") 'projectile-switch-project
    (kbd "<leader>tt") 'my/toggle-between-implementation-and-test
    ;; Ruby/Rails development (migrated from C-c r/T/R)
    (kbd "<leader>rr") 'rubocop-check-current-file   ; was C-c r f
    (kbd "<leader>rp") 'rubocop-check-project        ; was C-c r a
    (kbd "<leader>rd") 'rubocop-check-directory      ; was C-c r d
    (kbd "<leader>rf") 'rubocop-autocorrect-current-file ; was C-c r F
    (kbd "<leader>rF") 'rubocop-autocorrect-project  ; was C-c r P
    ;; RSpec testing (migrated from C-c T)
    (kbd "<leader>tr") 'rspec-verify                 ; was C-c T v
    (kbd "<leader>ta") 'rspec-verify-all             ; was C-c T a
    (kbd "<leader>ts") 'rspec-verify-single          ; was C-c T s
    (kbd "<leader>tR") 'rspec-rerun                  ; was C-c T r
    (kbd "<leader>tt") 'rspec-toggle-spec-and-target ; was C-c T t (override previous)
    (kbd "<leader>te") 'rspec-toggle-example         ; was C-c T e
    (kbd "<leader>tf") 'rspec-verify-matching        ; was C-c T f
    (kbd "<leader>tc") 'rspec-verify-continue        ; was C-c T c
    ;; Search and Replace operations
    (kbd "<leader>Rr") 'my/search-and-replace-in-buffer      ; Replace in buffer (Ctrl+H style)
    (kbd "<leader>RR") 'my/search-and-replace-regex-in-buffer ; Regex replace in buffer
    (kbd "<leader>Rp") 'my/search-and-replace-in-project     ; Project-wide replace
    ;; Bundler/Rails (migrated from C-c R)
    (kbd "<leader>rbi") 'bundle-install              ; was C-c R b i
    (kbd "<leader>rbu") 'bundle-update               ; was C-c R b u
    (kbd "<leader>rbc") 'bundle-check                ; was C-c R b c
    (kbd "<leader>rbe") 'bundle-exec)                ; was C-c R b e

;; Evil collection for package integrations
(use-package evil-collection
  :ensure t
  :after evil
  :config
  ;; Only enable safe, well-supported modes to avoid loading errors
  (setq evil-collection-mode-list
        '(bookmark
          buff-menu
          calc
          calendar
          compile
          consult
          dired
          ediff
          embark
          git-timemachine
          help
          ibuffer
          info
          log-edit
          magit
          man
          outline
          replace
          simple
          tab-bar
          tabulated-list
          term
          vertico
          which-key
          woman))
  (evil-collection-init)

  ;; Manual integration for problematic packages
  ;; Treemacs integration (if available)
  (with-eval-after-load 'treemacs
    (when (fboundp 'evil-define-key)
      (evil-define-key 'normal treemacs-mode-map
        (kbd "h") 'treemacs-collapse-parent-node
        (kbd "l") 'treemacs-expand-or-open
        (kbd "j") 'treemacs-next-line
        (kbd "k") 'treemacs-previous-line
        (kbd "r") 'treemacs-refresh
        (kbd "R") 'treemacs-refresh
        (kbd "q") 'treemacs-quit)))

  ;; Projectile integration (if needed)
  (with-eval-after-load 'projectile
    ;; Projectile works fine with evil without special integration
    ;; Just ensure SPC bindings work in projectile buffers
    (evil-define-key '(normal visual) projectile-mode-map
      (kbd "<leader>pp") 'projectile-switch-project
      (kbd "<leader>pf") 'projectile-find-file)))

;; Evil commentary for commenting
(use-package evil-commentary
  :ensure t
  :after evil
  :config
  (evil-commentary-mode 1))

;; Evil surround for surrounding text objects
(use-package evil-surround
  :ensure t
  :after evil
  :config
  (global-evil-surround-mode 1))

;; Evil matchit for enhanced % matching
(use-package evil-matchit
  :ensure t
  :after evil
  :config
  (global-evil-matchit-mode 1))

;; Evil indent textobject
(use-package evil-indent-plus
  :ensure t
  :after evil
  :config
  (evil-indent-plus-default-bindings))

;; Evil multiple cursors (VS Code-like multi-cursor)
(use-package evil-mc
  :ensure t
  :after evil
  :config
  (global-evil-mc-mode 1)

  ;; VS Code-like keybindings for multi-cursor
  (evil-define-key 'normal 'global
    (kbd "C-d") 'evil-mc-make-and-goto-next-match      ; VS Code Ctrl+D
    (kbd "C-S-d") 'evil-mc-make-and-goto-prev-match    ; VS Code Ctrl+Shift+D
    (kbd "C-S-l") 'evil-mc-make-all-cursors            ; VS Code Ctrl+Shift+L (select all)
    (kbd "C-M-d") 'evil-mc-undo-last-added-cursor     ; Undo last cursor
    (kbd "C-g") 'evil-mc-undo-all-cursors)            ; Clear all cursors (C-g is standard cancel)

  ;; Additional SPC bindings for multi-cursor
  (evil-define-key '(normal visual) 'global
    (kbd "<leader>ms") 'evil-mc-skip-and-goto-next-match     ; Skip current, select next
    (kbd "<leader>mu") 'evil-mc-undo-last-added-cursor      ; Undo last cursor
    (kbd "<leader>mq") 'evil-mc-undo-all-cursors)           ; Quit multi-cursor

  ;; Additional Evil multi-cursor bindings with SPC prefix
  (with-eval-after-load 'which-key
    (which-key-add-key-based-replacements
      "SPC m" "Multi-cursor"
      "SPC m n" "Next Match"
      "SPC m p" "Previous Match"
      "SPC m a" "All Matches"
      "SPC m s" "Skip Next"
      "SPC m u" "Undo Last"
      "SPC m q" "Quit Multi-cursor")))

;; Multiple cursors alternative (iedit for in-place editing)
(use-package iedit
  :ensure t
  :config
  ;; Bind iedit to a convenient key
  (global-set-key (kbd "C-c ;") 'iedit-mode)

  ;; SPC leader binding for iedit
  (with-eval-after-load 'which-key
    (which-key-add-key-based-replacements
      "SPC e" "Edit"
      "SPC e e" "Iedit Mode")))

;; Evil org-mode integration
(use-package evil-org
  :ensure t
  :after (evil org)
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys)

  ;; Ensure TAB works for folding in org-mode
  (evil-define-key 'normal org-mode-map
    (kbd "TAB") 'org-cycle
    (kbd "S-TAB") 'org-shifttab
    (kbd "<tab>") 'org-cycle
    (kbd "<S-tab>") 'org-shifttab)

  ;; Fix company-mode TAB conflict in org-mode specifically
  (with-eval-after-load 'company
    (add-hook 'org-mode-hook
              (lambda ()
                ;; In org-mode, prioritize org-cycle over company completion
                (setq-local company-idle-delay nil)  ; Disable auto-completion
                (define-key evil-normal-state-local-map (kbd "TAB") 'org-cycle)
                (define-key evil-insert-state-local-map (kbd "TAB") 'org-cycle))))))

;; Additional org-mode Evil integration
(with-eval-after-load 'org
  ;; Make sure org-cycle works in normal mode
  (evil-define-key 'normal org-mode-map
    (kbd "TAB") 'org-cycle
    (kbd "S-TAB") 'org-shifttab)

  ;; Ensure insert mode TAB works for indentation when needed
  (evil-define-key 'insert org-mode-map
    (kbd "TAB") 'org-cycle))

(provide 'evil)
;;; evil.el ends here
