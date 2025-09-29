local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local FTHighlight = require "lua.ft-highlight.class"

local ft_highlight

local T = new_set {
  hooks = {
    pre_case = function()
      ft_highlight = FTHighlight:new()
      vim.g.ft_highlight = nil
    end,
  },
}

T["#get_char_occurrence_at_position"] = new_set()

T["#get_char_occurrence_at_position"]["should handle unique characters"] = function()
  local actual = ft_highlight:get_char_occurrence_at_position "abc"
  local expected = { [1] = 1, [2] = 1, [3] = 1, }
  eq(actual, expected)
end

T["#get_char_occurrence_at_position"]["should handle repeat characters"] = function()
  local actual = ft_highlight:get_char_occurrence_at_position "aaabb"
  local expected = { [1] = 1, [2] = 2, [3] = 3, [4] = 1, [5] = 2, }
  eq(actual, expected)
end

T["#get_char_occurrence_at_position"]["should handle mixed characters"] = function()
  local actual = ft_highlight:get_char_occurrence_at_position "banana"
  local expected = { [1] = 1, [2] = 1, [3] = 1, [4] = 2, [5] = 2, [6] = 3, }
  eq(actual, expected)
end

T["#get_char_occurrence_at_position"]["should differentiate between uppercase and lower case"] = function()
  local actual = ft_highlight:get_char_occurrence_at_position "aAbB"
  local expected = { [1] = 1, [2] = 1, [3] = 1, [4] = 1, }
  eq(actual, expected)
end

T["#get_char_occurrence_at_position"]["should respect patterns"] = function()
  vim.g.ft_highlight = { highlight_pattern = "[A-Z]", }
  local actual = ft_highlight:get_char_occurrence_at_position "aAbB"
  local expected = { [1] = -1, [2] = 1, [3] = -1, [4] = 1, }
  eq(actual, expected)
end

T["#get_char_occurrence_at_position"]["should handle numbers, special characters"] = function()
  local actual = ft_highlight:get_char_occurrence_at_position "121##$"
  local expected = { [1] = 1, [2] = 1, [3] = 2, [4] = 1, [5] = 2, [6] = 1, }
  eq(actual, expected)
end

T["#get_char_occurrence_at_position"]["should handle numbers, special characters"] = function()
  local actual = ft_highlight:get_char_occurrence_at_position ""
  local expected = {}
  eq(actual, expected)
end

return T
