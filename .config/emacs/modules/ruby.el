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
  :config
  (setq enh-ruby-indent-level 2
        enh-ruby-hanging-brace-indent-level 2
        enh-ruby-hanging-paren-indent-level 2
        enh-ruby-bounce-deep-indent t
        enh-ruby-hanging-indent-level 2))

;; Ruby testing with RSpec
(use-package rspec-mode
  :hook (ruby-mode . rspec-mode)
  :config
  (setq rspec-use-rake-when-possible nil
        rspec-command-options "--format documentation"))

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
              ("C-c b i" . bundle-install)
              ("C-c b u" . bundle-update)
              ("C-c b c" . bundle-check)
              ("C-c b e" . bundle-exec)))

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

;; Additional Ruby tools
(use-package seeing-is-believing
  :hook ((ruby-mode enh-ruby-mode) . seeing-is-believing)
  :bind (:map ruby-mode-map
              ("C-c ? ?" . seeing-is-believing-run)
              ("C-c ? c" . seeing-is-believing-clear)))

(provide 'ruby)
;;; ruby.el ends here