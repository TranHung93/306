# ggsurvfit with strata saved

Same as
[ggsurvfit](http://www.danieldsjoberg.com/ggsurvfit/reference/ggsurvfit.md)
but with strata saved, so you can facet by covariables.

## Usage

``` r
ggsurvfit2(
  x,
  type = "survival",
  linetype_aes = FALSE,
  theme = theme_ggsurvfit_default(),
  ...
)
```

## Arguments

- x, type, linetype_aes, theme, ...:

  parameters passed directly
  [ggsurvfit](http://www.danieldsjoberg.com/ggsurvfit/reference/ggsurvfit.md).

## Value

A ggplot object. Each stratum variable is a column of the plot data, so
the plot can be faceted with e.g. \`ggplot2::facet_wrap(~ sex)\`.

## Examples

``` r
library(survival)
fit <- survfit(Surv(time, status) ~ sex + ph.ecog, data = subset(lung, ph.ecog < 3))
ggsurvfit2(fit) + ggplot2::facet_wrap(~ sex)
```
