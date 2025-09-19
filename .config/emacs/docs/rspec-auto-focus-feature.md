# RSpec Auto-Focus Feature Documentation

## Overview

Enhanced RSpec integration that automatically switches focus to the test output window when running tests, providing a more seamless testing workflow similar to modern IDEs.

## Features Implemented

### 🎯 **Auto-Focus Test Output**

When you run any RSpec test command, the focus automatically switches to the test output window so you can immediately see the results without manually switching windows.

#### ✅ **How It Works**

1. **Run Test**: Press any RSpec keybinding (e.g., `C-c T v`)
2. **Auto-Display**: Test output window opens at bottom (30% of screen height)
3. **Auto-Focus**: Cursor automatically moves to test output window
4. **Watch Results**: See test results immediately without manual window switching

### 🔄 **Smart Window Management**

#### ✅ **Test Output Window Configuration**
- **Position**: Bottom of screen
- **Size**: 30% of screen height
- **Reuse**: Same window reused for subsequent test runs
- **Auto-Focus**: Automatic cursor movement to output

#### ✅ **Toggle Between Test and Output**
- **New Keybinding**: `C-c T o` - Toggle between test file and output
- **Smart Navigation**: Remembers which test file you came from
- **Bidirectional**: Works from test file → output and output → test file

## Keybinding Summary

### **Enhanced RSpec Commands**
| Key | Command | Description | Auto-Focus |
|-----|---------|-------------|-----------|
| `C-c T v` | `rspec-verify` | Run current test | ✅ Yes |
| `C-c T a` | `rspec-verify-all` | Run all tests | ✅ Yes |
| `C-c T s` | `rspec-verify-single` | Run single test | ✅ Yes |
| `C-c T r` | `rspec-rerun` | Rerun last test | ✅ Yes |
| `C-c T f` | `rspec-verify-matching` | Run matching tests | ✅ Yes |
| `C-c T c` | `rspec-verify-continue` | Continue from failure | ✅ Yes |

### **New Navigation Commands**
| Key | Command | Description |
|-----|---------|-------------|
| `C-c T o` | `my/rspec-toggle-test-output` | Toggle between test file and output window |
| `C-c T F` | `my/rspec-toggle-auto-focus` | Toggle auto-focus behavior on/off |
| `C-c T d` | `my/debug-rspec-root` | Debug: Show RSpec execution directory |

## Workflow Examples

### **🔥 Typical Testing Workflow**

1. **Edit test file**: `/engines/emsp/spec/models/party_spec.rb`
2. **Run test**: `C-c T v`
3. **✅ Auto-focus**: Cursor moves to output window automatically
4. **View results**: See test output immediately
5. **Go back to test**: `C-c T o` (quick toggle)
6. **Edit and repeat**: Make changes, `C-c T v` again

### **🔄 Window Navigation**

```
Test File                    Test Output Window
┌─────────────────────────┐  ┌─────────────────────────┐
│ party_spec.rb           │  │ *rspec-compilation*     │
│                         │  │                         │
│ describe Party do       │  │ Running: bundle exec... │
│   it "should validate"  │  │                         │
│     expect(...)         │  │ Party                   │
│   end                   │  │   ✓ should validate     │ ←── AUTO-FOCUS HERE
│ end                     │  │                         │
│                         │  │ Finished in 0.123s     │
└─────────────────────────┘  └─────────────────────────┘
      ↑                                    ↑
   C-c T o ←──────────────────────────── C-c T o
   (go back)                           (or auto-focus)
```

## Technical Implementation

### **Display Buffer Configuration**

```elisp
(add-to-list 'display-buffer-alist
             '("\\*rspec-compilation\\*"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom)
               (window-height . 0.3)
               (reusable-frames . nil)
               (select-window . t))) ; Auto-focus enabled
```

### **Hook-Based Auto-Focus**

```elisp
(add-hook 'compilation-start-hook
          (lambda (proc)
            (when (string-match-p "rspec" (process-command proc))
              (run-with-timer 0.1 nil 'my/rspec-auto-focus-compilation))))
```

### **Toggle Function**

Smart bidirectional navigation between test files and output:

```elisp
(defun my/rspec-toggle-test-output ()
  "Toggle between the test file and RSpec output buffer."
  ;; Handles both directions: test → output and output → test
  )
```

## Configuration Options

### **Customizable Settings**

You can modify these aspects in `ruby.el`:

#### **Window Size**
```elisp
(window-height . 0.3)  ; 30% of screen - change to 0.25 for 25%, etc.
```

#### **Window Position**
```elisp
(side . bottom)  ; Change to 'right' for right side, 'left' for left side
```

#### **Auto-Focus Behavior**
```elisp
(select-window . t)  ; Change to 'nil' to disable auto-focus
```

#### **Disable Feature**
To disable auto-focus while keeping other enhancements:
```elisp
(select-window . nil)  ; In display-buffer-alist
;; And comment out the compilation-start-hook
```

## Benefits

### ✅ **Improved Developer Experience**
- **Immediate Feedback**: See test results instantly without manual navigation
- **Seamless Workflow**: No interruption to switch windows manually
- **IDE-like Behavior**: Similar to RubyMine, VSCode testing experience
- **Efficient Navigation**: Quick toggle between test and output

### ✅ **Preserved Functionality**
- **All RSpec Features**: Every existing RSpec command still works
- **Window Management**: Doesn't interfere with other Emacs window behavior
- **Backward Compatible**: Can be disabled if not desired

### ✅ **Enhanced Productivity**
- **Faster Feedback Loop**: Run test → see results immediately
- **Less Context Switching**: Focus stays on test-related work
- **Quick Iteration**: Easy to run test, check output, fix, repeat

## Troubleshooting

### **If Auto-Focus Doesn't Work**

1. **Restart Emacs**: Ensure new configuration is loaded
2. **Check RSpec Buffer**: Look for `*rspec-compilation*` buffer name
3. **Test Toggle**: Try `C-c T o` to manually switch to output
4. **Debug Function**: Use `C-c T d` to verify RSpec is running from correct directory

### **Window Management Issues**

```elisp
;; If output window is too small/large
(window-height . 0.4)  ; Increase to 40%

;; If you prefer right-side output
(side . right)
(window-width . 0.3)
```

## Integration with Rails Engines

This feature works seamlessly with the Rails engine fix:

1. **Engine Test**: `/engines/emsp/spec/models/party_spec.rb`
2. **RSpec Root**: Automatically detects Rails application root
3. **Command**: `bundle exec rspec engines/emsp/spec/models/party_spec.rb`
4. **Auto-Focus**: Output window focused automatically
5. **Navigation**: `C-c T o` to toggle back to engine test file

**Result: Perfect integration between Rails engine support and auto-focus behavior.**