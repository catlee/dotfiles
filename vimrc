" Vundle plugin management {{{
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
" Plugin 'vim-airline/vim-airline'
Plugin 'itchyny/lightline.vim'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-repeat'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'rust-lang/rust.vim'
Plugin 'w0rp/ale'
Plugin 'junegunn/fzf.vim'
set rtp+=~/.fzf
Plugin 'junegunn/seoul256.vim'
Plugin 'lifepillar/vim-solarized8'
Plugin 'machakann/vim-highlightedyank'
Plugin 'ambv/black'
" Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'PeterRincker/vim-argumentative'
Plugin 'jamessan/vim-gnupg'
Plugin 'mileszs/ack.vim'
Plugin 'justinmk/vim-sneak'
Plugin 'michaeljsmith/vim-indent-object'
Plugin 'takac/vim-hardtime'
Plugin 'mbbill/undotree'
call vundle#end()
" }}}

" Plugin settings {{{
let g:ultisnips_python_style='google'
let g:ale_python_mypy_options='--ignore-missing-imports --cache-dir=/dev/null'
let g:ackprg = "ag --vimgrep"
let g:ale_python_flake8_options = "--max-line-length=89"
" let g:hardtime_default_on = 1
" }}}

" Standard settings {{{
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
" }}}

" Keybindings {{{
" Editing/sourcing vimrc
noremap <leader>s :source ~/.vimrc<cr>
noremap <leader>e :new ~/.vimrc<cr>

" Don't highlight
nnoremap <C-h> :nohlsearch<cr>

" Map jk to escape
inoremap jk <Esc>

" Map X to :xa
cnoremap X xa

" Map Ctrl-F to convert to f-string
inoremap <C-f> <Esc>ma?['"]<CR>:nohlsearch<CR>if<Esc>`ala

" Move between warnings easily
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

"
" Intelligently navigate tmux panes and Vim splits using the same keys.
" See https://sunaku.github.io/tmux-select-pane.html for documentation.
let progname = substitute($VIM, '.*[/\\]', '', '')
set title titlestring=%{progname}\ %f\ +%l\ #%{tabpagenr()}.%{winnr()}
if &term =~ '^screen' && !has('nvim') | exe "set t_ts=\e]2; t_fs=\7" | endif

" }}}

" Filetype settings {{{
augroup filetype_yaml
    autocmd!
    "autocmd FileType yaml setlocal ts=3 sts=3 sw=3 expandtab
    autocmd FileType yaml setl indentkeys-=<:>
augroup END
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END
augroup filetype_js
    autocmd!
    autocmd FileType javascript set ts=2
    autocmd FileType javascript set sw=2
augroup END
augroup filetype_py
    autocmd!
    autocmd FileType python let b:ale_linters = ['flake8']
    "autocmd BufWritePre *.py execute ':Black'
augroup END
" }}}

" Neovim settings {{{
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

    " Use the host's python
    let g:python_host_prog = '/usr/bin/python'
    let g:python3_host_prog = '/usr/bin/python3'
endif
" }}}
