# Emacs Keybinding Reference

A comprehensive guide to Emacs keybindings covering core functionality and your custom configuration.

## Table of Contents

- [Essential Core Emacs Keybindings](#essential-core-emacs-keybindings)
- [Custom macOS-Style Keybindings](#custom-macos-style-keybindings)
- [File & Project Management](#file--project-management)
- [Navigation & Buffer Management](#navigation--buffer-management)
- [Search & Replace](#search--replace)
- [Code Navigation & Development](#code-navigation--development)
- [Window & Workspace Management](#window--workspace-management)
- [Git Integration](#git-integration)
- [Ruby/Rails Development](#rubyrails-development)
- [React Native Development](#react-native-development)
- [Configuration & Debugging](#configuration--debugging)
- [Tips & Tricks](#tips--tricks)

---

## Essential Core Emacs Keybindings

### File Operations
| Key | Command | Description |
|-----|---------|-------------|
| `C-x C-f` | `find-file` | Open file |
| `C-x C-s` | `save-buffer` | Save current buffer |
| `C-x C-w` | `write-file` | Save as (write file) |
| `C-x s` | `save-some-buffers` | Save all modified buffers |
| `C-x C-c` | `save-buffers-kill-terminal` | Exit Emacs |

### Basic Editing
| Key | Command | Description |
|-----|---------|-------------|
| `C-g` | `keyboard-quit` | Cancel current command |
| `C-/` or `C-_` | `undo` | Undo last action |
| `C-x u` | `undo` | Undo (alternative) |
| `M-/` | `dabbrev-expand` | Dynamic abbreviation expansion |
| `C-k` | `kill-line` | Kill (cut) to end of line |
| `C-y` | `yank` | Paste (yank) |
| `M-y` | `yank-pop` | Cycle through kill ring |
| `C-w` | `kill-region` | Kill (cut) selected region |
| `M-w` | `kill-ring-save` | Copy selected region |

### Movement
| Key | Command | Description |
|-----|---------|-------------|
| `C-f` | `forward-char` | Move forward one character |
| `C-b` | `backward-char` | Move backward one character |
| `C-n` | `next-line` | Move to next line |
| `C-p` | `previous-line` | Move to previous line |
| `C-a` | `beginning-of-line` | Move to beginning of line |
| `C-e` | `end-of-line` | Move to end of line |
| `M-f` | `forward-word` | Move forward one word |
| `M-b` | `backward-word` | Move backward one word |
| `M-<` | `beginning-of-buffer` | Move to beginning of buffer |
| `M->` | `end-of-buffer` | Move to end of buffer |
| `C-v` | `scroll-up-command` | Page down |
| `M-v` | `scroll-down-command` | Page up |

### Search & Replace
| Key | Command | Description |
|-----|---------|-------------|
| `C-s` | `isearch-forward` | Search forward |
| `C-r` | `isearch-backward` | Search backward |
| `M-%` | `query-replace` | Interactive find and replace |
| `M-x replace-string` | `replace-string` | Replace all occurrences |

---

## Custom macOS-Style Keybindings

Your configuration includes VS Code-like Command key bindings for familiar navigation:

### File & Project Operations
| Key | Command | Description |
|-----|---------|-------------|
| `Cmd+P` (`s-p`) | `my/find-project-files` | **Find Files** (Fuzzy search) |
| `Cmd+Shift+P` (`s-P`) | `my/project-switch-with-treemacs` | **Search Project** |
| `Cmd+B` (`s-b`) | `my/project-buffers` | **Switch Buffer** |
| `Cmd+Shift+F` (`s-F`) | `my/search-project` | **Search in Project** |

### Buffer Management
| Key | Command | Description |
|-----|---------|-------------|
| `Cmd+N` (`s-n`) | `my/new-empty-buffer` | **New Buffer** |
| `Cmd+W` (`s-w`) | `kill-current-buffer` | **Kill Buffer** |
| `Cmd+[` (`s-[`) | `my/switch-to-previous-buffer` | **Previous Buffer** |
| `Cmd+]` (`s-]`) | `next-buffer` | **Next Buffer** |

### Window Selection
| Key | Command | Description |
|-----|---------|-------------|
| `Cmd+0` (`s-0`) | `treemacs-select-window` | **Toggle File Explorer** |
| `Cmd+O` (`s-o`) | `ace-window` | **Switch Window** |
| `Cmd+1-9` (`s-1` to `s-9`) | `winum-select-window-N` | **Select Window by Number** |

### Code Navigation
| Key | Command | Description |
|-----|---------|-------------|
| `Cmd+T` (`s-t`) | `my/toggle-between-implementation-and-test` | **Toggle Impl/Test** |

### Workspace Management
| Key | Command | Description |
|-----|---------|-------------|
| `Cmd+{` (`s-{`) | `persp-prev` | **Previous Workspace** |
| `Cmd+}` (`s-}`) | `persp-next` | **Next Workspace** |

---

## File & Project Management

### Find Files & Directories
| Key | Command | Description |
|-----|---------|-------------|
| `C-c f f` | `consult-find` | Find files |
| `C-c f r` | `consult-recent-file` | Recent files |
| `C-c f d` | `consult-fd` | Find with fd (faster) |
| `C-c f g` | `my/find-git-files` | Git files |
| `C-c f p` | `my/find-project-files` | Project files |
| `C-c f D` | `consult-dir` | Find directory |

### Project Operations
| Key | Command | Description |
|-----|---------|-------------|
| `C-c p` | `projectile-command-map` | Projectile prefix |
| `C-c p p` | `projectile-switch-project` | Switch project |
| `C-c p f` | `projectile-find-file` | Find file in project |
| `C-c p s r` | `projectile-ripgrep` | Search in project |
| `C-c p i` | `projectile-invalidate-cache` | Invalidate cache |

---

## Navigation & Buffer Management

### Buffer Operations
| Key | Command | Description |
|-----|---------|-------------|
| `C-c b b` | `my/smart-switch-buffer` | Smart switch buffer |
| `C-c b c` | `consult-buffer` | Consult buffer |
| `C-c b p` | `consult-project-buffer` | Project buffer |
| `C-c b r` | `recentf-open-files` | Recent files |
| `C-c b s` | `scratch-buffer` | Scratch buffer |
| `C-c b n` | `my/new-empty-buffer` | New empty buffer |
| `C-c b d` | `my/duplicate-buffer` | Duplicate buffer |
| `C-c b k` | `kill-current-buffer` | Kill current buffer |
| `C-c b K` | `my/kill-other-buffers` | Kill other buffers |
| `C-c b A` | `my/kill-all-buffers` | Kill all buffers |
| `C-c b R` | `my/rename-current-buffer` | Rename buffer |
| `C-c b l` | `ibuffer` | Interactive buffer list |
| `C-c b 4` | `consult-buffer-other-window` | Buffer in other window |
| `C-c b 5` | `consult-buffer-other-frame` | Buffer in other frame |

### Jump & Navigation
| Key | Command | Description |
|-----|---------|-------------|
| `C-c j g` | `consult-goto-line` | Go to line |
| `C-c j m` | `consult-mark` | Jump to marks |
| `C-c j M` | `consult-global-mark` | Global marks |
| `C-c j o` | `consult-outline` | Outline/headings |
| `C-c j i` | `consult-imenu` | Imenu (functions) |
| `C-c j I` | `consult-imenu-multi` | Imenu across buffers |
| `C-c j b` | `consult-bookmark` | Jump to bookmark |

### Bookmarks
| Key | Command | Description |
|-----|---------|-------------|
| `C-c j m` | `bookmark-set` | Set bookmark |
| `C-c j j` | `bookmark-jump` | Jump to bookmark |
| `C-c j l` | `bookmark-bmenu-list` | List bookmarks |
| `C-c j d` | `bookmark-delete` | Delete bookmark |

---

## Search & Replace

### Search Operations
| Key | Command | Description |
|-----|---------|-------------|
| `C-c s s` | `consult-line` | Search in buffer |
| `C-c s m` | `consult-line-multi` | Search in multiple buffers |
| `C-c s g` | `consult-grep` | Grep |
| `C-c s r` | `consult-ripgrep` | Ripgrep (faster) |
| `C-c s l` | `consult-locate` | Locate files |
| `C-c s p` | `my/search-project` | Search in project |

### Async Search
| Key | Command | Description |
|-----|---------|-------------|
| `C-c a f` | `affe-find` | Async find |
| `C-c a g` | `affe-grep` | Async grep |

---

## Code Navigation & Development

### Implementation & Test Navigation
| Key | Command | Description |
|-----|---------|-------------|
| `C-c g i` | `my/find-implementation` | Find implementation |
| `C-c g t` | `my/goto-test` | Go to test |
| `C-c g T` | `my/toggle-between-implementation-and-test` | Toggle impl/test |

### Language Server Protocol (LSP)
| Key | Command | Description |
|-----|---------|-------------|
| `M-.` | `lsp-find-definition` | Go to definition |
| `M-?` | `lsp-find-references` | Find references |
| `M-,` | `pop-tag-mark` | Go back |
| `C-c l r` | `lsp-rename` | Rename symbol |
| `C-c l a` | `lsp-execute-code-action` | Code actions |
| `C-c l f` | `lsp-format-buffer` | Format buffer |
| `C-c l d` | `lsp-describe-thing-at-point` | Show documentation |
| `C-c l i` | `lsp-find-implementation` | Find implementation |
| `C-c l t` | `lsp-find-type-definition` | Find type definition |
| `C-c l s` | `lsp-workspace-symbol` | Search workspace symbols |
| `C-c l h` | `lsp-symbol-highlight` | Highlight symbol |

---

## Window & Workspace Management

### Window Operations
| Key | Command | Description |
|-----|---------|-------------|
| `C-c w d` | `delete-window` | Delete window |
| `C-c w v` | `split-window-right` | Split vertically |
| `C-c w h` | `split-window-below` | Split horizontally |
| `C-c w m` | `delete-other-windows` | Maximize window |
| `C-c w o` | `other-window` | Switch to other window |
| `C-c w u` | `winner-undo` | Undo window changes |
| `C-c w U` | `winner-redo` | Redo window changes |
| `C-c w 2` | `my/split-window-sensibly` | Smart split |
| `C-c w K` | `my/kill-other-buffers` | Kill other buffers |

### Workspace (Perspective) Management
| Key | Command | Description |
|-----|---------|-------------|
| `C-c w k` | `persp-kill-buffer*` | Workspace kill buffer |
| `C-c w c` | `my/create-workspace` | Create workspace |
| `C-c w P` | `my/workspace-for-project` | Workspace for project |

### Session Management
| Key | Command | Description |
|-----|---------|-------------|
| `C-c S s` | `my/save-session` | Save session |
| `C-c S r` | `my/restore-session` | Restore session |

---

## Git Integration

Your configuration includes Magit for Git operations:

### Basic Git Operations
| Key | Command | Description |
|-----|---------|-------------|
| `C-x g` | `magit-status` | Git status |
| `C-x M-g` | `magit-dispatch` | Git dispatch menu |
| `C-c g s` | `magit-status` | Git status |
| `C-c g l` | `magit-log` | Git log |
| `C-c g b` | `magit-branch` | Git branch |

---

## Ruby/Rails Development

### Ruby-specific Operations
| Key | Command | Description |
|-----|---------|-------------|
| `C-c r` | `projectile-rails-command-map` | Rails command map |
| `C-c r f f` | `projectile-rails-find-file` | Find Rails file |
| `C-c r f m` | `projectile-rails-find-model` | Find model |
| `C-c r f c` | `projectile-rails-find-controller` | Find controller |
| `C-c r f v` | `projectile-rails-find-view` | Find view |

### Ruby REPL & Execution
| Key | Command | Description |
|-----|---------|-------------|
| `C-c C-s` | `inf-ruby` | Start Ruby REPL |
| `C-c C-c` | `ruby-send-region-and-go` | Send region to REPL |
| `C-c C-x` | `ruby-send-definition` | Send definition to REPL |
| `C-c C-r` | `ruby-send-region` | Send region to REPL |

### Ruby Code Quality
| Key | Command | Description |
|-----|---------|-------------|
| `C-c R a` | `rubocop-check-project` | Check entire project |
| `C-c R d` | `rubocop-check-directory` | Check directory |
| `C-c R f` | `rubocop-check-current-file` | Check current file |
| `C-c R F` | `rubocop-autocorrect-current-file` | Auto-correct file |
| `C-c R P` | `rubocop-autocorrect-project` | Auto-correct project |

### Ruby Bundler
| Key | Command | Description |
|-----|---------|-------------|
| `C-c r b i` | `bundle-install` | Bundle install |
| `C-c r b u` | `bundle-update` | Bundle update |
| `C-c r b c` | `bundle-check` | Bundle check |
| `C-c r b e` | `bundle-exec` | Bundle exec |

### Ruby Utilities
| Key | Command | Description |
|-----|---------|-------------|
| `C-c h t` | `ruby-hash-syntax-toggle` | Toggle hash syntax |
| `C-c C-h` | `yari` | Ruby documentation lookup |
| `C-c ? ?` | `seeing-is-believing-run` | Execute with annotations |
| `C-c ? c` | `seeing-is-believing-clear` | Clear annotations |

### RSpec Testing
| Key | Command | Description |
|-----|---------|-------------|
| `C-c T v` | `rspec-verify` | Run current test |
| `C-c T s` | `rspec-verify-single` | Run single test |
| `C-c T a` | `rspec-verify-all` | Run all tests |
| `C-c T r` | `rspec-rerun` | Rerun last test |
| `C-c T t` | `rspec-toggle-spec-and-target` | Toggle spec/implementation |
| `C-c T e` | `rspec-toggle-example` | Toggle example focus |
| `C-c T f` | `rspec-verify-matching` | Run matching tests |
| `C-c T c` | `rspec-verify-continue` | Continue from failure |

---

## React Native Development

### TypeScript/JavaScript Navigation
| Key | Command | Description |
|-----|---------|-------------|
| `C-c n` | `npm-mode-command-keymap` | NPM command map |

### Company Completion
| Key | Command | Description |
|-----|---------|-------------|
| `TAB` | `company-complete-common` | Complete common |
| `C-n` | `company-select-next` | Next completion |
| `C-p` | `company-select-previous` | Previous completion |

---

## Configuration & Debugging

### Emacs Configuration
| Key | Command | Description |
|-----|---------|-------------|
| `C-c c r` | `reload-config` | Reload config |
| `C-c c e` | `open-config` | Edit config |
| `C-c c c` | `claude-code` | Launch Claude Code |
| `C-c c t` | `claude-code-terminal` | Claude terminal |
| `C-c c k` | `show-command-keybindings` | Show Command key bindings |
| `C-c c i` | `show-loaded-modules` | Show loaded modules |

### History & Advanced
| Key | Command | Description |
|-----|---------|-------------|
| `C-c h c` | `consult-command-history` | Command history |
| `C-c h k` | `consult-kmacro` | Macro history |
| `C-c h s` | `consult-history` | Minibuffer history |
| `C-c h x` | `consult-complex-command` | Complex command |

### Registers
| Key | Command | Description |
|-----|---------|-------------|
| `M-#` | `consult-register-load` | Load register |
| `M-'` | `consult-register-store` | Store register |
| `C-M-#` | `consult-register` | Consult register |

---

## Tips & Tricks

### Which-Key Integration
Your configuration includes `which-key` mode, which provides contextual help for key sequences. Simply start typing a key sequence and pause - a help window will appear showing available completions.

### Useful Key Patterns
- **`C-c`** - Personal keybindings and modes
- **`C-x`** - Core Emacs file and buffer operations
- **`M-x`** - Execute any command by name
- **`C-h`** - Help system (try `C-h k` to describe any key)

### Must-Know Help Commands
| Key | Command | Description |
|-----|---------|-------------|
| `C-h k` | `describe-key` | Describe what a key does |
| `C-h f` | `describe-function` | Describe a function |
| `C-h v` | `describe-variable` | Describe a variable |
| `C-h m` | `describe-mode` | Describe current mode |
| `C-h b` | `describe-bindings` | List all keybindings |

### Emergency Commands
| Key | Command | Description |
|-----|---------|-------------|
| `C-g` | `keyboard-quit` | Cancel anything |
| `M-x emergency-fallback` | `emergency-fallback` | Load minimal config |
| `M-x toggle-debug-on-error` | | Debug errors |

### Productivity Shortcuts
- Use `C-c f p` (or `Cmd+P`) for quick file finding in projects
- Use `C-c s r` for project-wide search with ripgrep
- Use `Cmd+T` to quickly toggle between implementation and test files
- Use `C-c b b` for intelligent buffer switching
- Use `Cmd+1-9` to jump to specific windows by number
- Use `C-c S s` and `C-c S r` for session save/restore (note: capital S to avoid conflict with search)

### File Explorer (Treemacs)
- `Cmd+0` (`s-0`) toggles the file explorer
- Navigate with arrow keys or `hjkl`
- Press `?` in Treemacs for help

### Company Completion
- `TAB` or `C-M-i` to trigger completion
- `C-n/C-p` to navigate candidates
- `C-w` to see documentation
- `M-(digit)` to select by number

---

## Configuration Architecture

Your Emacs configuration is modular with these key components:

1. **early-init.el** - Performance and UI setup
2. **init.el** - Main configuration loader
3. **modules/** - Organized feature modules:
   - `core.el` - Essential settings
   - `completion-unified.el` - Search and completion
   - `navigation.el` - Buffer and window management
   - `project-management.el` - Project tools
   - `file-explorer.el` - Treemacs file tree
   - `workspace.el` - Workspace management
   - `git.el` - Version control
   - `ruby.el` - Ruby/Rails development
   - `react-native.el` - JavaScript/TypeScript
   - `ui.el` - Themes and visual enhancements

This modular approach keeps functionality organized and makes the configuration maintainable and debuggable.

---

*This reference covers the most important keybindings in your configuration. Use `C-h b` to see all current bindings, or `C-c c k` to see the full Command key reference.*
