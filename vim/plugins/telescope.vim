if has('nvim-0.5')
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    nnoremap <leader>f <cmd>Telescope find_files<cr>
    nnoremap <leader>g <cmd>Telescope live_grep<cr>
    nnoremap <leader>B <cmd>Telescope buffers<cr>
    nnoremap <leader>G <cmd>Telescope grep_string<cr>
end
