# Get or set the reference level

A function to quickly get or set the reference level of a factor

## Usage

``` r
ref_lv(x)

# S3 method for class 'factor'
ref_lv(x)

ref_lv(x) <- value

# S3 method for class 'factor'
ref_lv(x) <- value
```

## Arguments

- x:

  A factor

- value:

  An existing level to be set as reference

## Value

\`ref_lv()\`: a string, the reference (first) level. \`ref_lv\<-\`: the
factor with \`value\` as its first level.

## Examples

``` r
arm <- factor(c("Placebo", "Drug", "Drug"))
ref_lv(arm)
#> [1] "Drug"
ref_lv(arm) <- "Placebo"
levels(arm)
#> [1] "Placebo" "Drug"   
```
