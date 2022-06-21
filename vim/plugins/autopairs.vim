if has('nvim-0.7')
Plug 'windwp/nvim-autopairs'

augroup Autopairs
    autocmd!
    autocmd User PlugLoaded ++nested lua require("nvim-autopairs").setup {}
augroup END
end
