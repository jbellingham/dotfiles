;;; ruby.el --- Ruby and Rails development configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Ruby and Ruby on Rails specific configuration and packages.

;;; Code:

(require 'cl-lib)

;; Ruby mode configuration (minimal - using enh-ruby-mode as primary)
(use-package ruby-mode
  :ensure nil
  :config
  (setq ruby-indent-level 2
        ruby-indent-tabs-mode nil
        ruby-insert-encoding-magic-comment nil))

;; Enhanced Ruby mode with additional features
(use-package enh-ruby-mode
  :mode "\\.rb\\'"
  :mode "Rakefile\\'"
  :mode "Gemfile\\'"
  :mode "Guardfile\\'"
  :mode "\\.rake\\'"
  :mode "\\.gemspec\\'"
  :hook (enh-ruby-mode . (lambda ()
                          ;; Ensure font-lock is properly initialized
                          (font-lock-mode 1)
                          (font-lock-ensure)
                          ;; Ensure company-mode is available
                          (when (not (bound-and-true-p company-backends))
                            (require 'company nil t)
                            (when (featurep 'company)
                              (setq-local company-backends '(company-capf))))
                          ;; Force refresh syntax highlighting
                          (run-with-timer 0.1 nil
                                        (lambda ()
                                          (when (eq major-mode 'enh-ruby-mode)
                                            (font-lock-fontify-buffer))))))
  :config

  (setq enh-ruby-indent-level 2
        enh-ruby-hanging-brace-indent-level 2
        enh-ruby-hanging-paren-indent-level 2
        enh-ruby-bounce-deep-indent t
        enh-ruby-hanging-indent-level 2
        ;; Fix for "Unprintable entity" errors
        enh-ruby-deep-indent-paren nil
        enh-ruby-deep-indent-construct nil)

  ;; Configure process communication for large projects
  (when (fboundp 'enh-ruby-mode)
    (add-hook 'enh-ruby-mode-hook
              (lambda ()
                ;; Set proper encoding for process communication
                (setq process-connection-type nil)
                ;; Increase process output buffer for large files
                (setq-local read-process-output-max (* 4 1024 1024))))) ; 4MB buffer

  ;; Handle process errors gracefully - simplified version
  (defadvice enh-ruby-mode (around handle-process-errors activate)
    "Handle enh-ruby-mode process errors gracefully."
    (condition-case err
        ad-do-it
      (error (message "enh-ruby-mode error: %s (continuing anyway)"
                     (error-message-string err))))))

;; Helper function to find Rails application root from engine
(defun my/find-rails-root-from-engine ()
  "Find the Rails application root when inside an engine."
  (let ((current-dir (or (buffer-file-name) default-directory)))
    (when current-dir
      (let ((dir (file-name-directory current-dir))
            (found-root nil))
        ;; Look for engines/ directory and go up to find the Rails root
        (while (and dir (not (string= dir "/")) (not found-root))
          (cond
           ;; If we're in an engines/ subdirectory, go up to find the Rails root
           ((string-match "/engines/[^/]+/" dir)
            (let ((potential-root (replace-regexp-in-string "/engines/[^/]+/.*" "" dir)))
              (when (and (file-exists-p (concat potential-root "/Gemfile"))
                         (file-exists-p (concat potential-root "/config/application.rb")))
                (setq found-root potential-root))))
           ;; Standard Rails root detection
           ((and (file-exists-p (concat dir "Gemfile"))
                 (file-exists-p (concat dir "config/application.rb")))
            (setq found-root dir))
           ;; Go up one directory
           (t (setq dir (file-name-directory (directory-file-name dir))))))
        ;; Return found root or original directory
        (or found-root (file-name-directory current-dir))))))

;; Ruby testing with RSpec
(use-package rspec-mode
  :hook ((ruby-mode enh-ruby-mode) . rspec-mode)
  :config
  (setq rspec-use-rake-when-possible nil
        rspec-use-spring-when-possible nil
        rspec-command-options "--format documentation"
        ;; Auto-focus the test output window
        rspec-compilation-buffer-window-auto-pop nil) ; We'll handle this ourselves

  ;; Custom variable to control auto-focus behavior
  (defcustom my/rspec-auto-focus-output t
    "Whether to automatically focus the RSpec output window when running tests."
    :type 'boolean
    :group 'rspec-mode)

  ;; Override rspec-project-root to handle Rails engines
  (defun rspec-project-root (&optional directory)
    "Find the root directory of the project, handling Rails engines.
For Rails engines, find the parent Rails application root."
    (let ((directory (file-name-as-directory (or directory default-directory))))
      (or (my/find-rails-root-from-engine)
          ;; Fall back to original logic
          (let ((dir directory)
                (found-root nil))
            (while (and dir (not (string= dir "/")) (not found-root))
              (cond ((or (file-regular-p (expand-file-name "Rakefile" dir))
                         (file-regular-p (expand-file-name "Gemfile" dir))
                         (file-regular-p (expand-file-name "Berksfile" dir)))
                     (setq found-root (expand-file-name dir)))
                    (t (setq dir (file-name-directory (directory-file-name dir))))))
            (or found-root (error "Could not determine the project root."))))))

  ;; Configure RSpec compilation buffer display (without auto-select to avoid conflicts)
  (add-to-list 'display-buffer-alist
               '("\\*rspec-compilation\\*"
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 (window-height . 0.3)
                 (reusable-frames . nil)))

  ;; Auto-focus approach: Advice the rspec commands to focus output after running
  (defun my/rspec-auto-focus-after-run (orig-fun &rest args)
    "Advice to auto-focus RSpec compilation buffer after running tests."
    (let ((result (apply orig-fun args)))
      ;; Only auto-focus if the setting is enabled
      (when my/rspec-auto-focus-output
        ;; Give the compilation buffer time to appear, then focus it
        (run-with-timer 0.2 nil
                        (lambda ()
                          (let ((rspec-buffer (get-buffer "*rspec-compilation*")))
                            (when rspec-buffer
                              (let ((rspec-window (get-buffer-window rspec-buffer)))
                                (when rspec-window
                                  (select-window rspec-window))))))))
      result))

  ;; Apply advice to main RSpec commands
  (advice-add 'rspec-verify :around #'my/rspec-auto-focus-after-run)
  (advice-add 'rspec-verify-all :around #'my/rspec-auto-focus-after-run)
  (advice-add 'rspec-verify-single :around #'my/rspec-auto-focus-after-run)
  (advice-add 'rspec-rerun :around #'my/rspec-auto-focus-after-run)
  (advice-add 'rspec-verify-matching :around #'my/rspec-auto-focus-after-run)
  (advice-add 'rspec-verify-continue :around #'my/rspec-auto-focus-after-run)

  ;; Function to toggle auto-focus behavior
  (defun my/rspec-toggle-auto-focus ()
    "Toggle automatic focusing of RSpec output window."
    (interactive)
    (setq my/rspec-auto-focus-output (not my/rspec-auto-focus-output))
    (message "RSpec auto-focus: %s" (if my/rspec-auto-focus-output "enabled" "disabled")))

  ;; Helper function to toggle between test and output
  (defun my/rspec-toggle-test-output ()
    "Toggle between the test file and RSpec output buffer."
    (interactive)
    (let ((rspec-buffer (get-buffer "*rspec-compilation*"))
          (current-buffer (current-buffer)))
      (cond
       ;; If we're in the RSpec buffer, go back to the last test file
       ((and rspec-buffer (eq current-buffer rspec-buffer))
        (let ((test-window (get-buffer-window (other-buffer rspec-buffer t))))
          (if test-window
              (select-window test-window)
            (switch-to-buffer (other-buffer rspec-buffer t)))))
       ;; If RSpec buffer exists, switch to it
       (rspec-buffer
        (let ((rspec-window (get-buffer-window rspec-buffer)))
          (if rspec-window
              (select-window rspec-window)
            (pop-to-buffer rspec-buffer))))
       ;; No RSpec buffer, inform user
       (t (message "No RSpec output buffer found")))))

  :bind (:map rspec-mode-map
              ("C-c T v" . rspec-verify)                ; Test verify (current)
              ("C-c T a" . rspec-verify-all)            ; Test all
              ("C-c T s" . rspec-verify-single)         ; Test single
              ("C-c T r" . rspec-rerun)                 ; Test rerun
              ("C-c T t" . rspec-toggle-spec-and-target) ; Test toggle
              ("C-c T e" . rspec-toggle-example)        ; Test example
              ("C-c T f" . rspec-verify-matching)       ; Test find/matching
              ("C-c T c" . rspec-verify-continue)       ; Test continue
              ("C-c T o" . my/rspec-toggle-test-output) ; Toggle test/output
              ("C-c T F" . my/rspec-toggle-auto-focus)) ; Toggle auto-focus
  )

;; Ruby refactoring tools
(use-package ruby-refactor
  :hook (ruby-mode . ruby-refactor-mode-launch))

;; Rubocop integration
(use-package rubocop
  :hook (ruby-mode . rubocop-mode)
  :config
  (setq rubocop-check-command "rubocop --format emacs")
  :bind (:map ruby-mode-map
              ("C-c C-r a" . rubocop-check-project)
              ("C-c C-r d" . rubocop-check-directory)
              ("C-c C-r f" . rubocop-check-current-file)
              ("C-c C-r F" . rubocop-autocorrect-current-file)
              ("C-c C-r P" . rubocop-autocorrect-project)))

;; YAML support for Rails configs
(use-package yaml-mode
  :mode "\\.ya?ml\\'"
  :config
  (setq yaml-indent-offset 2))

;; ERB template support
(use-package web-mode
  :mode "\\.erb\\'"
  :mode "\\.html\\.erb\\'"
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2
        web-mode-enable-auto-pairing t
        web-mode-enable-auto-expanding t
        web-mode-enable-css-colorization t))

;; Haml support
(use-package haml-mode
  :mode "\\.haml\\'")

;; Slim template support
(use-package slim-mode
  :mode "\\.slim\\'")

;; Rails-specific enhancements
(use-package projectile-rails
  :after projectile
  :hook (projectile-mode . projectile-rails-global-mode)
  :config
  (setq projectile-rails-expand-snippet nil)
  :bind-keymap ("C-c R" . projectile-rails-command-map))

;; Ruby REPL integration
(use-package inf-ruby
  :hook (ruby-mode . inf-ruby-minor-mode)
  :config
  (setq inf-ruby-default-implementation "pry")
  :bind (:map ruby-mode-map
              ("C-c R s" . inf-ruby)
              ("C-c R c" . ruby-send-region-and-go)
              ("C-c R x" . ruby-send-definition)
              ("C-c R r" . ruby-send-region)))

;; Bundler integration
(use-package bundler
  :bind (:map ruby-mode-map
              ("C-c R b i" . bundle-install)    ; Rails Bundle install
              ("C-c R b u" . bundle-update)     ; Rails Bundle update
              ("C-c R b c" . bundle-check)      ; Rails Bundle check
              ("C-c R b e" . bundle-exec))      ; Rails Bundle exec
  )

;; Ruby hash syntax conversion
(use-package ruby-hash-syntax
  :bind (:map ruby-mode-map
              ("C-c h t" . ruby-hash-syntax-toggle)))

;; Minitest support
(use-package minitest
  :hook ((ruby-mode enh-ruby-mode) . minitest-mode)
  :config
  (setq minitest-use-rails t))

;; Ruby documentation lookup
(use-package yari
  :bind (:map ruby-mode-map
              ("C-c C-h" . yari)))

;; Ruby end block completion
(use-package ruby-end
  :hook ((ruby-mode enh-ruby-mode) . ruby-end-mode))

;; Aggressive autocomplete for Ruby
(use-package company
  :demand t  ; Force loading immediately
  :hook ((ruby-mode enh-ruby-mode) . company-mode)
  :init
  ;; Initialize company-backends before any modes try to use it
  (setq company-backends '(company-capf))
  :config
  (setq company-idle-delay 0.1              ; Show completions quickly
        company-minimum-prefix-length 1     ; Show after 1 character
        company-show-numbers t               ; Number completions
        company-tooltip-align-annotations t
        company-require-match nil)
  :bind (:map company-active-map
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous)
              ("TAB" . company-complete-selection)
              ("<tab>" . company-complete-selection)))

;; Ruby-specific completion backend
(use-package robe
  :after company
  :hook ((ruby-mode enh-ruby-mode) . robe-mode)
  :config
  (when (bound-and-true-p company-backends)
    (add-to-list 'company-backends 'company-robe))
  ;; Start robe server automatically
  (defadvice inf-ruby-console-auto (before activate-rvm-for-robe activate)
    (rvm-activate-corresponding-ruby)))

;; Better Ruby method/class completion
(use-package ac-inf-ruby
  :after inf-ruby
  :hook ((ruby-mode enh-ruby-mode) . ac-inf-ruby-enable))

;; Snippet support for LSP
(use-package yasnippet
  :hook ((ruby-mode enh-ruby-mode) . yas-minor-mode)
  :config
  (yas-reload-all))

;; Ensure global font-lock is enabled
(global-font-lock-mode 1)

;; LSP for Ruby (requires solargraph gem)
(use-package lsp-mode
  :hook ((ruby-mode enh-ruby-mode) . lsp-deferred)
  :config
  (setq lsp-solargraph-use-bundler nil      ; Use global gem, not bundle
        lsp-completion-provider :capf
        lsp-enable-snippet t
        lsp-solargraph-server-command '("solargraph" "stdio")
        lsp-semantic-tokens-enable nil      ; Disable semantic tokens to preserve syntax highlighting
        lsp-enable-symbol-highlighting nil  ; Disable symbol highlighting
        ;; Speed optimizations without disabling features
        lsp-idle-delay 0.3                  ; Faster response time
        lsp-completion-show-detail t         ; Keep detailed info but make it faster
        lsp-completion-show-kind t           ; Keep kind icons
        lsp-eldoc-render-all t               ; Show full docs on hover
        lsp-signature-render-documentation t ; Show signature documentation
        lsp-completion-filter-on-incomplete t ; Filter as you type
        lsp-enable-completion-at-point t     ; Better integration with company
        lsp-response-timeout 10              ; 10 second timeout for requests
        lsp-modeline-code-actions-enable t   ; Show code actions in modeline
        lsp-modeline-diagnostics-enable t    ; Show diagnostics in modeline
        lsp-enable-file-watchers nil         ; Disable file watching for speed
        lsp-enable-folding nil               ; Disable folding for speed
        lsp-enable-links nil)                ; Disable links for speed

  ;; Fix for font-lock being disabled after LSP starts
  (add-hook 'lsp-after-open-hook
            (lambda ()
              (when (derived-mode-p 'ruby-mode 'enh-ruby-mode)
                (font-lock-mode 1)
                (font-lock-ensure))))

  ;; Additional font-lock fixes
  (add-hook 'lsp-mode-hook
            (lambda ()
              (when (derived-mode-p 'enh-ruby-mode)
                ;; Force font-lock to stay enabled
                (font-lock-mode 1)
                (setq-local font-lock-support-mode 'jit-lock-mode)
                (jit-lock-mode 1))))
  :commands (lsp lsp-deferred)
  :bind (:map lsp-mode-map
              ("M-." . lsp-find-definition)        ; Go to definition
              ("M-?" . lsp-find-references)        ; Find references
              ("M-," . pop-tag-mark)               ; Go back
              ("C-c l r" . lsp-rename)             ; Rename symbol
              ("C-c l a" . lsp-execute-code-action) ; Code actions
              ("C-c l f" . lsp-format-buffer)      ; Format buffer
              ("C-c l d" . lsp-describe-thing-at-point) ; Show docs
              ("C-c l i" . lsp-find-implementation) ; Find implementation
              ("C-c l t" . lsp-find-type-definition) ; Find type definition
              ("C-c l s" . lsp-workspace-symbol)   ; Search workspace symbols
              ("C-c l h" . lsp-symbol-highlight))) ; Highlight symbol


;; LSP UI improvements
(use-package lsp-ui
  :after lsp-mode
  :config
  (setq lsp-ui-doc-enable nil          ; Disable popup docs (can be slow)
        lsp-ui-sideline-enable t       ; Show hints in sideline
        lsp-ui-flycheck-enable t))

;; Additional Ruby tools
(use-package seeing-is-believing
  :hook ((ruby-mode enh-ruby-mode) . seeing-is-believing)
  :bind (:map ruby-mode-map
              ("C-c ? ?" . seeing-is-believing-run)
              ("C-c ? c" . seeing-is-believing-clear)))

;; Rubocop integration
(use-package rubocop
  :hook ((ruby-mode enh-ruby-mode) . rubocop-mode)
  :bind (:map ruby-mode-map
              ("C-c R a" . rubocop-check-project)
              ("C-c R d" . rubocop-check-directory)
              ("C-c R f" . rubocop-check-current-file)
              ("C-c R F" . rubocop-autocorrect-current-file)
              ("C-c R P" . rubocop-autocorrect-project)))

;; Bundler integration (using C-c R B prefix to avoid conflict with rails jobs)
(use-package bundler
  :bind (:map ruby-mode-map
              ("C-c R B i" . bundle-install)
              ("C-c R B u" . bundle-update)
              ("C-c R B c" . bundle-check)
              ("C-c R B e" . bundle-exec)))

;; YARI - Ruby documentation lookup
(use-package yari
  :bind (:map ruby-mode-map
              ("C-c R h" . yari)))

;; Ruby hash syntax toggle function
(defun ruby-hash-syntax-toggle ()
  "Toggle between old-style and new-style Ruby hash syntax."
  (interactive)
  (save-excursion
    (let ((start (if (region-active-p) (region-beginning) (point-min)))
          (end (if (region-active-p) (region-end) (point-max))))
      (goto-char start)
      (if (search-forward "=>" end t)
          ;; Convert old style to new style
          (progn
            (goto-char start)
            (while (re-search-forward ":\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*=>" end t)
              (replace-match "\\1:" nil nil)))
        ;; Convert new style to old style
        (goto-char start)
        (while (re-search-forward "\\([a-zA-Z_][a-zA-Z0-9_]*\\):" end t)
          (replace-match ":\\1 =>" nil nil)))))
  (message "Hash syntax toggled"))

;; Ruby REPL integration
(use-package inf-ruby
  :hook ((ruby-mode enh-ruby-mode) . inf-ruby-minor-mode)
  :bind (:map ruby-mode-map
              ("C-c R s" . inf-ruby)
              ("C-c R c" . ruby-send-region-and-go)
              ("C-c R x" . ruby-send-definition)
              ("C-c R r" . ruby-send-region)))

;; Ruby utilities keybinding
(global-set-key (kbd "C-c h t") 'ruby-hash-syntax-toggle)

;; Debug function to test Rails engine detection
(defun my/debug-rspec-root ()
  "Debug function to show what directory RSpec will use."
  (interactive)
  (if (fboundp 'rspec-project-root)
      (let ((root (rspec-project-root)))
        (message "RSpec will run from: %s" root)
        root)
    (message "rspec-project-root function not available")))

(global-set-key (kbd "C-c T d") 'my/debug-rspec-root)

;; Which-key descriptions for Ruby development
(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    ;; Ruby REPL operations
    "C-c R s" "Start Ruby REPL"
    "C-c R c" "Send Region & Go"
    "C-c R x" "Send Definition"
    "C-c R r" "Send Region"

    ;; Rubocop code quality
    "C-c R" "Rubocop"
    "C-c R a" "Check Project"
    "C-c R d" "Check Directory"
    "C-c R f" "Check File"
    "C-c R F" "Auto-correct File"
    "C-c R P" "Auto-correct Project"

    ;; Rails file navigation
    "C-c R" "Rails"
    "C-c R m" "Find Model"
    "C-c R c" "Find Controller"
    "C-c R v" "Find View"
    "C-c R j" "Find JavaScript"
    "C-c R s" "Find Stylesheet"
    "C-c R h" "Find Helper"
    "C-c R p" "Find Spec"
    "C-c R t" "Find Test"
    "C-c R n" "Find Migration"
    "C-c R u" "Find Fixture"
    "C-c R w" "Find Component"
    "C-c R l" "Find Lib"
    "C-c R f" "Find Feature"
    "C-c R i" "Find Initializer"
    "C-c R o" "Find Log"
    "C-c R e" "Find Environment"
    "C-c R a" "Find Locale"
    "C-c R @" "Find Mailer"
    "C-c R !" "Find Validator"
    "C-c R y" "Find Layout"
    "C-c R k" "Find Rake Task"
    "C-c R b" "Find Job"
    "C-c R z" "Find Serializer"
    "C-c R x" "Extract Region"
    "C-c R g" "Goto Map"
    "C-c R !" "Run Map"

    ;; Rails goto operations (C-c R g)
    "C-c R g" "Rails Goto"
    "C-c R g f" "Goto File at Point"
    "C-c R g g" "Goto Gemfile"
    "C-c R g r" "Goto Routes"
    "C-c R g d" "Goto Schema"
    "C-c R g s" "Goto Seeds"
    "C-c R g h" "Goto Spec Helper"
    "C-c R g p" "Goto Package"

    ;; Rails run operations (C-c R !)
    "C-c R !" "Rails Run"
    "C-c R ! c" "Rails Console"
    "C-c R ! s" "Rails Server"
    "C-c R ! r" "Rails Rake"
    "C-c R ! g" "Rails Generate"
    "C-c R ! d" "Rails Destroy"
    "C-c R ! b" "Rails DB Console"

    ;; Bundler operations (C-c R B)
    "C-c R B" "Bundler"
    "C-c R B i" "Bundle Install"
    "C-c R B u" "Bundle Update"
    "C-c R B c" "Bundle Check"
    "C-c R B e" "Bundle Exec"

    ;; RSpec testing
    "C-c T" "RSpec"
    "C-c T v" "Verify Test"
    "C-c T s" "Verify Single"
    "C-c T a" "Verify All"
    "C-c T r" "Rerun Test"
    "C-c T t" "Toggle Spec/Impl"
    "C-c T e" "Toggle Example"
    "C-c T f" "Verify Matching"
    "C-c T c" "Continue from Failure"
    "C-c T d" "Debug RSpec Root"
    "C-c T o" "Toggle Test/Output"
    "C-c T F" "Toggle Auto-Focus"

    ;; Ruby utilities
    "C-c R h" "Ruby Documentation"
    "C-c h t" "Toggle Hash Syntax"
    "C-c ? ?" "Execute with Annotations"
    "C-c ? c" "Clear Annotations"

    ;; LSP Ruby operations
    "C-c l" "LSP"
    "C-c l r" "Rename Symbol"
    "C-c l a" "Code Actions"
    "C-c l f" "Format Buffer"
    "C-c l d" "Show Documentation"
    "C-c l i" "Find Implementation"
    "C-c l t" "Find Type Definition"
    "C-c l s" "Search Symbols"
    "C-c l h" "Highlight Symbol"))

(provide 'ruby)
;;; ruby.el ends here