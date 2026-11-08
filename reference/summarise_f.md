# Reduce multiple values by summarisation functions.

Create variables summarising exisiting variables, by using summarisation
function.

## Usage

``` r
summarise_f(.data, ...)

# S3 method for class 'data.frame'
summarise_f(.data, ...)

# S3 method for class 'data.table'
summarise_f(.data, ...)

# S3 method for class 'tbl'
summarise_f(.data, ...)

# S3 method for class 'grouped_df'
summarise_f(.data, ...)
```

## Arguments

- .data:

  A data.frame, data.table, or tbl

- ...:

  Summarisation functions. Each of which must return a named list, whose
  names stand for new variables' names. Anonymous functions must be
  wrapped in parentheses.

## Value

a data.frame, data.table, or a tbl

## Examples

``` r
df <- data.frame(baz = 1:10, foo = c(rep(1, 5), rep(2, 5)), bar =4:13)
df %>%
   dplyr::group_by(foo) %>%
   summarise_f(list(mean_baz = mean(baz), max_bar = max(bar)))
#> # A tibble: 2 × 3
#> # Groups:   foo [2]
#>     foo mean_baz max_bar
#>   <dbl>    <dbl>   <int>
#> 1     1        3       8
#> 2     2        8      13
```
