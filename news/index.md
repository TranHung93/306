# Changelog

## C306 0.2.0

First release of the independently maintained version of C306 at
<https://github.com/TranHung93/306> (based on oucru-biostats/C306).
Install it with `remotes::install_github("TranHung93/306")`; the package
name is unchanged. Several bugs gave wrong numbers in tables or plots:
check the section below before relying on reports made with earlier
versions.

### Impact on previous reports

Five bugs gave wrong numbers in tables or plots. Reports made in the
periods below with the affected arguments should be re-run with this
version. In each case, the other numbers in the same table were correct.

1.  **Risk % in survival tables**
    - Functions:
      [`sstable.survcomp()`](https://tranhung93.github.io/306/reference/sstable.survcomp.md),
      [`sstable.survcomp.subgroup()`](https://tranhung93.github.io/306/reference/sstable.survcomp.subgroup.md)
      (all rows), and tables built from them
      ([`ss_flextable()`](https://tranhung93.github.io/306/reference/ss_flextable.md),
      [`ss_huxtable()`](https://tranhung93.github.io/306/reference/ss_huxtable.md),
      [`rbind()`](https://rdrr.io/r/base/cbind.html)).
    - Affected: `add.risk = TRUE` (the default), with any
      `compare.method`.
      [`sstable.survcomp.subgroup()`](https://tranhung93.github.io/306/reference/sstable.survcomp.subgroup.md)
      always uses it.
    - Period: 2024-07-09 (upstream oucru-biostats/C306 commit 40aeabd,
      “Adding mstate model to survcomp”; versions 0.1.5-022405 to
      0.1.5-240715) until this version.
    - What was wrong: the “risk \[%\]” figure was 100 × the cumulative
      hazard, not the absolute risk (e.g. 232% instead of 92%). It is
      now 1 − Kaplan–Meier, or the Aalen–Johansen probability of the
      cause of interest for competing risks. Competing-risks tables were
      wrong from the start (same commit). Before 2024-07-09 the column
      was correct. Event counts, HRs, RMST/cumulative-incidence
      estimates, CIs and p-values were not affected.
2.  **Subgroup rows with `reference.arm = "A"`**
    - Function:
      [`sstable.survcomp.subgroup()`](https://tranhung93.github.io/306/reference/sstable.survcomp.subgroup.md).
    - Affected: `reference.arm = "A"`, subgroup rows only (not “All
      patients”).
    - Period: 2024-06-17 (upstream oucru-biostats/C306 commit cbe10dc,
      when `reference.arm` was added) until this version.
    - What was wrong: subgroup rows ignored `reference.arm` and always
      used arm B as the reference, so their HR / RMST /
      cumulative-incidence comparisons were inverted relative to the
      “All patients” row (e.g. HR 0.54 shown instead of 1.85).
3.  **`model.censoring` dropped from the heterogeneity test**
    - Function:
      [`sstable.survcomp.subgroup()`](https://tranhung93.github.io/306/reference/sstable.survcomp.subgroup.md).
    - Affected: `compare.method = "rmst"` or `"cuminc"` with
      `model.censoring` given in `compare.args`; the “Test for
      heterogeneity” p-value only.
    - Period: 2024-06-13 (upstream oucru-biostats/C306 commit 869429c,
      “add RMST to survcomp”) until this version.
    - What was wrong: the user’s `model.censoring` was replaced by the
      eventglm default (`"independent"`) in the interaction test, so the
      heterogeneity p-value used a different censoring model from the
      one requested (e.g. 0.795 instead of 0.375).
4.  **Confidence intervals of
    [`subgroup_effect()`](https://tranhung93.github.io/306/reference/subgroup_effect.md)**
    - Function:
      [`subgroup_effect()`](https://tranhung93.github.io/306/reference/subgroup_effect.md),
      including `sstable = TRUE`, `flextable = TRUE` and
      `transpose = TRUE` output.
    - Affected: all calls, both `method = "lik.ratio"` and `"wald"`; the
      `CI.lower` / `CI.upper` columns only.
    - Period: 2019-12-26 (upstream oucru-biostats/C306 commit 5b44416,
      when the function was added) until this version.
    - What was wrong: the CI was that of the *log* odds ratio, printed
      next to the odds ratio (e.g. OR 1.06 with “CI” (-0.20, 0.32)
      instead of (0.82, 1.37)). It is now the CI of the OR, as in
      [`logist_summary()`](https://tranhung93.github.io/306/reference/logist_summary.md).
      ORs, log ORs and p-values were correct.
5.  **Drift of the competing-risks curves**
    - Functions:
      [`gg_ajsurvplot()`](https://tranhung93.github.io/306/reference/gg_ajsurvplot.md)
      (from 2024-06-20, upstream oucru-biostats/C306 commit 17a757d) and
      [`gg_ajsurvplot2()`](https://tranhung93.github.io/306/reference/gg_ajsurvplot2.md),
      including `.return_data = TRUE` (from 2024-06-25, upstream commit
      b89f64b), until this version.
    - Affected: plots with groups on the right-hand side of the formula
      whose censoring patterns differ.
    - What was wrong: the censoring weights were pooled over all groups,
      so the curves were not the Aalen–Johansen estimate of each group.
      They drifted in late follow-up (by up to 2.5 percentage points in
      [`survival::mgus2`](https://rdrr.io/pkg/survival/man/mgus2.html)
      by sex). Early follow-up was essentially unchanged. The curves are
      now exact Aalen–Johansen estimates. Fine–Gray hazard ratios in
      [`sstable.survcomp()`](https://tranhung93.github.io/306/reference/sstable.survcomp.md)
      were not affected (they correctly use pooled weights).

### Other changes to output

- [`sstable.survcomp.subgroup()`](https://tranhung93.github.io/306/reference/sstable.survcomp.subgroup.md):
  the “All patients” row now uses `pdigits` (it was fixed at 3; only the
  number of digits shown changes).
- [`sstable.baseline()`](https://tranhung93.github.io/306/reference/sstable.baseline.md):
  when the column variable is a character vector, its columns are now in
  reverse alphabetical order (e.g. B then A), the same as for factor
  arms and as in
  [`sstable.ae()`](https://tranhung93.github.io/306/reference/sstable.ae.md).
  Previously character arms were in alphabetical order.
- [`sstable.ae()`](https://tranhung93.github.io/306/reference/sstable.ae.md):
  grade rows are in clinical order (Grade 1, 2, … 10, or I, II, … V; a
  factor keeps its level order), with “Grade N/A” last. Before, they
  were in alphabetical order (“Grade 10” before “Grade 2”, “Grade N/A”
  first).
- `logist_summary(method = "lik.ratio")`: rows are in model term order,
  as with `method = "wald"` (they were sorted alphabetically).
- [`logist_summary()`](https://tranhung93.github.io/306/reference/logist_summary.md)
  for a model without intercept: the footer said that likelihood ratio
  p-values were not calculated, but they are (and are valid). It now
  says what they test.
- [`myformat.data()`](https://tranhung93.github.io/306/reference/myformat.data.md):
  factor codes that are not in the dictionary are kept as extra levels,
  with a warning, instead of becoming `NA`.
  [`inspect.data()`](https://tranhung93.github.io/306/reference/inspect.data.md)
  then reports them as “Out of range” instead of “Missing value”.
- `pct(method = "cont")` with exactly two ranges returns the percentage
  of each range (before: a single number, the second range only).
- [`contSummary()`](https://tranhung93.github.io/306/reference/contSummary.md)
  replaces only whole statistic names (any case) and keeps the rest of
  your text as written. Before, it lower-cased the whole string (“IQR”
  became “iqr”) and replaced names inside words (“minimum” became
  “1.0imum”). Output for the default statistics is unchanged. Statistics
  of all-missing data are `NA` without warnings (before: `NaN`, `Inf`
  and a warning).

### Bug fixes

- [`sstable.baseline()`](https://tranhung93.github.io/306/reference/sstable.baseline.md)
  no longer fails with “replacement has length zero” when the formula
  has a single row variable (e.g. `x ~ arm`).
- [`sstable.baseline()`](https://tranhung93.github.io/306/reference/sstable.baseline.md)
  no longer creates a copy of each summarised variable in the global
  environment.
- [`sstable.ae()`](https://tranhung93.github.io/306/reference/sstable.ae.md)
  with `flextable = TRUE` no longer fails with “could not find function
  as_paragraph” when flextable is not attached.
- [`sstable.ae()`](https://tranhung93.github.io/306/reference/sstable.ae.md)
  no longer changes `options(warn)`, and reports adverse events
  classified into more than one group with a single warning instead of
  printing to the console.
- [`sstable.ae()`](https://tranhung93.github.io/306/reference/sstable.ae.md):
  the flextable footer now describes the test actually used. It has no
  p-value note when `test = FALSE`, and says “Fisher’s exact test” when
  `chisq.test = FALSE`. User footers are no longer merged into the wrong
  footer row.
- [`sstable.ae()`](https://tranhung93.github.io/306/reference/sstable.ae.md)
  with a factor `grade.var` containing `NA` shows the missing grades as
  “Grade N/A” (they were dropped with a warning).
- [`simple_recode()`](https://tranhung93.github.io/306/reference/simple_recode.md):
  numeric input stays numeric (it was returned as character). A factor
  stays a factor with recoded levels; previously a 2-level factor came
  back as all `NA` and other factors as character. A 2-level factor
  recoded to `"TRUE"`/`"FALSE"` still becomes logical.
- [`pct()`](https://tranhung93.github.io/306/reference/pct.md) with
  `method = "fct"` no longer returns `NA` for every level when the data
  contain missing values, and works on character vectors.
- [`labAE()`](https://tranhung93.github.io/306/reference/labAE.md) works
  again with dplyr \>= 1.1.0 (it always failed with “`...` must be
  empty”).
- [`getlabel()`](https://tranhung93.github.io/306/reference/getlabel.md)
  on a data frame with `meta` no longer fails, and returns labels in the
  column order of the data.
- [`ss_flextable()`](https://tranhung93.github.io/306/reference/ss_flextable.md)
  now uses its `bg` argument (it was ignored).
- [`ss_huxtable()`](https://tranhung93.github.io/306/reference/ss_huxtable.md)
  accepts the objects returned by
  [`sstable.baseline()`](https://tranhung93.github.io/306/reference/sstable.baseline.md),
  [`sstable.ae()`](https://tranhung93.github.io/306/reference/sstable.ae.md)
  and
  [`sstable.survcomp()`](https://tranhung93.github.io/306/reference/sstable.survcomp.md)
  (it failed with “`sstable` must be a matrix or data frame”; only
  [`ss_flextable()`](https://tranhung93.github.io/306/reference/ss_flextable.md)
  had a method for them).
- [`ss_header()`](https://tranhung93.github.io/306/reference/ss_header.md),
  [`ss_body()`](https://tranhung93.github.io/306/reference/ss_body.md)
  and
  [`ss_section()`](https://tranhung93.github.io/306/reference/ss_section.md)
  now return an `ss_tbl` object.
- [`rbind.ss_obj()`](https://tranhung93.github.io/306/reference/rbind.ss_obj.md)
  called directly no longer fails.
- [`sstable.survcomp()`](https://tranhung93.github.io/306/reference/sstable.survcomp.md)
  no longer fails when only one arm is present in the data with
  `medsum = TRUE`. The missing arm is shown as “-”.
- [`sstable.survcomp.subgroup()`](https://tranhung93.github.io/306/reference/sstable.survcomp.subgroup.md)
  no longer fails when a subgroup variable has an empty level; that row
  is shown as “-”.
- `logist_summary(flextable = TRUE)` and
  `subgroup_effect(flextable = TRUE)` work. They always failed with
  “invalid row selection”, because
  [`ss_flextable()`](https://tranhung93.github.io/306/reference/ss_flextable.md)
  failed on tables with a single header row.
- [`logist_summary()`](https://tranhung93.github.io/306/reference/logist_summary.md)
  works for models with a single coefficient.
- [`ss_flextable()`](https://tranhung93.github.io/306/reference/ss_flextable.md)
  merges and bolds the right row for section rows (it used the row
  number of the whole table, including headers, as the body row number).
- [`as_sstable()`](https://tranhung93.github.io/306/reference/as_sstable.md)
  on a list with a list `body` works (it always failed with “the
  condition has length \> 1”).
- `ss_format(.guess = FALSE)` gives its intended message when rows are
  not classified, instead of “invalid ‘type’ (list) of argument”.
- [`inspect.data()`](https://tranhung93.github.io/306/reference/inspect.data.md)
  works without an explicit `check_missing` (it always failed with “the
  condition has length \> 1” on R \>= 4.2). It reports “No error was
  found!” with [`message()`](https://rdrr.io/r/base/message.html).
- [`convert.info()`](https://tranhung93.github.io/306/reference/convert.info.md)
  works in UTF-8 locales (the default on Windows since R 4.2, and on
  Linux/macOS). It always failed with “‘pattern’ is invalid”. Category
  labels are now transliterated to ASCII (e.g. “Nữ” becomes “Nu”)
  instead of losing their non-ASCII letters.
- [`import.info()`](https://tranhung93.github.io/306/reference/import.info.md)
  works when the dictionary has grids but none is requested.
- [`gg_ajsurvplot()`](https://tranhung93.github.io/306/reference/gg_ajsurvplot.md)
  and
  [`gg_ajsurvplot2()`](https://tranhung93.github.io/306/reference/gg_ajsurvplot2.md)
  work when `data` is not a global variable (e.g. inside a function);
  they failed with “object not found”.
- [`mutate_f()`](https://tranhung93.github.io/306/reference/mutate_f.md)
  on an ungrouped data frame keeps the name of a single new column.
- [`createProject()`](https://tranhung93.github.io/306/reference/createProject.md)
  now creates the RStudio project file (`<dir>.Rproj`) when the package
  is installed normally. The template `.Rproj` was left out of the built
  package by `.Rbuildignore`, so it was only created when the package
  was loaded from source.
- [`sstable.baseline()`](https://tranhung93.github.io/306/reference/sstable.baseline.md),
  [`sstable.ae()`](https://tranhung93.github.io/306/reference/sstable.ae.md),
  [`sstable.survcomp()`](https://tranhung93.github.io/306/reference/sstable.survcomp.md)
  and
  [`sstable.survcomp.subgroup()`](https://tranhung93.github.io/306/reference/sstable.survcomp.subgroup.md)
  with `flextable = TRUE` no longer fail when a group or arm name
  contains an apostrophe or a backslash (e.g. “O’Brien”). They failed
  with “unexpected symbol” or “unrecognized escape”, because the header
  labels were pasted into R code and run with `eval(parse())`. (A
  backslash that forms a valid escape, such as a literal `\t`, did not
  fail but was shown as a tab.) Output for other names is unchanged.

### Input checking

- The main functions now check their inputs and stop with a clear
  message (condition class `c306_input_error`) instead of a cryptic
  error, a warning, or wrong output. This covers
  [`sstable.baseline()`](https://tranhung93.github.io/306/reference/sstable.baseline.md),
  [`sstable.ae()`](https://tranhung93.github.io/306/reference/sstable.ae.md),
  [`sstable.survcomp()`](https://tranhung93.github.io/306/reference/sstable.survcomp.md),
  [`sstable.survcomp.subgroup()`](https://tranhung93.github.io/306/reference/sstable.survcomp.subgroup.md),
  [`logist_summary()`](https://tranhung93.github.io/306/reference/logist_summary.md),
  [`subgroup_effect()`](https://tranhung93.github.io/306/reference/subgroup_effect.md),
  [`pct()`](https://tranhung93.github.io/306/reference/pct.md),
  [`simple_recode()`](https://tranhung93.github.io/306/reference/simple_recode.md),
  [`contSummary()`](https://tranhung93.github.io/306/reference/contSummary.md),
  [`labAE()`](https://tranhung93.github.io/306/reference/labAE.md) and
  [`createProject()`](https://tranhung93.github.io/306/reference/createProject.md).
  The checks include:
  - data frames, and data with zero rows;
  - variables missing from the data, with their names listed;
  - the formula shape (e.g. a survival model must have
    [`Surv()`](https://rdrr.io/pkg/survival/man/Surv.html) on the left);
  - TRUE/FALSE arguments, digits, `pcutoff`, and `time > 0`. Inputs that
    were silently accepted and gave wrong results now give an error:
    `pdigits = -1`, `time = -1`, an empty `fullid_data`, and character
    grades in
    [`labAE()`](https://tranhung93.github.io/306/reference/labAE.md).
- Variables used in
  [`sstable.baseline()`](https://tranhung93.github.io/306/reference/sstable.baseline.md)
  formulas must be columns of `data`. (Variables from the calling
  environment never worked.)
- [`createProject()`](https://tranhung93.github.io/306/reference/createProject.md)
  now stops with an error for an unknown `structure` or a non-empty
  `dir`. Before, it reported success even when nothing was copied. It
  reports with [`message()`](https://rdrr.io/r/base/message.html)
  instead of printing, and returns the project path invisibly.
- [`ss_huxtable()`](https://tranhung93.github.io/306/reference/ss_huxtable.md),
  [`ht_theme_markdown()`](https://tranhung93.github.io/306/reference/ht_theme_markdown.md)
  and
  [`ht_theme_kable()`](https://tranhung93.github.io/306/reference/ht_theme_kable.md)
  now say clearly when the suggested package huxtable is not installed.

### Changes to function signatures

The following S3 methods now have the same arguments as their generics
(as required by R CMD check). Calls with positional arguments work as
before.

- `explicit.lm(x, ...)`: `explicit.lm(fit = )` is deprecated.
- `simple_relevel.data.frame(x, ..., by)`:
  `simple_relevel.data.frame(data = )` is deprecated.
  [`simple_relevel.default()`](https://tranhung93.github.io/306/reference/simple_relevel.md)
  gains `...`.
- `print.ss_tbl(x, pretty, ...)`: `print.ss_tbl(sstable = )` is
  deprecated.
- [`rbind.ss_ae()`](https://tranhung93.github.io/306/reference/rbind.ss_obj.md),
  [`rbind.ss_baseline()`](https://tranhung93.github.io/306/reference/rbind.ss_obj.md),
  [`rbind.ss_survcomp()`](https://tranhung93.github.io/306/reference/rbind.ss_obj.md),
  [`rbind.ss_obj()`](https://tranhung93.github.io/306/reference/rbind.ss_obj.md)
  now take the tables through `...`. `rbind(tbl1, tbl2)`, positional
  `header`/`footer`, and `tbl1 =`/`tbl2 =` all keep working.

### Performance

- [`inspect.data()`](https://tranhung93.github.io/306/reference/inspect.data.md)
  is about 7 times faster on large data (e.g. 5.8 s to 0.8 s for 20,000
  rows × 60 numeric variables). Numeric variables are no longer
  converted to text to look for empty strings, and each variable’s
  errors are collected before one data frame is built. The output is
  unchanged.

### Package infrastructure

- This version is maintained independently at
  <https://github.com/TranHung93/306> (based on oucru-biostats/C306);
  install it with `remotes::install_github("TranHung93/306")`. The
  package name stays C306.
- The bundled example datasets are now simulated.
  `inst/extdata/baseline_data.csv` and `inst/extdata/ae_data.csv` used
  to contain real trial data. They have been replaced by synthetic data
  with the same columns, types, factor levels and a similar pattern of
  missing values (IDs `SIM-001` etc.), generated reproducibly by
  `data-raw/simulate_data.R`. The same data are now also available as
  documented datasets (`baseline_data`, `ae_data`). Examples, the
  vignette and the README therefore show different numbers from earlier
  versions. The real data have been removed from the repository history,
  so commit hashes differ from those in oucru-biostats/C306; the commits
  cited above are labelled as upstream commits.
- Added a LICENSE file, a testthat (3rd edition) test suite, and this
  NEWS file.
- `crayon`, `assertthat` and `stringr` are no longer used. `Hmisc` moved
  from Imports to Suggests (it is only used in a vignette). `lifecycle`
  and the base packages `stats`, `utils`, `graphics`, `grDevices` and
  `methods` were added to Imports. `MASS` was added to Suggests (tests
  only). ggplot2 \>= 3.4.0 is required.
- Vignettes now build as HTML vignettes and no longer write files into
  the working directory.
