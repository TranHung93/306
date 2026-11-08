# Designation of body part for custom sstable

This function set the designated rows as body part of a sstable

## Usage

``` r
ss_body(sstable, rows)
```

## Arguments

- sstable:

  a data frame following sstable's grammar

- rows:

  a numeric vector

## Value

a matrix of class ss_tbl

## Examples

``` r
m <- rbind(c("", "Arm A", "Arm B"), c("Age", "50", "48"))
rownames(ss_body(ss_header(m, 1), 2))
#> [1] "header.1" "body.1"  
```
