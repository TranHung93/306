# Calculate summary statistics for continuous variable

A function to calculate summary statistics for continuous variable.

## Usage

``` r
contSummary(x, statistics = NULL, digits = 1, n = TRUE)
```

## Arguments

- x:

  a numeric vector to be summarised.

- statistics:

  a single string describing the summary, e.g. \`"mean (sd)"\` or
  \`"median (Q1-Q3)"\`. The words \`mean\`, \`median\`, \`sd\`, \`q1\`,
  \`q3\`, \`min\` and \`max\` (in any case, as whole words) are replaced
  by their values; all other text is kept as is.

- digits:

  a number specifies number of decimal places for numeric statistics.

- n:

  currently ignored; kept for backward compatibility.

## Value

a string displays formatted summary statistics. Statistics that cannot
be computed (e.g. all values missing) are shown as \`NA\`.

## Examples

``` r
contSummary(c(1, 2, 3, 10), "mean; median (Q1-Q3)")
#> [1] "4.0; 2.5 (1.8-4.8)"
contSummary(c(1, 2, 3, 10), "Median [IQR: Q1-Q3], range min-max", digits = 0)
#> [1] "2 [IQR: 2-5], range 1-10"
```
