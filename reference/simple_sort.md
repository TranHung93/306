# Sort a vector in a user-defined order

A function to sort a vector in an user-defined order

## Usage

``` r
simple_sort(x, order = levels(as.factor(x)))
```

## Arguments

- x:

  A vector to be sorted

- order:

  A manually defined order vector

## Value

A vector of the same type and attributes as \`x\`, sorted in the order
of \`order\`.

## Examples

``` r
simple_sort(c("high", "low", "medium", "low"), order = c("low", "medium", "high"))
#> [1] "low"    "low"    "medium" "high"  
```
