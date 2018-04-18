" Load Vundle
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'rust-lang/rust.vim'
Plugin 'w0rp/ale'
Plugin 'junegunn/fzf.vim'
set rtp+=~/.fzf
Plugin 'junegunn/seoul256.vim'
Plugin 'lifepillar/vim-solarized8'
Plugin 'machakann/vim-highlightedyank'
Plugin 'ambv/black', {'rtp': 'vim'}
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
call vundle#end()

" Standard settings
set nocompatible
filetype plugin indent on
syntax on

" Tabs are evil
set et

set hlsearch
set incsearch
set sts=4
set sw=4
set number
set smartcase
set ignorecase
set scrolloff=4
set encoding=utf-8
set complete+=i

set background=dark
colorscheme solarized8

" show tabs and trailing space
set list
set listchars=tab:>-,trail:.

" Editing/sourcing vimrc
noremap <leader>s :source ~/.vimrc<cr>
noremap <leader>e :new ~/.vimrc<cr>

" Don't highlight
nnoremap <C-h> :nohlsearch<cr>

" Map jk to escape
inoremap jk <Esc>

let g:ultisnips_python_style='google'

autocmd FileType yaml setlocal ts=3 sts=3 sw=3 expandtab
autocmd FileType yaml setl indentkeys-=<:>

if has('nvim')
    " Make Esc exit out of terminal mode
    " Use Alt-[ or Ctrl-V Esc to pass escape to terminal
    tnoremap <Esc> <C-\><C-n>
    tnoremap <M-[> <Esc>
    tnoremap <C-v><Esc> <Esc>
    tnoremap <C-v><Esc> <Esc>

    " Move between windows
    tnoremap <A-h> <C-\><C-n><C-w>h
    tnoremap <A-j> <C-\><C-n><C-w>j
    tnoremap <A-k> <C-\><C-n><C-w>k
    tnoremap <A-l> <C-\><C-n><C-w>l
    noremap <A-h> <C-w>h
    noremap <A-j> <C-w>j
    noremap <A-k> <C-w>k
    noremap <A-l> <C-w>l

    " Show effects of a command incrementally
    set inccommand=split
endif
