# Create or transform variables, with support for multiple assignment

A function to create new variable(s) based on existing ones.

## Usage

``` r
mutate_f(.data, ...)

# S3 method for class 'data.table'
mutate_f(.data, ...)

# S3 method for class 'tbl'
mutate_f(.data, ...)

# S3 method for class 'grouped_df'
mutate_f(.data, ...)

# S3 method for class 'data.frame'
mutate_f(.data, ...)
```

## Arguments

- .data:

  A data.frame, data.table, or tbl

- ...:

  Name-value pairs of expressions, following data.table syntax:
  "new_col" := expression. Multiple assignments can be done via
  c("new_col1", "new_col2") := expression_returning_a_list.

  If unnamed, names of each list elements will be used

## Value

a data.frame, data.table, or a tbl

## Examples

``` r
df <- data.frame(baz = 1:10, foo = c(rep(1, 5), rep(2, 5)))
# two new columns at once, computed within each group of foo
df %>%
   dplyr::group_by(foo) %>%
   mutate_f(c('cum_baz', 'double_baz') := list(cumsum(baz), baz * 2))
#> # A tibble: 10 × 4
#> # Groups:   foo [2]
#>      baz   foo cum_baz double_baz
#>    <int> <dbl>   <int>      <dbl>
#>  1     1     1       1          2
#>  2     2     1       3          4
#>  3     3     1       6          6
#>  4     4     1      10          8
#>  5     5     1      15         10
#>  6     6     2       6         12
#>  7     7     2      13         14
#>  8     8     2      21         16
#>  9     9     2      30         18
#> 10    10     2      40         20
```
