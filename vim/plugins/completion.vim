Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

set completeopt=menu,menuone,noselect

func s:setupComp()
lua <<EOF
require('cmp').setup({
sources = {
    { name = 'buffer' },
    { name = 'path' },
    { name = 'nvim_lsp' },
}
})
EOF
endfunc

augroup Complete
    autocmd!
    autocmd User PlugLoaded ++nested call s:setupComp()
augroup END

