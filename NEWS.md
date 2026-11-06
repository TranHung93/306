# C306 0.1.6 (development version)

## Changes that alter results of previous reports

* **`sstable.survcomp()` and `sstable.survcomp.subgroup()`: the "risk [%]"
  column now shows the absolute risk.** It is 1 − Kaplan–Meier for a single
  event type, and the Aalen–Johansen probability of the cause of interest for
  competing risks. Since 2024-07-09 (commit 40aeabd, "Adding mstate model to
  survcomp"; included in 0.1.5-240715) the column showed 100 × the cumulative
  hazard instead (e.g. 232% instead of 92%). **Every risk percentage in
  reports made with those versions is wrong and will change** when the report
  is re-run. Versions before that commit used 1 − Kaplan–Meier and are not
  affected. Event counts, HRs, RMST/cumulative-incidence estimates, CIs and
  p-values are not affected by this change.

* `sstable.survcomp.subgroup()` with `reference.arm = "A"`: the subgroup rows
  ignored `reference.arm` and were always computed with arm B as the
  reference, so their estimates were inverted relative to the "All patients"
  row. Subgroup rows now use the requested reference arm.

* `sstable.survcomp.subgroup()`: the "All patients" row now uses `pdigits`
  (it was fixed at 3).

* `sstable.survcomp.subgroup()` with `compare.method = "rmst"` or
  `"cuminc"`: a `model.censoring` given in `compare.args` was silently
  replaced by the eventglm default for the heterogeneity test. It is now used.

* **`subgroup_effect()`: the `CI.lower` / `CI.upper` columns are now the 95%
  confidence interval of the odds ratio**, matching the `OR` column next to
  them and `logist_summary()`. Since the function was added (2019-12-26,
  commit 5b44416) they showed the confidence interval of the *log* odds
  ratio, e.g. OR 1.06 with "CI" (-0.20, 0.32) instead of (0.82, 1.37). This
  affects tables built with `sstable = TRUE` or `flextable = TRUE` too. ORs,
  log ORs and p-values are unchanged.

* `gg_ajsurvplot()` and `gg_ajsurvplot2()` now plot the exact Aalen–Johansen
  cumulative incidence of each group. The censoring weights are now estimated
  within each plotted group. Before, they were pooled over all groups, so
  when censoring differed between groups the curves drifted from
  Aalen–Johansen in late follow-up (by up to 2.5 percentage points in
  `survival::mgus2` by sex). Early parts of the curves are essentially
  unchanged. Fine–Gray hazard ratios in `sstable.survcomp()` are not affected.

* `pct(method = "cont")` with exactly two ranges now returns the percentage of
  each range. Before, it returned a single number (the second range only).

* `sstable.baseline()`: when the column variable is a character vector, its
  columns are now in reverse alphabetical order (e.g. B then A), the same as
  for factor arms and as in `sstable.ae()`. Previously character arms were in
  alphabetical order, so their column order changes.

## Bug fixes

* `sstable.baseline()` no longer fails with "replacement has length zero" when
  the formula has a single row variable (e.g. `x ~ arm`).
* `sstable.baseline()` no longer creates a copy of each summarised variable in
  the global environment.
* `sstable.ae()` with `flextable = TRUE` no longer fails with
  "could not find function as_paragraph" when flextable is not attached.
* `sstable.ae()` no longer changes `options(warn)`, and reports adverse events
  classified into more than one group with a single warning instead of
  printing to the console.
* `sstable.ae()`: the flextable footer now describes the test actually used. It
  has no p-value note when `test = FALSE`, and says "Fisher's exact test" when
  `chisq.test = FALSE`. User footers are no longer merged into the wrong
  footer row.
* `simple_recode()`: numeric input stays numeric (it was returned as
  character). A factor stays a factor with recoded levels; previously a
  2-level factor came back as all `NA` and other factors as character. A
  2-level factor recoded to `"TRUE"`/`"FALSE"` still becomes logical.
* `pct()` with `method = "fct"` no longer returns `NA` for every level when the
  data contain missing values, and works on character vectors.
* `labAE()` works again with dplyr >= 1.1.0 (it always failed with
  "`...` must be empty").
* `getlabel()` on a data frame with `meta` no longer fails, and returns labels in
  the column order of the data.
* `ss_flextable()` now uses its `bg` argument (it was ignored).
* `ss_header()`, `ss_body()` and `ss_section()` now return an `ss_tbl` object.
* `rbind.ss_obj()` called directly no longer fails.
* `sstable.survcomp()` no longer fails when only one arm is present in the
  data with `medsum = TRUE`. The missing arm is shown as "-".
* `sstable.survcomp.subgroup()` no longer fails when a subgroup variable has
  an empty level; that row is shown as "-".
* `logist_summary(flextable = TRUE)` and `subgroup_effect(flextable = TRUE)`
  work. They always failed with "invalid row selection", because
  `ss_flextable()` failed on tables with a single header row.
* `logist_summary()` works for models with a single coefficient.
* `ss_flextable()` merges and bolds the right row for section rows (it used the
  row number of the whole table, including headers, as the body row number).
* `as_sstable()` on a list with a list `body` works (it always failed with
  "the condition has length > 1").
* `ss_format(.guess = FALSE)` gives its intended message when rows are not
  classified, instead of "invalid 'type' (list) of argument".
* `inspect.data()` works without an explicit `check_missing` (it always failed
  with "the condition has length > 1" on R >= 4.2). It reports "No error was
  found!" with `message()`.
* `convert.info()` works in UTF-8 locales (the default on Windows since
  R 4.2, and on Linux/macOS). It always failed with "'pattern' is invalid".
  Category labels are now transliterated to ASCII (e.g. "Nữ" becomes "Nu")
  instead of losing their non-ASCII letters.
* `import.info()` works when the dictionary has grids but none is requested.
* `gg_ajsurvplot()` and `gg_ajsurvplot2()` work when `data` is not a global
  variable (e.g. inside a function); they failed with "object not found".
* `mutate_f()` on an ungrouped data frame keeps the name of a single new
  column.
* `createProject()` now creates the RStudio project file (`<dir>.Rproj`) when
  the package is installed normally. The template `.Rproj` was left out of
  the built package by `.Rbuildignore`, so it was only created when the
  package was loaded from source.

## Input checking

* The main functions now check their inputs and stop with a clear message
  (condition class `c306_input_error`) instead of a cryptic error, a warning,
  or wrong output. This covers `sstable.baseline()`, `sstable.ae()`,
  `sstable.survcomp()`, `sstable.survcomp.subgroup()`, `logist_summary()`,
  `subgroup_effect()`, `pct()`, `simple_recode()`, `contSummary()`, `labAE()`
  and `createProject()`. The checks include:
  * data frames, and data with zero rows;
  * variables missing from the data, with their names listed;
  * the formula shape (e.g. a survival model must have `Surv()` on the left);
  * TRUE/FALSE arguments, digits, `pcutoff`, and `time > 0`.
  Inputs that were silently accepted and gave wrong results now give an
  error: `pdigits = -1`, `time = -1`, an empty `fullid_data`, and character
  grades in `labAE()`.
* Variables used in `sstable.baseline()` formulas must be columns of `data`.
  (Variables from the calling environment never worked.)
* `contSummary()` now replaces only whole statistic names (any case) and keeps
  the rest of your text as written. Before, it lower-cased the whole string
  ("IQR" became "iqr") and replaced names inside words ("minimum" became
  "1.0imum"). Output for the default statistics is unchanged. Statistics of
  all-missing data are now `NA` without warnings (before: `NaN`, `Inf` and a
  warning).
* `createProject()` now stops with an error for an unknown `structure` or a
  non-empty `dir`. Before, it reported success even when nothing was copied.
  It reports with `message()` instead of printing, and returns the project
  path invisibly.
* `ss_huxtable()`, `ht_theme_markdown()` and `ht_theme_kable()` now say clearly
  when the suggested package huxtable is not installed.

## Changes to function signatures

The following S3 methods now have the same arguments as their generics (as
required by R CMD check). Calls with positional arguments work as before.

* `explicit.lm(x, ...)`: `explicit.lm(fit = )` is deprecated.
* `simple_relevel.data.frame(x, ..., by)`: `simple_relevel.data.frame(data = )`
  is deprecated. `simple_relevel.default()` gains `...`.
* `print.ss_tbl(x, pretty, ...)`: `print.ss_tbl(sstable = )` is deprecated.
* `rbind.ss_ae()`, `rbind.ss_baseline()`, `rbind.ss_survcomp()`,
  `rbind.ss_obj()` now take the tables through `...`. `rbind(tbl1, tbl2)`,
  positional `header`/`footer`, and `tbl1 = `/`tbl2 = ` all keep working.

## Package infrastructure

* Added a LICENSE file, a testthat (3rd edition) test suite, and this NEWS file.
* `crayon`, `assertthat` and `stringr` are no longer used. `Hmisc` moved from
  Imports to Suggests (it is only used in a vignette). `lifecycle` and the
  base packages `stats`, `utils`, `graphics`, `grDevices` and `methods` were
  added to Imports.
* Vignettes now build as HTML vignettes and no longer write files into the
  working directory.
