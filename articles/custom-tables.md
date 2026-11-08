# Formatting and building custom tables

The table functions
([`sstable.baseline()`](https://tranhung93.github.io/306/reference/sstable.baseline.md),
[`sstable.ae()`](https://tranhung93.github.io/306/reference/sstable.ae.md),
[`sstable.survcomp()`](https://tranhung93.github.io/306/reference/sstable.survcomp.md),
…) return either a finished `flextable` or, with `flextable = FALSE`, an
*sstable*: a list with a character matrix `table` and a `footer`. This
vignette shows how to turn sstables into report tables, how to edit
them, and how to build a table of your own in the same style.

| Function | What it does |
|----|----|
| [`ss_flextable()`](https://tranhung93.github.io/306/reference/ss_flextable.md), [`ss_huxtable()`](https://tranhung93.github.io/306/reference/ss_huxtable.md) | render an sstable as a flextable or huxtable |
| [`ft_sstheme()`](https://tranhung93.github.io/306/reference/ft_sstheme.md), [`ht_theme_kable()`](https://tranhung93.github.io/306/reference/ht_theme_kable.md), [`ht_theme_markdown()`](https://tranhung93.github.io/306/reference/ht_theme_markdown.md) | apply the sstable look to any flextable or huxtable |
| [`sstable.baseline.edit()`](https://tranhung93.github.io/306/reference/sstable.baseline.edit.md) | adds the header and footer to a baseline table you edited |
| [`ss_header()`](https://tranhung93.github.io/306/reference/ss_header.md), [`ss_body()`](https://tranhung93.github.io/306/reference/ss_body.md), [`ss_section()`](https://tranhung93.github.io/306/reference/ss_section.md), [`ss_template()`](https://tranhung93.github.io/306/reference/ss_template.md), [`ss_format()`](https://tranhung93.github.io/306/reference/ss_format.md) | mark the rows of a hand-made table |
| [`print()`](https://rdrr.io/r/base/print.html) | prints an sstable matrix in the console |

``` r

library(C306)
```

The examples use `baseline_data`, a **simulated** two-arm trial bundled
with the package.

``` r

bl <- baseline_data
bl$Arm <- factor(bl$Arm, levels = c("Sham procedure", "Intrathecal treatment"))
tab <- sstable.baseline(age + sex + bmi + ablettscore ~ Arm, data = bl)
names(tab)
#> [1] "table"  "footer"
```

## Rendering: `ss_flextable()` and `ss_huxtable()`

[`ss_flextable()`](https://tranhung93.github.io/306/reference/ss_flextable.md)
turns an sstable into a `flextable` with bold header rows, indented row
groups and striped body rows. `add_footer` appends notes to the table’s
own footer:

``` r

ss_flextable(tab, add_footer = "Data are simulated.")
```

|  | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  |
|----|----|----|----|----|
| Characteristic | n | Summary statistic | n | Summary statistic |
| age | 136 | 49; 49 (38-60) | 135 | 49; 49 (38-58) |
| sex | 136 |  | 135 |  |
| - F |  | 26 (19%) |  | 27 (20%) |
| - M |  | 110 (81%) |  | 108 (80%) |
| bmi | 136 | 21; 20 (18-23) | 135 | 21; 21 (19-24) |
| ablettscore | 136 |  | 135 |  |
| - I |  | 50 (37%) |  | 53 (39%) |
| - II |  | 60 (44%) |  | 55 (41%) |
| - III |  | 26 (19%) |  | 27 (20%) |
| N is number of all patients, n is number of patients with non-missing value. |  |  |  |  |
| Summary statistic is absolute count (%) for categorical variable(s) and mean; median (Q1-Q3) for numeric variable(s). |  |  |  |  |
| Data are simulated. |  |  |  |  |

Given only the matrix, it uses `footer` instead, and `bg` sets the
colour of the stripes:

``` r

ss_flextable(tab$table, footer = "A custom footer", bg = "#E8F0F8")
```

|  | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  |
|----|----|----|----|----|
| Characteristic | n | Summary statistic | n | Summary statistic |
| age | 136 | 49; 49 (38-60) | 135 | 49; 49 (38-58) |
| sex | 136 |  | 135 |  |
| - F |  | 26 (19%) |  | 27 (20%) |
| - M |  | 110 (81%) |  | 108 (80%) |
| bmi | 136 | 21; 20 (18-23) | 135 | 21; 21 (19-24) |
| ablettscore | 136 |  | 135 |  |
| - I |  | 50 (37%) |  | 53 (39%) |
| - II |  | 60 (44%) |  | 55 (41%) |
| - III |  | 26 (19%) |  | 27 (20%) |
| A custom footer |  |  |  |  |

[`ss_huxtable()`](https://tranhung93.github.io/306/reference/ss_huxtable.md)
does the same with the `huxtable` package, which also prints to the
console, LaTeX and Markdown. It needs `huxtable`, which is only
suggested by C306:

``` r

ss_huxtable(tab, caption = "Baseline characteristics", caption_pos = "top")
```

|  |  |  |  |  |
|:--:|:--:|:--:|:--:|:--:|
|  | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  |
| Characteristic | n | Summary statistic | n | Summary statistic |
| age | 136 | 49; 49 (38-60) | 135 | 49; 49 (38-58) |
| sex | 136 |  | 135 |  |
| \- F |  | 26 (19%) |  | 27 (20%) |
| \- M |  | 110 (81%) |  | 108 (80%) |
| bmi | 136 | 21; 20 (18-23) | 135 | 21; 21 (19-24) |
| ablettscore | 136 |  | 135 |  |
| \- I |  | 50 (37%) |  | 53 (39%) |
| \- II |  | 60 (44%) |  | 55 (41%) |
| \- III |  | 26 (19%) |  | 27 (20%) |
| N is number of all patients, n is number of patients with non-missing value. |  |  |  |  |
| Summary statistic is absolute count (%) for categorical variable(s) and mean; median (Q1-Q3) for numeric variable(s). |  |  |  |  |

Baseline characteristics {.table .huxtable
quarto-disable-processing="true"
style="width: 100%; margin-left: auto; margin-right: auto;   break-inside: avoid; page-break-inside: avoid;"}

## Theming any table

The same look can be applied to tables not made by C306.
[`ft_sstheme()`](https://tranhung93.github.io/306/reference/ft_sstheme.md)
themes a flextable:

``` r

ft_sstheme(flextable::flextable(head(bl[, c("usubjid", "age", "sex", "Arm")])))
```

| usubjid | age | sex | Arm                   |
|---------|-----|-----|-----------------------|
| SIM-001 | 63  | F   | Intrathecal treatment |
| SIM-002 | 43  | M   | Intrathecal treatment |
| SIM-003 | 33  | M   | Sham procedure        |
| SIM-004 | 18  | F   | Intrathecal treatment |
| SIM-005 | 53  | M   | Sham procedure        |
| SIM-006 | 51  | F   | Sham procedure        |

[`ht_theme_markdown()`](https://tranhung93.github.io/306/reference/ht_theme_markdown.md)
(stripes) and
[`ht_theme_kable()`](https://tranhung93.github.io/306/reference/ht_theme_kable.md)
(borders, like
[`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html)) theme a
huxtable; `header_rows` says which rows are headers:

``` r

ht <- huxtable::as_hux(head(bl[, c("usubjid", "age", "sex", "Arm")]))
ht_theme_markdown(ht, header_rows = 1)
```

| usubjid | age | sex | Arm                   |
|---------|----:|-----|-----------------------|
| SIM-001 |  63 | F   | Intrathecal treatment |
| SIM-002 |  43 | M   | Intrathecal treatment |
| SIM-003 |  33 | M   | Sham procedure        |
| SIM-004 |  18 | F   | Intrathecal treatment |
| SIM-005 |  53 | M   | Sham procedure        |
| SIM-006 |  51 | F   | Sham procedure        |

``` r

ht_theme_kable(ht, header_rows = 1)
```

| usubjid | age | sex | Arm                   |
|---------|----:|-----|-----------------------|
| SIM-001 |  63 | F   | Intrathecal treatment |
| SIM-002 |  43 | M   | Intrathecal treatment |
| SIM-003 |  33 | M   | Sham procedure        |
| SIM-004 |  18 | F   | Intrathecal treatment |
| SIM-005 |  53 | M   | Sham procedure        |
| SIM-006 |  51 | F   | Sham procedure        |

## Printing in the console

An sstable matrix prints as a plain matrix, or, with `huxtable`
installed and `pretty = TRUE` (the default, set by
`options(ss_pretty.print = )`), as a formatted text table:

``` r

print(tab$table, pretty = FALSE)
#> $V1
#>  [1] ""               "Characteristic" "age"            "sex"           
#>  [5] "- F"            "- M"            "bmi"            "ablettscore"   
#>  [9] "- I"            "- II"           "- III"         
#> 
#> $V2
#>  [1] ""    "n"   "136" "136" ""    ""    "136" "136" ""    ""    ""   
#> 
#> $V3
#>  [1] "Intrathecal treatment (N=136)" "Summary statistic"            
#>  [3] "49; 49 (38-60)"                ""                             
#>  [5] "26 (19%)"                      "110 (81%)"                    
#>  [7] "21; 20 (18-23)"                ""                             
#>  [9] "50 (37%)"                      "60 (44%)"                     
#> [11] "26 (19%)"                     
#> 
#> $V4
#>  [1] ""    "n"   "135" "135" ""    ""    "135" "135" ""    ""    ""   
#> 
#> $V5
#>  [1] "Sham procedure (N=135)" "Summary statistic"      "49; 49 (38-58)"        
#>  [4] ""                       "27 (20%)"               "108 (80%)"             
#>  [7] "21; 21 (19-24)"         ""                       "53 (39%)"              
#> [10] "55 (41%)"               "27 (20%)"              
#> 
#> attr(,"class")
#> [1] "baseline_tbl" "ss_tbl"       "data.frame"
```

## Editing a baseline table: `sstable.baseline.edit()`

To change the content of a baseline table before it is formatted, ask
for the raw matrix with `matrix.raw = TRUE`, edit its cells, and pass it
back to
[`sstable.baseline.edit()`](https://tranhung93.github.io/306/reference/sstable.baseline.edit.md)
with the same formula and data. It adds the header rows and the footer
(`footer` adds your own notes). Keep the first column as it is: the
function uses the variable names there to order the rows.

``` r

raw <- sstable.baseline(age + sex ~ Arm, data = bl, matrix.raw = TRUE)
raw
#>      [,1]  [,2]  [,3]             [,4]  [,5]            
#> [1,] "age" "136" "49; 49 (38-60)" "135" "49; 49 (38-58)"
#> [2,] "sex" "136" ""               "135" ""              
#> [3,] "- F" ""    "26 (19%)"       ""    "27 (20%)"      
#> [4,] "- M" ""    "110 (81%)"      ""    "108 (80%)"
raw[1, 3] <- paste0(raw[1, 3], "*")   # flag the age summary of the first arm
edited <- sstable.baseline.edit(raw, age + sex ~ Arm, data = bl,
                                footer = "* Illustrative flag added by hand.")
ss_flextable(edited)
```

|  | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  |
|----|----|----|----|----|
| Characteristic | n | Summary statistic | n | Summary statistic |
| age | 136 | 49; 49 (38-60)\* | 135 | 49; 49 (38-58) |
| sex | 136 |  | 135 |  |
| - F |  | 26 (19%) |  | 27 (20%) |
| - M |  | 110 (81%) |  | 108 (80%) |
| N is number of all patients, n is number of patients with non-missing value. |  |  |  |  |
| Summary statistic is absolute count (%) for categorical variable(s) and mean, median (Q1-Q3) for numeric variable(s). |  |  |  |  |
| \* Illustrative flag added by hand. |  |  |  |  |

To rename rows, set a `label` attribute on the variables before calling
[`sstable.baseline()`](https://tranhung93.github.io/306/reference/sstable.baseline.md)
instead, as shown in
[`vignette("C306_vignette_v6", package = "C306")`](https://tranhung93.github.io/306/articles/C306_vignette_v6.md).

## Building a table from scratch

Any character matrix can be rendered in the sstable style once its rows
are marked as header, section (a row-group title) or body rows. The
functions
[`ss_header()`](https://tranhung93.github.io/306/reference/ss_header.md),
[`ss_section()`](https://tranhung93.github.io/306/reference/ss_section.md)
and [`ss_body()`](https://tranhung93.github.io/306/reference/ss_body.md)
do this one kind at a time:

``` r

m <- rbind(c("", "Sham procedure", "Intrathecal treatment"),
           c("Age, years", "50", "48"),
           c("Sex", "", ""),
           c("- Female", "30 (22%)", "29 (21%)"),
           c("- Male", "105 (78%)", "107 (79%)"))
m <- ss_header(m, 1)
m <- ss_body(m, c(2, 4, 5))
m <- ss_section(m, 3)
rownames(m)
#> [1] "header.1"  "body.1"    "section.1" "body.2"    "body.3"
ss_flextable(ss_format(m, .guess = FALSE))
```

|            | Sham procedure | Intrathecal treatment |
|------------|----------------|-----------------------|
| Age, years | 50             | 48                    |
| Sex        |                |                       |
| - Female   | 30 (22%)       | 29 (21%)              |
| - Male     | 105 (78%)      | 107 (79%)             |

[`ss_format()`](https://tranhung93.github.io/306/reference/ss_format.md)
does it in one step. Give the rows of each kind, or let it guess: header
rows come first, a section row has text only in its first column, and
the rest are body rows. `template` (`"baseline"`, `"survcomp"` or
`"ae"`, also set with
[`ss_template()`](https://tranhung93.github.io/306/reference/ss_template.md))
chooses the layout rules:

``` r

m2 <- rbind(c("", "Sham procedure", "", "Intrathecal treatment", ""),
            c("Characteristic", "n", "Summary", "n", "Summary"),
            c("Age, years", "135", "50 (40-60)", "136", "48 (41-55)"),
            c("Sex", "", "", "", ""),
            c("- Female", "", "30 (22%)", "", "29 (21%)"))
f <- ss_format(m2)
rownames(f)
#> [1] "header.1"  "header.2"  "body.1"    "section.1" "body.2"
ss_flextable(f, footer = "Median (Q1-Q3) or n (%). Illustrative numbers.")
```

|  | Sham procedure |  | Intrathecal treatment |  |
|----|----|----|----|----|
| Characteristic | n | Summary | n | Summary |
| Age, years | 135 | 50 (40-60) | 136 | 48 (41-55) |
| Sex |  |  |  |  |
| - Female |  | 30 (22%) |  | 29 (21%) |
| Median (Q1-Q3) or n (%). Illustrative numbers. |  |  |  |  |

Tables made this way can be stacked with tables made by the package
functions and with each other; see
[`as_sstable()`](https://tranhung93.github.io/306/reference/as_sstable.md)
in
[`vignette("regression", package = "C306")`](https://tranhung93.github.io/306/articles/regression.md)
for assembling a table from header and body parts.
