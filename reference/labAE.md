# Identify new lab adverse event to report

A function to identify new lab adverse event to report from a vector of
consecutive lab adverse event grade.

## Usage

``` r
labAE(data, gradecut)
```

## Arguments

- data:

  a numeric vector of consecutive lab adverse event grade.

- gradecut:

  a grade threshold to report.

## Value

A factor (levels "Yes", "No") of the same length as \`data\`: "Yes" when
the grade reaches \`gradecut\` and is higher than the previous grade (or
is the first value), \`NA\` where the grade is missing.

## Examples

``` r
# grades of one patient over consecutive visits; report grade >= 3
labAE(c(0, 1, 3, 3, 2, 4), gradecut = 3)
#> [1] No  No  Yes No  No  Yes
#> Levels: Yes No

# per patient, with dplyr
visits <- data.frame(id = rep(1:2, each = 3), grade = c(1, 3, 3, 3, 2, 4))
dplyr::mutate(dplyr::group_by(visits, id), new_ae = labAE(grade, gradecut = 3))
#> # A tibble: 6 × 3
#> # Groups:   id [2]
#>      id grade new_ae
#>   <int> <dbl> <fct> 
#> 1     1     1 No    
#> 2     1     3 Yes   
#> 3     1     3 No    
#> 4     2     3 Yes   
#> 5     2     2 No    
#> 6     2     4 Yes   
```
