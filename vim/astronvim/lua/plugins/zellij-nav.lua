---@type LazySpec
return {
  {
    "swaits/zellij-nav.nvim",
    lazy = false,
    enabled = vim.env.ZELLIJ ~= nil,
    init = function()
      -- Set up keymaps immediately when plugin is initialized
      vim.keymap.set("n", "<c-h>", "<cmd>ZellijNavigateLeftTab<cr>", { silent = true, desc = "navigate left or tab" })
      vim.keymap.set("n", "<c-j>", "<cmd>ZellijNavigateDown<cr>", { silent = true, desc = "navigate down" })
      vim.keymap.set("n", "<c-k>", "<cmd>ZellijNavigateUp<cr>", { silent = true, desc = "navigate up" })
      vim.keymap.set("n", "<c-l>", "<cmd>ZellijNavigateRightTab<cr>", { silent = true, desc = "navigate right or tab" })
      
      -- Pass Ctrl-B through to Zellij for session management
      vim.keymap.set({"n", "i", "v", "t"}, "<C-b>", function()
        -- Temporarily unlock Zellij and send Ctrl-B
        vim.fn.system("zellij action switch-mode normal")
        vim.fn.system("zellij action write 2") -- Send Ctrl-B (ASCII code 2)
      end, { silent = true, desc = "Pass Ctrl-B to Zellij" })
      
      -- Tab navigation keybindings
      -- First, unmap any existing Alt-Tab bindings
      pcall(vim.keymap.del, "n", "<A-Tab>")
      pcall(vim.keymap.del, "i", "<A-Tab>")
      pcall(vim.keymap.del, "v", "<A-Tab>")
      pcall(vim.keymap.del, "n", "<A-S-Tab>")
      pcall(vim.keymap.del, "i", "<A-S-Tab>")
      pcall(vim.keymap.del, "v", "<A-S-Tab>")
      
      -- Set up Zellij tab navigation for all modes
      local function next_tab()
        -- Unlock and switch tab (will re-lock on FocusGained)
        vim.fn.system("zellij action switch-mode normal")
        vim.fn.system("zellij action go-to-next-tab")
      end
      
      local function prev_tab()
        -- Unlock and switch tab (will re-lock on FocusGained)
        vim.fn.system("zellij action switch-mode normal")
        vim.fn.system("zellij action go-to-previous-tab")
      end
      
      vim.keymap.set({"n", "i", "v"}, "<A-Tab>", next_tab, { silent = true, desc = "Zellij next tab" })
      vim.keymap.set({"n", "i", "v"}, "<A-S-Tab>", prev_tab, { silent = true, desc = "Zellij previous tab" })
      
      -- Direct tab access (Alt+1 through Alt+9)
      for i = 1, 9 do
        vim.keymap.set("n", "<A-" .. i .. ">", function()
          -- Unlock and switch to specific tab (will re-lock on FocusGained)
          vim.fn.system("zellij action switch-mode normal")
          vim.fn.system("zellij action go-to-tab " .. i)
        end, { silent = true, desc = "Zellij tab " .. i })
      end
      
      -- Enable focus event detection in terminal
      vim.o.autoread = true
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
        command = "if mode() != 'c' | checktime | endif",
        pattern = { "*" },
      })
      
      -- Enable focus reporting in terminal (works for Kitty, Ghostty, and other modern terminals)
      if vim.env.TERM and not vim.g.neovide then
        vim.cmd [[
          let &t_fe = "\<Esc>[?1004h"
          let &t_fd = "\<Esc>[?1004l"
          execute "set <FocusGained>=\<Esc>[I"
          execute "set <FocusLost>=\<Esc>[O"
        ]]
      end
      
      -- Lock zellij when starting
      vim.cmd "silent !zellij action switch-mode locked"
    end,
    opts = {},
    config = function(_, opts)
      require("zellij-nav").setup(opts)
      
      -- Create augroup for zellij handling
      local augroup = vim.api.nvim_create_augroup("ZellijIntegration", { clear = true })
      
      -- Unlock when leaving Vim completely
      vim.api.nvim_create_autocmd("VimLeave", {
        group = augroup,
        pattern = "*",
        command = "silent !zellij action switch-mode normal",
      })
      
      -- Handle focus events
      vim.api.nvim_create_autocmd("FocusGained", {
        group = augroup,
        pattern = "*",
        callback = function()
          -- Lock zellij when Vim gains focus
          vim.fn.system("zellij action switch-mode locked")
        end,
      })
      
      vim.api.nvim_create_autocmd("FocusLost", {
        group = augroup,
        pattern = "*",
        callback = function()
          -- Unlock zellij when Vim loses focus
          vim.fn.system("zellij action switch-mode normal")
        end,
      })
      
      -- Enter insert mode when entering a terminal window
      vim.api.nvim_create_autocmd("WinEnter", {
        group = augroup,
        pattern = "*",
        callback = function()
          if vim.bo.buftype == "terminal" then
            vim.cmd("startinsert")
          end
        end,
      })
    end,
  },
}
