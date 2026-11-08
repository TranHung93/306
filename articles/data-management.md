# Data management tools

This vignette covers the helpers for setting up a study, importing and
checking data, and recoding and summarising variables. They follow the
steps of the pipeline described in
[`vignette("data_analysis_pipeline", package = "C306")`](https://tranhung93.github.io/306/articles/data_analysis_pipeline.md).

| Step | Functions |
|----|----|
| Set up a project | [`createProject()`](https://tranhung93.github.io/306/reference/createProject.md) |
| Import a data dictionary | [`import.info()`](https://tranhung93.github.io/306/reference/import.info.md), [`convert.info()`](https://tranhung93.github.io/306/reference/convert.info.md) |
| Format and check data | [`myformat.data()`](https://tranhung93.github.io/306/reference/myformat.data.md), [`inspect.data()`](https://tranhung93.github.io/306/reference/inspect.data.md), [`getlabel()`](https://tranhung93.github.io/306/reference/getlabel.md) |
| Recode and reorder | [`simple_recode()`](https://tranhung93.github.io/306/reference/simple_recode.md), [`simple_relevel()`](https://tranhung93.github.io/306/reference/simple_relevel.md), [`simple_sort()`](https://tranhung93.github.io/306/reference/simple_sort.md), [`ref_lv()`](https://tranhung93.github.io/306/reference/ref_lv.md) |
| Derive and summarise | [`mutate_f()`](https://tranhung93.github.io/306/reference/mutate_f.md), [`summarise_f()`](https://tranhung93.github.io/306/reference/summarise_f.md), [`labAE()`](https://tranhung93.github.io/306/reference/labAE.md), [`contSummary()`](https://tranhung93.github.io/306/reference/contSummary.md), [`pct()`](https://tranhung93.github.io/306/reference/pct.md) |

``` r

library(C306)
```

The examples use `baseline_data` and `ae_data`, a **simulated** two-arm
trial bundled with the package.

## Set up a project: `createProject()`

[`createProject()`](https://tranhung93.github.io/306/reference/createProject.md)
copies a standard folder structure, with template scripts for importing,
cleaning, analysing and reporting, into a new folder and adds an RStudio
project file. It refuses to write into a folder that is not empty.

``` r

proj <- file.path(tempdir(), "myStudy")
createProject(proj)
#> Project myStudy was created in /tmp/RtmpaRP1hy
list.files(proj, recursive = TRUE)
#>  [1] "Analysis/01_import.R"                                                
#>  [2] "Analysis/02_clean.R"                                                 
#>  [3] "Analysis/03_createVAD.R"                                             
#>  [4] "Analysis/04_analysis.R"                                              
#>  [5] "Analysis/05_report.Rmd"                                              
#>  [6] "Analysis/figures/Readme.txt"                                         
#>  [7] "Analysis/functions/Readme.txt"                                       
#>  [8] "Analysis/interim_01_import.R"                                        
#>  [9] "Analysis/interim_02_clean.R"                                         
#> [10] "Analysis/interim_03_createVAD.R"                                     
#> [11] "Analysis/Readme.txt"                                                 
#> [12] "Analysis/tmp/Readme.txt"                                             
#> [13] "Data/Cleaned/Readme.txt"                                             
#> [14] "Data/Imported/Readme.txt"                                            
#> [15] "Data/Info/Readme.txt"                                                
#> [16] "Data/RandomizationList/Readme.txt"                                   
#> [17] "Data/Raw/Final/Readme.txt"                                           
#> [18] "Data/Raw/Interim/Readme.txt"                                         
#> [19] "Data/Raw/Readme.txt"                                                 
#> [20] "Data/Readme.txt"                                                     
#> [21] "Data/VAD/Readme.txt"                                                 
#> [22] "Documents/DSMB_documents/Readme.txt"                                 
#> [23] "Documents/Manuscript/Readme.txt"                                     
#> [24] "Documents/Protocol_CRF/Readme.txt"                                   
#> [25] "Documents/SAP/Readme.txt"                                            
#> [26] "InterimAnalysis/InterimAnalysis_01/Data/InterimData/Readme.txt"      
#> [27] "InterimAnalysis/InterimAnalysis_01/Data/RandomizationList/Readme.txt"
#> [28] "InterimAnalysis/InterimAnalysis_01/interimAnalysis_01.Rmd"           
#> [29] "InterimAnalysis/Readme.txt"                                          
#> [30] "myStudy.Rproj"
```

## Import a data dictionary

### `import.info()`

OUCRU data dictionaries are Excel files with a `CRFs` sheet, a `Grids`
sheet and one sheet per CRF.
[`import.info()`](https://tranhung93.github.io/306/reference/import.info.md)
reads the requested sheets and saves one data frame per sheet,
`<sheet>_info`, in an `.RData` file. A grid is requested as
`<CRF>_<Grid>`. The package includes a small example dictionary:

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

### `convert.info()`

[`convert.info()`](https://tranhung93.github.io/306/reference/convert.info.md)
turns an OUCRU dictionary and its category list into the general
dictionary format used by
[`myformat.data()`](https://tranhung93.github.io/306/reference/myformat.data.md)
and
[`inspect.data()`](https://tranhung93.github.io/306/reference/inspect.data.md),
with columns `varname`, `label`, `type`, `unit`, `value`, `levels` and
`missing`:

``` r

oucru_info <- data.frame(
  Category = c(NA, "SEX"), Variable = c("AGE", "SEX"), Caption = c("Age", "Sex"),
  `Data type` = c("Integer", "RadioList"), Format = NA, check.names = FALSE
)
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

## Format and check data

### `myformat.data()`

[`myformat.data()`](https://tranhung93.github.io/306/reference/myformat.data.md)
applies a dictionary to raw data: it converts types, turns codes into
labelled factor levels, parses dates, sets missing-value codes to `NA`
and stores labels and units as attributes. Each row of the dictionary
describes one variable:

- `type`: `numeric`, `factor`, `character` or `datetime`
- `value`: the code-to-label map of a factor (`1='Male';2='Female'`),
  the date format of a datetime (`ymd`), or the allowed range of a
  number (`0;100`, used by
  [`inspect.data()`](https://tranhung93.github.io/306/reference/inspect.data.md))
- `levels`: the order of the factor levels
- `missing`: codes that mean missing, e.g. `-99`

Here we take a few columns of the simulated trial and introduce two
errors: an age of 150 and an ASA status of 4.

``` r

raw <- head(baseline_data[, c("usubjid", "age", "asa", "timetoadm")], 8)
raw$age[3] <- 150
raw$asa[5] <- 4
raw$timetoadm[6] <- -99

info <- data.frame(
  varname = c("usubjid", "age", "asa", "timetoadm"),
  label = c("Participant ID", "Age", "ASA physical status", "Time to admission"),
  type = c("character", "numeric", "factor", "numeric"),
  unit = c(NA, "years", NA, "days"),
  value = c(NA, "0;100", "1='ASA I';2='ASA II';3='ASA III'", "0;60"),
  levels = c(NA, NA, "'ASA I';'ASA II';'ASA III'", NA),
  missing = c(NA, NA, NA, "-99")
)

dat <- myformat.data(raw, info)
#> Warning: asa: value(s) not in the dictionary kept as extra level(s): 4.
str(dat)
#> 'data.frame':    8 obs. of  4 variables:
#>  $ usubjid  : chr  "SIM-001" "SIM-002" "SIM-003" "SIM-004" ...
#>  $ age      : num  63 43 150 18 53 51 77 37
#>   ..- attr(*, "label")= chr "Age"
#>   ..- attr(*, "unit")= chr "years"
#>   ..- attr(*, "scale")= num 1
#>   ..- attr(*, "center")= num 0
#>  $ asa      : Factor w/ 4 levels "ASA I","ASA II",..: 2 1 2 2 4 2 1 1
#>   ..- attr(*, "label")= chr "ASA physical status"
#>  $ timetoadm: num  11 3 5 4 21 NA 2 4
#>   ..- attr(*, "label")= chr "Time to admission"
#>   ..- attr(*, "unit")= chr "days"
#>   ..- attr(*, "scale")= num 1
#>   ..- attr(*, "center")= num 0
```

The warning flags the ASA code that is not in the dictionary; it is kept
as an extra level so that it can be reported.

### `inspect.data()`

[`inspect.data()`](https://tranhung93.github.io/306/reference/inspect.data.md)
checks formatted data against the dictionary and lists values out of
range, codes not in the dictionary and missing values. The list is
returned and also written to `<prefix>_error.csv` in `outdir`
(`plot = TRUE` also saves the distribution of each variable to a PDF).

``` r

inspect.data(dat, info, id = "usubjid", outdir = tempdir())
#>          usubjid index                       error
#> 1 "=""SIM-003"""     3     Out of range: age > 100
#> 2 "=""SIM-005"""     5       Out of range: asa = 4
#> 3 "=""SIM-006"""     6 Missing value for timetoadm
```

### `getlabel()`

[`getlabel()`](https://tranhung93.github.io/306/reference/getlabel.md)
returns the label of a variable, with its unit, from its attributes or
from a dictionary. With `fit = TRUE` it describes the variable as it
enters a model, using the `scale` attribute (e.g. “per 10 years”):

``` r

wt <- structure(c(60, 72), label = "Weight", unit = "kg", scale = 10)
getlabel(wt)
#> [1] "Weight [kg]"
getlabel(wt, fit = TRUE)
#> [1] "Weight [+10 kg]"

meta <- data.frame(varname = c("age", "sex"), label = c("Age", "Sex"),
                   unit = c("years", NA), scale = c(10, NA),
                   type = c("numeric", "factor"))
getlabel("age", meta = meta)
#> [1] "Age [years]"
getlabel(baseline_data[, c("age", "sex")], meta = meta)
#> [1] "Age [years]" "Sex"
```

## Recode and reorder

### `simple_recode()`

[`simple_recode()`](https://tranhung93.github.io/306/reference/simple_recode.md)
recodes values that match regular expressions; values that match no
pattern are kept. A pattern of `NA` recodes missing values.

``` r

simple_recode(c("yes", "Yes", "no", NA),
              map = list(Y = "^[Yy]es$", N = "^no$", Unknown = NA))
#> [1] "Y"       "Y"       "N"       "Unknown"
```

A factor stays a factor, and `as` converts the result. For a data frame,
give one map per variable:

``` r

recoded <- simple_recode(head(baseline_data[, c("sex", "vaso")]),
                         sex = list(Female = "^F$", Male = "^M$"),
                         vaso = list(Yes = "^Y$", No = "^N$"))
recoded
#>      sex vaso
#> 1 Female   No
#> 2   Male   No
#> 3   Male   No
#> 4 Female   No
#> 5   Male   No
#> 6 Female   No
```

### `simple_relevel()`

[`simple_relevel()`](https://tranhung93.github.io/306/reference/simple_relevel.md)
orders the levels of one variable to follow another factor. For example,
to list AE terms grouped by organ class in the order of the classes:

``` r

grp <- read.csv(system.file("extdata", "group_data.csv", package = "C306"))
grp$class <- factor(grp$class)
grp2 <- simple_relevel(grp, ctcaename, by = class)
head(levels(grp2$ctcaename))
#> [1] "Allergy"                  "Pruritus"                
#> [3] "Skin allergy"             "Arterial thromboembolism"
#> [5] "Atrial fibrillation"      "Atrial thrombosis"
```

For a vector, give the grouping factor and a `map` from each group to
its values:

``` r

simple_relevel(c("p", "q", "r"), by = factor(c("B", "A", "B"), levels = c("B", "A")),
               map = list(A = "q", B = c("p", "r")), value = "levels")
#> [1] "p" "r" "q"
```

### `simple_sort()`

[`simple_sort()`](https://tranhung93.github.io/306/reference/simple_sort.md)
sorts a vector in a user-defined order:

``` r

simple_sort(c("III", "I", "II", "I"), order = c("I", "II", "III"))
#> [1] "I"   "I"   "II"  "III"
```

### `ref_lv()`

[`ref_lv()`](https://tranhung93.github.io/306/reference/ref_lv.md) gets
the reference (first) level of a factor, and `ref_lv<-` sets it while
keeping the order of the other levels:

``` r

arm <- factor(baseline_data$Arm)
ref_lv(arm)
#> [1] "Intrathecal treatment"
ref_lv(arm) <- "Sham procedure"
levels(arm)
#> [1] "Sham procedure"        "Intrathecal treatment"
```

## Derive and summarise

### `mutate_f()` and `summarise_f()`

These work like
[`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)
and
[`dplyr::summarise()`](https://dplyr.tidyverse.org/reference/summarise.html)
but can create several columns in one expression, with
`c(...) := list(...)` in
[`mutate_f()`](https://tranhung93.github.io/306/reference/mutate_f.md)
and a named list in
[`summarise_f()`](https://tranhung93.github.io/306/reference/summarise_f.md).
They work on data frames, grouped tibbles and data.tables.

``` r

small <- head(baseline_data[, c("usubjid", "Arm", "maxhr", "minhr")], 6)
small %>%
  dplyr::group_by(Arm) %>%
  mutate_f(c("hr_range", "hr_mid") := list(maxhr - minhr, (maxhr + minhr) / 2))
#> # A tibble: 6 × 6
#> # Groups:   Arm [2]
#>   usubjid Arm                   maxhr minhr hr_range hr_mid
#>   <chr>   <chr>                 <int> <int>    <int>  <dbl>
#> 1 SIM-001 Intrathecal treatment   133    92       41  112. 
#> 2 SIM-002 Intrathecal treatment   135    64       71   99.5
#> 3 SIM-003 Sham procedure           84    84        0   84  
#> 4 SIM-004 Intrathecal treatment   106    84       22   95  
#> 5 SIM-005 Sham procedure           95    63       32   79  
#> 6 SIM-006 Sham procedure           82    79        3   80.5

baseline_data %>%
  dplyr::group_by(Arm) %>%
  summarise_f(list(n = length(age), mean_age = mean(age), max_sofa = max(sofa, na.rm = TRUE)))
#> # A tibble: 2 × 4
#> # Groups:   Arm [2]
#>   Arm                       n mean_age max_sofa
#>   <chr>                 <int>    <dbl>    <int>
#> 1 Intrathecal treatment   136     48.6        7
#> 2 Sham procedure          135     48.7        5
```

### `labAE()`

For laboratory adverse events graded at each visit,
[`labAE()`](https://tranhung93.github.io/306/reference/labAE.md) flags
the visits where a new event should be reported: the grade reaches
`gradecut` and is higher than the worst grade so far.

``` r

labAE(c(0, 1, 3, 3, 2, 4), gradecut = 3)
#> [1] No  No  Yes No  No  Yes
#> Levels: Yes No

visits <- data.frame(id = rep(c("SIM-001", "SIM-002"), each = 3),
                     grade = c(1, 3, 3, 3, 2, 4))
visits %>%
  dplyr::group_by(id) %>%
  dplyr::mutate(new_ae = labAE(grade, gradecut = 3))
#> # A tibble: 6 × 3
#> # Groups:   id [2]
#>   id      grade new_ae
#>   <chr>   <dbl> <fct> 
#> 1 SIM-001     1 No    
#> 2 SIM-001     3 Yes   
#> 3 SIM-001     3 No    
#> 4 SIM-002     3 Yes   
#> 5 SIM-002     2 No    
#> 6 SIM-002     4 Yes
```

### `contSummary()`

[`contSummary()`](https://tranhung93.github.io/306/reference/contSummary.md)
formats summary statistics of a numeric vector as text. The `statistics`
string is a template: the words `mean`, `sd`, `median`, `Q1`, `Q3`,
`min` and `max` (in any case) are replaced by their values and all other
text is kept. This is what
[`sstable.baseline()`](https://tranhung93.github.io/306/reference/sstable.baseline.md)
uses for continuous variables.

``` r

contSummary(baseline_data$bmi, "mean (sd)")
#> [1] "21.3 (3.7)"
contSummary(baseline_data$age, "median (Q1-Q3)", digits = 0)
#> [1] "49 (38-59)"
contSummary(baseline_data$icudays, "Median [IQR: Q1-Q3], range min-max", digits = 0)
#> [1] "17 [IQR: 11-23], range 3-58"
```

### `pct()`

[`pct()`](https://tranhung93.github.io/306/reference/pct.md) returns
proportions: the percentage of `TRUE` for a logical vector, one per
level for a factor, or one per interval for a number cut at `breaks`.

``` r

pct(baseline_data$vaso == "Y")
#> [1] 12.54613
pct(factor(baseline_data$ablettscore))
#>        I       II      III 
#> 38.00738 42.43542 19.55720
pct(baseline_data$age, method = "cont", breaks = c(0, 40, 60, 100))
#>   (0,40]  (40,60] (60,100] 
#> 30.99631 47.23247 21.77122
```
