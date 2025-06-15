local FTHighlight = require "ft-highlight.class"
local ft_highlight = FTHighlight:new()
local validate = require "ft-highlight.validator".validate

local M = {}

--- @param opts AddHighlightOpts
M.add_highlight = function(opts)
  --- @type Schema
  local opts_schema = {
    type = "table",
    exact = true,
    entries = {
      forward = { type = "boolean", },
      highlight_pattern = { type = "string", optional = true, },
    },
  }

  if not validate(opts_schema, opts) then
    vim.notify(
      string.format(
        "Malformed opts passed to ft-highlight.add_highlight! Expected %s, received %s",
        vim.inspect(opts_schema),
        vim.inspect(opts)
      ),
      vim.log.levels.ERROR
    )
    return
  end

  ft_highlight:add_highlight(opts)
end


M.clear_highlight = function()
  ft_highlight:clear_highlight()
end

--- @class OnKeyOpts : AddHighlightOpts
--- @field key "f" | "F" | "t" | "T"

--- @param opts OnKeyOpts
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
local function get_hl_fg(hl_name) return vim.api.nvim_get_hl(0, { name = hl_name, }).fg end

--- @class FTHighlightOpts
--- @field default_keymaps boolean Set keymaps for `f`, `F`, `t`, and `T`. Defaults to `true`
--- @field highlight_pattern string A string pattern to determine if a character should be highlighted according to its occurrence. The pattern is passed to `string.match(str, pattern)` with the current character as `str` and the `highlight_pattern` opt as `pattern`. If `string.match` returns `true`, the character is highlighted as `FTHighlight{First,Second,Third}`, otherwise as `FTHighlightDimmed`. Defaults to `"."` (matches every character).

--- @param opts FTHighlightOpts | nil
M.setup = function(opts)
  --- @type Schema
  local opts_schema = {
    type = "table",
    exact = true,
    entries = {
      default_keymaps = { type = "boolean", optional = true, },
      highlight_pattern = { type = "string", optional = true, },
    },
    optional = true,
  }

  if not validate(opts_schema, opts) then
    vim.notify(
      string.format(
        "Malformed opts passed to ft-highlight.setup! Expected %s, received %s",
        vim.inspect(opts_schema),
        vim.inspect(opts)
      ),
      vim.log.levels.ERROR
    )
    return
  end

  local helpers = require "ft-highlight.helpers"
  opts = helpers.default(opts, {})
  local default_keymaps = helpers.default(opts.default_keymaps, true)

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
