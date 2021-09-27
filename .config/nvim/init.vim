au BufLeave $MYVIMRC :source $MYVIMRC
"
" sync js/ts syntax on buffer enter
" This seems to slow things down. Enable if syntax highlighting actually gets
" out of sync
" autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart
" autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear

" Automatically save the session when leaving Vim
" autocmd! VimLeave * mksession ~/Session.vim
" Automatically load the session when entering vim
" autocmd! VimEnter * source ~/Session.vim

command! -nargs=0 Prettier :CocCommand prettier.formatFile
" enable code folding
set foldmethod=syntax
set foldnestmax=10
set nofoldenable
set foldlevel=2

set ignorecase                  " Search case insensitive...
set smartcase                   " ... but not when search pattern contains upper case characters
set smartindent                 " Context sensitive indent

" cannot code without the following
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set encoding=UTF-8
syntax on
set number

" only vim can do this
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set cursorline
set cursorcolumn

" errors flash screen rather than emit beep
set visualbell

" reload files changed outside of Vim not currently modified in Vim (needs below)
set autoread

" http://stackoverflow.com/questions/2490227/how-does-vims-autoread-work#20418591
au FocusGained,BufEnter * :silent! !

" don't create `filename~` backups
set nobackup
set nowritebackup

" don't create temp files
set noswapfile

" line numbers and distances
" set relativenumber
set number

" number of lines offset when jumping
set scrolloff=2

" Indent new line the same as the preceding line
set autoindent

" statusline indicates insert or normal mode
set showmode showcmd

" make scrolling and painting fast
" ttyfast kept for vim compatibility but not needed for nvim
set ttyfast lazyredraw

" highlight matching parens, braces, brackets, etc
set showmatch

" http://vim.wikia.com/wiki/Searching
set hlsearch incsearch ignorecase smartcase

" As opposed to `wrap`
set nowrap

" http://vim.wikia.com/wiki/Set_working_directory_to_the_current_file
" set autochdir

" open new buffers without saving current modifications (buffer remains open)
set hidden

" http://stackoverflow.com/questions/9511253/how-to-effectively-use-vim-wildmenu
set wildmenu wildmode=list:longest,full


" StatusLine always visible, display full path
" http://learnvimscriptthehardway.stevelosh.com/chapters/17.html
set laststatus=2 statusline=%F

" Use system clipboard
" http://vim.wikia.com/wiki/Accessing_the_system_clipboard
" for linux
"set clipboard=unnamedplus
" for macOS
set clipboard=unnamed

" more natural window split opening
set splitbelow
set splitright

" it is ok to wrap lines, just use gj or gk to move
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set wrap

" load plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
source ~/.config/nvim/plugins.vim

" load custom keybindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
source ~/.config/nvim/keybindings.vim

" load coc-config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
source ~/.config/nvim/coc-config.vim
