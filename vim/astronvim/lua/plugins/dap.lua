---@type LazySpec
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "suketa/nvim-dap-ruby", -- Used as fallback when no launch.json exists
    },
    config = function()
      local dap = require("dap")

      -- Custom adapter that handles "program" field like VS Code's ruby_lsp
      -- This allows loading .vscode/launch.json files directly
      dap.adapters.ruby_lsp = function(callback, config)
        -- For attach requests, just connect to the running debugger
        if config.request == "attach" then
          callback({
            type = "server",
            host = config.host or "127.0.0.1",
            port = config.port or 38698,
          })
          return
        end

        local program = config.program or ("ruby " .. vim.fn.expand("%:p"))
        -- Substitute VS Code variables
        program = program:gsub("%${file}", vim.fn.expand("%:p"))
        program = program:gsub("%${relativeFile}", vim.fn.expand("%"))
        program = program:gsub("%${lineNumber}", tostring(vim.fn.line(".")))
        program = program:gsub("%${workspaceFolder}", vim.fn.getcwd())

        -- Pick a random port
        local port = math.random(49152, 65535)
        local host = "127.0.0.1"

        -- Detect if this is a test or a long-running server
        local is_test = program:match("test") or program:match("rspec") or program:match("spec")
        local is_server = program:match("server") or program:match("worker") or program:match("job%-worker")

        -- Build env vars
        local env_vars = {
          "RUBY_DEBUG_OPEN=true",
          "RUBY_DEBUG_HOST=" .. host,
          "RUBY_DEBUG_PORT=" .. tostring(port),
        }

        -- For servers: nonstop so the server boots and we hit breakpoints on requests
        if is_server then
          table.insert(env_vars, "RUBY_DEBUG_NONSTOP=true")
        end

        if config.env then
          for k, v in pairs(config.env) do
            table.insert(env_vars, k .. "=" .. v)
          end
        end

        -- Build the command string
        -- -n is --nonstop, only use for servers
        -- For tests: use --stop-at-load to pause before code runs
        local rdbg_flags = "--open --port " .. port
        if is_test then
          rdbg_flags = rdbg_flags .. " --stop-at-load"
        else
          rdbg_flags = "-n " .. rdbg_flags  -- nonstop for servers
        end
        local cmd = table.concat(env_vars, " ") .. " bundle exec rdbg " .. rdbg_flags .. " --command -- " .. program

        -- Log the full command for debugging (to file since notifications disappear)
        local log_file = io.open("/tmp/dap-ruby.log", "a")
        if log_file then
          log_file:write(os.date() .. " Running: " .. cmd .. "\n")
          log_file:close()
        end

        -- Use termopen to run in a terminal buffer (provides PTY for test reporters)
        -- Create a new buffer for the terminal
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buf, "DAP: " .. (config.name or "ruby"))

        -- Open terminal in the buffer
        vim.api.nvim_buf_call(buf, function()
          vim.fn.termopen(cmd, {
            cwd = vim.fn.getcwd(),
            on_exit = function(_, code)
              local log_file = io.open("/tmp/dap-ruby.log", "a")
              if log_file then
                log_file:write(os.date() .. " Exited with code " .. code .. "\n")
                log_file:close()
              end
              -- Close the terminal buffer when done (delay to allow reading output)
              vim.defer_fn(function()
                if vim.api.nvim_buf_is_valid(buf) then
                  -- Find and close any windows showing this buffer
                  for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_get_buf(win) == buf then
                      vim.api.nvim_win_close(win, true)
                    end
                  end
                  vim.api.nvim_buf_delete(buf, { force = true })
                end
              end, 1000)
            end,
          })
        end)

        -- Show the terminal in a split
        vim.cmd("sbuffer " .. buf)

        -- Wait for debugger to be ready, then connect
        vim.defer_fn(function()
          callback({
            type = "server",
            host = host,
            port = port,
          })
        end, 2000)
      end

      -- nvim-dap automatically loads .vscode/launch.json when dap.continue() is called.
      -- We just need the ruby_lsp adapter defined above, and nvim-dap-ruby as fallback
      -- for projects without a launch.json.
      require("dap-ruby").setup()
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    opts = {
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 60, -- Width of the side panel (default is 40)
          position = "left",
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          size = 0.25,
          position = "bottom",
        },
      },
    },
  },
}
