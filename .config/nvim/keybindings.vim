
" map leader key to ;
let mapleader=";"

nnoremap <leader>tconf :e ~/.tmux.conf<cr>
nnoremap <leader>conf :e ~/.config/nvim/init.vim<cr>
nnoremap <leader>plug :e ~/.config/nvim/plugins.vim<cr>
nnoremap <leader>bind :e ~/.config/nvim/keybindings.vim<cr>
nnoremap <leader>p :bp<cr>
nnoremap <leader>n :bn<cr>

inoremap <M-o>       <Esc>o
inoremap <C-j>       <Down>
let g:ragtag_global_maps = 1
" open terminal
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" nnoremap <leader>t :below 10sp term://$SHELL<cr>i
" hit <Escape> key to exit from terminal mode
:tnoremap <Esc> <C-\><C-n>

" remap window split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" window split creation
nnoremap <leader>vv :vsplit<cr>
nnoremap <leader>hh :split<cr>

" cycle buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:nnoremap <leader>n :bnext<CR>
:nnoremap <leader>p :bprevious<CR>

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
