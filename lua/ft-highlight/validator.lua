-- https://github.com/elanmed/schema-validator.nvim/blob/591ff7eafc7a74614e51b03636cf7509bb164bd9/lua/schema-validator/init.lua

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

--- @class GetAssertMessageOpts
--- @field prefix? string
--- @field name string
--- @field expected any
--- @field actual any

--- @param opts GetAssertMessageOpts
local function get_validate_assert_message(opts)
  return
      "ERROR! Schema validation failed when parsing `" ..
      opts.name .. "`\n" ..
      "Expected:\n" ..
      "---------\n" ..
      vim.inspect(opts.expected) .. "\n" ..
      "Actual:\n" ..
      "-------\n" ..
      vim.inspect(opts.actual)
end

--- @class AssertOptOpts
--- @field cond boolean
--- @field name string
--- @field expected any
--- @field actual any

--- @class BuildAssertOptOpts
--- @field fn_name string
--- @field arg_name string

--- @param build_opts BuildAssertOptOpts
local function build_assert_opt(build_opts)
  local assert_prefix = ("[schema-validator] ERROR! The `%s` argument provided to `%s` is invalid.\n"):format(
    build_opts.arg_name,
    build_opts.fn_name
  )
  --- @param opts AssertOptOpts
  return function(opts)
    assert(
      opts.cond,
      assert_prefix ..
      string.format(
        "Expected `%s` to be a `%s`, received `%s`.",
        opts.name,
        opts.expected,
        opts.actual
      )
    )
  end
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
--- @param val any
--- @return boolean
M.validate = function(schema, val)
  -- In an earlier version of `schema-validator`, I experimented with validating the shape a the `schema` argument with `validate` itself.
  -- This worked, and it was elegant, but it led to some very confusing error messages. Instead, I'm opting to explicitly call out when the
  -- schema itself is malformed with `assert` functions rather than `validate`.
  local assert_prefix =
  "[schema-validator] ERROR! The provided `schema` is invalid. The `val` argument may or may not conform to the schema - it cannot be validated against a malformed schema.\n"

  assert(
    type(schema.type) == "string" or type(schema.type) == "function",
    assert_prefix ..
    string.format("Expected `type(schema.type)` to be a `string` or `function`, received `%s`.", type(schema.type))
  )

  assert(
    type(schema.optional) == "nil" or type(schema.optional) == "boolean",
    assert_prefix ..
    string.format("Expected `type(schema.option)` to be `nil` or `boolean`, received `%s`.", type(schema.type))
  )

  local optional = default(schema.optional, false)
  if val == nil and optional then
    return true
  end

  if type(schema.type) == "string" then
    assert(
      vim.tbl_contains({ "nil", "number", "string", "boolean", "function", "table", "any", }, schema.type),
      assert_prefix .. string.format(
        "Expected `schema.type` to be one of the following:\n%s\n. Received: `%s`.",
        "`nil`, `number`, `string`, `boolean`, `function`, `table`",
        schema.type
      )
    )

    if schema.type == "table" then
      assert(
        type(schema.entries) == "string" or type(schema.entries) == "table" or type(schema.entries) == "function",
        assert_prefix .. string.format(
          "Expected `type(schema.entries)` to be a `string`, `table`, or `function`, received `%s`.",
          type(schema.entries)
        )
      )

      if type(val) ~= "table" then return false end

      if type(schema.entries) == "string" or type(schema.entries) == "function" then
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
  local assert_opt = build_assert_opt { fn_name = "union", arg_name = "schemas", }
  assert_opt {
    cond = type(schemas) == "table",
    actual = type(schemas),
    expected = "table",
    name = "type(schemas)",
  }

  return function(val)
    for _, schema in pairs(schemas) do
      if M.validate(schema, val) then return true end
    end
    return false
  end
end

--- @class AssertOpts
--- @field name string
--- @field schema Schema
--- @field val any

--- @param opts AssertOpts
M.assert = function(opts)
  local assert_opt = build_assert_opt { fn_name = "assert", arg_name = "opts", }
  assert_opt { cond = type(opts) == "table", name = "type(opts)", expected = "table", actual = type(opts), }
  assert_opt { cond = type(opts.name) == "string", name = "type(opts.name)", expected = "string", actual = type(opts.name), }
  assert_opt { cond = type(opts.schema) == "table", name = "type(opts.schema)", expected = "table", actual = type(opts.schema), }

  assert(
    M.validate(opts.schema, opts.val),
    get_validate_assert_message { name = opts.name, actual = opts.val, expected = opts.schema, }
  )
end

--- @param opts AssertOpts
M.notify_assert = function(opts)
  local assert_opt = build_assert_opt { fn_name = "notify_assert", arg_name = "opts", }
  assert_opt { cond = type(opts) == "table", name = "type(opts)", expected = "table", actual = type(opts), }
  assert_opt { cond = type(opts.name) == "string", name = "type(opts.name)", expected = "string", actual = type(opts.name), }
  assert_opt { cond = type(opts.schema) == "table", name = "type(opts.schema)", expected = "table", actual = type(opts.schema), }

  local validate_res = M.validate(opts.schema, opts.val)

  if not validate_res then
    vim.notify(
      get_validate_assert_message { name = opts.name, actual = opts.val, expected = opts.schema, },
      vim.log.levels.ERROR
    )
  end
  return validate_res
end

return M
