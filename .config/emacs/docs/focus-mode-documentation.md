# Focus Mode Documentation

## Overview

Focus Mode is a toggleable distraction-free editing environment that centers your current buffer in the window, providing a zen-like coding experience similar to modern editors like VSCode's Zen Mode or Sublime Text's Distraction Free Mode.

## ✨ Features

### 🎯 **Core Functionality**
- **One-Key Toggle**: Instantly enter/exit focus mode with `C-c F`
- **Smart Centering**: Automatically centers buffer content with configurable width
- **State Restoration**: Perfectly restores your window layout when exiting
- **Visual Margins**: Clean side margins for distraction-free focus

### ⚙️ **Customization Options**
- **Adjustable Width**: 60-200 columns (default: 100)
- **Quick Presets**: Narrow (80), Medium (100), Wide (120) column layouts
- **Dynamic Adjustment**: Resize on-the-fly with `+`/`-` keys
- **Visual Styling**: Customizable margin colors and appearance

### 🔧 **Smart Behavior**
- **Window Memory**: Remembers your exact window configuration
- **Auto-Adjustment**: Responsive to window size changes
- **Mode Safety**: Prevents activation in problematic contexts (minibuffer, special buffers)
- **Status Indicator**: Optional modeline indicator showing focus state

## 🎮 Keybindings

### **Primary Controls**
| Key | Command | Description |
|-----|---------|-------------|
| `C-c F` | `my/focus-mode-toggle` | **Quick toggle focus mode** |
| `C-c f f` | `my/focus-mode-toggle` | Toggle focus mode on/off |
| `C-c f s` | `my/focus-mode-status` | Show current focus status |

### **Width Adjustment**
| Key | Command | Description |
|-----|---------|-------------|
| `C-c f +` | `my/focus-mode-increase-width` | Increase width by 10 columns |
| `C-c f -` | `my/focus-mode-decrease-width` | Decrease width by 10 columns |

### **Quick Presets**
| Key | Command | Description |
|-----|---------|-------------|
| `C-c f 1` | `my/focus-mode-narrow` | **Narrow**: 80 columns (code review) |
| `C-c f 2` | `my/focus-mode-medium` | **Medium**: 100 columns (default) |
| `C-c f 3` | `my/focus-mode-wide` | **Wide**: 120 columns (documentation) |

## 🚀 Usage Examples

### **Basic Usage**
```
1. Working in split windows with multiple buffers
2. Press C-c F
3. ✨ Current buffer centers, other windows disappear
4. Focus on current task without distractions
5. Press C-c F again to restore layout
```

### **Writing Workflow**
```
Documentation file with multiple windows open:
├─ Code file (left)
├─ Documentation (center) ← You're here
└─ Terminal (bottom)

Press C-c f 3 (wide mode):
┌─────────────────────────────────────────────┐
│                                             │
│   # Documentation                           │
│                                             │
│   Writing focused content with              │
│   perfect 120-column width for              │
│   documentation and markdown files.         │
│                                             │
│                                             │
└─────────────────────────────────────────────┘
```

### **Code Review Workflow**
```
Press C-c f 1 (narrow mode):
┌───────────────────────────────────┐
│                                   │
│    function validateUser(user) {  │
│      if (!user.email) {           │
│        throw new Error('Email');  │
│      }                            │
│      return true;                 │
│    }                              │
│                                   │
└───────────────────────────────────┘
Perfect 80-column view for code review
```

## ⚙️ Configuration

### **Customizable Variables**

```elisp
;; Target width for focused buffer (default: 100)
(setq my/focus-mode-width 120)

;; Enable visual margins (default: t)
(setq my/focus-mode-enable-margins t)

;; Margin background color (default: "#1a1a1a")
(setq my/focus-mode-margin-color "#2d2d2d")

;; Show modeline indicator (default: t)
(setq my/focus-mode-preserve-modeline t)
```

### **Width Presets Customization**

```elisp
;; Customize preset widths
(defun my/focus-mode-ultrawide ()
  "Set focus mode to ultra-wide (140 columns)."
  (interactive)
  (setq my/focus-mode-width 140)
  (when my/focus-mode-active (my/focus-mode-adjust-margins))
  (message "Focus mode: ultra-wide (140 columns)"))

;; Bind to custom key
(global-set-key (kbd "C-c f 4") #'my/focus-mode-ultrawide)
```

## 🔧 Technical Implementation

### **State Management**
- **Window Configuration**: Uses `current-window-configuration` for perfect restoration
- **Margin Storage**: Preserves original margin settings
- **Frame Integration**: Handles window size changes and frame events

### **Centering Algorithm**
```elisp
(defun my/focus-mode-calculate-margins ()
  "Calculate margin widths to center the buffer."
  (let* ((window-width (window-width))
         (target-width my/focus-mode-width)
         (margin-width (max 0 (/ (- window-width target-width) 2))))
    (when (> window-width target-width) margin-width)))
```

### **Smart Activation**
- **Context Awareness**: Prevents activation in minibuffer, special buffers
- **Safe Restoration**: Always restores state even if Emacs crashes
- **Dynamic Response**: Adjusts to window resizing automatically

## 💡 Pro Tips

### **Best Practices**
1. **Use presets**: `C-c f 1/2/3` for common scenarios
2. **Quick toggle**: `C-c F` is fastest for enter/exit
3. **Width adjustment**: `C-c f +/-` for fine-tuning while active
4. **Context switching**: Perfect for deep work sessions

### **Workflow Integration**
```
Normal Multi-Window Development:
┌─────────────┬─────────────┬─────────────┐
│ Code        │ Tests       │ Terminal    │
│             │             │             │
│ function(){ │ describe(){ │ $ npm test  │
│   ...       │   ...       │             │
│             │             │             │
└─────────────┴─────────────┴─────────────┘

Focus Mode (C-c F):
┌─────────────────────────────────────────┐
│                                         │
│     function validateInput(input) {     │
│       if (!input) return false;         │
│       return input.trim().length > 0;   │
│     }                                   │
│                                         │
└─────────────────────────────────────────┘

Back to Normal (C-c F again):
┌─────────────┬─────────────┬─────────────┐
│ Code        │ Tests       │ Terminal    │ ← Perfectly restored
│             │             │             │
│ function(){ │ describe(){ │ $ npm test  │
│   ...       │   ...       │             │
```

### **Use Cases**
- **📝 Documentation Writing**: Use wide mode (`C-c f 3`) for markdown files
- **🐛 Debugging**: Focus mode to concentrate on problematic code
- **📖 Code Reading**: Narrow mode (`C-c f 1`) for reviewing code
- **✍️ Deep Coding**: Medium mode (`C-c f 2`) for implementation work

## 🔄 Integration with Other Features

### **Compatibility**
- ✅ **Works with**: All major modes, LSP, syntax highlighting
- ✅ **Preserves**: Font settings, themes, syntax colors
- ✅ **Restores**: Exact window layout, cursor position
- ✅ **Respects**: Buffer-local settings and modes

### **Treemacs Integration**
Focus mode works seamlessly with your file explorer:
```
Before Focus: Code + Treemacs + Terminal
Focus Mode: Just centered code buffer
After Focus: Everything restored including Treemacs position
```

### **Testing Integration**
Perfect for test-driven development:
```
1. Write test in split window
2. C-c F to focus on implementation
3. Code without distractions
4. C-c F to restore and run tests
```

## 📊 Status and Feedback

### **Visual Indicators**
- **Modeline**: `[FOCUS]` indicator when active
- **Messages**: Clear feedback on enter/exit/width changes
- **Margins**: Visual centering with customizable colors

### **Status Commands**
```elisp
;; Check current state
(my/focus-mode-status)  ; "Focus mode: ACTIVE" or "Focus mode: inactive"

;; Check current width
my/focus-mode-width  ; Shows current column width setting
```

## 🚨 Troubleshooting

### **Common Issues**

**Q: Focus mode doesn't center properly?**
A: Check window width. If window is smaller than target width, no margins are applied.

**Q: Colors look wrong in margin area?**
A: Customize `my/focus-mode-margin-color` to match your theme.

**Q: Can't exit focus mode?**
A: Use `C-c F` or `C-c f f`. If stuck, `M-x my/focus-mode-exit`.

**Q: Window configuration not restored?**
A: This is rare but can happen if window configuration becomes invalid. Restart Emacs or manually arrange windows.

### **Debug Commands**
```elisp
;; Force exit if stuck
(my/focus-mode-exit)

;; Check state variables
my/focus-mode-active           ; Should be t when active
my/focus-mode-window-config    ; Should contain saved configuration
```

## 🎯 Perfect For

- **📚 Reading Documentation**: Wide mode for comprehensive docs
- **✍️ Writing Code**: Medium mode for most programming tasks
- **🔍 Code Review**: Narrow mode for focused line-by-line review
- **📝 Writing Documentation**: Wide mode for markdown and prose
- **🐛 Debugging Sessions**: Any mode for distraction-free problem solving
- **📖 Learning New Code**: Focus on understanding without UI clutter

**Result: A professional, distraction-free editing environment that enhances focus and productivity while preserving your workflow.**