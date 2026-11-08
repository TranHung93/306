# Import OUCRU's data dictionary into R

A function to import OUCRU's data dictionary into R.

## Usage

``` r
import.info(table_name, input, output)
```

## Arguments

- table_name:

  a character vector specifies names of Excel sheets (in OUCRU's data
  dictionary) to be imported. A grid is named \`\<CRF\>\_\<Grid\>\`; its
  CRF sheet must be requested too.

- input:

  a character value specifies path to the OUCRU's data dictionary file
  (in Excel format).

- output:

  a character value specifies the \`.RData\` file in which to save
  imported data.

## Value

Nothing (called for its side effect). The file \`output\` contains one
data frame \`\<sheet\>\_info\` per imported sheet, and
\`sheet_info_name\`, the names of those data frames.

## Examples

``` r
dict <- system.file("extdata", "oucru_dictionary.xlsx", package = "C306")
out <- tempfile(fileext = ".RData")
import.info(c("ENR", "LAB", "LAB_G1"), input = dict, output = out)
load(out)
sheet_info_name
#> [1] "ENR_info"    "LAB_info"    "LAB_G1_info"
ENR_info
#> # A tibble: 3 × 8
#>   Variable Caption        `Data type` Category Format   Grid  Note1 Note2
#>   <chr>    <chr>          <chr>       <chr>    <chr>    <lgl> <lgl> <lgl>
#> 1 AGE      Age            Integer     NA       NA       NA    NA    NA   
#> 2 SEX      Sex            RadioList   SEX      NA       NA    NA    NA   
#> 3 ENRDATE  Enrolment date DateTime    NA       dd/mm/yy NA    NA    NA   
```
