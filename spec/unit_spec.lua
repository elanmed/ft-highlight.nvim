local FTHighlight = require "lua.ft-highlight.class"

describe("#get_char_occurrence_at_position", function()
  local ft_highlight

  before_each(function()
    ft_highlight = FTHighlight:new()
  end)

  it("should handle unique characters", function()
    local actual = ft_highlight:get_char_occurrence_at_position { str = "abc", }
    local expected = { [1] = 1, [2] = 1, [3] = 1, }
    assert.is.Same(actual, expected)
  end)

  it("should handle repeat characters", function()
    local actual = ft_highlight:get_char_occurrence_at_position { str = "aaabb", }
    local expected = { [1] = 1, [2] = 2, [3] = 3, [4] = 1, [5] = 2, }
    assert.is.Same(actual, expected)
  end)

  it("should handle mixed characters", function()
    local actual = ft_highlight:get_char_occurrence_at_position { str = "banana", }
    local expected = { [1] = 1, [2] = 1, [3] = 1, [4] = 2, [5] = 2, [6] = 3, }
    assert.is.Same(actual, expected)
  end)

  it("should differentiate between uppercase and lower case", function()
    local actual = ft_highlight:get_char_occurrence_at_position { str = "aAbB", }
    local expected = { [1] = 1, [2] = 1, [3] = 1, [4] = 1, }
    assert.is.Same(actual, expected)
  end)

  it("should handle patterns", function()
    local actual = ft_highlight:get_char_occurrence_at_position { str = "aAbB", highlight_pattern = "[A-Z]", }
    local expected = { [1] = -1, [2] = 1, [3] = -1, [4] = 1, }
    assert.is.Same(actual, expected)
  end)

  it("should handle numbers, special characters", function()
    local actual = ft_highlight:get_char_occurrence_at_position { str = "121##$", }
    local expected = { [1] = 1, [2] = 1, [3] = 2, [4] = 1, [5] = 2, [6] = 1, }
    assert.is.Same(actual, expected)
  end)

  it("should handle empty strings", function()
    local actual = ft_highlight:get_char_occurrence_at_position { str = "", }
    local expected = {}
    assert.is.Same(actual, expected)
  end)
end)
