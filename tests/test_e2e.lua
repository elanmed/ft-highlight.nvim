local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

local T = new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua", }
      child.api.nvim_buf_set_lines(0, 0, -1, true, { " Ava ate an apple. ", })
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

T["configuration"] = new_set()
T["configuration"]["highlight_pattern"] = function()
  child.g.ft_highlight = { highlight_pattern = "[a-z]", }

  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "f"
  eq(get_hl_names(ns_id), {
    "FTHighlightDimmed", -- A
    "FTHighlightFirst", -- v
    "FTHighlightFirst", -- a
    "FTHighlightDimmed", --
    "FTHighlightSecond", -- a
    "FTHighlightFirst", -- t
    "FTHighlightFirst", -- e
    "FTHighlightDimmed", --
    "FTHighlightThird", -- a
    "FTHighlightFirst", -- n
    "FTHighlightDimmed", --
    "FTHighlightDimmed", -- a
    "FTHighlightFirst", -- p
    "FTHighlightSecond", -- p
    "FTHighlightFirst", -- l
    "FTHighlightSecond", -- e
    "FTHighlightDimmed", -- .
    "FTHighlightDimmed", --
  })
  child.type_keys "A"
  eq(get_hl_names(ns_id), {})
end

T["keypress"] = new_set()
T["keypress"]["f"] = new_set()
T["keypress"]["f"]["highlights correctly from the first char"] = function()
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "f"
  eq(get_hl_names(ns_id), {
    "FTHighlightFirst", -- A
    "FTHighlightFirst", -- v
    "FTHighlightFirst", -- a
    "FTHighlightFirst", --
    "FTHighlightSecond", -- a
    "FTHighlightFirst", -- t
    "FTHighlightFirst", -- e
    "FTHighlightSecond", --
    "FTHighlightThird", -- a
    "FTHighlightFirst", -- n
    "FTHighlightThird", --
    "FTHighlightDimmed", -- a
    "FTHighlightFirst", -- p
    "FTHighlightSecond", -- p
    "FTHighlightFirst", -- l
    "FTHighlightSecond", -- e
    "FTHighlightFirst", -- .
    "FTHighlightDimmed", --
  })
  child.type_keys "A"
  eq(get_hl_names(ns_id), {})
end
T["keypress"]["f"]["highlights correctly from a middle first char"] = function()
  child.type_keys "4l"
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "f"
  eq(get_hl_names(ns_id), {
    "FTHighlightFirst", -- a
    "FTHighlightFirst", -- t
    "FTHighlightFirst", -- e
    "FTHighlightFirst", --
    "FTHighlightSecond", -- a
    "FTHighlightFirst", -- n
    "FTHighlightSecond", --
    "FTHighlightThird", -- a
    "FTHighlightFirst", -- p
    "FTHighlightSecond", -- p
    "FTHighlightFirst", -- l
    "FTHighlightSecond", -- e
    "FTHighlightFirst", -- .
    "FTHighlightThird", --
  })
  child.type_keys "a"
  eq(get_hl_names(ns_id), {})
end
T["keypress"]["f"]["highlights correctly from the last char"] = function()
  child.type_keys "$"
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "f"
  eq(get_hl_names(ns_id), {})
  child.type_keys "<esc>"
  eq(get_hl_names(ns_id), {})
end

T["keypress"]["F"] = new_set()
T["keypress"]["F"]["highlights correctly from the last char"] = function()
  child.type_keys "$"
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "F"
  eq(get_hl_names(ns_id), {
    "FTHighlightDimmed", --
    "FTHighlightFirst", -- A
    "FTHighlightFirst", -- v
    "FTHighlightDimmed", -- a
    "FTHighlightThird", --
    "FTHighlightThird", -- a
    "FTHighlightFirst", -- t
    "FTHighlightSecond", -- e
    "FTHighlightSecond", --
    "FTHighlightSecond", -- a
    "FTHighlightFirst", -- n
    "FTHighlightFirst", --
    "FTHighlightFirst", -- a
    "FTHighlightSecond", -- p
    "FTHighlightFirst", -- p
    "FTHighlightFirst", -- l
    "FTHighlightFirst", -- e
    "FTHighlightFirst", -- .
  })
  child.type_keys "."
  eq(get_hl_names(ns_id), {})
end
T["keypress"]["F"]["highlights correctly from a middle char"] = function()
  child.type_keys "$7h"
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "F"
  eq(get_hl_names(ns_id), {
    "FTHighlightThird", --
    "FTHighlightFirst", -- A
    "FTHighlightFirst", -- v
    "FTHighlightThird", -- a
    "FTHighlightSecond", --
    "FTHighlightSecond", -- a
    "FTHighlightFirst", -- t
    "FTHighlightFirst", -- e
    "FTHighlightFirst", --
    "FTHighlightFirst", -- a
    "FTHighlightFirst", -- n
  })
  child.type_keys "."
  eq(get_hl_names(ns_id), {})
end
T["keypress"]["F"]["highlights correctly from the first char"] = function()
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "F"
  eq(get_hl_names(ns_id), {})
  child.type_keys "<esc>"
  eq(get_hl_names(ns_id), {})
end

return T
