# Create summary table using huxtable package.

This function generate a huxtable from a sstable.

## Usage

``` r
ss_huxtable(sstable, ...)

# S3 method for class 'list'
ss_huxtable(sstable, add_footer = NULL, ...)

# S3 method for class 'ss_obj'
ss_huxtable(sstable, add_footer = NULL, ...)

# Default S3 method
ss_huxtable(
  sstable,
  footer = NULL,
  caption = NULL,
  caption_pos = c("top", "bottom", "topleft", "topcenter", "topright", "bottomleft",
    "bottomcenter", "bottomright"),
  bg = c(grey(0.95), "white"),
  border_width = 0.8,
  border_color = grey(0.75),
  wrap = FALSE,
  ...
)
```

## Arguments

- sstable:

  a data frame following sstable's grammar

- ...:

  additional parameters that will be passed to ss_format if the sstable
  has yet to be formatted.

- add_footer:

  additional footer lines to be appended to object footers

- footer:

  a character vector each of which is the footnote of the flextable

- caption:

  a string containing table caption. Default is NULL

- caption_pos:

  A length-one character vector, one of "top", "bottom", "topleft",
  "topcenter", "topright", "bottomleft", "bottomcenter", "bottomright".
  Default is "bottomcenter".

  See also
  [caption_pos](https://hughjonesd.github.io/huxtable/reference/caption_pos.html)

- bg:

  a character vector that defines background color of the flextable. If
  length(bg) \>= 2, the table will have stripe background, otherwise
  plain.

- border_width:

  a number that defines huxtable border width

- border_color:

  a character string that defines huxtable border color

- wrap:

  a logical value. Default is FALSE. If TRUE, long texts would be
  wrapped, long lines would be broken. This applies to the whole table.
  Please use huxtable::set_wrap instead if you want a cell-wise
  approach. See also
  [wrap](https://hughjonesd.github.io/huxtable/reference/wrap.html)

## Value

an object of class huxtable

## See also

[huxtable](https://hughjonesd.github.io/huxtable/reference/huxtable.html)

## Examples

``` r
if (requireNamespace("huxtable", quietly = TRUE)) {
  bl <- read.csv(system.file("extdata", "baseline_data.csv", package = "C306"))
  tab <- sstable.baseline(age + sex ~ Arm, data = bl)
  ss_huxtable(tab, caption = "Baseline characteristics", caption_pos = "top")
}
#>                             Baseline characteristics                            
#>   ────────────────────────────────────────────────────────────────────────────
#>                     Sham procedure (N=135)        Intrathecal treatment       
#>                                                          (N=136)              
#>     Characterist        n           Summary           n           Summary     
#>          ic                        statistic                     statistic    
#>   ────────────────────────────────────────────────────────────────────────────
#>     age            135            49; 49         136            49; 49        
#>                                   (38-58)                       (38-60)       
#>     sex            135                           136                          
#>     - F                           27 (20%)                      26 (19%)      
#>     - M                           108 (80%)                     110 (81%)     
#>   ────────────────────────────────────────────────────────────────────────────
#>     N is number of all patients, n is number of patients with                 
#>     non-missing value.                                                        
#>     Summary statistic is absolute count (%) for categorical                   
#>     variable(s) and mean; median (Q1-Q3) for numeric                          
#>     variable(s).                                                              
#>   ────────────────────────────────────────────────────────────────────────────
#> 
#> Column names: Characteristic, n, Summary statistic, n, Summary statistic
```
