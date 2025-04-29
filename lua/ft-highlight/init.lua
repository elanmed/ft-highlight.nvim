local M = {}

--- @class FTHighlightOpts
--- @field enable boolean Enable the plugin, defaults to `false`

--- @param opts FTHighlightOpts | nil
M.setup = function(opts)
  opts = opts or {}
  local enable = opts.enable or false
  if not enable then return end

  local FTHighlight = require "ft-highlight.class"
  local ft_highlight = FTHighlight:new()

  --- @param on_key_opts { key: "f"|"F"|"t"|"T", forward: boolean }
  local function on_key(on_key_opts)
    -- the `schedule` ensures that the highlight is cleared after operator pending mode is complete
    -- example:
    -- - in normal mode, `f` is pressed
    -- - on_key begins to run
    -- - the clearing cb is scheduled, but not run
    -- - the highlight is added
    -- - on_key waits for `f`'s operator before finishing
    -- - an operator is pressed
    -- - on_key finishes running
    -- - the clearing cb is run
    vim.schedule(function()
      if ft_highlight.is_highlighted then
        ft_highlight:maybe_clear_highlight()
        ft_highlight:toggle_off()
      end
    end)

    ft_highlight:highlight { forward = on_key_opts.forward, }
    return on_key_opts.key
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
