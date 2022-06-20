if has('nvim-0.6')
    Plug 'neovim/nvim-lspconfig'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'RRethy/nvim-treesitter-textsubjects'
    Plug 'RRethy/nvim-treesitter-endwise'
    Plug 'nvim-treesitter/playground'
    augroup Treesitter
        autocmd!
        autocmd User PlugLoaded ++nested call s:setup()
    augroup END
end

func s:setup()
lua << EOF
require("nvim-treesitter.configs").setup {
    ensure_installed = { "bash", "json", "lua", "make", "markdown", "python", "ruby", "rust", "vim", "yaml" },
    highlight = { enable = true, },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
            },
        },
    indent = { enable = true },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
                },
            },
        swap = {
            enable = true,
            swap_next = {
                [">,"] = "@parameter.inner",
                },
            swap_previous = {
                ["<,"] = "@parameter.inner",
                },
            },
        move = {
            enable = true,
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = "@class.outer",
                },
            goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
                },
            goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer",
                },
            goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
                },
            },
        },
    textsubjects = {
        enable = true,
        keymaps = {
            ['.'] = 'textsubjects-smart',
            [';'] = 'textsubjects-container-outer',
            },
        },
    endwise = { enable = true },
    }
EOF
endfunc
