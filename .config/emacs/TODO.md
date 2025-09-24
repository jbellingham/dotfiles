### Wishlist
- VS Code-like tabs across the top of the screen. Middle click to close tab
- Debug ruby/rails apps entirely in Emacs via pry
- A rails debugging cheatsheet I can bring up in a separate window with a key binding
  - Window opens readonly
- An evil mode cheatsheet
- Setup org-mode
  - Be able to create org-mode notes about work stuff.
  - Would these notes need to be co-located next to work code, and thus gitignored?
- Emacs cheatsheet
  - How to use bookmarks
  - How to use registers
- Key binding for commenting a line/block

### Bugs
- Not really a bug as such, but part of the cool thing about using org-mode is being able to
create blocks of source code with #+begin_src emacs-lisp (;;some lisp code) #+end_src and you can edit
these source blocks in a separate buffer with the correct major mode for the specified language and all the benefits that brings.
Something about my setup meant this never worked, I would consistently get errors like
"Cannot modify an area being edited in a dedicated buffer". I've gone with a configuration that essentially just
stops that separate buffer from opening and instead I edit the src blocks inline. Would be cool to get this working.
