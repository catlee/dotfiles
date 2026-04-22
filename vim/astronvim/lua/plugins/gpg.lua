---@type LazySpec
return {
  {
    "jamessan/vim-gnupg",
    lazy = false,
    init = function()
      -- Keep decrypted content off disk by using pipes instead of temp files.
      vim.g.GPGUsePipes = 1
    end,
  },
}
