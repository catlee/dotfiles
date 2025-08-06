-- Helper script to clean up old Mason Ruby installations
-- Run with: :lua require("plugins.mason-cleanup").clean()

local M = {}

function M.list_installations()
  local data_path = vim.fn.stdpath("data")
  local installations = vim.fn.glob(data_path .. "/mason-ruby-*", false, true)
  
  if #installations == 0 then
    print("No Mason Ruby installations found")
    return {}
  end
  
  print("Found Mason Ruby installations:")
  for i, path in ipairs(installations) do
    local hash = path:match("mason%-ruby%-([^/]+)$")
    print(string.format("%d. %s (hash: %s)", i, path, hash or "unknown"))
  end
  
  return installations
end

function M.get_current_hash()
  local components = {}
  local ruby_path = vim.fn.system("which ruby 2>/dev/null"):gsub("\n", "")
  if ruby_path ~= "" then table.insert(components, ruby_path) end
  local ruby_config = vim.fn.system([[ruby -e "require 'digest'; puts Digest::SHA256.hexdigest(RbConfig::CONFIG.to_s)" 2>/dev/null]]):gsub("\n", "")
  if ruby_config ~= "" then table.insert(components, ruby_config) end
  local env_vars = { "NIX_STORE", "NIX_PROFILES", "SHADOWENV_DATA", "RUBY_ROOT", "GEM_HOME", "GEM_PATH" }
  for _, var in ipairs(env_vars) do
    local value = vim.fn.getenv(var)
    if value and value ~= vim.NIL then table.insert(components, var .. "=" .. value) end
  end
  local combined = table.concat(components, "|")
  return vim.fn.sha256(combined):sub(1, 8)
end

function M.clean(keep_current)
  keep_current = keep_current ~= false -- default to true
  
  local installations = M.list_installations()
  if #installations == 0 then return end
  
  local current_hash = M.get_current_hash()
  local data_path = vim.fn.stdpath("data")
  local current_path = data_path .. "/mason-ruby-" .. current_hash
  
  print("\nCurrent Ruby environment hash: " .. current_hash)
  print("Current Mason path: " .. current_path)
  
  local to_remove = {}
  for _, path in ipairs(installations) do
    if not keep_current or path ~= current_path then
      table.insert(to_remove, path)
    end
  end
  
  if #to_remove == 0 then
    print("\nNo installations to remove")
    return
  end
  
  print("\nWill remove:")
  for _, path in ipairs(to_remove) do
    print("  - " .. path)
  end
  
  local confirm = vim.fn.input("\nProceed with cleanup? (y/N): ")
  if confirm:lower() == "y" then
    for _, path in ipairs(to_remove) do
      vim.fn.delete(path, "rf")
      print("Removed: " .. path)
    end
    print("\nCleanup complete!")
  else
    print("\nCleanup cancelled")
  end
end

return M