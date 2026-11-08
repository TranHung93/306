# Format data based on pre-defined information

A function to format each variable in data frame based on pre-defined
information.

## Usage

``` r
myformat.data(data, info)
```

## Arguments

- data:

  a data frame contains variables to be formatted

- info:

  a data frame specifies how variables will be formatted. This data
  frame should have the following columns: varname (character variable
  specifies name of each variable), label (character variable specifies
  label of each variables), type (character variable specifies type of
  each variable \[numeric, factor, character, datetime\], unit
  (character variable specifies units of each continuous variable),
  value (character variable specifies values of each variable \[format
  of datetime variables/values of categorical variables\], levels
  (character variable specifies order of levels of each categorical
  variable), missing (character variable specifies coding for missing
  values for each variable).

## Value

a data frame with variables are formatted according information
specified in info. For factors with \`levels\` in \`info\`, codes that
are not in the dictionary are kept as extra levels (after the dictionary
levels) with a warning, so that \[inspect.data()\] reports them as out
of range.

## Examples

``` r
info <- data.frame(varname = c("age", "sex", "visit"), label = c("Age", "Sex", "Visit date"),
                   type = c("numeric", "factor", "datetime"), unit = c("years", NA, NA),
                   value = c(NA, "1='Male';2='Female'", "ymd"),
                   levels = c(NA, "'Male';'Female'", NA), missing = c("-99", NA, NA))
raw <- data.frame(age = c(30, -99), sex = c(1, 2), visit = c("2024-01-05", "2024-02-10"))
dat <- myformat.data(raw, info)
str(dat)
#> 'data.frame':    2 obs. of  3 variables:
#>  $ age  : num  30 NA
#>   ..- attr(*, "label")= chr "Age"
#>   ..- attr(*, "unit")= chr "years"
#>   ..- attr(*, "scale")= num 1
#>   ..- attr(*, "center")= num 0
#>  $ sex  : Factor w/ 2 levels "Male","Female": 1 2
#>   ..- attr(*, "label")= chr "Sex"
#>  $ visit: Date, format: "2024-01-05" "2024-02-10"
```
