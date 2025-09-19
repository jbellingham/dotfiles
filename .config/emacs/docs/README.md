# Modern Emacs Configuration for Ruby on Rails Development

A clean, modular, and modern Emacs configuration specifically optimized for Ruby on Rails development.

## Features

### Core Functionality
- **Modern Package Management**: Uses `use-package` for clean, organized configuration
- **Performance Optimized**: Fast startup with deferred loading and optimized garbage collection
- **Modular Structure**: Organized into logical modules for easy maintenance and customization

### Ruby on Rails Development
- **Enhanced Ruby Mode**: Superior syntax highlighting and indentation
- **Rails Integration**: Project-aware Rails commands and navigation
- **Testing Support**: RSpec and Minitest integration
- **Code Quality**: Rubocop integration with auto-correction
- **Template Support**: ERB, Haml, and Slim template modes
- **REPL Integration**: Pry/IRB integration with `inf-ruby`
- **Refactoring Tools**: Built-in Ruby refactoring capabilities

### Development Tools
- **Project Management**: Projectile for project-aware operations
- **Git Integration**: Full-featured Magit with GitHub/GitLab support
- **Completion System**: Modern completion with Vertico, Consult, and Company
- **File Navigation**: Treemacs file explorer and enhanced search
- **Code Intelligence**: Smart completion and documentation lookup

### User Interface
- **Modern Theme**: Doom One theme with consistent styling
- **Enhanced Modeline**: Informative and beautiful doom-modeline
- **Visual Feedback**: Git gutter, indent guides, and syntax highlighting
- **Window Management**: Intelligent window switching and management
- **Icons**: All-the-icons integration for visual appeal

## Installation

1. **Backup existing configuration** (if any):
   ```bash
   mv ~/.emacs.d ~/.emacs.d.backup
   ```

2. **Start Emacs**: The configuration will automatically install required packages on first startup.

3. **Install fonts** (if using GUI Emacs):
   - Run `M-x all-the-icons-install-fonts` after first startup

## Module Structure

```
.config/emacs/
├── init.el              # Main configuration entry point
└── modules/
    ├── core.el          # Essential Emacs settings
    ├── completion.el    # Completion and search
    ├── project.el       # Project management
    ├── git.el           # Git integration
    ├── ruby.el          # Ruby and Rails development
    └── ui.el            # User interface and themes
```

## Key Bindings

### Project Management
- `C-c p p` - Switch project
- `C-c p f` - Find file in project
- `C-c p s r` - Search in project (ripgrep)
- `C-c p t` - Toggle between implementation and test

### Rails Specific
- `C-c r` - Rails command prefix
- `C-c r f m` - Find model
- `C-c r f c` - Find controller
- `C-c r f v` - Find view
- `C-c r g m` - Generate migration

### Git Operations
- `C-x g` - Magit status
- `C-c g l` - Git log for current file
- `C-c g b` - Git blame
- `C-x v n/p` - Next/previous git hunk

### Code Navigation
- `M-s r` - Search with ripgrep
- `C-c C-s` - Ruby REPL
- `C-.` - Embark actions
- `M-o` - Switch windows

### Testing
- `C-c , v` - Verify (run test)
- `C-c , a` - Verify all tests
- `C-c , r` - Re-run last test
- `C-c , s` - Verify single test

## Ruby Development Workflow

1. **Open Project**: `C-c p p` to switch to Rails project
2. **Navigate Files**: Use `C-c r f` commands to quickly jump between MVC files
3. **Run Tests**: Use RSpec shortcuts to run tests without leaving Emacs
4. **Code Quality**: Rubocop runs automatically and provides fix suggestions
5. **Git Integration**: Stage, commit, and push changes with Magit
6. **REPL**: Test code snippets with `C-c C-s` to open Ruby REPL

## Customization

### Adding New Modules
1. Create a new `.el` file in the `modules/` directory
2. Add `(load-config-module "module-name")` to `init.el`

### Modifying Settings
Each module is self-contained and can be customized independently:
- `core.el` - Basic Emacs behavior
- `ruby.el` - Ruby/Rails specific settings
- `ui.el` - Visual appearance
- `completion.el` - Search and completion behavior

### Performance Tuning
The configuration includes startup optimizations, but you can further customize:
- Adjust `gc-cons-threshold` in init.el
- Enable/disable specific packages based on your needs
- Use `emacs --debug-init` to identify slow-loading packages

## Troubleshooting

### First Startup Issues
- Ensure internet connection for package downloads
- Check `*Messages*` buffer for error details
- Run `M-x package-refresh-contents` if packages fail to install

### Ruby Integration
- Ensure Ruby, Bundler, and Rails are installed and in PATH
- Install recommended gems: `pry`, `rubocop`, `solargraph`
- For Rails projects, ensure `.projectile` file exists or use `projectile-add-known-project`

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

### Recommended Ruby Gems
```bash
gem install pry rubocop solargraph
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

This configuration prioritizes simplicity, performance, and Ruby on Rails development workflow while remaining extensible for other programming tasks.