
<!-- README.md is generated from README.Rmd. Please edit that file -->

# C306

C306 collects the R tools used by the Biostatistics group of the Oxford
University Clinical Research Unit (OUCRU) to analyse and report clinical
studies:

- **report tables**: baseline characteristics, adverse events, and
  time-to-event comparisons (Cox, Fine–Gray, restricted mean survival
  time, cumulative incidence), overall and by subgroup, as flextables
  (Word, HTML, PDF) or plain matrices;
- **model summaries**: odds ratios with likelihood-ratio or Wald CIs,
  also within subgroups of an interacting variable;
- **plots**: Aalen–Johansen curves for competing risks, Box–Cox profile
  likelihood;
- **data tools**: import an OUCRU data dictionary, format raw data with
  it, and check the data for missing and out-of-range values.

## Installation

Install the development version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("oucru-biostats/C306")
```

## Quick start

``` r
library(C306)
library(survival)

bl <- read.csv(system.file("extdata", "baseline_data.csv", package = "C306"))
```

**Baseline table.** Each row variable is summarised by arm: continuous
variables with the statistics you ask for, categorical variables as n
(%).

``` r
tab <- sstable.baseline(age + sex + icudays ~ Arm, data = bl,
                        statistics = "median (Q1-Q3)", test = TRUE)
show_table(tab$table)
```

| Characteristic | n | Sham procedure (N=135) Summary statistic | n | Intrathecal treatment (N=136) Summary statistic | p value |
|:---|:---|:---|:---|:---|:---|
| age | 135 | 50 (41-60) | 136 | 46 (38-57) | 0.0812 |
| sex | 135 |  | 136 |  | 1 |
| \- F |  | 22 (16%) |  | 22 (16%) |  |
| \- M |  | 113 (84%) |  | 114 (84%) |  |
| icudays | 133 | 16 (8-23) | 136 | 14 (8-21) | 0.25 |

Add `flextable = TRUE` (or call `ss_flextable(tab)`) for a formatted
table that can be saved with `flextable::save_as_docx()`.

**Adverse events.** Number of episodes and of patients with at least one
event, by arm:

``` r
ae <- read.csv(system.file("extdata", "ae_data.csv", package = "C306"))
tab <- sstable.ae(ae_data = ae, fullid_data = bl, id.var = "usubjid",
                  aetype.var = "ctcaename", grade.var = "ctcaegrade",
                  arm.var = "Arm", flextable = FALSE)
show_table(tab$table, rows = 1:6)
```

| Type of adverse event | n episode | Sham procedure (N=135) n patient | n episode | Intrathecal treatment (N=136) n patient | p value |
|:---|:---|:---|:---|:---|:---|
| Any selected adverse event | 283 | 88 (65%) | 251 | 84 (62%) | 0.559 |
| \- Grade I | 26 | 25 (19%) | 32 | 26 (19%) |  |
| \- Grade II | 208 | 79 (59%) | 192 | 73 (54%) |  |
| \- Grade III | 40 | 25 (19%) | 19 | 17 (12%) |  |
| \- Grade IV | 6 | 6 (4%) | 5 | 5 (4%) |  |
| \- Grade N/A | 3 | 3 (2%) | 3 | 3 (2%) |  |

**Time to event.** Events, absolute risk, hazard ratio and median
survival:

``` r
lung2 <- transform(na.omit(lung[, c("time", "status", "sex")]),
                   arm = factor(sex, labels = c("Male", "Female")))
tab <- sstable.survcomp(Surv(time, status) ~ arm, data = lung2, flextable = FALSE)
show_table(tab$table)
```

| Endpoint | Female (n=90) events/n (risk \[%\]) | Male (n=138) events/n (risk \[%\]) | Comparison HR (95%CI); p-value | Test for proportional hazards p-value |
|:---|:---|:---|:---|:---|
| status | 53/90 (91.68) | 112/138 (96.43) | 0.59 (0.42, 0.82); p=0.00149 | 0.0906 |
| time |  |  |  |  |
| \- Median (95%CI) | 426.00 (348.00, 550.00) | 270.00 (212.00, 310.00) |  |  |
| \- Lower IQR (95%CI) | 226.00 (186.00, 340.00) | 144.00 (107.00, 177.00) |  |  |
| \- Upper IQR (95%CI) | 687.00 (550.00, NA) | 457.00 (387.00, 574.00) |  |  |

Use `compare.method = "rmst"` for a restricted mean survival time
comparison, `sstable.survcomp.subgroup()` for subgroup analyses, and a
competing-risks outcome (`Surv(time, event)` with a factor `event`) for
Fine–Gray models.

## Main functions

| Area | Functions |
|----|----|
| Report tables | `sstable.baseline()`, `sstable.ae()`, `sstable.survcomp()`, `sstable.survcomp.subgroup()` |
| Formatting tables | `ss_flextable()`, `ss_huxtable()`, `as_sstable()`, `ss_format()`, `ft_sstheme()`, `ht_theme_markdown()`, `ht_theme_kable()`, `rbind()` |
| Models | `logist_summary()`, `subgroup_effect()`, `explicit()` |
| Plots | `gg_ajsurvplot()`, `gg_ajsurvplot2()`, `ggsurvfit2()`, `tidy_survfit2()`, `gg_boxcox()` |
| Data tools | `import.info()`, `convert.info()`, `myformat.data()`, `inspect.data()`, `getlabel()`, `labAE()`, `createProject()` |
| Helpers | `contSummary()`, `pct()`, `simple_recode()`, `simple_relevel()`, `simple_sort()`, `ref_lv()`, `mutate_f()`, `summarise_f()` |

See `vignette("C306_vignette_v6", package = "C306")` for a detailed
guide to the report tables, and `NEWS.md` for changes, including the
**impact of fixed bugs on previous reports**.

## Authors

Lam Phung Khanh, Trinh Dong Huu Khanh and Tran Thai Hung (maintainer),
with functions originally written by Marcel Wolbers.
