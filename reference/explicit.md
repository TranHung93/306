# Transform an object to its explicit form

A function to transform an object to its explicit form if possible

## Usage

``` r
explicit(x, ...)
```

## Arguments

- x:

  An object

- ...:

  additional arguments passed to methods.

## Value

The explicit form of \`x\`; see the methods.

## See also

[explicit.lm](https://tranhung93.github.io/306/reference/explicit.lm.md)

## Examples

``` r
fit <- lm(Sepal.Width ~ Sepal.Length * Petal.Width, data = iris)
fit_explicit <- explicit(fit)
formula(fit_explicit)
#> Sepal.Width ~ Sepal.Length + Petal.Width + `Sepal.Length:Petal.Width`
#> <environment: 0x55bcaffca370>
drop1(fit_explicit)   # the main effects can now be dropped too
#> Single term deletions
#> 
#> Model:
#> Sepal.Width ~ Sepal.Length + Petal.Width + `Sepal.Length:Petal.Width`
#>                            Df Sum of Sq    RSS     AIC
#> <none>                                  20.296 -292.03
#> Sepal.Length                1    0.0000 20.296 -294.03
#> Petal.Width                 1    2.7526 23.049 -274.95
#> `Sepal.Length:Petal.Width`  1    1.3866 21.683 -284.12
```
