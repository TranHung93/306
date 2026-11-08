# Check formatted data based on a pre-defined information

A function to check a formatted data frame based on a pre-defined
information.

## Usage

``` r
inspect.data(
  data,
  info,
  id,
  check_missing = c(TRUE, FALSE),
  plot = FALSE,
  prefix = "",
  outdir
)
```

## Arguments

- data:

  a formatted data frame to be checked.

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
  values for each variable), condition (character variable specifies
  conditional checking), strict (a character variable \[Yes, No\]
  specifies whether missing data should be checked for each variable).

- id:

  a character specifies name of subject id variable.

- check_missing:

  a logical value specifies whether missing data should be checked
  (default \`TRUE\`).

- plot:

  a logical value specifies whether plot (bar plot for categorical
  variables, boxplot for continuous variables) should be produced.

- prefix:

  a character to be appended as prefix of all output files.

- outdir:

  a character specifies where to save output files. Defaults to the
  working directory.

## Value

A data frame lists all identified potential data errors (columns
\`index\` and \`error\`, plus \`id\` if given), also written to
\`\<prefix\>\_error.csv\` in \`outdir\`. If no error is found, a message
and \`NULL\`. With \`plot = TRUE\`, the distributions are drawn in
\`\<prefix\>\_distribution.pdf\` in \`outdir\`.

## Examples

``` r
info <- data.frame(varname = c("id", "age", "sex"), label = c("ID", "Age", "Sex"),
                   type = c("character", "numeric", "factor"), unit = NA,
                   value = c(NA, "0;100", "1='Male';2='Female'"),
                   levels = c(NA, NA, "'Male';'Female'"), missing = NA)
raw <- data.frame(id = c("a1", "a2", "a3"), age = c(30, 150, NA), sex = c(1, 2, 3))
dat <- myformat.data(raw, info)   # warns: sex = 3 is not in the dictionary
#> Warning: sex: value(s) not in the dictionary kept as extra level(s): 3.
inspect.data(dat, info, id = "id", outdir = tempdir())
#>          id index                   error
#> 1 "=""a3"""     3   Missing value for age
#> 2 "=""a2"""     2 Out of range: age > 100
#> 3 "=""a3"""     3   Out of range: sex = 3
```
