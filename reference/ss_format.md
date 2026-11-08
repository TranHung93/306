# Quick format a sstable in preparation for create flextable/huxtable

This function is the combination of ss_header, ss_body, and ss_section.

## Usage

``` r
ss_format(
  sstable,
  header = c(),
  section = c(),
  body = c(),
  template = c("baseline", "survcomp", "ae"),
  .guess = TRUE
)
```

## Arguments

- sstable:

  a data frame following sstable's grammar

- header:

  a numeric vector that will be passed to ss_header

- section:

  a numeric vector that will be passed to ss_section

- body:

  a numeric vector that will be passed to ss_body

- template:

  An accepted template for sstable: must be either 'baseline',
  'survcomp', or 'ae'.

  If NA, the existing template in the sstable is kept as-is. It no
  template built-in, will return a no-template sstable instead.

- .guess:

  a logical value. If TRUE, the function will try to guess to which part
  each row belongs.

## Value

a matrix of class ss_tbl

## Examples

``` r
m <- rbind(c("", "Arm A", "", "Arm B", ""),
           c("Characteristic", "n", "Summary", "n", "Summary"),
           c("Age", "10", "50 (40-60)", "12", "48 (41-55)"),
           c("Sex", "", "", "", ""),
           c("- Female", "", "5 (50%)", "", "6 (50%)"))
f <- ss_format(m)          # rows guessed: 2 header rows, a section, body rows
rownames(f)
#> [1] "header.1"  "header.2"  "body.1"    "section.1" "body.2"   
ss_format(m, header = 1:2, section = 4, body = c(3, 5), .guess = FALSE)
#>            ──────────────────────────────────────────────────────────
#>                             Arm A                Arm B               
#>              Characterist   n       Summary      n       Summary     
#>              ic                                                      
#>              Age            10      50 (40-60)   12      48 (41-55)  
#>              Sex                                                     
#>              - Female               5 (50%)              6 (50%)     
#>            ──────────────────────────────────────────────────────────
#> 
#> Column names: V1, V2, V3, V4, V5
```
