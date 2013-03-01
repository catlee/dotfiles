set nocompatible
" let mapleader="\"
" Load pathogen
filetype off
set smartcase
set ignorecase
set scrolloff=4

set encoding=utf-8

call pathogen#infect()
call pathogen#helptags()

filetype plugin indent on
syntax on
colorscheme zellner

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
