Plug 'windwp/nvim-autopairs'

augroup Autopairs
    autocmd!
    autocmd User PlugLoaded ++nested lua require("nvim-autopairs").setup {}
augroup END
