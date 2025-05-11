# ft-highlight.nvim

Add highlights to a `{f,F,t,T}` movement to visualize the number of jumps to a given character.

![demo](https://elanmed.dev/nvim-plugins/ft-highlight.png)

In the example above:
- 1 jump is white
- 2 jumps is yellow
- 3 jumps is red
- 4+ jumps is grey

Colors are based on existing highlight groups defined by your colorscheme, see the section
on [highlight groups](#highlight-groups).

## Status
 
A WIP, tested but may have some bugs.

TODO:
- [] Add vim docs
- [] Run tests on side branches

## Setup

```lua
require("ft-highlight").setup({
  -- Set keymaps for `f`, `F`, `t`, and `T`. Defaults to `true`
  default_keymaps = true, 

  -- A string pattern to determine if a character should be highlighted according to its 
  -- occurrence. The pattern is passed to `string.match(str, pattern)` with the current 
  -- character as `str` and the `highlight_pattern` opt as `pattern`. If `string.match` 
  -- returns a match, the character is highlighted as `FTHighlight{First,Second,Third}`, 
  -- otherwise as `FTHighlightDimmed`. Occurrences beyond the third are also highlighted 
  -- as `FTHighlightDimmed`. 
  -- Defaults to `"."` (matches every character).
  highlight_pattern = "."
})
```

## Highlight Groups

`ft-highlight` uses four highlight groups with the following defaults:

```lua
vim.api.nvim_set_hl(0, "FTHighlightFirst", { link = "Normal", })
vim.api.nvim_set_hl(0, "FTHighlightSecond", { link = "DiagnosticWarn", })
vim.api.nvim_set_hl(0, "FTHighlightThird", { link = "DiagnosticError", })
vim.api.nvim_set_hl(0, "FTHighlightDimmed", { link = "Comment", })
```

To override, update the highlight group after calling the `setup` function:

```lua
require("ft-highlight").setup()

vim.api.nvim_set_hl(0, "FTHighlightFirst", { link = "Normal", underline = true })
```

## Exported functions

### `add_highlight`

Accepts an `opts` argument of the following type:

```lua
--- @class AddHighlightOpts
--- @field forward boolean The direction in which to highlight the char occurrences
--- @field highlight_pattern string (See highlight_pattern in `setup`)
```

Returns no value.

### `clear_highlight`

A function that clears the currently highlighted line.

Accepts no arguments, returns no value.
