local make = require("make")

vim.keymap.set("n", "<leader>m", make.compile_command, {})
