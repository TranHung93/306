# TODO

Open items left after the 0.2.0 code-quality work. Each one changes
behaviour in some case, so each needs a decision and, for a fix, a test
that fails on the current code first. Line numbers refer to the 0.2.0
sources. Find the current sites with `lintr::lint_package()`
(vector_logic_linter, seq_linter).

## 1. `|` and `&` inside `if()` (vector_logic_linter, 31 lines)

`if()` needs one TRUE/FALSE value. `||` and `&&` give that and stop
early, but switching is not always a pure style change:

- `||` / `&&` do not evaluate the right-hand side when the left decides
  the result. That can avoid an error, or skip one, that the current
  code hits.
- Since R 4.3, `||` / `&&` raise an error for arguments of length \> 1,
  where `|` / `&` silently give a vector (and `if()` errors only if that
  vector is not of length 1).

Check each site for the length of both sides before changing it.

- `R/checking.R:9` — `identical(...) | identical(...) | ...` (scalars;
  safe to switch)
- `R/checking.R:97` — `!missing(id) & !is.null(output)`
- `R/checking.R:123` — `mode(tmpdata) != "numeric" | is.factor(tmpdata)`
- `R/checking.R:173` — `anyNA(x) | any(blank)`
- `R/checking.R:177` —
  `type == "numeric" & (!is.na(value) & value != "")` (`value` from the
  dictionary; check it is always length 1)
- `R/checking.R:186` — `type == "factor" & !is.na(value)`
- `R/formating.R:104` — `is.na(levels) | levels == ""`
- `R/getlabel.R:36` —
  `(is.factor(x) | attr(x, 'type') == 'factor') | unit == FALSE`
  (attribute set to “” on line 32, so length 1)
- `R/getlabel.R:64` — `.type == 'factor' | unit == FALSE`
- `R/group_effect.R:66-67` —
  `length(summary_vars) & !(length(summary_vars) == 1 & ...)`
- `R/group_effect.R:115` — `all(...) & simplify`
- `R/ssformat.R:9` — `!is.matrix(sstable) & !is.data.frame(sstable)`
- `R/ssformat.R:457` —
  `k < length(which.start) & which.start[k+1] - which.start[k] > 1`
  (right side is NA for the last k; `&&` would not evaluate it)
- `R/ssformat.R:474` — same as line 457
- `R/ssformat.R:575` —
  `!is.na(ht[header_row, col]) & trimws(ht[header_row, col]) != ''`
- `R/sstable.ae.R:189` —
  `!is.null(names(aetype.var)) & isTRUE(nchar(names(aetype.var)) > 0)`
- `R/sstable.baseline.edit.R:115` —
  `(is.null(z) & any(continuous)) | (!is.null(z) & !is.factor(z))`
- `R/sstable.baseline.edit.R:122` —
  `(is.null(z) & any(continuous == FALSE)) | (!is.null(z) & is.factor(z))`
- `R/sstable.baseline.R:268-269` — class checks of the column variable
  `y`
- `R/sstable.baseline.R:306` —
  `continuous[i] == FALSE & !is.factor(x[, i])`
- `R/sstable.baseline.R:310` — `!is.null(z) & any(continuous == TRUE)`
- `R/sstable.baseline.R:314` — `bycol == FALSE & any(...)`
- `R/sstable.baseline.R:381` — `test == TRUE & ngroup > 1`
- `R/sstable.baseline.R:466` — `test == TRUE & ngroup > 1`
- `R/sstable.R:7` — `identical(...) | identical(...) | ...` (scalars;
  safe to switch)
- `R/sstable.survcomp.R:339` — `medsum & !ms`
- `R/toolkits.R:195` —
  `method == 'bin' & !is.logical(x) & !setequal(unique(x), c(0,1))`
- `R/toolkits.R:213` — `is.logical(x) | length(unique(x)) <= 2`
- `R/toolkits.R:214` —
  `is.factor(x) | is.character(x) | (is.numeric(x) & length(unique(x)) <= 5)`

## 2. `1:n` where n can be 0 (seq_linter, 19 sites)

When n is 0, `1:n` is `c(1, 0)`: the loop runs twice with nonsense
indices and usually fails with an unrelated error. `seq_len(n)` /
`seq_along(x)` would run zero times, which changes the result for that
input. (The sites where n is always at least 1 were already changed in
0.2.0.)

Inputs that reach n = 0:

- `R/checking.R:77` — `1:ncol(data)`:
  [`inspect.data()`](https://tranhung93.github.io/306/reference/inspect.data.md)
  when no column of `data` is in `info$varname`
- `R/checking.R:110` — `1:length(info$varname)`: same, with
  `plot = TRUE`
- `R/ssformat.R:61`, `:78`, `:95` —
  `rownames(sstable) <- 1:nrow(sstable)`: a table with no rows
- `R/ssformat.R:161`, `:174` — `ss_guess_format()` on a table with no
  rows
- `R/ssformat.R:270`, `:292`, `:301`, `:330`, `:463`, `:574` —
  `1:ncol(...)`: a table with no columns
- `R/sstable.ae.R:251` — `1:length(grade)`: a character `grade.var` that
  is all `NA` (`._grade_order()` drops NA)
- `R/sstable.baseline.R:390`, `:483` — `1:length(levels(x))`: a row
  variable with no non-missing value, with a third-dimension variable
- `R/sstable.survcomp.subgroup.R:108` — `1:length(subgroup.char)`:
  `subgroup.model = ~1`
- `R/sstable.survcomp.subgroup.R:193` — `1:length(factor.levels)`: a
  subgroup variable that is all `NA`
- `R/toolkits.R:93` — `1:nrow(Map)`:
  [`simple_recode()`](https://tranhung93.github.io/306/reference/simple_recode.md)
  with an empty `map`

For most of these the better fix is an input check with a clear error
(`c306_abort()`), not only
[`seq_len()`](https://rdrr.io/r/base/seq.html).

## 3. Depends vs Imports

DESCRIPTION has `Depends: data.table, dplyr`.
[`library(C306)`](https://tranhung93.github.io/306/) therefore attaches
both packages to the user’s search path, which can mask functions
(e.g. [`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html)
masks [`stats::filter()`](https://rdrr.io/r/stats/filter.html), and
data.table and dplyr both define `between()`, `first()` and `last()`).
Moving them to `Imports` is the usual practice, but scripts that rely on
[`library(C306)`](https://tranhung93.github.io/306/) to make dplyr or
data.table functions available would then need their own
[`library()`](https://rdrr.io/r/base/library.html) calls. That is a
user-visible change: decide, announce it in NEWS, and check the vignette
and the project templates in `inst/structure`.
