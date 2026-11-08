# Calculation of covariable effects within each value of another covariable that has interaction

This function calculate the OR, CI, an p.value within each value of
specified covariable.

## Usage

``` r
subgroup_effect(
  formula,
  model,
  method = c("lik.ratio", "wald"),
  transpose = FALSE,
  stat_digits = 2,
  p_digits = 4,
  sstable = FALSE,
  flextable = FALSE,
  simplify = TRUE,
  ...
)
```

## Arguments

- formula:

  A formula in the the form of A + B ~ X, where

  \- X is the covariable to be concerned. X must be of type factor. - A,
  B are the covarables having interaction with X whose effects will be
  calculated. If . or blank. All covariables having interaction with X
  would be included.

- model:

  A fitted glm model or a formula

- method:

  a string whose value is either "lik.ratio" for CI and tests based on
  likelihood ratio statistics (preferred) or "wald" for CI and tests
  based on Wald statistics

- transpose:

  logical value, default is FALSE, whether to return a transposed
  summary. See also
  [t.subgroup_logist_summary](https://tranhung93.github.io/306/reference/t.subgroup_logist_summary.md)

- stat_digits:

  Number of decimal digits for statistics

- p_digits:

  Number of decimal digits for the p-values

- sstable:

  logical value specifying whether to return in sstable format. Default
  is FALSE. Set to TRUE forces verbose to FALSE

- flextable:

  logical value specifying whether to build flextable object. Default it
  FALSE. Set to TRUE forces sstable to TRUE.

- simplify:

  by default, if there is only one variable on each side of the formula
  and no LHS is a binary, then the function will combine tables in each
  state of X to one. Set to FALSE to avoid this behaviour.

- ...:

  additional parameters passed to glm to fit "model" (if model is a
  formula)

## Value

Under certain circumstances defined in param simplify, a flextable, an
sstable, a data.frame of class 'subgroup_logist_summary', or a
'subgroup_logist_summary'/list of logist_summary, each represents one
state of X. Each table has columns \`log.OR\`, \`OR\`, \`CI.lower\`,
\`CI.upper\` (the 95

## See also

[logist_summary](https://tranhung93.github.io/306/reference/logist_summary.md),
[print.subgroup_logist_summary](https://tranhung93.github.io/306/reference/print.subgroup_logist_summary.md),
[t.subgroup_logist_summary](https://tranhung93.github.io/306/reference/t.subgroup_logist_summary.md)

## Author

Trinh Dong Huu Khanh

## Examples

``` r
d <- transform(na.omit(survival::lung[, c("status", "age", "sex", "ph.ecog")]),
               died = status == 2, ecog = factor(ph.ecog > 0, labels = c("ECOG 0", "ECOG 1+")))
fit <- glm(died ~ age * ecog + sex * ecog, data = d, family = binomial)

# OR of age and of sex within each ECOG group
subgroup_effect(~ ecog, fit)
#> - Method: Likelihood ratio 
#> - CIs are calculated at 95% level of confidence.
#> 
#>  ecog = ECOG 0 log.OR   OR CI.lower CI.upper p.value
#>            age   0.08 1.09     1.02     1.17  0.0094
#>            sex  -1.83 0.16     0.05     0.51  0.0017
#> 
#>  ecog = ECOG 1+ log.OR   OR CI.lower CI.upper p.value
#>             age   0.00 1.00     0.96     1.04  0.9197
#>             sex  -0.69 0.50     0.24     1.06  0.0707
#> 

# one covariable only: a single table with one row per ECOG group
subgroup_effect(age ~ ecog, fit, method = "wald")
#> - Effect table for age
#> - Method: Wald 
#> - CIs are calculated at 95% level of confidence.
#> 
#>         log.OR   OR CI.lower CI.upper p.value
#> ECOG 0    0.08 1.09     1.02     1.17  0.0150
#> ECOG 1+   0.00 1.00     0.96     1.04  0.9196
```
