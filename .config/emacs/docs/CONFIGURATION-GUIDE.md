# Emacs Configuration Guide

## 🎯 Overview

This is a modern, modular Emacs configuration designed for development productivity. It provides a VS Code-like experience with powerful Emacs capabilities, organized into focused, single-responsibility modules.

## 📁 Module Structure

### Core Modules (Always Loaded)

| Module | Purpose | Key Features |
|--------|---------|--------------|
| **core.el** | Essential Emacs settings | Performance, basic editing, macOS integration |
| **completion-unified.el** | Search and completion | VS Code-like fuzzy finding, unified completion UI |
| **navigation.el** | Buffer and window management | Smart switching, enhanced navigation |
| **file-explorer.el** | File tree and dashboard | Treemacs integration, project dashboard |
| **project-management.el** | Project operations | Projectile integration, project-aware functions |
| **workspace.el** | Session and workspace management | Perspective workspaces, session persistence |
| **git.el** | Version control | Magit, git integration, diff highlighting |

### Language Modules

| Module | Purpose | Key Features |
|--------|---------|--------------|
| **ruby.el** | Ruby/Rails development | Rails-specific tools, testing, debugging |
| **react-native.el** | React Native development | Metro, simulator integration, debugging |

### UI Module

| Module | Purpose | Key Features |
|--------|---------|--------------|
| **ui.el** | Visual enhancements | Themes, fonts, icons, visual improvements |

## ⌨️ Key Bindings

### Global Command Key Shortcuts (macOS Style)

| Binding | Function | Description |
|---------|----------|-------------|
| `Cmd+P` | Find Files | VS Code-like fuzzy file finder |
| `Cmd+Shift+F` | Search Project | Project-wide text search |
| `Cmd+B` | Switch Buffer | Smart buffer switching |
| `Cmd+0` | Toggle File Explorer | Show/hide treemacs |
| `Cmd+O` | Switch Window | Quick window switching |
| `Cmd+W` | Kill Buffer | Close current buffer |
| `Cmd+N` | New Buffer | Create new empty buffer |
| `Cmd+[` | Previous Buffer | Navigate backwards |
| `Cmd+]` | Next Buffer | Navigate forwards |
| `Cmd+1-9` | Select Window | Jump to window by number |
| `Cmd+{` | Previous Workspace | Switch workspace backwards |
| `Cmd+}` | Next Workspace | Switch workspace forwards |

### Organized C-c Prefixes

#### File Operations (C-c f)
| Binding | Function | Description |
|---------|----------|-------------|
| `C-c f f` | Find Files | Find files with consult |
| `C-c f r` | Recent Files | Open recent files |
| `C-c f d` | Find with fd | Fast file search |
| `C-c f p` | Project Files | Find files in project |
| `C-c f g` | Git Files | Find git-tracked files |

#### Search Operations (C-c s)
| Binding | Function | Description |
|---------|----------|-------------|
| `C-c s s` | Search Buffer | Search in current buffer |
| `C-c s r` | Ripgrep | Fast text search |
| `C-c s p` | Search Project | Search in project |
| `C-c s g` | Grep | Standard grep search |

#### Buffer Management (C-c b)
| Binding | Function | Description |
|---------|----------|-------------|
| `C-c b b` | Switch Buffer | Smart buffer switching |
| `C-c b k` | Kill Buffer | Close current buffer |
| `C-c b K` | Kill Other Buffers | Close all except current |
| `C-c b r` | Recent Files | Open recent files |
| `C-c b l` | List Buffers | Open ibuffer |

#### Window Management (C-c w)
| Binding | Function | Description |
|---------|----------|-------------|
| `C-c w v` | Split Vertical | Split window vertically |
| `C-c w h` | Split Horizontal | Split window horizontally |
| `C-c w d` | Delete Window | Close current window |
| `C-c w o` | Delete Other Windows | Maximize current window |
| `C-c w s` | Switch Workspace | Change perspective |

#### Project Operations (C-c p)
| Binding | Function | Description |
|---------|----------|-------------|
| `C-c p f` | Find File | Project file finder |
| `C-c p s` | Switch Project | Change projects |
| `C-c p b` | Project Buffer | Switch project buffer |
| `C-c p g` | Git Files | Find git files |

#### File Explorer (C-c e)
| Binding | Function | Description |
|---------|----------|-------------|
| `C-c e t` | Toggle Explorer | Show/hide treemacs |
| `C-c e T` | Add Project | Add project to explorer |
| `C-c e f` | Find File | Find file in explorer |

#### Git Operations (C-c g)
| Binding | Function | Description |
|---------|----------|-------------|
| `C-c g s` | Git Status | Open magit status |
| `C-c g b` | Git Blame | Show git blame |
| `C-c g l` | Git Log | Show git log |
| `C-c g t` | Git Timemachine | Browse file history |

## 🚀 Getting Started

### 1. Backup Current Configuration
```bash
mv ~/.emacs.d ~/.emacs.d.backup
```

### 2. Install New Configuration
```bash
# Copy the new modules to your .emacs.d/modules directory
# Replace init.el with init-improved.el
cp init-improved.el init.el
```

### 3. First Launch
1. Start Emacs
2. Wait for packages to install automatically
3. Use `C-c C-i` to see loaded modules
4. Use `C-c C-r` to reload configuration if needed

## 🔧 Customization

### Adding New Modules

1. Create a new `.el` file in the `modules/` directory
2. Follow the module template:

```elisp
;;; my-module.el --- Description -*- lexical-binding: t; -*-

;;; Commentary:
;; What this module does

;;; Code:

;; Your configuration here

;; Which-key descriptions
(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "C-c x" "My Module"))

(provide 'my-module)
;;; my-module.el ends here
```

3. Add the module to the loading list in `init.el`:
```elisp
(load-config-module "my-module")
```

### Customizing Keybindings

Each module contains its own keybindings and which-key descriptions. To customize:

1. Find the relevant module file
2. Modify the `:bind` sections in `use-package` declarations
3. Update corresponding `which-key-add-key-based-replacements` calls
4. Reload with `C-c C-r`

### Module Dependencies

Modules are loaded in dependency order:
1. `core` - Must be first
2. Core functionality modules
3. Language-specific modules
4. UI modules
5. Optional modules (auto-detected)

## 📋 Migration from Old Configuration

### Old → New Module Mapping

| Old File | New Modules | Changes |
|----------|-------------|---------|
| `project.el` | `file-explorer.el`, `project-management.el`, `workspace.el` | Split by responsibility |
| `completion.el` + `telescope.el` | `completion-unified.el` | Merged, removed duplication |
| `buffer-navigation.el` | `navigation.el` | Enhanced with more features |
| `which-key.el` | Distributed across modules | Descriptions near their bindings |

### Key Binding Changes

- More consistent Command key usage for macOS
- Organized C-c prefixes by function
- Eliminated conflicts and duplicates
- Added VS Code-like shortcuts

### Breaking Changes

1. **Module Loading**: Use `completion-unified` instead of separate `completion` and `telescope`
2. **Keybindings**: Some shortcuts have changed for consistency
3. **Which-key**: Descriptions are now in individual modules

## 🛠️ Troubleshooting

### Common Issues

1. **Module Not Found**: Check file exists in `modules/` directory
2. **Package Errors**: Run `package-refresh-contents` and restart
3. **Keybinding Conflicts**: Check which-key with `C-h` after prefix

### Debug Commands

| Command | Purpose |
|---------|---------|
| `C-c C-i` | Show module information |
| `C-c C-r` | Reload configuration |
| `C-c C-e` | Edit main config file |
| `C-c C-m` | Find and edit module |

### Performance Issues

1. Check startup time in `*Messages*` buffer
2. Use `M-x use-package-report` to see slow packages
3. Disable modules temporarily to isolate issues

## 🎨 Customization Examples

### Personal Module

Create `modules/personal.el`:

```elisp
;;; personal.el --- Personal customizations -*- lexical-binding: t; -*-

;;; Code:

;; Your personal settings
(setq user-full-name "Your Name"
      user-mail-address "your@email.com")

;; Custom functions
(defun my/custom-function ()
  "My custom function."
  (interactive)
  (message "Hello from my custom function!"))

;; Custom keybindings
(global-set-key (kbd "C-c C-x") #'my/custom-function)

(provide 'personal)
;;; personal.el ends here
```

### Language-Specific Module

Create `modules/python.el` for Python development:

```elisp
;;; python.el --- Python development -*- lexical-binding: t; -*-

;;; Code:

(use-package python-mode
  :mode "\\.py\\'"
  :config
  (setq python-indent-offset 4))

;; Add to which-key
(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "C-c p y" "Python"))

(provide 'python)
;;; python.el ends here
```

## 📚 Learning Resources

### Emacs Fundamentals
- Understanding use-package syntax
- Emacs Lisp basics for customization
- Key binding concepts

### Included Packages
- **Projectile**: Project management
- **Treemacs**: File explorer
- **Magit**: Git interface
- **Consult/Vertico**: Completion and search
- **Company**: Auto-completion
- **Perspective**: Workspace management

### Advanced Usage
- Creating custom modules
- Advanced keybinding patterns
- Performance optimization
- Package development

## 🤝 Contributing

To improve this configuration:

1. Create focused, single-responsibility modules
2. Follow consistent keybinding patterns
3. Include which-key descriptions
4. Document breaking changes
5. Test with clean Emacs installation

## 📄 License

This configuration is provided as-is for educational and productivity purposes.