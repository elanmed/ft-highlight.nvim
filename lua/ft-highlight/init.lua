local M = {}

--- @class FTHighlightOpts
--- @field enable boolean Enable the plugin, defaults to `false`

--- @param opts FTHighlightOpts | nil
M.setup = function(opts)
  opts = opts or {}
  local enable = opts.enable or false
  if not enable then return end

  local FTHighlight = require "lua.ft-highlight.class"
  local ft_highlight = FTHighlight:new()

  --- @param on_key_opts { key: "f"|"F"|"t"|"T", forward: boolean }
  local function on_key(on_key_opts)
    ft_highlight:highlight { forward = on_key_opts.forward, }
    local input = vim.fn.nr2char(vim.fn.getchar())

    if ft_highlight.is_highlighted then
      ft_highlight:maybe_clear_highlight()
      ft_highlight:toggle_off()
    end
    return on_key_opts.key .. input
  end

  vim.api.nvim_set_hl(0, "FTHighlightFirst", { link = "Normal", })
  vim.api.nvim_set_hl(0, "FTHighlightSecond", { link = "DiagnosticWarn", })
  vim.api.nvim_set_hl(0, "FTHighlightThird", { link = "DiagnosticError", })
  vim.api.nvim_set_hl(0, "FTHighlightDimmed", { link = "Comment", })

  vim.keymap.set({ "n", "v", "o", }, "f", function() return on_key { key = "f", forward = true, } end, { expr = true, })
  vim.keymap.set({ "n", "v", "o", }, "F", function() return on_key { key = "F", forward = false, } end, { expr = true, })
  vim.keymap.set({ "n", "v", "o", }, "t", function() return on_key { key = "t", forward = true, } end, { expr = true, })
  vim.keymap.set({ "n", "v", "o", }, "T", function() return on_key { key = "T", forward = false, } end, { expr = true, })
end

return M
