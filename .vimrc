" Syntax stuff
set nocompatible
set wildmenu
set modeline
set history=1000
set laststatus=2
set statusline=%F%m%r%h%w\ [%{&ff}]\ %y\ [POS=%03l/%L,%03v][%p%%]
set nofsync
set hidden

syn on
filetype on
filetype indent on
filetype plugin on
let python_highlight_all=1
let html_use_css=1
"set spelllang=en_ca
au BufEnter *.inc set filetype=php
au BufEnter /tmp/cvs* set tw=75
au BufEnter svn-commit.tmp* set tw=75
au FileType make set noexpandtab
au BufEnter */make/C++* set filetype=make
au BufEnter */make/common* set filetype=make
au BufEnter master*.cfg set filetype=python
autocmd FileType python compiler pylint
let g:pylint_onwrite = 0

" Key bindings
map! <C-F> <C-X><C-F>
vnoremap C :TC<CR>

" Manage vimrc
map ,s :source ~/.vimrc<CR>
map ,e :sp ~/.vimrc<CR>

" Editing settings
set showmatch
set shiftwidth=4
set tabstop=8
set softtabstop=4
set expandtab
set autoindent
set backspace=2
set incsearch
set hlsearch

" Vim behaviour
set updatetime=1000
set autowrite
set viminfo='1000,f1,<500,/50,:50
" Save the state of editing files
"au BufWinLeave *.* mkview
"au BufWinEnter *.* silent loadview

" GUI stuff
au GUIEnter * set guifont="Monospace 10"

" Remap the tab key to do autocompletion or indentation depending on the
" context (from http://www.vim.org/tips/tip.php?tip_id=102)
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>
