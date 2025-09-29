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

`ft-highlight` is autoloaded but most code is deferred until the first `f`/`F`/`t`/`T` key

## Configuration

```lua
-- defaults to:
vim.g.ft_highlight = {
  -- A string pattern to determine if a character should be highlighted according to its 
  -- occurrence. The pattern is passed to `string.match(str, pattern)` with the current 
  -- character as `str` and the `highlight_pattern` opt as `pattern`. If `string.match` 
  -- returns a match, the character is highlighted as `FTHighlight{First,Second,Third}`, 
  -- otherwise as `FTHighlightDimmed`. Occurrences beyond the third are also highlighted 
  -- as `FTHighlightDimmed`. 
  -- Defaults to `"."` (matches every character).
  highlight_pattern = "."
}
```

## Highlight Groups

`ft-highlight` uses four highlight groups with the following defaults:

```lua
local function get_hl_fg(hl_name) return vim.api.nvim_get_hl(0, { name = hl_name, }).fg end

vim.api.nvim_set_hl(0, "FTHighlightFirst", { fg = get_hl_fg "Normal", })
vim.api.nvim_set_hl(0, "FTHighlightSecond", { fg = get_hl_fg "DiagnosticWarn", bold = true, })
vim.api.nvim_set_hl(0, "FTHighlightThird", { fg = get_hl_fg "DiagnosticError", bold = true, })
vim.api.nvim_set_hl(0, "FTHighlightDimmed", { fg = get_hl_fg "Comment", })
```
