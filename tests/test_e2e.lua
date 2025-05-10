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

--- @param key string
--- @param mode string
local function has_keymap(key, mode)
  local abbr = false
  return child.fn.maparg(key, mode, abbr) ~= ""
end

--- @param variant "all" | "none"
local function has_keymaps(variant)
  for _, key in pairs { "f", "F", "t", "T", } do
    for _, mode in pairs { "n", "v", "o", } do
      if variant == "all" then
        if not has_keymap(key, mode) then
          return false
        end
      else
        if has_keymap(key, mode) then return false end
      end
    end
  end

  return true
end

T["M"] = new_set()

T["M"]["setup"] = new_set()
T["M"]["setup"]["default default_keymaps=true"] = function()
  child.lua [[M = require "ft-highlight".setup() ]]
  eq(has_keymaps "all", true)
end
T["M"]["setup"]["explicit default_keymaps=true"] = function()
  child.lua [[M = require "ft-highlight".setup { default_keymaps = true, }]]
  eq(has_keymaps "all", true)
end
T["M"]["setup"]["explicit default_keymaps=false"] = function()
  child.lua [[M = require "ft-highlight".setup { default_keymaps = false, }]]
  eq(has_keymaps "none", true)
end
T["M"]["setup"]["highlight_pattern"] = function()
  child.lua [[M = require "ft-highlight".setup { highlight_pattern = "[a-z]", }]]

  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "f"
  eq(get_hl_names(ns_id), {
    "FTHighlightDimmed", -- A
    "FTHighlightFirst",  -- v
    "FTHighlightFirst",  -- a
    "FTHighlightDimmed", --
    "FTHighlightSecond", -- a
    "FTHighlightFirst",  -- t
    "FTHighlightFirst",  -- e
    "FTHighlightDimmed", --
    "FTHighlightThird",  -- a
    "FTHighlightFirst",  -- n
    "FTHighlightDimmed", --
    "FTHighlightDimmed", -- a
    "FTHighlightFirst",  -- p
    "FTHighlightSecond", -- p
    "FTHighlightFirst",  -- l
    "FTHighlightSecond", -- e
    "FTHighlightDimmed", -- .
    "FTHighlightDimmed", --
  })
  child.type_keys "A"
  eq(get_hl_names(ns_id), {})
end

T["M"]["setup"] = new_set()
T["M"]["add_highlight,clear_highlight"] = function()
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.lua [[require "ft-highlight".add_highlight { forward = true, highlight_pattern = "[a-z]", }]]
  eq(get_hl_names(ns_id), {
    "FTHighlightDimmed", -- A
    "FTHighlightFirst",  -- v
    "FTHighlightFirst",  -- a
    "FTHighlightDimmed", --
    "FTHighlightSecond", -- a
    "FTHighlightFirst",  -- t
    "FTHighlightFirst",  -- e
    "FTHighlightDimmed", --
    "FTHighlightThird",  -- a
    "FTHighlightFirst",  -- n
    "FTHighlightDimmed", --
    "FTHighlightDimmed", -- a
    "FTHighlightFirst",  -- p
    "FTHighlightSecond", -- p
    "FTHighlightFirst",  -- l
    "FTHighlightSecond", -- e
    "FTHighlightDimmed", -- .
    "FTHighlightDimmed", --
  })
  child.lua [[require "ft-highlight".clear_highlight()]]
  eq(get_hl_names(ns_id), {})
end
T["M"]["on_key"] = function()
  child.lua [[
  vim.keymap.set(
    { "n", "v", "o", },
    "f",
    function() return require "ft-highlight".on_key { key = "f", forward = false, highlight_pattern = "[a-z]", } end,
    { expr = true, }
  )
  ]]

  child.type_keys "$"
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "f"
  eq(get_hl_names(ns_id), {
    "FTHighlightDimmed", --
    "FTHighlightDimmed", -- A
    "FTHighlightFirst",  -- v
    "FTHighlightDimmed", -- a
    "FTHighlightDimmed", --
    "FTHighlightThird",  -- a
    "FTHighlightFirst",  -- t
    "FTHighlightSecond", -- e
    "FTHighlightDimmed", --
    "FTHighlightSecond", -- a
    "FTHighlightFirst",  -- n
    "FTHighlightDimmed", --
    "FTHighlightFirst",  -- a
    "FTHighlightSecond", -- p
    "FTHighlightFirst",  -- p
    "FTHighlightFirst",  -- l
    "FTHighlightFirst",  -- e
    "FTHighlightDimmed", -- .
  })
  child.type_keys "."
  eq(get_hl_names(ns_id), {})
end


T["keypress"] = new_set {
  hooks = {
    pre_case = function()
      child.lua [[M = require "ft-highlight".setup() ]]
    end,
  },
}
T["keypress"]["f"] = new_set()
T["keypress"]["f"]["highlights correctly from the first char"] = function()
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
    "FTHighlightThird",  --
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
T["keypress"]["F"]["highlights correctly from a middle char"] = function()
  child.type_keys "$7h"
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "F"
  eq(get_hl_names(ns_id), {
    "FTHighlightThird",  --
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
T["keypress"]["F"]["highlights correctly from the first char"] = function()
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "F"
  eq(get_hl_names(ns_id), {})
  child.type_keys "<esc>"
  eq(get_hl_names(ns_id), {})
end

return T
