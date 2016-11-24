set nocompatible
colorscheme zellner
" let mapleader="\"
filetype off
set smartcase
set ignorecase
set scrolloff=4

set encoding=utf-8

" Load pathogen
" call pathogen#infect()
" call pathogen#helptags()

" Load Vundle
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

Plugin 'tmhedberg/SimpylFold'
let g:SimplyFold_docstring_preview=1
set foldmethod=indent
set foldlevel=99

Plugin 'vim-scripts/indentpython.vim'

Plugin 'Valloric/YouCompleteMe'
"Plugin 'scrooloose/syntastic'
Plugin 'nvie/vim-flake8'
autocmd BufWritePost *.py call Flake8()
let g:flake8_show_in_gutter=1

Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-fugitive'
Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'rust-lang/rust.vim'

call vundle#end()

let python_highlight_all=1

filetype plugin indent on
syntax on

" Tabs are evil
set et

set hlsearch
set incsearch
set sts=4
set sw=4

map <leader>s :source ~/.vimrc<cr>
map <leader>e :new ~/.vimrc<cr>

set number

nmap <F8> :TagbarToggle<CR>

" Show fancy status!
let g:Powerline_symbols = 'fancy'
set laststatus=2

" show tabs and trailing space
set list
set listchars=tab:>-,trail:.

" Don't highlight
nmap <C-h> :nohlsearch<cr>

" Disable rope
let g:pymode_rope=0

" Map jk to escape
inoremap jk <Esc>
