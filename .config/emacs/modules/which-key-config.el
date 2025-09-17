;;; which-key-config.el --- Which-key descriptions for all keybindings -*- lexical-binding: t; -*-

;;; Commentary:
;; Human-readable descriptions for all keybindings to make Emacs more discoverable.

;;; Code:

;; Which-key descriptions for all Ruby and Rails bindings
(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    ;; LSP bindings
    "C-c l" "LSP"
    "C-c l r" "Rename Symbol"
    "C-c l a" "Code Actions"
    "C-c l f" "Format Buffer"
    "C-c l d" "Show Documentation"
    "C-c l i" "Find Implementation"
    "C-c l t" "Find Type Definition"
    "C-c l s" "Search Symbols"
    "C-c l h" "Highlight Symbol"

    ;; RSpec test bindings
    "C-c t" "Testing"
    "C-c t v" "Run Current Spec"
    "C-c t a" "Run All Specs"
    "C-c t s" "Run Single Example"
    "C-c t r" "Rerun Last Spec"
    "C-c t t" "Toggle Spec/Implementation"
    "C-c t e" "Toggle Example"
    "C-c t f" "Run Matching Specs"
    "C-c t c" "Continue Failed Specs"

    ;; Rubocop bindings
    "C-c C-r" "Rubocop"
    "C-c C-r a" "Check Project"
    "C-c C-r d" "Check Directory"
    "C-c C-r f" "Check Current File"
    "C-c C-r F" "Fix Current File"
    "C-c C-r P" "Fix Project"

    ;; Ruby REPL bindings
    "C-c C-s" "Start Ruby REPL"
    "C-c C-c" "Send Region & Go"
    "C-c C-x" "Send Definition"
    "C-c C-r" "Send Region"

    ;; Bundler bindings
    "C-c b" "Bundler"
    "C-c b i" "Bundle Install"
    "C-c b u" "Bundle Update"
    "C-c b c" "Bundle Check"
    "C-c b e" "Bundle Exec"

    ;; Rails bindings (projectile-rails) - ACTUAL MAPPINGS
    "C-c r" "Rails"

    ;; Core find commands (actual projectile-rails mappings)
    "C-c r m" "Find Model"
    "C-c r c" "Find Controller"
    "C-c r v" "Find View"
    "C-c r h" "Find Helper"
    "C-c r b" "Find Job"

    ;; Go to files
    "C-c r g" "Go to File"
    "C-c r g f" "Go to File at Point"
    "C-c r g g" "Go to Gemfile"
    "C-c r g r" "Go to Routes"
    "C-c r g d" "Go to Schema"
    "C-c r RET" "Go to File at Point"

    ;; Rails commands
    "C-c r !" "Rails Commands"
    "C-c r ! c" "Rails Console"
    "C-c r ! s" "Rails Server"
    "C-c r ! b" "Database Console"
    "C-c r ! g" "Rails Generate"
    "C-c r r" "Rails Console"
    "C-c r R" "Rails Server"

    ;; Extract functionality
    "C-c r x" "Extract to Partial"

    ;; Ruby hash syntax
    "C-c h t" "Toggle Hash Syntax"

    ;; Seeing is believing
    "C-c ?" "Seeing is Believing"
    "C-c ? ?" "Run SiB"
    "C-c ? c" "Clear SiB"

    ;; Ruby documentation
    "C-c C-h" "Ruby Documentation"

    ;; Config management
    "C-c c" "Config"
    "C-c c r" "Reload Config"
    "C-c c e" "Edit Config"
    "C-c c c" "Claude Code"))

(provide 'which-key-config)
;;; which-key-config.el ends here