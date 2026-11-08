# Set template for sstable

This function set the template for sstable

## Usage

``` r
ss_template(sstable, template = c("baseline", "survcomp", "ae"))
```

## Arguments

- sstable:

  a data frame following sstable's grammar

- template:

  An accepted template for sstable: must be either 'baseline',
  'survcomp', or 'ae'.

  If NA, the existing template in the sstable is kept as-is. It no
  template built-in, will return a no-template sstable instead.

## Value

a matrix of class ss_tbl

## Examples

``` r
m <- rbind(c("", "Arm A", "Arm B"), c("Age", "50", "48"))
class(ss_template(m, "baseline"))
#> [1] "baseline_tbl" "ss_tbl"       "matrix"       "array"       
```
