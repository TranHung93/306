# Obtain label of variable(s) based on metadata information

A function to obtain label of one vector or each variable in one data
frame based on pre-defined metadata information.

## Usage

``` r
getlabel(x, meta = NULL, unit = TRUE, fit = FALSE)
```

## Arguments

- x:

  a vector or data frame to get label.

- meta:

  a data frame contains metadata of the dataset. This data frame should
  have the following variables: varname (character variable specifies
  name of each variable), label (character variable specifies label of
  each variables), type (character variable specifies type of each
  variable \[numeric, factor, character, datetime\], unit (character
  variable specifies units of each continuous variable), scale (numeric
  variable specifies how each variable will be scaled).

- unit:

  a logical value specifies whether unit will be appended in the label
  of continuous variables.

- fit:

  a logical value specifies whether the label will use presentation as
  in model fitting.

## Value

A character vector of labels: one for a vector, one per column for a
data frame (the column name when a column has no label). With \`meta\`,
\`x\` is a variable name (or a data frame whose column names are looked
up in \`meta\$varname\`).

## Examples

``` r
wt <- structure(c(60, 72), label = "Weight", unit = "kg", scale = 10)
getlabel(wt)
#> [1] "Weight [kg]"
getlabel(wt, fit = TRUE)      # as in a model with weight per 10 kg
#> [1] "Weight [+10 kg]"

meta <- data.frame(varname = c("age", "sex"), label = c("Age", "Sex"),
                   unit = c("years", NA), scale = c(10, NA), type = c("numeric", "factor"))
getlabel("age", meta = meta)
#> [1] "Age [years]"
getlabel(data.frame(age = 50, sex = "F"), meta = meta)
#> [1] "Age [years]" "Sex"        
```
