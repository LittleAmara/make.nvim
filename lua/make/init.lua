M = {}

M.compile_command = function()
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
end

return M
