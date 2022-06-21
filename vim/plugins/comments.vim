if has('nvim-0.7')
Plug 'numToStr/Comment.nvim'

augroup Comment
    autocmd!
    autocmd User PlugLoaded ++nested lua require('Comment').setup()
augroup end
end
