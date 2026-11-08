# Get the proportion for each level or range of a vector

A function to calculate the proportion of each value range

## Usage

``` r
pct(x, method = c("auto", "bin", "cont", "fct"), na.rm = TRUE, ...)
```

## Arguments

- x:

  An object

- method:

  A method to calculate the percentage. Default is 'auto' which will
  attempt to choose the most fit method. 'bin' is only meaningful for
  vector that only has to values. 'fct' is meaningful for descrete
  variable 'cont' is used for continuous variables. This will break the
  variable into several ranges depended on the breaks specified in ...

- na.rm:

  A logical value deciding whether NA should be removed

- ...:

  Additional parameters passed to
  [cut](https://rdrr.io/r/base/cut.html). Only work if method = 'cont'
  See [cut](https://rdrr.io/r/base/cut.html)

## Value

If method == 'bin': the percentage of non-reference level

If method == 'fct': the percentages of all levels

If method == 'cont': the percentages of all ranges based on specified
breaks

## Examples

``` r
pct(c(TRUE, FALSE, TRUE, NA))                 # binary: % TRUE among non-missing
#> [1] 66.66667
pct(factor(c("a", "b", "b", "c")))            # one % per level
#>  a  b  c 
#> 25 50 25 
pct(survival::lung$age, method = "cont", breaks = c(0, 50, 65, 100))
#>   (0,50]  (50,65] (65,100] 
#> 11.40351 48.24561 40.35088 
```
