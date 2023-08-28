local make = require("make")

vim.keymap.set("n", "<space><leader>", make.compile_command, {})
vim.keymap.set("n", "<space><CR>", make.run, {})
