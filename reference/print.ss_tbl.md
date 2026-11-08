# Print an sstable matrix

Print method for objects of class \`ss_tbl\`. When \`pretty\` is
\`TRUE\` and the huxtable package is installed, the table is printed as
a huxtable; otherwise it is printed as a plain matrix.

## Usage

``` r
# S3 method for class 'ss_tbl'
print(x, pretty = getOption("ss_pretty.print", TRUE), ...)
```

## Arguments

- x:

  an object of class \`ss_tbl\`.

- pretty:

  a logical value: print as a huxtable? Defaults to the
  \`ss_pretty.print\` option, or \`TRUE\` if that option is unset.

- ...:

  unused; kept for compatibility with \[print()\]. Passing the table as
  \`sstable = \` is deprecated, use \`x\` instead.

## Value

\`x\`, invisibly.

## Examples

``` r
library(survival)
tab <- sstable.survcomp(Surv(time, status) ~ sex, data = lung, medsum = FALSE,
                        flextable = FALSE)$table
print(tab, pretty = FALSE)
#>      [,1]       [,2]                  [,3]                 
#> [1,] "Endpoint" "2 (n=90)"            "1 (n=138)"          
#> [2,] ""         "events/n (risk [%])" "events/n (risk [%])"
#> [3,] "status"   "53/90 (91.68)"       "112/138 (96.43)"    
#>      [,4]                           [,5]                           
#> [1,] "Comparison"                   "Test for proportional hazards"
#> [2,] "HR (95%CI); p-value"          "p-value"                      
#> [3,] "0.59 (0.42, 0.82); p=0.00149" "0.0906"                       
#> attr(,"class")
#> [1] "survcomp_tbl" "ss_tbl"       "matrix"       "array"       
if (requireNamespace("huxtable", quietly = TRUE)) print(tab)
#>     ────────────────────────────────────────────────────────────────────────
#>       Endpoint   2 (n=90)       1 (n=138)      Comparison     Test for      
#>                                                               proportional  
#>                                                               hazards       
#>                  events/n       events/n       HR (95%CI);    p-value       
#>                  (risk [%])     (risk [%])     p-value                      
#>       status     53/90          112/138        0.59 (0.42,    0.0906        
#>                  (91.68)        (96.43)        0.82);                       
#>                                                p=0.00149                    
#>     ────────────────────────────────────────────────────────────────────────
#> 
#> Column names: V1, V2, V3, V4, V5
```
