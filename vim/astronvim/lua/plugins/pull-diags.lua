-- For nvim prior to 0.10
---@type LazySpec
return {
  {
    "catlee/pull_diags.nvim",
    -- dev = true,
    event = "LspAttach",
    opts = {},
  },
}
