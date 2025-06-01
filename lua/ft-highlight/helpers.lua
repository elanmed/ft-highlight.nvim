local M = {}

--- @generic T
--- @param val T | nil
--- @param default_val T
--- @return T
M.default = function(val, default_val)
  if val == nil then
    return default_val
  end
  return val
end

return M
