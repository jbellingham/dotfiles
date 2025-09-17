;;; which-key-fixed.el --- Clean Which-key configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Comprehensive which-key descriptions for all mnemonic key bindings.

;;; Code:

(use-package which-key
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.5
        which-key-max-description-length 25
        which-key-sort-order 'which-key-prefix-then-key-order)

  ;; Global key descriptions using the correct function
  (which-key-add-key-based-replacements
    ;; LSP - L prefix (Language Server Protocol)
    "C-c l" "LSP"
    "C-c l r" "LSP Rename"
    "C-c l a" "LSP Actions"
    "C-c l f" "LSP Format"
    "C-c l d" "LSP Documentation"
    "C-c l i" "LSP Implementation"
    "C-c l t" "LSP Type Definition"
    "C-c l s" "LSP Symbols"
    "C-c l h" "LSP Highlight"
    "C-c l o" "LSP Organize Imports"

    ;; Testing - T prefix (Tests)
    "C-c T" "Testing"
    "C-c T t" "Test File"
    "C-c T a" "Test All"
    "C-c T s" "Test Single"
    "C-c T r" "Test Rerun"
    "C-c T v" "Test Verify"
    "C-c T e" "Test Example"
    "C-c T f" "Test Find/Match"
    "C-c T c" "Test Continue"
    "C-c T p" "Test Popup"

    ;; React Native - R prefix (React Native)
    "C-c R" "React Native"
    "C-c R i" "RN iOS"
    "C-c R a" "RN Android"
    "C-c R s" "RN Start Metro"
    "C-c R c" "RN Clean"
    "C-c R p" "RN Pods"
    "C-c R r" "RN Reload"
    "C-c R d" "RN Dev Menu"

    ;; Rails - r prefix (Rails/Ruby)
    "C-c r" "Rails"
    "C-c r b" "Rails Bundle"
    "C-c r b i" "Bundle Install"
    "C-c r b u" "Bundle Update"
    "C-c r b c" "Bundle Check"
    "C-c r b e" "Bundle Exec"

    ;; NPM - n prefix (Node/NPM)
    "C-c n" "NPM"

    ;; Git - g prefix (Git)
    "C-c g" "Git"
    "C-c g s" "Git Status"
    "C-c g m" "Git Magit"
    "C-c g M" "Git Magit Dispatch"
    "C-c g c" "Git Clone"
    "C-c g b" "Git Blame"
    "C-c g l" "Git Log File"
    "C-c g p" "Git Pull"
    "C-c g r" "Git Browse Remote"
    "C-c g L" "Git Link"
    "C-c g C" "Git Link Commit"
    "C-c g H" "Git Homepage"
    "C-c g i" "Git Commit Info"
    "C-c g d" "Git Diff Info"
    "C-c g t" "Git Timemachine"
    "C-c g o" "Git Show Message"
    "C-c g v" "Git View Hunks"
    "C-c g v =" "Git View Hunk"
    "C-c g v p" "Git View Previous"
    "C-c g v n" "Git View Next"
    "C-c g v s" "Git View Stage"
    "C-c g v r" "Git View Revert"
    "C-c g h" "Git Hunks (diff-hl)"
    "C-c g h p" "Git Hunk Previous"
    "C-c g h n" "Git Hunk Next"
    "C-c g h =" "Git Hunk Show"

    ;; Debug - d prefix (Debug)
    "C-c d" "Debug"
    "C-c d d" "Debug Start"
    "C-c d b" "Debug Breakpoint"
    "C-c d r" "Debug Restart"
    "C-c d n" "Debug Next"
    "C-c d s" "Debug Step In"
    "C-c d o" "Debug Step Out"
    "C-c d c" "Debug Continue"

    ;; Find/Files - f prefix (Find)
    "C-c f" "Find"
    "C-c f f" "Find Files"
    "C-c f r" "Find Recent"
    "C-c f d" "Find with fd"
    "C-c f p" "Find in Project"
    "C-c f g" "Find Git Files"
    "C-c f b" "Find Buffers"
    "C-c f D" "Find Directory"
    "C-c f j" "Find Jump File"

    ;; Search - s prefix (Search)
    "C-c s" "Search"
    "C-c s s" "Search Line"
    "C-c s m" "Search Multi"
    "C-c s g" "Search Grep"
    "C-c s r" "Search Ripgrep"
    "C-c s l" "Search Locate"
    "C-c s p" "Search Project"

    ;; Jump/Navigate - j prefix (Jump)
    "C-c j" "Jump"
    "C-c j g" "Jump to Line"
    "C-c j m" "Jump to Mark"
    "C-c j M" "Jump Global Mark"
    "C-c j o" "Jump Outline"
    "C-c j i" "Jump Imenu"
    "C-c j I" "Jump Imenu Multi"

    ;; Buffer - b prefix (Buffer)
    "C-c b" "Buffer"
    "C-c b k" "Buffer Kill Others"
    "C-c b K" "Buffer Kill All"
    "C-c b s" "Buffer Scratch"
    "C-c b r" "Buffer Recent"
    "C-c b p" "Buffer Project"
    "C-c b l" "Buffer List (ibuffer)"
    "C-c b b" "Buffer Switch"
    "C-c b c" "Buffer Consult"
    "C-c b 4" "Buffer Other Window"
    "C-c b 5" "Buffer Other Frame"
    "C-c b m" "Buffer Bookmarks"

    ;; Workspace/Windows - w prefix (Workspace)
    "C-c w" "Workspace"
    "C-c w s" "Workspace Switch"
    "C-c w k" "Workspace Kill"
    "C-c w r" "Workspace Rename"
    "C-c w a" "Workspace Add Buffer"
    "C-c w A" "Workspace Set Buffer"
    "C-c w b" "Workspace Switch Buffer"
    "C-c w i" "Workspace Import"
    "C-c w n" "Workspace Next"
    "C-c w p" "Workspace Previous"
    "C-c w g" "Window Group Buffers"
    "C-c w l" "Workspace List Buffers"
    "C-c w o" "Window Switch (ace)"
    "C-c w d" "Window Delete"
    "C-c w v" "Window Vertical (other)"
    "C-c w h" "Window Horizontal (frame)"

    ;; Explorer - e prefix (Explorer)
    "C-c e" "Explorer"
    "C-c e t" "Explorer Toggle"
    "C-c e T" "Explorer Add Project"
    "C-c e 1" "Explorer Delete Others"
    "C-c e b" "Explorer Bookmark"
    "C-c e f" "Explorer Find File"
    "C-c e g" "Explorer Find Tag"

    ;; Project - p prefix (Project)
    "C-c p" "Project"
    "C-c p b" "Project Buffer"

    ;; Config/Claude - c prefix (Config)
    "C-c c" "Config"
    "C-c c r" "Config Reload"
    "C-c c e" "Config Edit"
    "C-c c c" "Claude Code"
    "C-c c t" "Claude Terminal"
    "C-c c h" "Config History"
    "C-c c m" "Config Mode Commands"
    "C-c c k" "Config Kmacro"
    "C-c c x" "Config Complex Command"

    ;; Async/Affe - a prefix (Async)
    "C-c a" "Async"
    "C-c a f" "Async Find"
    "C-c a g" "Async Grep"

    ;; Jump/Navigate - j prefix (Jump)
    "C-c j" "Jump"
    "C-c j g" "Jump to Line"
    "C-c j m" "Jump to Mark"
    "C-c j M" "Jump Global Mark"
    "C-c j o" "Jump Outline"
    "C-c j i" "Jump Imenu"
    "C-c j I" "Jump Imenu Multi"
    "C-c j b" "Jump Bookmark"

    ;; Special key sequences
    "C-c SPC" "Telescope Menu"

    ;; Global Command (Super) key bindings
    "s-0" "Select Treemacs"
    "s-o" "Switch Window"
    "s-p" "Find Files"))

(provide 'which-key-fixed)
;;; which-key-fixed.el ends here