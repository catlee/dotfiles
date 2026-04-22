---@type LazySpec
return {
  "klimeryk/vim-monkey-c",
  ft = { "monkey-c" },
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "monkey-c",
      callback = function()
        vim.opt_local.autoindent = true
        vim.opt_local.smartindent = true
      end,
    })
  end,
}
