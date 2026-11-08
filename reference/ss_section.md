# Designation of section title rows for custom sstable

This function set the designated rows as section title rows of an
sstable

## Usage

``` r
ss_section(sstable, rows)
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
m <- rbind(c("", "Arm A", "Arm B"), c("Sex", "", ""), c("- Female", "5", "6"))
rownames(ss_section(m, 2))
#> [1] "1"         "section.1" "3"        
```
