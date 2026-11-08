# Transpose a subgroup logist summary table

A method to transpose logist summary table, rather than stratify by
subgroup, it stratifies by covariables.

## Usage

``` r
# S3 method for class 'subgroup_logist_summary'
t(x)

# S3 method for class 'subgroup_logist_summary'
x[...]
```

## Arguments

- x:

  an object of class subgroup_logist_summary

- ...:

  row and column indices, as for a data frame.

## Value

If x is a simplified subgroup_logist_summary (aka a data.frame), return
itself. Otherwise, a transposed list of class subgroup_logist_summary

## Details

\`\[\` subsets a simplified \`subgroup_logist_summary\` like a data
frame.

## See also

[t](https://rdrr.io/r/base/t.html)

## Author

Trinh Dong Huu Khanh

## Examples

``` r
d <- transform(na.omit(survival::lung[, c("status", "age", "sex", "ph.ecog")]),
               died = status == 2, ecog = factor(ph.ecog > 0, labels = c("ECOG 0", "ECOG 1+")))
fit <- glm(died ~ age * ecog + sex * ecog, data = d, family = binomial)
se <- subgroup_effect(~ ecog, fit, method = "wald")
t(se)   # one table per covariable instead of one per ECOG group
#> - Method: Wald 
#> - CIs are calculated at 95% level of confidence.
#> 
#>      age log.OR   OR CI.lower CI.upper p.value
#>   ECOG 0   0.08 1.09     1.02     1.17  0.0150
#>  ECOG 1+   0.00 1.00     0.96     1.04  0.9196
#> 
#>      sex log.OR   OR CI.lower CI.upper p.value
#>   ECOG 0  -1.83 0.16     0.05     0.53  0.0026
#>  ECOG 1+  -0.69 0.50     0.24     1.06  0.0706
#> 
```
