# Compute and draw Box-Cox transformation plot for linear models using ggplot2

A forked version of MASS::boxcox using ggplot2

## Usage

``` r
gg_boxcox(object, ...)

# S3 method for class 'formula'
gg_boxcox(
  object,
  lambda = seq(-2, 2, 1/10),
  interp = (m < 100),
  eps = 1/50,
  xlab = expression(lambda),
  ylab = "log-Likelihood",
  ...
)

# S3 method for class 'lm'
gg_boxcox(
  object,
  lambda = seq(-2, 2, 1/10),
  interp = (m < 100),
  eps = 1/50,
  xlab = expression(lambda),
  ylab = "log-Likelihood",
  ...
)

# Default S3 method
gg_boxcox(
  object,
  lambda = seq(-2, 2, 1/10),
  interp = (m < 100),
  eps = 1/50,
  xlab = expression(lambda),
  ylab = "log-Likelihood",
  ...
)
```

## Arguments

- object:

  a formula or fitted model object. Currently only lm and aov objects
  are handled.

- ...:

  additional parameters to be used in the model fitting.

- lambda:

  vector of values of lambda – default (-2, 2) in steps of 0.1

- interp:

  logical which controls whether spline interpolation is used. Default
  to TRUE if plotting with lambda of length less than 100.

- eps:

  Tolerance for lambda = 0; defaults to 0.02

- xlab:

  defaults to "lambda"

- ylab:

  defaults to "log-Likelihood"

## Value

a ggplot object

## See also

[boxcox](https://rdrr.io/pkg/MASS/man/boxcox.html)

## Examples

``` r
gg_boxcox(Volume ~ log(Height) + log(Girth), data = trees,
          lambda = seq(-0.25, 0.25, length = 10))
```
