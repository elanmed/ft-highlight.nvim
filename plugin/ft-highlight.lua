vim.keymap.set({ "n", "v", "o" }, "<Plug>FtHighlight_f", function()
  return require("ft-highlight").on_key { key = "f", forward = true }
end, { expr = true })
vim.keymap.set({ "n", "v", "o" }, "<Plug>FtHighlight_F", function()
  return require("ft-highlight").on_key { key = "F", forward = false }
end, { expr = true })
vim.keymap.set({ "n", "v", "o" }, "<Plug>FtHighlight_t", function()
  return require("ft-highlight").on_key { key = "t", forward = true }
end, { expr = true })
vim.keymap.set({ "n", "v", "o" }, "<Plug>FtHighlight_T", function()
  return require("ft-highlight").on_key { key = "T", forward = false }
end, { expr = true })
