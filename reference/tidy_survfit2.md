# Tidy survfit with strata save

Same as
[tidy_survfit](http://www.danieldsjoberg.com/ggsurvfit/reference/tidy_survfit.md)
but with strata saved.

## Usage

``` r
tidy_survfit2(x, times = NULL, type = "survival")
```

## Arguments

- x, times, type:

  same as
  [tidy_survfit](http://www.danieldsjoberg.com/ggsurvfit/reference/tidy_survfit.md)

## Value

A tibble as from
[tidy_survfit](http://www.danieldsjoberg.com/ggsurvfit/reference/tidy_survfit.md),
with one extra column per stratum variable (e.g. \`sex\`, \`ph.ecog\`).

## Examples

``` r
library(survival)
fit <- survfit(Surv(time, status) ~ sex + ph.ecog, data = subset(lung, ph.ecog < 3))
head(tidy_survfit2(fit))
#> # A tibble: 6 × 18
#>    time n.risk n.event n.censor cum.event cum.censor estimate std.error
#>   <dbl>  <dbl>   <dbl>    <dbl>     <dbl>      <dbl>    <dbl>     <dbl>
#> 1     0     36       0        0         0          0    1        0     
#> 2    11     36       1        0         1          0    0.972    0.0282
#> 3    15     35       1        0         2          0    0.944    0.0404
#> 4    31     34       1        0         3          0    0.917    0.0503
#> 5    53     33       1        0         4          0    0.889    0.0589
#> 6    65     32       1        0         5          0    0.861    0.0669
#> # ℹ 10 more variables: conf.high <dbl>, conf.low <dbl>, strata <fct>,
#> #   estimate_type <chr>, estimate_type_label <chr>, monotonicity_type <chr>,
#> #   strata_label <chr>, conf.level <dbl>, sex <chr>, ph.ecog <chr>
```
