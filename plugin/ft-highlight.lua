local singleton

local maybe_initialize = function()
  if vim.g.ft_highlight_initialized then return end
  vim.g.ft_highlight_initialized = true

  --- @param hl_name string
  local function get_hl_fg(hl_name) return vim.api.nvim_get_hl(0, { name = hl_name, }).fg end

  vim.api.nvim_set_hl(0, "FTHighlightFirst", { fg = get_hl_fg "Normal", })
  vim.api.nvim_set_hl(0, "FTHighlightSecond", { fg = get_hl_fg "DiagnosticWarn", bold = true, })
  vim.api.nvim_set_hl(0, "FTHighlightThird", { fg = get_hl_fg "DiagnosticError", bold = true, })
  vim.api.nvim_set_hl(0, "FTHighlightDimmed", { fg = get_hl_fg "Comment", })

  local FTHighlight = require "ft-highlight.class"
  singleton = FTHighlight:new()
end

--- @class OnKeyOpts : AddHighlightOpts
--- @field key "f" | "F" | "t" | "T"
--- @param opts OnKeyOpts
local function on_key(opts)
  maybe_initialize()

  singleton:add_highlight { forward = opts.forward, }
  local ok, input = pcall(vim.fn.getcharstr)
  singleton:clear_highlight()

  if not ok then
    return opts.key
  end
  return opts.key .. input
end

vim.keymap.set({ "n", "v", "o", }, "f",
  function()
    return on_key { key = "f", forward = true, }
  end,
  { expr = true, }
)
vim.keymap.set({ "n", "v", "o", }, "F",
  function()
    return on_key { key = "F", forward = false, }
  end,
  { expr = true, }
)
vim.keymap.set({ "n", "v", "o", }, "t",
  function()
    return on_key { key = "t", forward = true, }
  end,
  { expr = true, }
)
vim.keymap.set({ "n", "v", "o", }, "T",
  function()
    return on_key { key = "T", forward = false, }
  end,
  { expr = true, }
)
