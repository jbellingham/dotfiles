au BufLeave $MYVIMRC :source $MYVIMRC

set ignorecase                  " Search case insensitive...
set smartcase                   " ... but not when search pattern contains upper case characters

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
set autochdir

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

" map leader key to Spacebar ala Spacemacs
let mapleader=" "

" open terminal
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>t :below 10sp term://$SHELL<cr>i
" hit <Escape> key to exit from terminal mode
:tnoremap <Esc> <C-\><C-n>

" remap window split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" these "Ctrl mappings" work well when Caps Lock is mapped to Ctrl
nmap <silent> t<C-n> :TestNearest<CR>
nmap <silent> t<C-f> :TestFile<CR>
nmap <silent> t<C-s> :TestSuite<CR>
nmap <silent> t<C-l> :TestLast<CR>
nmap <silent> t<C-g> :TestVisit<CR>

" Telescope command mappings
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" use current file directory as a start to find file to edit
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map ,e :e <C-R>=expand("%:p:h") . "/" <CR>
map ,t :tabe <C-R>=expand("%:p:h") . "/" <CR>
map ,s :split <C-R>=expand("%:p:h") . "/" <CR>
" credits to:
" https://stackoverflow.com/a/1708936

" it is ok to wrap lines, just use gj or gk to move
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set wrap

" console.log hot key: type cll
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" insert mode, puts focus inside parentheses
imap cll console.log()<Esc><S-f>(a
" from visual mode on next line, puts visual selection inside parentheses
vmap cll yocll<Esc>p
" from normal mode, wraps word under cursor
nmap cll yiwocll<Esc>p
" credits to:
" https://gist.github.com/jasongonzales23/6189da1d82ee05a91edfd53403d6941d

" cycle buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:nnoremap gb :bnext<CR>

" load plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
source ~/.config/nvim/plugins.vim
