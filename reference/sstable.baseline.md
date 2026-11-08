# Create baseline table

A function to create a simple summary baseline table.

## Usage

``` r
sstable.baseline(
  formula,
  data,
  bycol = TRUE,
  pooledGroup = FALSE,
  keepEmptyGroup = FALSE,
  statistics = "mean; median (Q1-Q3)",
  cont = NULL,
  cat = NULL,
  fullfreq = FALSE,
  digits.numeric = c("mean(x, na.rm = TRUE) > 10 ~ 0",
    "mean(x, na.rm=T) > 1 & mean(x, na.rm=T) <= 10 ~ 1", "mean(x, na.rm=T) <= 1 ~ 2"),
  digits.nonnumeric = c("!is.numeric(x) ~ 0"),
  digits.name = NULL,
  test = FALSE,
  pdigits = 3,
  pcutoff = 1e-04,
  chisq.test = FALSE,
  correct = FALSE,
  simulate.p.value = FALSE,
  B = 2000,
  workspace = 1e+06,
  hybrid = FALSE,
  keepEmptyString = FALSE,
  footer = NULL,
  flextable = FALSE,
  bg = "#F2EFEE",
  matrix.raw = FALSE
)
```

## Arguments

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

- cat:

  a vector specifies whether each row variables is categorical.

- fullfreq:

  a logical value specifies whether to show total frequency as a
  denominator

- digits.numeric:

  a list of characters to specify the numerical conditions for how many
  decimal places of summarizing statistics will display

- digits.nonnumeric:

  a list of characters to specify the nonnumerical conditions for how
  many decimal places of summarizing statistics will display

- digits.name:

  a list of names of variables to specify for how many decimal places of
  summarizing statistics will display for those variable names

- test:

  a logical value specifies whether a statistical test will be performed
  to compare between treatment arms.

- pdigits:

  a number specifies number of significant digits for p value.

- pcutoff:

  a number specifies threshold value of p value to be displayed as "\<
  pcutoff".

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

- keepEmptyString:

  a logical value specifying whether should keep empty string values in
  categorical variables.

- footer:

  a vector of strings to be used as footnote of table.

- flextable:

  a logical value specifies whether output will be a flextable-type
  table.

- bg:

  a character specifies color of the odd rows in the body of
  flextable-type table.

- matrix.raw:

  a logical values specifies whether output will be a draw dataframe.

## Value

If \`flextable = TRUE\`, a flextable. If \`matrix.raw = TRUE\`, the
summary matrix without header and footer. Otherwise a list of class
\`ss_baseline\` with elements \`table\` (the table as a character
matrix, header rows first) and \`footer\`; use \[ss_flextable()\] or
\[ss_huxtable()\] to render it later.

## Examples

``` r
bl <- read.csv(system.file("extdata", "baseline_data.csv", package = "C306"))

# summary by arm, with tests
tab <- sstable.baseline(age + sex + bmi ~ Arm, data = bl, test = TRUE)
tab$table
#>          ──────────────────────────────────────────────────────────────
#>            V1           V2    V3           V4    V5           V6       
#>          ──────────────────────────────────────────────────────────────
#>                               Sham               Intratheca   p value  
#>                               procedure          l                     
#>                               (N=135)            treatment             
#>                                                  (N=136)               
#>            Characteri   n     Summary      n     Summary               
#>            stic               statistic          statistic             
#>            age          135   49; 49       136   49; 49       0.896    
#>                               (38-58)            (38-60)               
#>            sex          135                136                0.879    
#>            - F                27 (20%)           26 (19%)              
#>            - M                108 (80%)          110 (81%)             
#>            bmi          135   21; 21       136   21; 20       0.332    
#>                               (19-24)            (18-23)               
#>          ──────────────────────────────────────────────────────────────
#> 
#> Column names: V1, V2, V3, V4, V5, V6
tab$footer
#> [1] "N is number of all patients, n is number of patients with non-missing value."                                                             
#> [2] "Summary statistic is absolute count (%) for categorical variable(s) and mean; median (Q1-Q3) for numeric variable(s)."                    
#> [3] "p-values were based on Fisher's exact test for categorical variable(s) and Kruskal-Wallis/Mann-Whitney U-test for continuous variable(s)."

# median (Q1-Q3), a "Total" column, and a flextable
sstable.baseline(age + sex + icudays ~ Arm, data = bl, statistics = "median (Q1-Q3)",
                 pooledGroup = TRUE, flextable = TRUE)


.cl-d8bad469{}.cl-8a796ab5{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-5430bca3{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-6477613b{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-8bef961a{width:1.348in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 1.5pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-a9da5a42{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 1.5pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bb4fe468{width:1.673in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 1.5pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-fda8e67f{width:1.348in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-404263b3{width:0.75in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2b3cb2e9{width:1.673in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4e3f1be5{width:1.348in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-07bfab68{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c1afde5a{width:1.673in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-32246134{width:1.348in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-e412e24a{width:0.75in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-9adb6d15{width:1.673in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-9b4aec1b{width:1.348in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1c23095b{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-9c7b9b2a{width:1.673in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}



Characteristic
```
