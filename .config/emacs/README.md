# Modern Emacs Configuration for Full-Stack Development

A clean, modular, and modern Emacs configuration optimized for Ruby on Rails and React Native/TypeScript development using literate programming in org-mode.

## Features

### Core Functionality
- **Modern Package Management**: Uses `use-package` for clean, organized configuration
- **Performance Optimized**: Fast startup with deferred loading and optimized garbage collection
- **Modular Structure**: Organized into logical modules for easy maintenance and customization

### Development Languages
- **Ruby on Rails**: Enhanced Ruby mode, Rails navigation, RSpec/Minitest integration, Rubocop
- **React Native/TypeScript**: TypeScript support, React development tools, JSX/TSX modes
- **Web Technologies**: HTML, CSS, SCSS, JavaScript with modern tooling
- **Template Support**: ERB, Haml, Slim, and JSX/TSX templates
- **REPL Integration**: Multiple language REPLs including Ruby (Pry/IRB)
- **Code Quality**: Linting and formatting for all supported languages

### Development Tools
- **Project Management**: Projectile for project-aware operations
- **Git Integration**: Full-featured Magit with GitHub/GitLab support
- **Completion System**: Modern completion with Vertico, Consult, and Company
- **File Navigation**: Treemacs file explorer and enhanced search
- **Code Intelligence**: Smart completion and documentation lookup

### User Interface
- **Modern Theme**: Doom One theme with consistent styling
- **VS Code-like Tabs**: Centaur tabs for familiar buffer management
- **Enhanced Modeline**: Informative and beautiful doom-modeline
- **Visual Feedback**: Git gutter, indent guides, and syntax highlighting
- **Window Management**: Intelligent window switching with Evil mode integration
- **Icons**: All-the-icons integration for visual appeal
- **Focus Mode**: Distraction-free editing environment

## Installation

This configuration uses literate programming - all settings are documented in org-mode files and automatically generated into elisp files.

1. **Backup existing configuration** (if any):
   ```bash
   mv ~/.emacs.d ~/.emacs.d.backup OR
   mv ~/.config/emacs ~/.config/emacs.backup
   ```

2. **Start Emacs**: The configuration will automatically install required packages on first startup.

3. **Install fonts** (if using GUI Emacs):
   - Run `M-x all-the-icons-install-fonts` after first startup

## Architecture

This configuration uses **literate programming** with org-babel. The main configuration file is `config.org`, which tangles to individual module files. Each module is documented in its own `.org` file and generates the corresponding `.el` file automatically.

## Module Structure

```
.config/emacs/
├── config.org           # Main literate configuration file
├── init.el             # Configuration entry point
├── early-init.el       # Early initialization settings
└── modules/
    ├── performance.org → performance.el    # Startup & performance optimization
    ├── core.org → core.el                  # Essential Emacs settings
    ├── evil.org → evil.el                  # Vim emulation with Evil mode
    ├── completion.org → completion.el      # Modern completion & search
    ├── navigation.org → navigation.el      # Buffer & window navigation
    ├── explorer.org → explorer.el          # File explorer (Treemacs)
    ├── project.org → project.el            # Project management (Projectile)
    ├── workspace.org → workspace.el        # Workspace management
    ├── git.org → git.el                    # Git integration (Magit)
    ├── development.org → development.el    # Ruby/Rails + React Native/TypeScript
    ├── ui.org → ui.el                      # Themes, tabs, modeline
    └── focus.org → focus.el                # Distraction-free editing
```

**Note**: Modify the `.org` files, not the `.el` files. The `.el` files are auto-generated.

## Key Bindings

### VS Code-inspired Shortcuts
- `Cmd+P` (`s-p`) - Find project files
- `Cmd+Shift+P` (`s-P`) - Switch project
- `Cmd+Shift+F` (`s-F`) - Search in project
- `Cmd+B` (`s-b`) - Switch buffer
- `Cmd+W` (`s-w`) - Close buffer safely
- `Cmd+N` (`s-n`) - New empty buffer

### Navigation & Development
- `F12` - Go to implementation/definition
- `Cmd+F12` (`s-<f12>`) - Go to test file
- `Cmd+J` (`s-j`) - Toggle between implementation and test
- `Cmd+0` (`s-0`) - Focus file explorer (Treemacs)

### Project Management (Projectile)
- `C-c p p` - Switch project
- `C-c p f` - Find file in project
- `C-c p s r` - Search in project (ripgrep)
- `C-c p t` - Toggle between implementation and test

### Git Operations (Magit)
- `C-x g` - Magit status
- `C-c g l` - Git log for current file
- `C-c g b` - Git blame

### Code Navigation
- `M-s r` - Search with ripgrep
- `C-.` - Embark actions
- `M-o` - Switch windows

## Development Workflow

### Ruby on Rails
1. **Open Project**: `Cmd+Shift+P` or `C-c p p` to switch to Rails project
2. **Navigate Files**: Use `Cmd+P` for quick file finding or `F12` for go-to-definition
3. **Toggle Tests**: Use `Cmd+J` to switch between implementation and test files
4. **Code Quality**: Rubocop integration with automatic linting
5. **Git Integration**: Use Magit (`C-x g`) for version control operations
6. **REPL**: Access Ruby REPL for testing code snippets

### React Native/TypeScript
1. **Project Navigation**: Same `Cmd+P` workflow for TypeScript/JSX files
2. **Code Intelligence**: TypeScript language server integration
3. **Component Development**: JSX/TSX support with proper syntax highlighting
4. **Testing**: Integrated testing support for JavaScript/TypeScript
5. **Build Tools**: Integration with modern JavaScript tooling

## Customization

### Adding New Modules
1. Create a new `.org` file in the `modules/` directory with proper org-babel headers
2. Configure the tangle target to generate the corresponding `.el` file
3. Add module loading to the main `config.org` file

### Modifying Settings
Each module is self-contained and documented. **Always modify the `.org` files**, not the `.el` files:
- `performance.org` - Startup optimization and performance settings
- `core.org` - Basic Emacs behavior and fundamental settings
- `evil.org` - Vim emulation configuration and key bindings
- `completion.org` - Modern completion and search configuration
- `development.org` - Language-specific development settings
- `ui.org` - Visual appearance, themes, and interface elements

### Performance Tuning
The configuration includes extensive startup optimizations in `performance.org`:
- Optimized garbage collection settings during startup
- Deferred package loading for faster initialization
- Careful package management to minimize startup time
- Use `emacs --debug-init` to identify any issues

## Troubleshooting

### First Startup Issues
- Ensure internet connection for package downloads
- Check `*Messages*` buffer for error details
- Run `M-x package-refresh-contents` if packages fail to install

### Development Environment
- **Ruby**: Ensure Ruby, Bundler, and Rails are installed and in PATH
- **Node.js**: Required for TypeScript/React Native development
- **Recommended gems**: `pry`, `rubocop`, `solargraph`
- **Project Setup**: For Rails projects, ensure `.projectile` file exists or use `projectile-add-known-project`

### Performance Issues
- Check startup time with: `emacs --eval "(message \"%s\" (emacs-init-time))"`
- Use `profiler-start` and `profiler-report` to identify bottlenecks
- Consider disabling heavy packages if not needed

## Dependencies

### System Requirements
- Emacs 29.1 or higher
- Git
- Ruby 2.7+ with Bundler
- Ripgrep (for fast searching)
- Node.js (for some language servers)

### Recommended Tools
```bash
# Ruby gems
gem install pry rubocop solargraph

# Node.js packages (for TypeScript/React Native)
npm install -g typescript typescript-language-server
```

### Optional Dependencies
- `fd` - Faster file finding
- `delta` - Better git diffs
- Language servers for enhanced completion

## Contributing

Feel free to customize this configuration for your needs. The modular structure makes it easy to:
- Add new programming languages
- Integrate additional tools
- Customize appearance and behavior
- Share improvements

This configuration prioritizes simplicity, performance, and full-stack development (Ruby on Rails + React Native/TypeScript) using literate programming principles. All configuration is documented and easily customizable through org-mode files.
