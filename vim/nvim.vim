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

" Find files using Telescope command-line sugar.
if has('nvim-0.5')
    nnoremap <leader>f <cmd>Telescope find_files<cr>
    nnoremap <leader>g <cmd>Telescope live_grep<cr>
    nnoremap <leader>b <cmd>Telescope buffers<cr>
    nnoremap <leader>ex <cmd>Telescope file_browser<cr>
else
    nnoremap <leader>f <cmd>Files<cr>
    nnoremap <leader>g <cmd>Rg<cr>
    nnoremap <leader>b <cmd>Buffers<cr>
    let g:fzf_action = {
      \ 'ctrl-t': 'tab split',
      \ 'ctrl-x': 'split',
      \ 'ctrl-v': 'vsplit' }
    let g:fzf_tags_command = 'ctags -R'
    " Border color
    let g:fzf_layout = {'up':'~90%', 'window': { 'width': 0.8, 'height': 0.8,'yoffset':0.5,'xoffset': 0.5, 'highlight': 'Todo', 'border': 'sharp' } }
    let $FZF_DEFAULT_OPTS = '--layout=reverse --info=inline'
    let $FZF_DEFAULT_COMMAND="fd --type f --exclude '**/*.pyc'"
end

if has('nvim-0.6')
    source ~/.config/nvim/lsp.vim
end
