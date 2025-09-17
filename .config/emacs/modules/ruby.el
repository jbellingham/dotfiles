;;; ruby.el --- Ruby and Rails development configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Ruby and Ruby on Rails specific configuration and packages.

;;; Code:

;; Ruby mode configuration
(use-package ruby-mode
  :ensure nil
  :mode "\\.rb\\'"
  :mode "Rakefile\\'"
  :mode "Gemfile\\'"
  :mode "Guardfile\\'"
  :mode "\\.rake\\'"
  :mode "\\.gemspec\\'"
  :hook (ruby-mode . (lambda ()
                       (font-lock-mode 1)
                       (font-lock-ensure)))
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
                          (font-lock-mode 1)
                          (font-lock-ensure)))
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

  ;; Handle process errors gracefully
  (defadvice enh-ruby-mode (around handle-process-errors activate)
    "Handle enh-ruby-mode process errors gracefully."
    (condition-case err
        ad-do-it
      (error (progn
               (message "enh-ruby-mode error (falling back to ruby-mode): %s"
                       (error-message-string err))
               (ruby-mode))))))

;; Ruby testing with RSpec
(use-package rspec-mode
  :hook ((ruby-mode enh-ruby-mode) . rspec-mode)
  :config
  (setq rspec-use-rake-when-possible nil
        rspec-use-spring-when-possible nil
        rspec-command-options "--format documentation")
  :bind (:map rspec-mode-map
              ("C-c T v" . rspec-verify)                ; Test verify (current)
              ("C-c T a" . rspec-verify-all)            ; Test all
              ("C-c T s" . rspec-verify-single)         ; Test single
              ("C-c T r" . rspec-rerun)                 ; Test rerun
              ("C-c T t" . rspec-toggle-spec-and-target) ; Test toggle
              ("C-c T e" . rspec-toggle-example)        ; Test example
              ("C-c T f" . rspec-verify-matching)       ; Test find/matching
              ("C-c T c" . rspec-verify-continue))      ; Test continue
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
  :bind-keymap ("C-c r" . projectile-rails-command-map))

;; Ruby REPL integration
(use-package inf-ruby
  :hook (ruby-mode . inf-ruby-minor-mode)
  :config
  (setq inf-ruby-default-implementation "pry")
  :bind (:map ruby-mode-map
              ("C-c C-s" . inf-ruby)
              ("C-c C-c" . ruby-send-region-and-go)
              ("C-c C-x" . ruby-send-definition)
              ("C-c C-r" . ruby-send-region)))

;; Bundler integration
(use-package bundler
  :bind (:map ruby-mode-map
              ("C-c r b i" . bundle-install)    ; Rails Bundle install
              ("C-c r b u" . bundle-update)     ; Rails Bundle update
              ("C-c r b c" . bundle-check)      ; Rails Bundle check
              ("C-c r b e" . bundle-exec))      ; Rails Bundle exec
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
  :hook ((ruby-mode enh-ruby-mode) . company-mode)
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
  :hook ((ruby-mode enh-ruby-mode) . robe-mode)
  :config
  (push 'company-robe company-backends)
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

(provide 'ruby)
;;; ruby.el ends here