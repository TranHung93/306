# Print method for logist_summary

Print method for logist_summary table

## Usage

``` r
# S3 method for class 'logist_summary'
print(x, ...)
```

## Arguments

- x:

  an object of class logist_summary

- ...:

  additional params passed to print.data.frame

## Value

invisibly return itself

## See also

[print.data.frame](https://rdrr.io/r/base/print.dataframe.html)

## Examples

``` r
fit <- glm(I(status == 2) ~ age + sex, data = survival::lung, family = binomial)
print(logist_summary(fit), right = FALSE)
#> - Method: Likelihood ratio 
#> - CIs are calculated at 95% level of confidence.
#> 
#>             log.OR OR   lower.CI upper.CI p.value
#> (Intercept) 0.52   1.67 0.17     17.36    0.6602 
#> age         0.03   1.03 1.00     1.07     0.0601 
#> sex         -1.05  0.35 0.19     0.64     0.0006 
```
