" Load pathogen
filetype off

call pathogen#infect()
call pathogen#helptags()

filetype plugin indent on
syntax on
colorscheme evening

" Tabs are evil
set et

set hlsearch
set incsearch
set sts=4
set sw=4

map <leader>s :source ~/.vimrc<cr>
map <leader>e :new ~/.vimrc<cr>
