# Convert imported OUCRU's data dictionary into a general data dictionary

A function to convert imported OUCRU's data dictionary into a general
data dictionary.

## Usage

``` r
convert.info(oucru_info, oucru_category)
```

## Arguments

- oucru_info:

  a data frame contains imported data of a sheet from OUCRU's data
  dictionary.

- oucru_category:

  a data frame specifies how categorical variables are coded in OUCRU's
  database.

## Value

A data frame contains data dictionary information in a general format
(columns \`varname\`, \`label\`, \`type\`, \`unit\`, \`value\`,
\`levels\`, \`missing\`, \`scale\`, \`condition\`, \`strict\`), ready
for \[myformat.data()\] and \[inspect.data()\].

## Examples

``` r
oucru_info <- data.frame(
  Category = c(NA, "SEX"), Variable = c("AGE", "SEX"), Caption = c("Age", "Sex"),
  `Data type` = c("Integer", "RadioList"), Format = NA, check.names = FALSE)
oucru_category <- data.frame(category = "SEX", submissionvalue = c("1", "2"),
                             text = c("Male", "Female"))
convert.info(oucru_info, oucru_category)
#>   varname label    type unit               value          levels missing scale
#> 1     SEX   Sex  factor   NA 1='Male';2='Female' 'Male';'Female'      NA    NA
#> 2     AGE   Age numeric   NA                <NA>            <NA>      NA    NA
#>   condition strict
#> 1        NA    Yes
#> 2        NA    Yes
```
