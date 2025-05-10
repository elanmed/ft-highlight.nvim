local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

local T = new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua", }
      child.lua [[M = require "ft-highlight".setup { enabled = true, }]]
    end,
    post_once = child.stop,
  },
}

--- @param ns_id number
local function get_marks(ns_id)
  return child.api.nvim_buf_get_extmarks(0, ns_id, 0, -1, { details = true, })
end

--- @param ns_id number
local function get_hl_names(ns_id)
  local marks = get_marks(ns_id)
  return vim.tbl_map(function(mark) return mark[4].hl_group end, marks)
end

T["forward=true"] = new_set()

T["forward=true"]["highlights correctly from the first char"] = function()
  child.api.nvim_buf_set_lines(0, 0, -1, true, { "_Ava ate an apple.", })
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "f"
  eq(get_hl_names(ns_id), {
    "FTHighlightFirst",  -- A
    "FTHighlightFirst",  -- v
    "FTHighlightFirst",  -- a
    "FTHighlightFirst",  --
    "FTHighlightSecond", -- a
    "FTHighlightFirst",  -- t
    "FTHighlightFirst",  -- e
    "FTHighlightSecond", --
    "FTHighlightThird",  -- a
    "FTHighlightFirst",  -- n
    "FTHighlightThird",  --
    "FTHighlightDimmed", -- a
    "FTHighlightFirst",  -- p
    "FTHighlightSecond", -- p
    "FTHighlightFirst",  -- l
    "FTHighlightSecond", -- e
    "FTHighlightFirst",  -- .
  })
  child.type_keys "A"
  eq(get_hl_names(ns_id), {})
end

T["forward=true"]["highlights correctly from a middle first char"] = function()
  child.api.nvim_buf_set_lines(0, 0, -1, true, { "Ava ate an apple.", })
  child.type_keys "f "
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "f"
  eq(get_hl_names(ns_id), {
    "FTHighlightFirst",  -- a
    "FTHighlightFirst",  -- t
    "FTHighlightFirst",  -- e
    "FTHighlightFirst",  --
    "FTHighlightSecond", -- a
    "FTHighlightFirst",  -- n
    "FTHighlightSecond", --
    "FTHighlightThird",  -- a
    "FTHighlightFirst",  -- p
    "FTHighlightSecond", -- p
    "FTHighlightFirst",  -- l
    "FTHighlightSecond", -- e
    "FTHighlightFirst",  -- .
  })
  child.type_keys "a"
  eq(get_hl_names(ns_id), {})
end

T["forward=true"]["highlights correctly from the last char"] = function()
  child.api.nvim_buf_set_lines(0, 0, -1, true, { "Ava ate an apple.", })
  child.type_keys "f."
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "f"
  eq(get_hl_names(ns_id), {})
  child.type_keys "<esc>"
  eq(get_hl_names(ns_id), {})
end

T["forward=false"] = new_set()

T["forward=false"]["highlights correctly from the last char"] = function()
  child.api.nvim_buf_set_lines(0, 0, -1, true, { "Ava ate an apple._", })
  child.type_keys "f_"
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "F"
  eq(get_hl_names(ns_id), {
    "FTHighlightFirst",  -- A
    "FTHighlightFirst",  -- v
    "FTHighlightDimmed", -- a
    "FTHighlightThird",  --
    "FTHighlightThird",  -- a
    "FTHighlightFirst",  -- t
    "FTHighlightSecond", -- e
    "FTHighlightSecond", --
    "FTHighlightSecond", -- a
    "FTHighlightFirst",  -- n
    "FTHighlightFirst",  --
    "FTHighlightFirst",  -- a
    "FTHighlightSecond", -- p
    "FTHighlightFirst",  -- p
    "FTHighlightFirst",  -- l
    "FTHighlightFirst",  -- e
    "FTHighlightFirst",  -- .
  })
  child.type_keys "."
  eq(get_hl_names(ns_id), {})
end

T["forward=false"]["highlights correctly from a middle char"] = function()
  child.api.nvim_buf_set_lines(0, 0, -1, true, { "Ava ate an apple.", })
  child.type_keys "f.F "
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "F"
  eq(get_hl_names(ns_id), {
    "FTHighlightFirst",  -- A
    "FTHighlightFirst",  -- v
    "FTHighlightThird",  -- a
    "FTHighlightSecond", --
    "FTHighlightSecond", -- a
    "FTHighlightFirst",  -- t
    "FTHighlightFirst",  -- e
    "FTHighlightFirst",  --
    "FTHighlightFirst",  -- a
    "FTHighlightFirst",  -- n
  })
  child.type_keys "."
  eq(get_hl_names(ns_id), {})
end

T["forward=false"]["highlights correctly from the first char"] = function()
  child.api.nvim_buf_set_lines(0, 0, -1, true, { "Ava ate an apple.", })
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "F"
  eq(get_hl_names(ns_id), {})
  child.type_keys "<esc>"
  eq(get_hl_names(ns_id), {})
end

return T
