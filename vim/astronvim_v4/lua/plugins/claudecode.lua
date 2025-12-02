---@type LazySpec
return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal = {
        split_width_percentage = 0.40, -- Set to 40% width (default is 30%)
      },
    },
    config = function(_, opts)
      require("claudecode").setup(opts)

      -- Set up navigation keymaps for Claude Code windows
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "*",
        callback = function()
          -- Check if this is a Claude Code terminal
          local bufname = vim.api.nvim_buf_get_name(0)
          if bufname:match "claude" then
            local bufnr = vim.api.nvim_get_current_buf()
            local keymap_opts = { buffer = bufnr, noremap = true, silent = true }
            -- Terminal mode navigation mappings using <C-w> prefix
            vim.keymap.set("t", "<C-w>h", "<C-\\><C-n><C-w>h", keymap_opts)
            vim.keymap.set("t", "<C-w>j", "<C-\\><C-n><C-w>j", keymap_opts)
            vim.keymap.set("t", "<C-w>k", "<C-\\><C-n><C-w>k", keymap_opts)
            vim.keymap.set("t", "<C-w>l", "<C-\\><C-n><C-w>l", keymap_opts)
            
            -- Direct Zellij navigation from terminal mode
            vim.keymap.set("t", "<C-h>", "<C-\\><C-n><cmd>ZellijNavigateLeftTab<cr>", keymap_opts)
            vim.keymap.set("t", "<C-j>", "<C-\\><C-n><cmd>ZellijNavigateDown<cr>", keymap_opts)
            vim.keymap.set("t", "<C-k>", "<C-\\><C-n><cmd>ZellijNavigateUp<cr>", keymap_opts)
            vim.keymap.set("t", "<C-l>", "<C-\\><C-n><cmd>ZellijNavigateRightTab<cr>", keymap_opts)
          end
        end,
      })
    end,
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr><cmd>ClaudeCodeFocus<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr><cmd>ClaudeCodeFocus<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
}
