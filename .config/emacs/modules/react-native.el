;;; react-native.el --- React Native with TypeScript development configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; React Native and TypeScript specific configuration and packages.

;;; Code:

;; Tree-sitter grammar installation and setup
(when (and (treesit-available-p) (version<= "29" emacs-version))
  ;; Install required grammars if not available
  (setq treesit-language-source-alist
        '((typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
          (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")))

  ;; Install grammars if not present
  (dolist (lang '(typescript tsx javascript))
    (unless (treesit-language-available-p lang)
      (message "Installing tree-sitter grammar for %s..." lang)
      (treesit-install-language-grammar lang)))

  ;; Only remap if grammars are available
  (when (treesit-language-available-p 'typescript)
    (add-to-list 'major-mode-remap-alist '(typescript-mode . typescript-ts-mode)))
  (when (treesit-language-available-p 'tsx)
    (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode)))
  (when (treesit-language-available-p 'javascript)
    (add-to-list 'major-mode-remap-alist '(js-mode . js-ts-mode))))

;; Enable global font-lock
(global-font-lock-mode 1)
(setq font-lock-maximum-decoration t)

;; TypeScript mode
(use-package typescript-mode
  :mode "\\.ts\\'"
  :mode "\\.tsx\\'"
  :hook (typescript-mode . (lambda ()
                             (font-lock-mode 1)
                             (font-lock-ensure)))
  :config
  (setq typescript-indent-level 2)

  ;; Enhanced syntax highlighting
  (font-lock-add-keywords 'typescript-mode
    '(;; React/JSX keywords
      ("\\<\\(React\\|Component\\|Props\\|State\\)\\>" . font-lock-type-face)
      ;; TypeScript keywords
      ("\\<\\(interface\\|type\\|enum\\|namespace\\|declare\\|readonly\\)\\>" . font-lock-keyword-face)
      ;; React Native components
      ("\\<\\(View\\|Text\\|Image\\|ScrollView\\|TouchableOpacity\\|FlatList\\|StyleSheet\\)\\>" . font-lock-builtin-face)
      ;; Hook patterns
      ("\\<use[A-Z][a-zA-Z]*\\>" . font-lock-function-name-face)
      ;; Props and state destructuring
      ("\\<\\(props\\|state\\)\\>" . font-lock-variable-name-face))))

;; Enhanced TypeScript support with tree-sitter
(use-package typescript-ts-mode
  :ensure nil ; Built into Emacs 29+
  :mode "\\.ts\\'"
  :mode "\\.tsx\\'"
  :hook (typescript-ts-mode . (lambda ()
                                (font-lock-mode 1)
                                (font-lock-ensure)))
  :config
  (setq typescript-ts-mode-indent-offset 2)

  ;; Enhanced syntax highlighting for tree-sitter mode
  (font-lock-add-keywords 'typescript-ts-mode
    '(;; React/JSX keywords
      ("\\<\\(React\\|Component\\|Props\\|State\\|FC\\|FunctionComponent\\)\\>" . font-lock-type-face)
      ;; TypeScript keywords
      ("\\<\\(interface\\|type\\|enum\\|namespace\\|declare\\|readonly\\|public\\|private\\|protected\\)\\>" . font-lock-keyword-face)
      ;; React Native components
      ("\\<\\(View\\|Text\\|Image\\|ScrollView\\|TouchableOpacity\\|FlatList\\|StyleSheet\\|Pressable\\|Modal\\|TextInput\\|SafeAreaView\\)\\>" . font-lock-builtin-face)
      ;; Hook patterns
      ("\\<use[A-Z][a-zA-Z]*\\>" . font-lock-function-name-face)
      ;; Modern JS/TS features
      ("\\<\\(const\\|let\\|async\\|await\\|export\\|import\\|default\\|from\\)\\>" . font-lock-keyword-face)
      ;; Generic types
      ("<[A-Z][a-zA-Z0-9]*>" . font-lock-type-face))))

;; TSX support for React components
(use-package tsx-ts-mode
  :ensure nil ; Built into Emacs 29+
  :mode "\\.tsx\\'"
  :hook (tsx-ts-mode . (lambda ()
                         (font-lock-mode 1)
                         (font-lock-ensure)))
  :config
  (setq tsx-ts-mode-indent-offset 2)

  ;; JSX/TSX specific highlighting
  (font-lock-add-keywords 'tsx-ts-mode
    '(;; JSX tags
      ("<\\(/\\)?\\([a-zA-Z0-9]+\\)\\>" . font-lock-function-name-face)
      ;; JSX attributes
      ("\\s-+\\([a-zA-Z0-9-]+\\)=" . font-lock-variable-name-face)
      ;; React Native components
      ("\\<\\(View\\|Text\\|Image\\|ScrollView\\|TouchableOpacity\\|FlatList\\|StyleSheet\\|Pressable\\|Modal\\|TextInput\\)\\>" . font-lock-builtin-face)
      ;; React hooks
      ("\\<use[A-Z][a-zA-Z]*\\>" . font-lock-function-name-face)
      ;; JSX expressions
      ("{[^}]*}" . font-lock-string-face))))

;; JavaScript mode for RN projects
(use-package js2-mode
  :mode "\\.js\\'"
  :mode "\\.jsx\\'"
  :hook (js2-mode . (lambda ()
                      (font-lock-mode 1)
                      (font-lock-ensure)))
  :config
  (setq js2-basic-offset 2
        js2-bounce-indent-p nil
        js2-strict-missing-semi-warning nil
        js2-missing-semi-one-line-override nil)

  ;; Enhanced JavaScript highlighting
  (font-lock-add-keywords 'js2-mode
    '(;; React components and hooks
      ("\\<\\(React\\|Component\\|useState\\|useEffect\\|useContext\\|useReducer\\)\\>" . font-lock-type-face)
      ;; React Native components
      ("\\<\\(View\\|Text\\|Image\\|ScrollView\\|TouchableOpacity\\|FlatList\\|StyleSheet\\)\\>" . font-lock-builtin-face)
      ;; Modern JavaScript keywords
      ("\\<\\(const\\|let\\|async\\|await\\|import\\|export\\|default\\)\\>" . font-lock-keyword-face)
      ;; Template literals
      ("`[^`]*`" . font-lock-string-face))))

;; Enhanced JavaScript with tree-sitter
(use-package js-ts-mode
  :ensure nil ; Built into Emacs 29+
  :mode "\\.js\\'"
  :mode "\\.mjs\\'"
  :hook (js-ts-mode . (lambda ()
                        (font-lock-mode 1)
                        (font-lock-ensure)))
  :config
  (setq js-indent-level 2))

;; JSX support
(use-package jsx-ts-mode
  :ensure nil ; Built into Emacs 29+
  :mode "\\.jsx\\'"
  :hook (jsx-ts-mode . (lambda ()
                         (font-lock-mode 1)
                         (font-lock-ensure)))
  :config
  (setq jsx-ts-mode-indent-offset 2)

  ;; JSX specific highlighting
  (font-lock-add-keywords 'jsx-ts-mode
    '(;; JSX tags and components
      ("<\\(/\\)?\\([A-Z][a-zA-Z0-9]*\\)\\>" . font-lock-type-face)
      ("<\\(/\\)?\\([a-z][a-zA-Z0-9]*\\)\\>" . font-lock-function-name-face)
      ;; JSX attributes
      ("\\s-+\\([a-zA-Z0-9-]+\\)=" . font-lock-variable-name-face)
      ;; React Native specific
      ("\\<\\(View\\|Text\\|Image\\|ScrollView\\|TouchableOpacity\\|FlatList\\|StyleSheet\\)\\>" . font-lock-builtin-face)
      ;; JSX expressions
      ("{[^}]*}" . font-lock-string-face))))

;; React Native specific file modes
(use-package react-snippets
  :after yasnippet)

;; Web mode for various template files
(use-package web-mode
  :mode "\\.html\\'"
  :mode "\\.css\\'"
  :mode "\\.scss\\'"
  :mode "\\.sass\\'"
  :mode "\\.less\\'"
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2
        web-mode-enable-auto-pairing t
        web-mode-enable-auto-expanding t
        web-mode-enable-css-colorization t))

;; JSON support for package.json, config files
(use-package json-mode
  :mode "\\.json\\'"
  :config
  (setq json-reformat:indent-width 2))

;; YAML support for CI/CD configs
(use-package yaml-mode
  :mode "\\.ya?ml\\'"
  :config
  (setq yaml-indent-offset 2))

;; Prettier for code formatting
(use-package prettier-js
  :hook ((typescript-mode typescript-ts-mode tsx-ts-mode js2-mode js-ts-mode jsx-ts-mode) . prettier-js-mode)
  :config
  (setq prettier-js-args '("--single-quote" "--trailing-comma" "es5")))

;; ESLint integration
(use-package flycheck
  :hook ((typescript-mode typescript-ts-mode tsx-ts-mode js2-mode js-ts-mode jsx-ts-mode) . flycheck-mode)
  :config
  ;; Use local eslint if available
  (defun my/use-eslint-from-node-modules ()
    (let* ((root (locate-dominating-file
                  (or (buffer-file-name) default-directory)
                  "node_modules"))
           (eslint (and root
                        (expand-file-name "node_modules/.bin/eslint"
                                          root))))
      (when (and eslint (file-executable-p eslint))
        (setq-local flycheck-javascript-eslint-executable eslint))))

  (add-hook 'flycheck-mode-hook #'my/use-eslint-from-node-modules))

;; Jest testing integration
(use-package jest
  :bind (:map typescript-mode-map
              ("C-c t t" . jest-file)
              ("C-c t a" . jest)
              ("C-c t s" . jest-single)
              ("C-c t p" . jest-popup))
  :config
  (setq jest-executable "npm test --"))

;; Node.js REPL
(use-package nodejs-repl
  :bind (:map typescript-mode-map
              ("C-c C-s" . nodejs-repl)
              ("C-c C-r" . nodejs-repl-send-region)
              ("C-c C-c" . nodejs-repl-send-buffer)
              ("C-c C-l" . nodejs-repl-load-file)))

;; NPM integration
(use-package npm-mode
  :hook ((typescript-mode typescript-ts-mode tsx-ts-mode js2-mode js-ts-mode jsx-ts-mode) . npm-mode)
  :bind-keymap ("C-c n" . npm-mode-command-keymap))

;; Indium for JavaScript debugging
(use-package indium
  :hook ((typescript-mode typescript-ts-mode js2-mode js-ts-mode) . indium-interaction-mode)
  :bind (:map indium-interaction-mode-map
              ("C-c C-e" . indium-eval-last-node)
              ("C-c C-r" . indium-eval-region)))

;; Tree-sitter support (fallback for older tree-sitter package)
(use-package tree-sitter
  :if (not (and (treesit-available-p) (version<= "29" emacs-version)))
  :hook ((typescript-mode js2-mode) . tree-sitter-mode)
  :hook (tree-sitter-after-on . tree-sitter-hl-mode)
  :config
  (setq tree-sitter-hl-use-font-lock-keywords t))

(use-package tree-sitter-langs
  :if (not (and (treesit-available-p) (version<= "29" emacs-version)))
  :after tree-sitter
  :config
  ;; Only load if available
  (when (fboundp 'tree-sitter-require)
    (ignore-errors
      (tree-sitter-require 'typescript)
      (tree-sitter-require 'tsx))))

;; Aggressive autocomplete
(use-package company
  :hook ((typescript-mode typescript-ts-mode tsx-ts-mode js2-mode js-ts-mode jsx-ts-mode) . company-mode)
  :config
  (setq company-idle-delay 0.1
        company-minimum-prefix-length 1
        company-show-numbers t
        company-tooltip-align-annotations t
        company-require-match nil)
  :bind (:map company-active-map
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous)
              ("TAB" . company-complete-selection)
              ("<tab>" . company-complete-selection)))

;; Snippet support
(use-package yasnippet
  :hook ((typescript-mode typescript-ts-mode tsx-ts-mode js2-mode js-ts-mode jsx-ts-mode) . yas-minor-mode)
  :config
  (yas-reload-all))

;; TypeScript/JavaScript snippets
(use-package yasnippet-snippets
  :after yasnippet)

;; LSP mode for TypeScript/JavaScript
(use-package lsp-mode
  :hook ((typescript-mode typescript-ts-mode tsx-ts-mode js2-mode js-ts-mode jsx-ts-mode) . lsp-deferred)
  :config
  (setq lsp-completion-provider :capf
        lsp-enable-snippet t
        lsp-semantic-tokens-enable nil
        lsp-enable-symbol-highlighting nil
        lsp-idle-delay 0.3
        lsp-completion-show-detail t
        lsp-completion-show-kind t
        lsp-eldoc-render-all t
        lsp-signature-render-documentation t
        lsp-completion-filter-on-incomplete t
        lsp-enable-completion-at-point t
        lsp-response-timeout 10
        lsp-modeline-code-actions-enable t
        lsp-modeline-diagnostics-enable t
        lsp-enable-file-watchers t
        lsp-enable-folding t
        lsp-enable-links t
        ;; TypeScript specific settings
        lsp-typescript-preferences-import-module-specifier "relative"
        lsp-typescript-suggest-auto-imports t
        lsp-typescript-format-enable t)

  ;; Preserve syntax highlighting with LSP
  (add-hook 'lsp-after-open-hook
            (lambda ()
              (when (derived-mode-p 'typescript-mode 'typescript-ts-mode 'tsx-ts-mode
                                   'js2-mode 'js-ts-mode 'jsx-ts-mode)
                (font-lock-mode 1)
                (font-lock-ensure))))

  ;; React Native specific LSP configuration
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection "typescript-language-server --stdio")
                    :major-modes '(typescript-mode typescript-ts-mode tsx-ts-mode js2-mode js-ts-mode jsx-ts-mode)
                    :server-id 'ts-ls
                    :initialization-options
                    (lambda ()
                      `(:preferences (:includeInlayParameterNameHints "all"
                                      :includeInlayParameterNameHintsWhenArgumentMatchesName t
                                      :includeInlayFunctionParameterTypeHints t
                                      :includeInlayVariableTypeHints t
                                      :includeInlayPropertyDeclarationTypeHints t
                                      :includeInlayFunctionLikeReturnTypeHints t
                                      :includeInlayEnumMemberValueHints t)))))

  :commands (lsp lsp-deferred)
  :bind (:map lsp-mode-map
              ("M-." . lsp-find-definition)
              ("M-?" . lsp-find-references)
              ("M-," . pop-tag-mark)
              ("C-c l r" . lsp-rename)
              ("C-c l a" . lsp-execute-code-action)
              ("C-c l f" . lsp-format-buffer)
              ("C-c l d" . lsp-describe-thing-at-point)
              ("C-c l i" . lsp-find-implementation)
              ("C-c l t" . lsp-find-type-definition)
              ("C-c l s" . lsp-workspace-symbol)
              ("C-c l h" . lsp-symbol-highlight)
              ("C-c l o" . lsp-organize-imports)))

;; LSP UI improvements
(use-package lsp-ui
  :after lsp-mode
  :config
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-position 'bottom
        lsp-ui-doc-delay 0.5
        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-hover t
        lsp-ui-sideline-show-code-actions t
        lsp-ui-flycheck-enable t
        lsp-ui-peek-enable t))

;; DAP (Debug Adapter Protocol) for debugging
(use-package dap-mode
  :after lsp-mode
  :config
  (require 'dap-node)
  (dap-mode 1)
  (dap-ui-mode 1)
  (dap-tooltip-mode 1)
  (tooltip-mode 1)
  (dap-ui-controls-mode 1)

  ;; React Native debugging configuration
  (dap-register-debug-template
   "React Native: Debug iOS"
   (list :type "reactnative"
         :request "launch"
         :name "Debug iOS"
         :program "${workspaceFolder}/index.js"
         :platform "ios"
         :sourceMaps t
         :outDir "${workspaceFolder}"
         :sourceMapPathOverrides (make-hash-table :test 'equal)))

  (dap-register-debug-template
   "React Native: Debug Android"
   (list :type "reactnative"
         :request "launch"
         :name "Debug Android"
         :program "${workspaceFolder}/index.js"
         :platform "android"
         :sourceMaps t
         :outDir "${workspaceFolder}"
         :sourceMapPathOverrides (make-hash-table :test 'equal)))

  :bind (:map dap-mode-map
              ("C-c d d" . dap-debug)
              ("C-c d b" . dap-breakpoint-toggle)
              ("C-c d r" . dap-debug-restart)
              ("C-c d n" . dap-next)
              ("C-c d s" . dap-step-in)
              ("C-c d o" . dap-step-out)
              ("C-c d c" . dap-continue)))

;; React Native specific utilities
(defun rn-run-ios ()
  "Run React Native iOS simulator."
  (interactive)
  (compile "npx react-native run-ios"))

(defun rn-run-android ()
  "Run React Native Android emulator."
  (interactive)
  (compile "npx react-native run-android"))

(defun rn-start-metro ()
  "Start Metro bundler."
  (interactive)
  (compile "npx react-native start"))

(defun rn-clean ()
  "Clean React Native project."
  (interactive)
  (compile "npx react-native clean"))

(defun rn-install-pods ()
  "Install CocoaPods for iOS."
  (interactive)
  (compile "cd ios && pod install"))

(defun rn-reload-app ()
  "Reload React Native app (iOS simulator)."
  (interactive)
  (shell-command "xcrun simctl spawn booted launch io.appleseed.Bridge"))

(defun rn-open-dev-menu ()
  "Open React Native developer menu (iOS simulator)."
  (interactive)
  (shell-command "xcrun simctl spawn booted launch io.appleseed.Bridge"))

;; React Native key bindings (using different prefix to avoid Rails conflict)
(defvar react-native-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c n i") 'rn-run-ios)
    (define-key map (kbd "C-c n a") 'rn-run-android)
    (define-key map (kbd "C-c n s") 'rn-start-metro)
    (define-key map (kbd "C-c n c") 'rn-clean)
    (define-key map (kbd "C-c n p") 'rn-install-pods)
    (define-key map (kbd "C-c n r") 'rn-reload-app)
    (define-key map (kbd "C-c n d") 'rn-open-dev-menu)
    map)
  "Keymap for React Native commands.")

;; Minor mode for React Native
(define-minor-mode react-native-mode
  "Minor mode for React Native development."
  :init-value nil
  :lighter " RN"
  :keymap react-native-mode-map)

;; Auto-enable React Native mode in RN projects
(defun enable-react-native-mode ()
  "Enable React Native mode if in a React Native project."
  (when (and buffer-file-name
             (locate-dominating-file buffer-file-name "package.json"))
    (let ((package-json (expand-file-name "package.json"
                                          (locate-dominating-file buffer-file-name "package.json"))))
      (when (file-exists-p package-json)
        (with-temp-buffer
          (insert-file-contents package-json)
          (goto-char (point-min))
          (when (re-search-forward "react-native" nil t)
            ;; Disable Rails mode if active to avoid conflicts
            (when (bound-and-true-p projectile-rails-mode)
              (projectile-rails-mode -1))
            (react-native-mode 1)
            (message "React Native mode enabled (C-c n prefix for commands)")))))))

;; Force syntax highlighting refresh
(defun force-typescript-highlighting ()
  "Force refresh of TypeScript syntax highlighting."
  (when (derived-mode-p 'typescript-mode 'typescript-ts-mode 'tsx-ts-mode)
    (font-lock-mode -1)
    (font-lock-mode 1)
    (font-lock-ensure)
    ;; Only enable tree-sitter if available and working
    (when (and (fboundp 'tree-sitter-hl-mode)
               (not (and (treesit-available-p) (version<= "29" emacs-version))))
      (ignore-errors (tree-sitter-hl-mode 1)))))

;; Hook to enable React Native mode
(add-hook 'typescript-mode-hook #'enable-react-native-mode)
(add-hook 'typescript-ts-mode-hook #'enable-react-native-mode)
(add-hook 'tsx-ts-mode-hook #'enable-react-native-mode)
(add-hook 'js2-mode-hook #'enable-react-native-mode)
(add-hook 'js-ts-mode-hook #'enable-react-native-mode)
(add-hook 'jsx-ts-mode-hook #'enable-react-native-mode)

;; Force highlighting refresh after mode initialization
(add-hook 'typescript-mode-hook #'force-typescript-highlighting)
(add-hook 'typescript-ts-mode-hook #'force-typescript-highlighting)
(add-hook 'tsx-ts-mode-hook #'force-typescript-highlighting)

;; Emmet for JSX
(use-package emmet-mode
  :hook ((tsx-ts-mode jsx-ts-mode) . emmet-mode)
  :config
  (setq emmet-move-cursor-between-quotes t))

;; Auto-completion for JSX attributes
(use-package company-web
  :after company
  :config
  (add-to-list 'company-backends 'company-web-html))

;; React/JSX refactoring
(use-package js2-refactor
  :hook ((js2-mode typescript-mode tsx-ts-mode jsx-ts-mode) . js2-refactor-mode)
  :config
  (js2r-add-keybindings-with-prefix "C-c C-r"))

;; Import/export helpers
(use-package add-node-modules-path
  :hook ((typescript-mode typescript-ts-mode tsx-ts-mode js2-mode js-ts-mode jsx-ts-mode) . add-node-modules-path))

(provide 'react-native)
;;; react-native.el ends here