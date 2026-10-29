local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

local T = new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
      child.api.nvim_buf_set_lines(0, 0, -1, true, { " Ava ate an apple. " })
      child.lua [[
        vim.keymap.set({ "n", "v", "o" }, "f", "<Plug>FtHighlight_f", { remap = true })
        vim.keymap.set({ "n", "v", "o" }, "F", "<Plug>FtHighlight_F", { remap = true })
        vim.keymap.set({ "n", "v", "o" }, "t", "<Plug>FtHighlight_t", { remap = true })
        vim.keymap.set({ "n", "v", "o" }, "T", "<Plug>FtHighlight_T", { remap = true })
      ]]
    end,
    post_once = child.stop,
  },
}

--- @param ns_id number
local function get_marks(ns_id)
  return child.api.nvim_buf_get_extmarks(0, ns_id, 0, -1, { details = true })
end

--- @param ns_id number
local function get_hl_names(ns_id)
  local marks = get_marks(ns_id)
  return vim.tbl_map(function(mark)
    return mark[4].hl_group
  end, marks)
end

local function set_line(line)
  child.api.nvim_buf_set_lines(0, 0, -1, true, { line })
end

T["configuration"] = new_set()
T["configuration"]["highlight_pattern"] = function()
  child.g.ft_highlight = { highlight_pattern = "[a-z]" }

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

T["keypress"]["t"] = new_set()
T["keypress"]["t"]["highlights correctly from the first char"] = function()
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "t"
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
T["keypress"]["t"]["highlights correctly from a middle first char"] = function()
  child.type_keys "4l"
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "t"
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
T["keypress"]["t"]["highlights correctly from the last char"] = function()
  child.type_keys "$"
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "t"
  eq(get_hl_names(ns_id), {})
  child.type_keys "<esc>"
  eq(get_hl_names(ns_id), {})
end

T["keypress"]["T"] = new_set()
T["keypress"]["T"]["highlights correctly from the last char"] = function()
  child.type_keys "$"
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "T"
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
T["keypress"]["T"]["highlights correctly from a middle char"] = function()
  child.type_keys "$7h"
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "T"
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
T["keypress"]["T"]["highlights correctly from the first char"] = function()
  local ns_id = child.api.nvim_create_namespace "FTHighlight"
  eq(get_hl_names(ns_id), {})
  child.type_keys "T"
  eq(get_hl_names(ns_id), {})
  child.type_keys "<esc>"
  eq(get_hl_names(ns_id), {})
end

T["mapped motions"] = new_set()
T["mapped motions"]["f moves to the typed character and clears highlights"] = function()
  set_line "abca"
  child.api.nvim_win_set_cursor(0, { 1, 0 })
  local ns_id = child.api.nvim_create_namespace "FTHighlight"

  child.type_keys "f"
  child.type_keys "c"

  eq(child.api.nvim_win_get_cursor(0), { 1, 2 })
  eq(get_marks(ns_id), {})
end

T["mapped motions"]["f preserves visual mode and moves to the typed character"] = function()
  set_line "abca"
  child.api.nvim_win_set_cursor(0, { 1, 0 })
  child.type_keys "v"
  child.type_keys "f"
  child.type_keys "c"

  eq(child.api.nvim_win_get_cursor(0), { 1, 2 })
  eq(child.fn.mode(), "v")
end

T["mapped motions"]["f works as an operator-pending motion"] = function()
  set_line "abca"
  child.api.nvim_win_set_cursor(0, { 1, 0 })
  child.type_keys "d"
  child.type_keys "f"
  child.type_keys "c"

  eq(child.api.nvim_buf_get_lines(0, 0, -1, true), { "a" })
  eq(child.api.nvim_win_get_cursor(0), { 1, 0 })
end

T["mapped motions"]["cancelling f clears highlights without moving"] = function()
  set_line "abca"
  child.api.nvim_win_set_cursor(0, { 1, 0 })
  local ns_id = child.api.nvim_create_namespace "FTHighlight"

  child.type_keys "f"
  eq(#get_marks(ns_id) > 0, true)
  child.type_keys "<Esc>"

  eq(child.api.nvim_win_get_cursor(0), { 1, 0 })
  eq(get_marks(ns_id), {})
end

T["mapped motions"]["empty lines produce no highlights and do not move"] = function()
  set_line ""
  child.api.nvim_win_set_cursor(0, { 1, 0 })
  local ns_id = child.api.nvim_create_namespace "FTHighlight"

  child.type_keys "f"
  child.type_keys "a"

  eq(child.api.nvim_win_get_cursor(0), { 1, 0 })
  eq(get_marks(ns_id), {})
end

T["mapped motions"]["F moves to the previous typed character"] = function()
  set_line "abca"
  child.api.nvim_win_set_cursor(0, { 1, 3 })
  local ns_id = child.api.nvim_create_namespace "FTHighlight"

  child.type_keys "F"
  child.type_keys "b"

  eq(child.api.nvim_win_get_cursor(0), { 1, 1 })
  eq(get_marks(ns_id), {})
end

T["mapped motions"]["t moves before the typed character"] = function()
  set_line "abca"
  child.api.nvim_win_set_cursor(0, { 1, 0 })
  local ns_id = child.api.nvim_create_namespace "FTHighlight"

  child.type_keys "t"
  child.type_keys "c"

  eq(child.api.nvim_win_get_cursor(0), { 1, 1 })
  eq(get_marks(ns_id), {})
end

T["mapped motions"]["T moves after the previous typed character"] = function()
  set_line "abca"
  child.api.nvim_win_set_cursor(0, { 1, 3 })
  local ns_id = child.api.nvim_create_namespace "FTHighlight"

  child.type_keys "T"
  child.type_keys "b"

  eq(child.api.nvim_win_get_cursor(0), { 1, 2 })
  eq(get_marks(ns_id), {})
end

T["mapped motions"]["F preserves visual mode and selects to the previous character"] = function()
  set_line "abca"
  child.api.nvim_win_set_cursor(0, { 1, 3 })
  child.type_keys "v"
  child.type_keys "F"
  child.type_keys "b"

  eq(child.api.nvim_win_get_cursor(0), { 1, 1 })
  eq(child.fn.mode(), "v")
end

T["mapped motions"]["t preserves visual mode and selects before the character"] = function()
  set_line "abca"
  child.api.nvim_win_set_cursor(0, { 1, 0 })
  child.type_keys "v"
  child.type_keys "t"
  child.type_keys "c"

  eq(child.api.nvim_win_get_cursor(0), { 1, 1 })
  eq(child.fn.mode(), "v")
end

T["mapped motions"]["T preserves visual mode and selects after the previous character"] = function()
  set_line "abca"
  child.api.nvim_win_set_cursor(0, { 1, 3 })
  child.type_keys "v"
  child.type_keys "T"
  child.type_keys "b"

  eq(child.api.nvim_win_get_cursor(0), { 1, 2 })
  eq(child.fn.mode(), "v")
end

T["mapped motions"]["F works as an operator-pending motion"] = function()
  set_line "abca"
  child.api.nvim_win_set_cursor(0, { 1, 3 })
  child.type_keys "d"
  child.type_keys "F"
  child.type_keys "b"

  eq(child.api.nvim_buf_get_lines(0, 0, -1, true), { "aa" })
end

T["mapped motions"]["t works as an operator-pending motion"] = function()
  set_line "abca"
  child.api.nvim_win_set_cursor(0, { 1, 0 })
  child.type_keys "d"
  child.type_keys "t"
  child.type_keys "c"

  eq(child.api.nvim_buf_get_lines(0, 0, -1, true), { "ca" })
end

T["mapped motions"]["T works as an operator-pending motion"] = function()
  set_line "abca"
  child.api.nvim_win_set_cursor(0, { 1, 3 })
  child.type_keys "d"
  child.type_keys "T"
  child.type_keys "b"

  eq(child.api.nvim_buf_get_lines(0, 0, -1, true), { "aba" })
end

return T
