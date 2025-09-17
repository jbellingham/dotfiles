;;; telescope-new.el --- Clean telescope-like fuzzy finding -*- lexical-binding: t; -*-

;;; Commentary:
;; Telescope-inspired fuzzy finding with clean, mnemonic key bindings.

;;; Code:

;; Vertico - Fast and minimal completion UI (like telescope)
(use-package vertico
  :config
  (vertico-mode 1)
  (setq vertico-cycle t
        vertico-resize t
        vertico-count 20))

;; Orderless - Flexible completion style
(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Marginalia - Rich annotations in minibuffer
(use-package marginalia
  :after vertico
  :config
  (marginalia-mode 1))

;; Consult - Telescope-like commands with live preview
(use-package consult
  :bind (;; File finding - F prefix (Find)
         ("C-c f f" . consult-find)          ; Find files
         ("C-c f r" . consult-recent-file)   ; Recent files
         ("C-c f d" . consult-fd)            ; Find with fd

         ;; Search - S prefix (Search)
         ("C-c s s" . consult-line)          ; Search in buffer
         ("C-c s m" . consult-line-multi)    ; Search in Multiple buffers
         ("C-c s g" . consult-grep)          ; Grep
         ("C-c s r" . consult-ripgrep)       ; Ripgrep (faster)
         ("C-c s l" . consult-locate)        ; Locate files

         ;; Jump/Navigation - J prefix (Jump)
         ("C-c j g" . consult-goto-line)     ; Go to line
         ("C-c j m" . consult-mark)          ; Jump to marks
         ("C-c j M" . consult-global-mark)   ; Global marks
         ("C-c j o" . consult-outline)       ; Outline/headings
         ("C-c j i" . consult-imenu)         ; Imenu (functions)
         ("C-c j I" . consult-imenu-multi)   ; Imenu across buffers

         ;; History - H prefix (History)
         ("C-c h c" . consult-command-history) ; Command history
         ("C-c h k" . consult-kmacro)         ; Macro history
         ("C-c h s" . consult-history)        ; Minibuffer history

         ;; Replace common commands
         ("M-y" . consult-yank-pop)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line))

  :config
  ;; Configure preview
  (setq consult-preview-key '(:debounce 0.2 any)
        consult-narrow-key "<"
        consult-line-numbers-widen t
        consult-async-min-input 2
        consult-async-refresh-delay 0.15
        consult-async-input-throttle 0.2
        consult-async-input-debounce 0.1)

  ;; Configure project root finding
  (setq consult-project-function (lambda (_) (projectile-project-root)))

  ;; Configure ripgrep arguments
  (setq consult-ripgrep-args "rg --null --line-buffered --color=never --max-columns=1000 --path-separator /   --smart-case --no-heading --with-filename --line-number --search-zip"))

;; Embark - Action menu (like telescope actions)
(use-package embark
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim)
         ("C-h B" . embark-bindings))
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Embark Consult integration
(use-package embark-consult
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Consult LSP integration
(use-package consult-lsp
  :after (consult lsp-mode)
  :bind (;; LSP symbols - L prefix (Language)
         ("C-c l s" . consult-lsp-symbols)      ; LSP symbols
         ("C-c l d" . consult-lsp-diagnostics)  ; LSP diagnostics
         ("C-c l f" . consult-lsp-file-symbols) ; File symbols
         ))

;; All the Icons Completion - Icons in completion
(use-package all-the-icons-completion
  :after (marginalia all-the-icons)
  :hook (marginalia-mode . all-the-icons-completion-marginalia-setup)
  :init
  (all-the-icons-completion-mode))

;; Consult Directory - Directory-specific searches
(use-package consult-dir
  :bind (("C-c f D" . consult-dir)           ; Find Directory
         :map vertico-map
         ("C-c f D" . consult-dir)           ; Find Directory
         ("C-c f j" . consult-dir-jump-file))) ; Find Jump file

;; Affe - Asynchronous fuzzy finder (very fast, like telescope)
(use-package affe
  :bind (("C-c a f" . affe-find)   ; Async find
         ("C-c a g" . affe-grep))  ; Async grep
  :config
  ;; Configure to use fd and rg
  (setq affe-find-command "fd --color=never --full-path"
        affe-grep-command "rg --color=never --no-heading --line-number -v ^$"))

;; Projectile integration for better project-wide searches
(use-package projectile
  :bind-keymap ("C-c p" . projectile-command-map)
  :config
  (projectile-mode +1)
  (setq projectile-completion-system 'default
        projectile-enable-caching t
        projectile-indexing-method 'alien))

;; Enhanced project-wide search functions
(defun find-files ()
  "VS Code-like fuzzy file finder with true filename matching."
  (interactive)
  (if (projectile-project-p)
      ;; In project: use projectile for true fuzzy filename matching
      (projectile-find-file)
    ;; Not in project: use consult-find but with better message
    (let ((default-directory (read-directory-name "Find files in: " default-directory)))
      (if (executable-find "fd")
          (consult-fd default-directory)
        (consult-find default-directory)))))

(defun live-grep ()
  "Live grep in current project or directory."
  (interactive)
  (if (projectile-project-p)
      (consult-ripgrep (projectile-project-root))
    (consult-ripgrep default-directory)))

(defun project-buffers ()
  "List project buffers."
  (interactive)
  (if (projectile-project-p)
      (consult-project-buffer)
    (consult-buffer)))

(defun git-files ()
  "Find git files in current project."
  (interactive)
  (if (and (projectile-project-p) (projectile-project-vcs))
      (consult-find (projectile-project-root))
    (consult-find)))

;; Quick access functions with mnemonic names
(global-set-key (kbd "C-c f p") 'find-files)      ; Find in Project
(global-set-key (kbd "C-c s p") 'live-grep)       ; Search in Project
(global-set-key (kbd "C-c b p") 'project-buffers) ; Buffers in Project
(global-set-key (kbd "C-c f g") 'git-files)       ; Git files

;; VS Code-like Command+P fuzzy file finder
(global-set-key (kbd "s-p") 'find-files)          ; Command+P fuzzy find

;; Configure completion for better telescope feel
(setq completion-cycle-threshold 3
      tab-always-indent 'complete
      completion-styles '(orderless basic)
      completion-auto-help nil
      completion-auto-select nil)

;; Enable completion in region
(setq completion-in-region-function
      (lambda (&rest args)
        (apply (if vertico-mode
                   #'consult-completion-in-region
                 #'completion--in-region)
               args)))

(provide 'telescope-new)
;;; telescope-new.el ends here