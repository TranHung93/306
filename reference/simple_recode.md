# Do a simple recode via pattern for data

A function to re-encode data by using a map. Patterns are accepted.
Unmentioned data are left intact.

Method for class data.frame supports a robust replacement for data by
providing relevant map in the form of var = map.

## Usage

``` r
simple_recode(...)

# S3 method for class 'data.frame'
simple_recode(.data, ..., ignore.case = FALSE, fixed = FALSE, perl = TRUE)

# Default S3 method
simple_recode(
  x,
  map,
  as = c("as_is", "numeric", "factor", "character", "logical"),
  ignore.case = FALSE,
  fixed = FALSE,
  perl = TRUE,
  ...
)
```

## Arguments

- ...:

  For method for data.frame: Replacement in the form of var = map. Maps
  must follow the syntax stipulated in the map parameter.

  For default method: Additional parameters passed to factor()

- .data:

  A data frame to modify

- ignore.case:

  Specify whether the pattern is case-insensitive. Default is FALSE
  (case sensitive). Passed to \[gsub()\].

- fixed:

  If TRUE, patterns are matched as is rather than as regular
  expressions. Passed to \[gsub()\].

- perl:

  Are patterns follow the Perl-style regular expression. Passed to
  \[gsub()\].

- x:

  a vector

- map:

  A map.

  Map can be a list in the form of recoded_text = c(to_be_recoded_text)

  Or as a data frame having 2 columns named "from" and "to".

- as:

  A character string defining the post-recoded data type of x. Default
  is keeping as-is: numeric input stays numeric when possible, and
  factor input stays a factor (a 2-level factor recoded to
  "TRUE"/"FALSE" becomes logical).

## Value

If input is a vector, return a vector of the same length.

If input is a data frame, return a data frame with relevant variables
recoded.

## See also

[regex](https://rdrr.io/r/base/regex.html)
[case_when](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)

## Examples

``` r
# patterns are regular expressions; text that matches no pattern is kept
simple_recode(c("yes", "Yes", "no", NA), map = list(Y = "^[Yy]es$", N = "^no$", Unknown = NA))
#> [1] "Y"       "Y"       "N"       "Unknown"

# a factor stays a factor, with recoded levels
simple_recode(factor(c("m", "f", "f")), map = list(Male = "^m$", Female = "^f$"))
#> [1] Male   Female Female
#> Levels: Female Male

# several variables of a data frame at once
df <- data.frame(sex = c("m", "f"), smoker = c("y", "n"))
simple_recode(df, sex = list(Male = "m", Female = "f"), smoker = list(Yes = "y", No = "n"))
#>      sex smoker
#> 1   Male    Yes
#> 2 Female     No
```
