# Print method for subgroup_logist_summary

Print method for subgroup_logist_summary

## Usage

``` r
# S3 method for class 'subgroup_logist_summary'
print(x, ...)
```

## Arguments

- x:

  an object of class subgroup_logist_summary

- ...:

  additional params passed to print.data.frame

## Value

invisibly return itself

## See also

[print.data.frame](https://rdrr.io/r/base/print.dataframe.html)

## Examples

``` r
d <- transform(na.omit(survival::lung[, c("status", "age", "sex", "ph.ecog")]),
               died = status == 2, ecog = factor(ph.ecog > 0, labels = c("ECOG 0", "ECOG 1+")))
fit <- glm(died ~ age * ecog + sex * ecog, data = d, family = binomial)
print(subgroup_effect(~ ecog, fit, method = "wald"))
#> - Method: Wald 
#> - CIs are calculated at 95% level of confidence.
#> 
#>  ecog = ECOG 0 log.OR   OR CI.lower CI.upper p.value
#>            age   0.08 1.09     1.02     1.17  0.0150
#>            sex  -1.83 0.16     0.05     0.53  0.0026
#> 
#>  ecog = ECOG 1+ log.OR   OR CI.lower CI.upper p.value
#>             age   0.00 1.00     0.96     1.04  0.9196
#>             sex  -0.69 0.50     0.24     1.06  0.0706
#> 
```
