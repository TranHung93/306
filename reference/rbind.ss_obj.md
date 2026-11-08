# Row-binding two sstables

Row-bind two sstable objects (as returned by \[sstable.ae()\],
\[sstable.baseline()\] or \[sstable.survcomp()\] with \`flextable =
FALSE\`) built with the same settings. The header rows of the second
table are dropped.

Call it as \`rbind(tbl1, tbl2)\`. The old forms \`rbind.ss_ae(tbl1,
tbl2, header, footer)\`, with arguments given by position or as \`tbl1 =
\` / \`tbl2 = \`, still work.

## Usage

``` r
# S3 method for class 'ss_obj'
rbind(..., deparse.level = 1)

# S3 method for class 'ss_ae'
rbind(..., deparse.level = 1, header = 1:3, footer)

# S3 method for class 'ss_survcomp'
rbind(..., deparse.level = 1, header = 1:3, footer)

# S3 method for class 'ss_baseline'
rbind(..., deparse.level = 1, header = 1:2, footer)
```

## Arguments

- ...:

  the two sstable objects (\`tbl1\`, \`tbl2\`) of the same template.

- deparse.level:

  unused; kept for compatibility with \[rbind()\].

- header:

  the rows considered to be the header area. This area is removed from
  the second table before binding.

- footer:

  the footer of the result. By default the (common) footer of the two
  tables; an error is raised if their footers differ and no footer is
  given.

## Value

a list with elements \`table\` and \`footer\`, like the inputs.

## Examples

``` r
library(survival)
lung2 <- transform(na.omit(lung[, c("time", "status", "sex", "ph.ecog")]), arm = factor(sex))
# all patients, then patients with ECOG 0-1, in one table
t1 <- sstable.survcomp(Surv(time, status) ~ arm, data = lung2, medsum = FALSE,
                       flextable = FALSE)
t2 <- sstable.survcomp(Surv(time, status) ~ arm, data = subset(lung2, ph.ecog < 2),
                       medsum = FALSE, flextable = FALSE)
rbind(t1, t2)$table
#>     ────────────────────────────────────────────────────────────────────────
#>       Endpoint   2 (n=90)       1 (n=137)      Comparison     Test for      
#>                                                               proportional  
#>                                                               hazards       
#>                  events/n       events/n       HR (95%CI);    p-value       
#>                  (risk [%])     (risk [%])     p-value                      
#>       status     53/90          111/137        0.59 (0.43,    0.1           
#>                  (91.68)        (96.40)        0.82);                       
#>                                                p=0.00176                    
#>     ────────────────────────────────────────────────────────────────────────
#> 
#> Column names: V1, V2, V3, V4, V5
```
