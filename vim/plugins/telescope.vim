if has('nvim-0.5')
    Plug 'nvim-lua/completion-nvim'
    Plug 'nvim-lua/popup.nvim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    nnoremap <leader>f <cmd>Telescope find_files<cr>
    nnoremap <leader>g <cmd>Telescope live_grep<cr>
    nnoremap <leader>B <cmd>Telescope buffers<cr>
    nnoremap <leader>G <cmd>Telescope grep_string<cr>
end

func s:setup()
lua << EOF
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local telescope_custom_actions = {}

function telescope_custom_actions._multiopen(prompt_bufnr, open_cmd)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local selected_entry = action_state.get_selected_entry()
    local num_selections = #picker:get_multi_selection()
    if not num_selections or num_selections <= 1 then
        actions.add_selection(prompt_bufnr)
    end
    actions.send_selected_to_qflist(prompt_bufnr)
    vim.cmd("cfdo " .. open_cmd)
end
function telescope_custom_actions.multi_selection_open_vsplit(prompt_bufnr)
    telescope_custom_actions._multiopen(prompt_bufnr, "vsplit")
end
function telescope_custom_actions.multi_selection_open_split(prompt_bufnr)
    telescope_custom_actions._multiopen(prompt_bufnr, "split")
end
function telescope_custom_actions.multi_selection_open_tab(prompt_bufnr)
    telescope_custom_actions._multiopen(prompt_bufnr, "tabe")
end
function telescope_custom_actions.multi_selection_open(prompt_bufnr)
    telescope_custom_actions._multiopen(prompt_bufnr, "edit")
end

require('telescope').setup({
    defaults = {
        mappings = {
            i = {
                ["<ESC>"] = actions.close,
                ["<C-J>"] = actions.move_selection_next,
                ["<C-K>"] = actions.move_selection_previous,
                ["<TAB>"] = actions.toggle_selection,
                ["<C-TAB>"] = actions.toggle_selection + actions.move_selection_next,
                ["<S-TAB>"] = actions.toggle_selection + actions.move_selection_previous,
                ["<CR>"] = telescope_custom_actions.multi_selection_open,
                ["<C-V>"] = telescope_custom_actions.multi_selection_open_vsplit,
                ["<C-S>"] = telescope_custom_actions.multi_selection_open_split,
                ["<C-T>"] = telescope_custom_actions.multi_selection_open_tab,
                ["<C-DOWN>"] = require('telescope.actions').cycle_history_next,
                ["<C-UP>"] = require('telescope.actions').cycle_history_prev,
            },
            n = i,
        },

   }
})
EOF
endfunc

augroup Telescope
    autocmd!
    autocmd User PlugLoaded ++nested call s:setup()
augroup END

