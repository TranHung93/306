# Create baseline table

Adds the header and footer to the summary matrix built by
\[sstable.baseline()\] (with \`matrix.raw = TRUE\`), optionally as a
flextable. Usually called by \[sstable.baseline()\] itself.

## Usage

``` r
sstable.baseline.edit(
  value,
  formula,
  data,
  bycol = TRUE,
  pooledGroup = FALSE,
  keepEmptyGroup = FALSE,
  statistics = "mean, median (Q1-Q3)",
  cont = NULL,
  cate = NULL,
  fullfreq = TRUE,
  digits = 1,
  test = FALSE,
  pdigits = 3,
  pcutoff = 1e-04,
  keepEmptyString = TRUE,
  chisq.test = FALSE,
  correct = FALSE,
  simulate.p.value = FALSE,
  B = 2000,
  workspace = 1e+06,
  hybrid = FALSE,
  footer = NULL,
  flextable = FALSE,
  bg = "#F2EFEE"
)
```

## Arguments

- value:

  the summary matrix returned by \`sstable.baseline(..., matrix.raw =
  TRUE)\`.

- formula:

  a formula specifies variables for rows, variable for column and
  third-dimension variable.

  If formula is in the form of x+y ~ a, the function will summary x and
  y with respects to each value of a

  If formula is in the form of x+y ~ a\|z, the function will summary z
  with respects to each value of {a, x} and {a, y}

- data:

  a data frame to derive baseline table from.

- bycol:

  a logical value specifies whether the summary will be by column or by
  row.

- pooledGroup:

  a logical value specifies whether to pool all subgroups of column
  variable.

- keepEmptyGroup:

  a logical value specifying whether should keep empty groups

- statistics:

  a character specifies summary statistics for continuous row variables.

- cont:

  a vector specifies whether each row variables is continuous.

- cate:

  a vector specifies whether each row variables is categorical.

- fullfreq:

  a logical value specifies whether to show total frequency as a
  denominator.

- digits:

  a number specifies number of significant digits for numeric
  statistics.

- test:

  a logical value specifies whether a statistical test will be performed
  to compare between treatment arms.

- pdigits:

  a number specifies number of significant digits for p value.

- pcutoff:

  a number specifies threshold value of p value to be displayed as "\<
  pcutoff".

- keepEmptyString:

  a logical value specifying whether should keep empty string values in
  categorical variables.

- chisq.test:

  a logical value specifies whether Chi-squared test or Fisher's exact
  test will be used to compare between treatment arms.

- correct:

  a parameter for chisq.test().

- simulate.p.value:

  a parameter for chisq.test() and fisher.test().

- B:

  a parameter for chisq.test() and fisher.test().

- workspace:

  a parameter for fisher.test().

- hybrid:

  a parameter for fisher.test().

- footer:

  a vector of strings to be used as footnote of table.

- flextable:

  a logical value specifies whether output will be a flextable-type
  table.

- bg:

  a character specifies color of the odd rows in the body of
  flextable-type table.

## Value

A flextable if \`flextable = TRUE\`, otherwise a list of class
\`ss_baseline\` with elements \`table\` and \`footer\` (see
\[sstable.baseline()\]).

## Examples

``` r
bl <- read.csv(system.file("extdata", "baseline_data.csv", package = "C306"))
raw <- sstable.baseline(age + sex ~ Arm, data = bl, matrix.raw = TRUE)
# ... edit `raw` here if needed, then add the header and footer:
tab <- sstable.baseline.edit(raw, age + sex ~ Arm, data = bl)
tab$table
#>            ──────────────────────────────────────────────────────────
#>              V1             V2    V3             V4    V5            
#>            ──────────────────────────────────────────────────────────
#>                                   Sham                 Intrathecal   
#>                                   procedure            treatment     
#>                                   (N=135)              (N=136)       
#>              Characterist   n     Summary        n     Summary       
#>              ic                   statistic            statistic     
#>              age            135   49; 49         136   49; 49        
#>                                   (38-58)              (38-60)       
#>              sex            135                  136                 
#>              - F                  27 (20%)             26 (19%)      
#>              - M                  108 (80%)            110 (81%)     
#>            ──────────────────────────────────────────────────────────
#> 
#> Column names: V1, V2, V3, V4, V5
```
