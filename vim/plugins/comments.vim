Plug 'numToStr/Comment.nvim'

augroup Comment
    autocmd!
    autocmd User PlugLoaded ++nested lua require('Comment').setup()
augroup end
