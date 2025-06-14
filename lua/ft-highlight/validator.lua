-- https://github.com/elanmed/schema-validator.nvim/blob/3559ea5482a099e85b39473cedfbc6b8d4d0f970/lua/schema-validator/init.lua

--- @generic T
--- @param val T | nil
--- @param default_val T
--- @return T
local function default(val, default_val)
  if val == nil then
    return default_val
  end
  return val
end

local M = {}

--- @alias CustomValidator fun(val: any): boolean
--- @alias Type "nil" | "number" | "string" | "boolean" | "function" | "table" | "any" | CustomValidator

--- @class BaseSchema
--- @field type Type
--- @field optional? boolean

--- @class TableSchema : BaseSchema
--- @field entries? Type | Schema[]
--- @field exact? boolean

--- @alias Schema BaseSchema | TableSchema

--- @param schema Schema
--- @return boolean
M.validate = function(schema, val)
  if type(schema.type) ~= "string" and type(schema.type) ~= "function" then
    error(
      string.format(
        "Expected `type(schema.type)` to be a `string` or `function`, received `%s`. Schema: %s",
        type(schema.type),
        vim.inspect(schema)
      )
    )
  end

  if type(schema.optional) ~= "nil" and type(schema.optional) ~= "boolean" then
    error(
      string.format(
        "Expected `type(schema.option)` to be `nil` or `boolean`, received `%s`. Schema: %s",
        type(schema.optional),
        vim.inspect(schema)
      )
    )
  end

  if type(schema.exact) ~= "nil" and type(schema.exact) ~= "boolean" then
    error(
      string.format(
        "Expected `type(schema.exact)` to be `nil` or `boolean`, received `%s`. Schema: %s",
        type(schema.exact),
        vim.inspect(schema)
      )
    )
  end

  local optional = default(schema.optional, false)
  if val == nil and optional then
    return true
  end

  if type(schema.type) == "string" then
    if not vim.tbl_contains({ "nil", "number", "string", "boolean", "function", "table", "any", }, schema.type) then
      error(
        string.format("Expected `schema.type` to be one of the following: %s, received `%s`. Schema: %s",
          "`nil`, `number`, `string`, `boolean`, `function`, `table`",
          schema.type,
          vim.inspect(schema)
        )
      )
    end

    if schema.type == "table" then
      if type(schema.entries) ~= "string" and type(schema.entries) ~= "table" then
        error(
          string.format(
            "Expected `type(schema.entries)` to be a `string` or `table`, received `%s`. Schema: %s",
            type(schema.entries),
            vim.inspect(schema)
          )
        )
      end

      if type(val) ~= "table" then return false end

      if type(schema.entries) == "string" then
        for _, curr_val in pairs(val) do
          if not M.validate({ type = schema.entries, }, curr_val) then
            return false
          end
        end

        return true
      elseif type(schema.entries) == "table" then
        for key, entry in pairs(schema.entries) do
          if not M.validate(entry, val[key]) then
            return false
          end
        end

        local exact = default(schema.exact, false)
        if exact then
          for key, entry in pairs(val) do
            local schema_entry = schema.entries[key]
            if schema_entry == nil then
              return false
            end

            if not M.validate(schema_entry, entry) then
              return false
            end
          end
        end

        return true
      end
    end

    if schema.type == "any" then return true end
    if type(val) == schema.type then return true end
    return false
  elseif type(schema.type) == "function" then
    return schema.type(val)
  end
end

--- @param literal any
M.literal = function(literal)
  vim.inspect()
  return function(val)
    return vim.deep_equal(val, literal)
  end
end

--- @param schemas Schema[]
M.union = function(schemas)
  return function(val)
    for _, schema in pairs(schemas) do
      if M.validate(schema, val) then return true end
    end
    return false
  end
end

return M
