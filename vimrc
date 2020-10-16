" Plugin management {{{
call plug#begin()

" Plug 'vim-airline/vim-airline'
" Plug 'airblade/vim-rooter'
" Plug 'cespare/vim-toml'
Plug 'honza/vim-snippets'
Plug 'itchyny/lightline.vim'
Plug 'jamessan/vim-gnupg'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/seoul256.vim'
Plug 'justinmk/vim-sneak'
Plug 'lifepillar/vim-solarized8'
Plug 'machakann/vim-highlightedyank'
" Plug 'mattboehm/vim-unstack'
Plug 'mbbill/undotree'
Plug 'michaeljsmith/vim-indent-object'
" Plug 'mileszs/ack.vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 'peterrincker/vim-argumentative'
Plug 'psf/black', {'tag': '19.10b0'}
Plug 'rust-lang/rust.vim'
Plug 'sirver/ultisnips'
Plug 'sunaku/tmux-navigate'
Plug 'takac/vim-hardtime'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/indentpython.vim'
" Plug 'w0rp/ale'
Plug 'catlee/logdelta'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'terryma/vim-multiple-cursors'
Plug 'ThePrimeagen/vim-be-good', {'do': './install.sh'}
call plug#end()
" }}}

" Plugin settings {{{
let g:ultisnips_python_style='google'
let g:ale_python_mypy_options='--ignore-missing-imports --cache-dir=/dev/null'
let g:ackprg = "ag --vimgrep"
let g:ale_python_flake8_options = "--max-line-length=89"
" let g:hardtime_default_on = 1
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_tags_command = 'ctags -R'
" Border color
let g:fzf_layout = {'up':'~90%', 'window': { 'width': 0.8, 'height': 0.8,'yoffset':0.5,'xoffset': 0.5, 'highlight': 'Todo', 'border': 'sharp' } }

let $FZF_DEFAULT_OPTS = '--layout=reverse --info=inline'
let $FZF_DEFAULT_COMMAND="fdfind --type f --exclude '**/*.pyc'"

let g:lightline = {
    \ 'colorscheme': 'wombat',
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
    \ },
    \ 'component_function': {
    \   'cocstatus': 'coc#status'
    \ },
    \ }

" Use autocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
" }}}

" Standard settings {{{
set nocompatible
filetype plugin indent on
syntax enable

" Tabs are evil
set et
set smarttab

set hlsearch
set incsearch
set sts=4
set sw=4
set number
set relativenumber
set smartcase
set ignorecase
set scrolloff=4
set encoding=utf-8
set complete+=i
set showtabline=2
set noshowmode

set background=dark
colorscheme solarized8

" show tabs and trailing space
set list
set listchars=tab:>-,trail:.
" }}}

" Keybindings {{{
" Editing/sourcing vimrc
noremap <leader>S :source ~/.vimrc<cr>
noremap <leader>e :new ~/.vimrc<cr>

" Don't highlight
nnoremap <C-h> :nohlsearch<cr>

" Map jk to escape
inoremap jk <Esc>

" Map H/L to move to the beginning/end of a line
nnoremap H ^
nnoremap L g_

" Map Ctrl-F to convert to f-string
inoremap <C-f> <Esc>ma?['"]<CR>:nohlsearch<CR>if<Esc>`ala

" Move between warnings easily
" nmap <silent> <C-k> <Plug>(ale_previous_wrap)
" nmap <silent> <C-j> <Plug>(ale_next_wrap)

" Use TAB/Shift-TAB to move between tabs
nnoremap <TAB> :tabnext<CR>
nnoremap <S-TAB> :tabprevious<CR>

" Better tabbing in visual mode
vnoremap < <gv
vnoremap > >gv

" Commenting
nnoremap <leader>/ :Commentary<CR>
vnoremap <leader>/ :Commentary<CR>

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command, '--header', '$FILE']}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

map <leader>f :Files<CR>
map <leader>b :Buffers<CR>
map <leader>g :RG<CR>

nnoremap <c-n> :cnext<cr>
nnoremap <c-p> :cprev<cr>

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif
" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>F  <Plug>(coc-format-selected)
nmap <leader>F  <Plug>(coc-format-selected)
" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" path text objects
" -----------------
" i/ a/
function! VisualPath()
    " find the end of the current path segment
    call search('[^/: "=]\+', 'ceW')
    silent! normal! v
    " find the beginning of the current path segment
    call search('[^/: "=]\+', 'bW')
endfunction
xnoremap i/ :<C-u>silent! call VisualPath()<CR>
onoremap i/ :<C-u>silent! normal vi/<CR>
xnoremap a/ :<C-u>silent! call VisualPath()<CR>
onoremap a/ :<C-u>silent! normal va/<CR>

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
    " tnoremap <Esc> <C-\><C-n>
    " tnoremap <M-[> <Esc>
    " tnoremap <C-v><Esc> <Esc>
    " tnoremap <C-v><Esc> <Esc>

    " Move between windows
    tnoremap <A-h> <C-\><C-n><C-w>h
    tnoremap <A-j> <C-\><C-n><C-w>j
    tnoremap <A-k> <C-\><C-n><C-w>k
    tnoremap <A-l> <C-\><C-n><C-w>l
    noremap <A-h> <C-w>h
    noremap <A-j> <C-w>j
    noremap <A-k> <C-w>k
    noremap <A-l> <C-w>l
    " Use ctrl + hjkl to resize windows
    nnoremap <C-j>    :resize -2<CR>
    nnoremap <C-k>    :resize +2<CR>
    " nnoremap <C-h>    :vertical resize -2<CR>
    " nnoremap <C-l>    :vertical resize +2<CR>

    " Show effects of a command incrementally
    set inccommand=split

    " Use the host's python
    let g:python_host_prog = '/usr/bin/python'
    let g:python3_host_prog = '/usr/bin/python3'
endif
" }}}
