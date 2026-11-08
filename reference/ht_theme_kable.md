# A kable-esque theme for huxtable object

This function provides a kable-esque theme for huxtable object

## Usage

``` r
ht_theme_kable(
  ht,
  header_rows = 1:2,
  header_cols = NULL,
  border_width = 1,
  border_color = "#dddddd",
  bg = c("white", "#f9f9f9")
)
```

## Arguments

- ht:

  an object of class huxtable

- header_rows:

  a numeric vector that delimits the header zone.

- header_cols:

  a numeric vector of columns to be shown in bold, or NULL.

- border_width:

  a number that defines huxtable border width

- border_color:

  a character string that defines huxtable border color

- bg:

  a character vector that defines background color of the flextable. If
  length(bg) \>= 2, the table will have stripe background, otherwise
  plain.

## Value

an object of class huxtable

## Examples

``` r
if (requireNamespace("huxtable", quietly = TRUE)) {
  ht_theme_kable(huxtable::as_hux(head(mtcars[, 1:4])), header_rows = 1)
}
#>                             mpg    cyl   disp     hp  
#>                          ─────────────────────────────
#>                            21        6    160    110  
#>                          ─────────────────────────────
#>                            21        6    160    110  
#>                          ─────────────────────────────
#>                            22.8      4    108     93  
#>                          ─────────────────────────────
#>                            21.4      6    258    110  
#>                          ─────────────────────────────
#>                            18.7      8    360    175  
#>                          ─────────────────────────────
#>                            18.1      6    225    105  
#>                          ─────────────────────────────
#> 
#> Column names: mpg, cyl, disp, hp
```
