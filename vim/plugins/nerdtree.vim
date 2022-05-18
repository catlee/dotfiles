Plug 'preservim/nerdtree'

" Open NerdTree at the current file
nnoremap <expr> <leader>n g:NERDTree.IsOpen() ? ':NERDTreeClose<CR>' : @% == '' ? ':NERDTree<CR>' : ':NERDTreeFind<CR>'

let NERDTreeWinSize=40
