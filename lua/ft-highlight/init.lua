local FTHighlight = require "lua.ft-highlight.class"
local ft_highlight = FTHighlight:new()

local M = {}

--- @class FTHighlightOpts
--- @field enabled boolean Enable the plugin. Defaults to `false`
--- @field default_keymaps boolean Set keymaps for `f`, `F`, `t`, and `T`. Defaults to `true`

--- @param opts { forward: boolean }
M.highlight = function(opts)
  return ft_highlight:highlight(opts)
end

M.clear_highlight = function()
  return ft_highlight:clear_highlight()
end

--- @param opts { key: "f"|"F"|"t"|"T", forward: boolean }
M.on_key = function(opts)
  ft_highlight:highlight { forward = opts.forward, }
  local input = vim.fn.nr2char(vim.fn.getchar())

  if ft_highlight.is_highlighted then
    ft_highlight:clear_highlight()
  end
  return opts.key .. input
end

--- @param opts FTHighlightOpts | nil
M.setup = function(opts)
  opts = opts or {}
  local enabled = opts.enabled or false
  local default_keymaps = opts.default_keymaps or true
  if not enabled then return end

  vim.api.nvim_set_hl(0, "FTHighlightFirst", { link = "Normal", })
  vim.api.nvim_set_hl(0, "FTHighlightSecond", { link = "DiagnosticWarn", })
  vim.api.nvim_set_hl(0, "FTHighlightThird", { link = "DiagnosticError", })
  vim.api.nvim_set_hl(0, "FTHighlightDimmed", { link = "Comment", })

  if default_keymaps then
    vim.keymap.set({ "n", "v", "o", }, "f", function() return M.on_key { key = "f", forward = true, } end,
      { expr = true, })
    vim.keymap.set({ "n", "v", "o", }, "F", function() return M.on_key { key = "F", forward = false, } end,
      { expr = true, })
    vim.keymap.set({ "n", "v", "o", }, "t", function() return M.on_key { key = "t", forward = true, } end,
      { expr = true, })
    vim.keymap.set({ "n", "v", "o", }, "T", function() return M.on_key { key = "T", forward = false, } end,
      { expr = true, })
  end
end

return M
