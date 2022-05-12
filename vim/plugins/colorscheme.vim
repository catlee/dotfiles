Plug 'lifepillar/vim-solarized8'
let g:solarized_extra_hi_groups = 1

set bg=dark

augroup ColorSchemeOverride
    autocmd!
    autocmd User PlugLoaded ++nested colorscheme solarized8_low
augroup end
