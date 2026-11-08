# Coerce an object to sstable

A function to coerce objects to a sstable

## Usage

``` r
as_sstable(x, ...)

# Default S3 method
as_sstable(x, flextable = FALSE, ...)

# S3 method for class 'list'
as_sstable(x, flextable = FALSE, ...)

# S3 method for class 'logist_summary'
as_sstable(x, include_footnote = TRUE, flextable = FALSE, ...)

# S3 method for class 'overlap_summary'
as_sstable(x, include_footnote = TRUE, flextable = FALSE, ...)

# S3 method for class 'subgroup_logist_summary'
as_sstable(x, include_footnote = TRUE, flextable = FALSE, ...)
```

## Arguments

- x:

  An object, usually a named list of length 2 whose names are 'table'
  and 'footer', or a data.frame/matrix (optionally with attribute
  "footer")

- ...:

  additional parameters passed to
  [ss_flextable](https://tranhung93.github.io/306/reference/ss_flextable.md)

- flextable:

  logical value specifying whether to return a flextable. Default is
  FALSE

- include_footnote:

  logical value specifying whether to include footnote in the output.
  Default is FALSE

## Value

If \`flextable = TRUE\`, a flextable. Otherwise a list with elements
\`table\` (a matrix of class \`ss_tbl\`) and \`footer\`, or only the
matrix when \`include_footnote = FALSE\`.

## Examples

``` r
# a logistic regression summary
fit <- glm(I(status == 2) ~ age + sex, data = survival::lung, family = binomial)
as_sstable(logist_summary(fit))
#> $table
#>          ──────────────────────────────────────────────────────────────
#>                         log.OR   OR     lower.CI   upper.CI   p.value  
#>            (Intercept   0.52     1.67   0.17       17.36      0.6602   
#>            )                                                           
#>            age          0.03     1.03   1.00       1.07       0.0601   
#>            sex          -1.05    0.35   0.19       0.64       0.0006   
#>          ──────────────────────────────────────────────────────────────
#> 
#> Column names: V1, V2, V3, V4, V5, V6
#> 
#> $footer
#> [1] "Note: 95% confidence intervals and p-values are based on likelihood ratio statistics."
#> 

# a table assembled from header and body parts
x <- list(header = list(c("", "Arm A", "Arm B")),
          body = list("Age, years" = rbind(c("Mean", "50.1", "49.8"),
                                           c("Median", "51", "49"))),
          footer = "Example table.")
as_sstable(x)
#> $table
#>                     ────────────────────────────────────────
#>                                    Arm A        Arm B       
#>                       Age, years   Age, years   Age, years  
#>                       Mean         50.1         49.8        
#>                       Median       51           49          
#>                     ────────────────────────────────────────
#> 
#> Column names: V1, V2, V3
#> 
#> $footer
#> [1] "Example table."
#> 
as_sstable(x, flextable = TRUE)


.cl-d8bad469{}.cl-8a796ab5{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-5430bca3{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-6477613b{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-fb546ef0{width:0.841in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 1.5pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b81a2977{width:0.754in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 1.5pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-49e2a87a{width:0.755in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 1.5pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4dc59b20{width:0.841in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-867fdd0c{width:0.754in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-e308a743{width:0.755in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f1ba4cd1{width:0.841in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-5f6c419a{width:0.754in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-6263f4c9{width:0.755in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-ef3a1cba{width:0.841in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-def0f92d{width:0.754in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-e5153f76{width:0.755in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-82bda4c9{width:0.841in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-e074625d{width:0.754in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-622ce4d1{width:0.755in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}

```
