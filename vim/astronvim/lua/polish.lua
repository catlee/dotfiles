-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Prevent dedenting in Ruby after typing '.'
vim.cmd "autocmd FileType ruby setlocal indentkeys-=."
