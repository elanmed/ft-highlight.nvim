local FTHighlight = require "ft-highlight.class"
local ft_highlight = FTHighlight:new()

local M = {}

--- @class FTHighlightOpts
--- @field enabled boolean Enable the plugin. Defaults to `false`
--- @field default_keymaps boolean Set keymaps for `f`, `F`, `t`, and `T`. Defaults to `true`
--- @field highlight_pattern string A string pattern to determine if a character should be highlighted according to its occurrence. The pattern is passed to `string.match(str, pattern)` with the current character as `str` and the `highlight_pattern` opt as `pattern`. If `string.match` returns `true`, the character is highlighted as `FTHighlight{First,Second,Third}`, otherwise as `FTHighlightDimmed`. Defaults to `"."` (matches every character).

--- @param opts { forward: boolean, highlight_pattern: string }
M.add_highlight = function(opts)
  return ft_highlight:add_highlight(opts)
end

M.clear_highlight = function()
  return ft_highlight:clear_highlight()
end

--- @param opts { key: "f"|"F"|"t"|"T", forward: boolean, highlight_pattern: string }
M.on_key = function(opts)
  ft_highlight:add_highlight { forward = opts.forward, highlight_pattern = opts.highlight_pattern, }
  local ok, input = pcall(vim.fn.nr2char, vim.fn.getchar())

  if ft_highlight.is_highlighted then
    ft_highlight:clear_highlight()
  end

  if not ok then
    return opts.key
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
    vim.keymap.set({ "n", "v", "o", }, "f",
      function() return M.on_key { key = "f", forward = true, highlight_pattern = opts.highlight_pattern, } end,
      { expr = true, })
    vim.keymap.set({ "n", "v", "o", }, "F",
      function() return M.on_key { key = "F", forward = false, highlight_pattern = opts.highlight_pattern, } end,
      { expr = true, })
    vim.keymap.set({ "n", "v", "o", }, "t",
      function() return M.on_key { key = "t", forward = true, highlight_pattern = opts.highlight_pattern, } end,
      { expr = true, })
    vim.keymap.set({ "n", "v", "o", }, "T",
      function() return M.on_key { key = "T", forward = false, highlight_pattern = opts.highlight_pattern, } end,
      { expr = true, })
  end
end

return M
