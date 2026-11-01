local M = {}

local ns_id = vim.api.nvim_create_namespace "FTHighlight"
local highlighted_line = nil
local highlighted_buf = nil
local initialized = false

--- @generic T
--- @param val T | nil
--- @param default_val T
--- @return T
local nonnil = function(val, default_val)
  if val == nil then
    return default_val
  end
  return val
end

--- @param str string
function M.get_char_occurrence_at_position(str)
  -- bee -> { "b" = 1, "e" = 2 }
  local char_to_num_occurrence = {}
  -- bee -> { 1 = 1, 2 = 1, 3 = 2 }
  local char_occurrence_at_position = {}

  local opts = nonnil(vim.g.ft_highlight, {})
  local pattern = nonnil(opts.highlight_pattern, ".")

  for index = 1, #str do
    local char = str:sub(index, index)
    if not char:match(pattern) then
      char_occurrence_at_position[index] = -1
      goto continue
    end

    if char_to_num_occurrence[char] == nil then
      char_to_num_occurrence[char] = 0
    end
    char_to_num_occurrence[char] = char_to_num_occurrence[char] + 1

    char_occurrence_at_position[index] = char_to_num_occurrence[char]

    ::continue::
  end

  return char_occurrence_at_position
end

--- @param opts { forward: boolean }
function M.add_highlight(opts)
  M.clear_highlight()

  local curr_line = vim.api.nvim_get_current_line()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  local row_1_indexed = cursor_pos[1]
  local row_0_indexed = row_1_indexed - 1

  local col_0_indexed = cursor_pos[2]
  local col_1_indexed = col_0_indexed + 1

  local orders = nil
  if opts.forward then
    -- highlight starting with the char after the cursor
    local forward_start = col_1_indexed + 1
    local forward_subbed = curr_line:sub(forward_start)

    orders = M.get_char_occurrence_at_position(forward_subbed)
  else
    -- highlight starting with the char before the cursor
    local backward_start = col_1_indexed - 1
    local backward_subbed = curr_line:sub(1, backward_start) -- inclusive!
    local backward_subbed_reversed = backward_subbed:reverse()

    orders = M.get_char_occurrence_at_position(backward_subbed_reversed)
  end

  for offset, value in pairs(orders) do
    local hl_group
    if value == 1 then
      hl_group = "FTHighlightFirst"
    elseif value == 2 then
      hl_group = "FTHighlightSecond"
    elseif value == 3 then
      hl_group = "FTHighlightThird"
    else
      hl_group = "FTHighlightDimmed"
    end

    local highlight_col_1_indexed
    if opts.forward then
      highlight_col_1_indexed = col_1_indexed + offset
    else
      highlight_col_1_indexed = col_1_indexed - offset
    end

    local highlight_col_0_indexed = highlight_col_1_indexed - 1

    vim.hl.range(
      0,
      ns_id,
      hl_group,
      { row_0_indexed, highlight_col_0_indexed },
      { row_0_indexed, highlight_col_0_indexed + 1 }
    )
  end

  highlighted_line = row_0_indexed
  highlighted_buf = vim.api.nvim_get_current_buf()
  vim.cmd "redraw"
end

function M.clear_highlight()
  if highlighted_line == nil or highlighted_buf == nil then
    return
  end
  if vim.api.nvim_buf_is_valid(highlighted_buf) then
    vim.api.nvim_buf_clear_namespace(highlighted_buf, ns_id, highlighted_line, highlighted_line + 1)
  end
  highlighted_line = nil
  highlighted_buf = nil
end

local function maybe_initialize()
  if initialized then
    return
  end
  initialized = true

  --- @param hl_name string
  local function get_hl_fg(hl_name)
    return vim.api.nvim_get_hl(0, { name = hl_name }).fg
  end

  vim.api.nvim_set_hl(0, "FTHighlightFirst", { fg = get_hl_fg "Normal" })
  vim.api.nvim_set_hl(0, "FTHighlightSecond", { fg = get_hl_fg "DiagnosticWarn", bold = true })
  vim.api.nvim_set_hl(0, "FTHighlightThird", { fg = get_hl_fg "DiagnosticError", bold = true })
  vim.api.nvim_set_hl(0, "FTHighlightDimmed", { fg = get_hl_fg "Comment" })
end

--- @param opts { key: "f" | "F" | "t" | "T", forward: boolean }
function M.on_key(opts)
  maybe_initialize()

  M.add_highlight { forward = opts.forward }
  local ok, input = pcall(vim.fn.getcharstr)
  M.clear_highlight()

  if not ok then
    return opts.key
  end
  return opts.key .. input
end

return M
