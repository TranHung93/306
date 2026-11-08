# Relevel in correspondence to another factor

Function to relevel a variable in accordance to a another variable of
class "factor".

## Usage

``` r
simple_relevel(x, ...)

# S3 method for class 'data.frame'
simple_relevel(x, ..., by)

# Default S3 method
simple_relevel(x, by, map, value = c("unsorted", "sorted", "levels"), ...)
```

## Arguments

- x:

  For the data.frame method: a data.frame (passing it as \`data = \` is
  deprecated). For the default method: a vector that will be relevelled.

- ...:

  For the data.frame method: unquoted variable names that will be
  relevelled. Unused by the default method.

- by:

  For the data.frame method: an unquoted variable name the relevelling
  process will base on. For the default method: a vector that the
  relevelling process will base on.

- map:

  a list that links by to x in the form of list(by.1 = c(x1.1, x1.2...),
  by.2 = c(x2.1, x2.2...)) or a data.frame with two columns "from" and
  "to" serving the same purpose.

- value:

  a string: whether to return

  \- "levels": new levels only

  \- "unsorted" (default): an unsorted, relevelled factor

  \- "sorted": a sorted, relevelled factor

## Value

An object of the same class as the input

A factor or a numeric vector of order

## Examples

``` r
df <- data.frame(g = factor(c("b", "a", "b", "a"), levels = c("b", "a")),
                 x = c("x1", "y1", "x2", "y2"))
levels(simple_relevel(df, x, by = g)$x)
#> [1] "x1" "x2" "y1" "y2"
simple_relevel(c("p", "q", "r"), by = factor(c("B", "A", "B"), levels = c("B", "A")),
               map = list(A = "q", B = c("p", "r")), value = "levels")
#> [1] "p" "r" "q"
```
