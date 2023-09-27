M = {}

M.compile_command = function()
  -- TODO add some sort of history
  -- Define the size of the floating window
  local width = 60
  local height = 1
  local prompt_prefix = "> "

  -- Create the prompt buffer that will be displayed
  local bufnr = vim.api.nvim_create_buf(false, true)
  assert(bufnr, "failed to create buffer")
  vim.api.nvim_buf_set_option(bufnr, "buftype", "prompt")
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")

  -- Config the prompt
  vim.fn.prompt_setprompt(bufnr, prompt_prefix)
  vim.fn.prompt_setcallback(bufnr, function(input)
    vim.opt.makeprg = input
    vim.cmd("close!")
  end)

  -- Get the current UI
  local ui = vim.api.nvim_list_uis()[1]

  -- Create the floating window
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = (ui.width / 2) - (width / 2),
    row = (ui.height / 3) - (height / 3),
    style = "minimal",
    border = "rounded",
    title = { { " Compile Command ", "FloatBorder" } },
    title_pos = "center",
  }

  -- Creating the window
  local win = vim.api.nvim_open_win(bufnr, true, opts)
  assert(win, "failed to create a window")
  vim.cmd("startinsert")

  -- Update the prompt with the current makeprg
  vim.defer_fn(function()
    local current_makeprg = vim.opt.makeprg:get()
    vim.api.nvim_buf_set_text(bufnr, 0, #prompt_prefix, 0, #prompt_prefix, { current_makeprg })
    vim.api.nvim_win_set_cursor(win, { 1, #prompt_prefix + #current_makeprg + 1 })
  end, 0)

  -- Useful bindings
  vim.keymap.set("n", "<esc>", "<cmd>close!<cr>", { silent = true, buffer = bufnr })
  vim.keymap.set("n", "q", "<cmd>close!<cr>", { silent = true, buffer = bufnr })
  vim.keymap.set("i", "<C-W>", "<C-S-W>", { silent = true, buffer = bufnr })
end

M.run = function()
  -- TODO: manage only one buffer instead of creating one everytime
  local bufnr = vim.api.nvim_create_buf(true, true)
  assert(bufnr, "failed to create buffer")

  -- This is currently nvim-0.9.1 and we cannot create vertical windows via the nvim api, see
  -- https://github.com/neovim/neovim/issues/14315
  -- see `:h vertical`, `:h botright` and `:h sbuffer` if you do not understand this line.
  vim.cmd("vertical botright sbuffer" .. tostring(bufnr))

  -- Setup the look of the window
  local winnr = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_option(winnr, "number", false)
  vim.api.nvim_win_set_option(winnr, "relativenumber", false)

  -- Clear the qf list
  vim.fn.setqflist({}, "r")

  local chan_id = vim.fn.termopen(vim.opt.makeprg:get(), {
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.fn.setqflist({}, "a", {
          lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false),
          title = "Compile errors",
        })
      end
    end,
  })

  -- Useful bindings
  vim.keymap.set("n", "q", "<cmd>close!<cr>", { silent = true, buffer = bufnr })
  vim.keymap.set("n", "s", function()
    vim.fn.jobstop(chan_id)
  end)
end

return M
