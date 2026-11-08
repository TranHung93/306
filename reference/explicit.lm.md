# Transform a model to its explicit form

A function to transform an lm model formula to its explicit form. This
is useful when you want to use stats::drop1 to drop additional terms in
interaction models.

## Usage

``` r
# S3 method for class 'lm'
explicit(x, ...)
```

## Arguments

- x:

  An object of class "lm"

- ...:

  unused. Passing the model as \`fit = \` is deprecated, use \`x\`
  instead.

## Value

A model with explicit formula

## See also

[add1](https://rdrr.io/r/stats/add1.html)

## Examples

``` r
iris.model <- lm(Sepal.Width ~ Sepal.Length*Petal.Width, data=iris)
explicit(iris.model)
#> 
#> Call:
#> lm(formula = Sepal.Width ~ Sepal.Length + Petal.Width + `Sepal.Length:Petal.Width`, 
#>     data = iris)
#> 
#> Coefficients:
#>                (Intercept)                Sepal.Length  
#>                  3.4393294                  -0.0003418  
#>                Petal.Width  `Sepal.Length:Petal.Width`  
#>                 -1.5293584                   0.1933552  
#> 
```
