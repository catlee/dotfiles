local HAVE_TMUX = vim.fn.executable "tmux" == 1

return {
  { "preservim/vimux", enabled = HAVE_TMUX },
  {
    "vim-test/vim-test",
    config = function()
      if HAVE_TMUX then
        vim.g["test#strategy"] = "vimux"
      else
        vim.g["test#strategy"] = "neovim"
      end

      vim.cmd [[
      function! ClearTransform(cmd) abort
        return 'clear; ' . a:cmd
      endfunction
      let g:test#custom_transformations = {'clear': function('ClearTransform')}
      let g:test#transformation = 'clear'
      let test#ruby#rspec#executable = 'bundle exec rspec'

      function! TestContext()
      wall
      let [_, lnum, cnum, _] = getpos('.')
      RubyBlockSpecParentContext
      TestNearest
      call cursor(lnum, cnum)
      endfunction

      command! TestContext :call TestContext()

      autocmd FileType ruby,erb nnoremap <silent> <LocalLeader>rc :TestContext<CR>
      nnoremap <silent> <leader>rf :wa<CR>:TestNearest<CR>
      nnoremap <silent> <leader>rb :wa<CR>:TestFile<CR>
      nnoremap <silent> <leader>ra :wa<CR>:TestSuite<CR>
      nnoremap <silent> <leader>rl :wa<CR>:TestLast<CR>

      let test#ruby#use_binstubs = 1
      if filereadable(glob("bin/test"))
        let test#ruby#minitest#executable = 'bin/test'
      endif
    ]]
    end,
  },
}
