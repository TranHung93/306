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
* `ht_theme_markdown()` and `ht_theme_kable()` now give a plain background when
  `bg` has length 1.
* `ss_header()`, `ss_body()` and `ss_section()` now return an `ss_tbl` object.
* `rbind.ss_obj()` called directly no longer fails.

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
