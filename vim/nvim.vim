" Neovim settings {{{
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

" Show effects of a command incrementally
set inccommand=split

if has('nvim-0.6')
    source ~/.config/nvim/lsp.vim
endif
