local FTHighlight = {}
FTHighlight.__index = FTHighlight

local default = function(val, default_val)
  if val == nil then
    return default_val
  end
  return val
end

function FTHighlight:new()
  local ns_id = vim.api.nvim_create_namespace "FTHighlight"

  local this = {
    highlighted_line = nil,
    ns_id = ns_id,
  }
  return setmetatable(this, FTHighlight)
end

--- @param opts { highlighted_line: number }
function FTHighlight:toggle_on(opts)
  self.highlighted_line = opts.highlighted_line
end

function FTHighlight:toggle_off()
  self.highlighted_line = nil
end

--- @param str string
function FTHighlight:get_char_occurrence_at_position(str)
  -- bee -> { "b" = 1, "e" = 2 }
  local char_to_num_occurrence = {}
  -- bee -> { 1 = 1, 2 = 1, 3 = 2 }
  local char_occurrence_at_position = {}

  local opts = default(vim.g.ft_highlight, {})
  local pattern = default(opts.highlight_pattern, ".")

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

--- @class AddHighlightOpts
--- @field forward boolean The direction in which to count the char occurrences

--- @param opts AddHighlightOpts
function FTHighlight:add_highlight(opts)
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

    orders = self:get_char_occurrence_at_position(forward_subbed)
  else
    -- highlight starting with the char before the cursor
    local backward_start = col_1_indexed - 1
    local backward_subbed = curr_line:sub(1, backward_start) -- inclusive!
    local backward_subbed_reversed = backward_subbed:reverse()

    orders = self:get_char_occurrence_at_position(backward_subbed_reversed)
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
      self.ns_id,
      hl_group,
      { row_0_indexed, highlight_col_0_indexed, },
      { row_0_indexed, highlight_col_0_indexed + 1, }
    )
  end

  self:toggle_on { highlighted_line = row_0_indexed, }
  vim.cmd "redraw"
end

function FTHighlight:clear_highlight()
  if self.highlighted_line == nil then
    return
  end
  vim.api.nvim_buf_clear_namespace(0, self.ns_id, self.highlighted_line, self.highlighted_line + 1)
  self:toggle_off()
end

return FTHighlight
