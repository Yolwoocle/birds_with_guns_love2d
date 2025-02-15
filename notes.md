# Guide to convert PICO-8 games to LÖVE

Regex to convert in-place operations (e.g. `x += 1`) into their traditional equivalent (e.g. `x = x + 1`):
- match: `([\w\.]+)\s*((?:[+\-*\/%^&|]|(?:\.\.)){1})=\s*(.+)`
- to: `$1 = $1 $2 $3`

Regex to convert `if(cond) expr` statements into `if cond then expr end`
Source: https://stackoverflow.com/questions/546433/regular-expression-to-match-balanced-parentheses
- match: `^.*if\s*\(((?:[^)(]|\((?:[^)(]|\((?:[^)(]|\([^)(]*\))*\))*\))*)\).*$` (up to 3 nested parenthesis)
- or, simpler: `^.*if\(.*$`
- I have not provided a replacement pattern as it's risky to work with and not 100% reliable, so it's best to use it as a pattern to then manually replace those occurences.