local FTHighlight = require "ft-highlight.class"
local ft_highlight = FTHighlight:new()

--- @generic T
--- @param val T | nil
--- @param default_val T
--- @return T
local function default(val, default_val)
  if val == nil then
    return default_val
  end
  return val
end

local M = {}

--- @class AddHighlightOpts
--- @field forward boolean The direction in which to count the char occurrences
--- @field highlight_pattern string A string pattern to determine if a character should be highlighted according to its occurrence. See FTHighlightOpts.highlight_pattern
--- @param opts AddHighlightOpts
M.add_highlight = function(opts)
  ft_highlight:add_highlight(opts)
end


M.clear_highlight = function()
  ft_highlight:clear_highlight()
end

--- @param opts { key: "f"|"F"|"t"|"T", forward: boolean, highlight_pattern: string }
local function on_key(opts)
  ft_highlight:add_highlight { forward = opts.forward, highlight_pattern = opts.highlight_pattern, }
  local ok, input = pcall(vim.fn.getcharstr)
  ft_highlight:clear_highlight()

  if not ok then
    return opts.key
  end
  return opts.key .. input
end

--- @param hl_name string
local function get_hl_fg(hl_name)
  local hl = vim.api.nvim_get_hl(0, { name = hl_name, })
  return hl.fg
end

--- @class FTHighlightOpts
--- @field default_keymaps boolean Set keymaps for `f`, `F`, `t`, and `T`. Defaults to `true`
--- @field highlight_pattern string A string pattern to determine if a character should be highlighted according to its occurrence. The pattern is passed to `string.match(str, pattern)` with the current character as `str` and the `highlight_pattern` opt as `pattern`. If `string.match` returns `true`, the character is highlighted as `FTHighlight{First,Second,Third}`, otherwise as `FTHighlightDimmed`. Defaults to `"."` (matches every character).
--- @param opts FTHighlightOpts | nil
M.setup = function(opts)
  opts = default(opts, {})
  local default_keymaps = default(opts.default_keymaps, true)

  vim.api.nvim_set_hl(0, "FTHighlightFirst", { fg = get_hl_fg "Normal", })
  vim.api.nvim_set_hl(0, "FTHighlightSecond", { fg = get_hl_fg "DiagnosticWarn", bold = true, })
  vim.api.nvim_set_hl(0, "FTHighlightThird", { fg = get_hl_fg "DiagnosticError", bold = true, })
  vim.api.nvim_set_hl(0, "FTHighlightDimmed", { fg = get_hl_fg "Comment", })

  if default_keymaps then
    vim.keymap.set(
      { "n", "v", "o", },
      "f",
      function() return on_key { key = "f", forward = true, highlight_pattern = opts.highlight_pattern, } end,
      { expr = true, }
    )
    vim.keymap.set(
      { "n", "v", "o", },
      "F",
      function() return on_key { key = "F", forward = false, highlight_pattern = opts.highlight_pattern, } end,
      { expr = true, }
    )
    vim.keymap.set({ "n", "v", "o", },
      "t",
      function() return on_key { key = "t", forward = true, highlight_pattern = opts.highlight_pattern, } end,
      { expr = true, }
    )
    vim.keymap.set({ "n", "v", "o", },
      "T",
      function() return on_key { key = "T", forward = false, highlight_pattern = opts.highlight_pattern, } end,
      { expr = true, }
    )
  end
end

return M
