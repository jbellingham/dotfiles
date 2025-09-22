This project is an emacs configuration implemented using literate
programming done entirely in org-mode documentation.
Any changes you make to configuration should NOT be made in any of the files in
modules/\*\*.el as these files are generated and changes will be gone upon save.
Instead, all configuration lives in .config/emacs/config.org. Sections added or updated
are to be configured to tangle into files in modules/\*\*.el.

I have many custom keybindings in my config, following a mnemonic pattern.
Before adding or modifying a keybinding, check existing custom and out-of-the-box
bindings and be sure to not create clashes.

My configuration is quite complex, and so large changes should be broken down into small chunks
and a todo list published to $feature.todo.md.
After each small chunk, STOP AND TEST THAT THE CONFIGURATION STILL LOADS. If not, stop
what you are doing and fix the problem. If yes, do not make any further changes,
until I am able to verify that the config is still behaving as expected.
