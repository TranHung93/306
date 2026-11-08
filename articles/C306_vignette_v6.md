# Creating and Displaying a Baseline Table with sstable in C306 package

## Introduction

This vignette demonstrates how to create a baseline table for a dataset
using the `sstable.baseline` function and how to format the table using
the `flextable` package in R. The baseline table summarizes various
characteristics of the study population, often divided by a variable
like treatment arms. By following the provided steps, users can
efficiently generate and format their baseline tables for reporting and
analysis.

## Prerequisites

Before proceeding, ensure that we have the `C306` (note C306 come with
capital C), `flextable` and `dplyr` packages installed. If they are not
installed, we can install them using the following commands:

``` r

install.packages(c("flextable", "dplyr", "remotes"))
remotes::install_github("TranHung93/306")
```

## Basic table

Step-by-Step Guide  
**Step 1: Load the Required Libraries**  
First, load the necessary libraries, including flextable for creating
flexible tables and dplyr for data manipulation.

``` r

library(flextable)
library(dplyr)
library(C306) 
```

**Step 2: Read and Prepare the Data**  
In this example, we read the data from a file named baseline_data.csv
which is in the folder extdata of the C306 package. The full explanation
of the variables is shown in the index.

``` r

# Get the path to the extdata directory
extdata_path <- system.file("extdata", "baseline_data.csv", package = "C306")

# Load the data
baseline_data <- read.csv(extdata_path)
```

Ensure that the treatment arms are correctly labeled and set as factors.
Note that the table will present the higher-level group followed by the
lower-level group, ensuring that the treatment group is presented before
the placebo.

``` r

# Create a factor with custom levels
baseline_data$Arm <- factor(
  baseline_data$Arm, 
  levels = c("Sham procedure", "Intrathecal treatment"),
  labels = c("Sham procedure", "Intrathecal treatment"))
```

**Step 3: Create the Baseline Table**  
Use the sstable.baseline function to create the baseline table. The
formula argument specifies the variables to be included in the table,
with subgroups specified based on the variable following the ~. The Arm
variable indicates the treatment groups. Set the pooledGroup argument to
FALSE to avoid having another column that summarizes the variables after
pooling the treatment groups together, and set digits to 1 to format
numeric values with one decimal place. Remember to set flextable
argument to TRUE to ensure the output is a flextable-type table,
allowing us to use flextable functions to edit our table more
conveniently. If flextable argument is not specified, the package will
set it FALSE by default and the output will be a matrix. For example, we
would like to summarize the characteristics of age, sex, BMI, tetanus,
ICU days, outcome, time to admission, max temperature, respiratory rate,
FiO2, and SpO2 among treatment arm groups. The code would be as follows.

``` r

formula <- age + sex + bmi + tetanus + icudays + outcome + timetoadm +
            maxtemp + resp + fio2 + spo2 ~ Arm
baseline.sstable <- sstable.baseline(
  formula = formula,
  data = baseline_data,
  statistics = "Median (q1, q3)",
  pooledGroup = FALSE,
  flextable = TRUE,
  footer = "we can add any note here and it will appear at the bottom of the table",
  bg = "lightblue" #we can style our table with different color, if we do not specify this argument, it will be gray in color by default

) 
baseline.sstable 
```

| Characteristic | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  |
|----|----|----|----|----|
|  | n | Summary statistic | n | Summary statistic |
| age | 136 | 49 (38, 60) | 135 | 49 (38, 58) |
| sex | 136 |  | 135 |  |
| - F |  | 26 (19%) |  | 27 (20%) |
| - M |  | 110 (81%) |  | 108 (80%) |
| bmi | 136 | 20 (18, 23) | 135 | 21 (19, 24) |
| tetanus | 136 |  | 135 |  |
| - Y |  | 136 (100%) |  | 135 (100%) |
| icudays | 135 | 15 (11, 22) | 134 | 18 (12, 27) |
| outcome | 136 |  | 135 |  |
| - 2 |  | 18 (13%) |  | 28 (21%) |
| - 3 |  | 107 (79%) |  | 97 (72%) |
| - 4 |  | 11 (8%) |  | 10 (7%) |
| timetoadm | 136 | 4.0 (2.0, 6.0) | 135 | 4.0 (2.0, 6.0) |
| maxtemp | 136 | 38 (37, 38) | 135 | 38 (37, 38) |
| resp | 136 | 21 (19, 24) | 135 | 22 (19, 25) |
| fio2 | 136 | 21 (21, 30) | 135 | 21 (21, 25) |
| spo2 | 136 | 96 (94, 99) | 135 | 96 (94, 98) |
| N is number of all patients, n is number of patients with non-missing value. |  |  |  |  |
| Summary statistic is absolute count (%) for categorical variable(s) and Median (q1, q3) for numeric variable(s). |  |  |  |  |
| we can add any note here and it will appear at the bottom of the table |  |  |  |  |

**Step 4: Add Footnotes and Caption by functions in flextable**  
Enhance the table by adding footnotes and a caption for better
readability and understanding. The caption provides a brief description
of the table’s content.

``` r

baseline.sstable <- baseline.sstable %>%
  set_caption(caption = 'Baseline characteristics of study population grouped by Treatment Arm.') #set_caption is a function in 'flextable' package to customize your table. You can use any other functions too. As baseline.sstable has been formated in flextable format by argument flextable = TRUE.
```

**Step 5: Display the Table**  
Finally, display the formatted table using the print function.

``` r

baseline.sstable
```

| Characteristic | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  |
|----|----|----|----|----|
|  | n | Summary statistic | n | Summary statistic |
| age | 136 | 49 (38, 60) | 135 | 49 (38, 58) |
| sex | 136 |  | 135 |  |
| - F |  | 26 (19%) |  | 27 (20%) |
| - M |  | 110 (81%) |  | 108 (80%) |
| bmi | 136 | 20 (18, 23) | 135 | 21 (19, 24) |
| tetanus | 136 |  | 135 |  |
| - Y |  | 136 (100%) |  | 135 (100%) |
| icudays | 135 | 15 (11, 22) | 134 | 18 (12, 27) |
| outcome | 136 |  | 135 |  |
| - 2 |  | 18 (13%) |  | 28 (21%) |
| - 3 |  | 107 (79%) |  | 97 (72%) |
| - 4 |  | 11 (8%) |  | 10 (7%) |
| timetoadm | 136 | 4.0 (2.0, 6.0) | 135 | 4.0 (2.0, 6.0) |
| maxtemp | 136 | 38 (37, 38) | 135 | 38 (37, 38) |
| resp | 136 | 21 (19, 24) | 135 | 22 (19, 25) |
| fio2 | 136 | 21 (21, 30) | 135 | 21 (21, 25) |
| spo2 | 136 | 96 (94, 99) | 135 | 96 (94, 98) |
| N is number of all patients, n is number of patients with non-missing value. |  |  |  |  |
| Summary statistic is absolute count (%) for categorical variable(s) and Median (q1, q3) for numeric variable(s). |  |  |  |  |
| we can add any note here and it will appear at the bottom of the table |  |  |  |  |

Baseline characteristics of study population grouped by Treatment Arm.
{.table .cl-d8bad469 quarto-disable-processing="true"}

If we want to change the names appearing in the table to make them
easier to understand, we could label them in the raw data first. The
package will detect the label. If a label is not available, it will use
the name of the variable.

``` r

# a label is simply a "label" attribute (Hmisc::label() sets the same attribute)
baseline_data <- baseline_data %>%
  mutate(
    age = structure(age, label='Age'), #label to make capital letter
    sex = structure(sex, label='Sex'),
    bmi = structure(bmi, label='Body Mass Index'), #label to explain the variable
    tetanus = structure(tetanus, label='Tetanus Confirmation'),
    icudays = structure(icudays, label='Days in ICU'),
    outcome = structure(outcome, label='Outcome'),
    timetoadm = structure(timetoadm, label='Time to Admission'),
    maxtemp = structure(maxtemp, label='Max Temperature'),
    resp = structure(resp, label='Respiratory Rate'),
    fio2 = structure(fio2, label='FiO2'),
    spo2 = structure(spo2, label='SpO2'),
    pao2 = structure(pao2, label='PaO2'),
    wbc = structure(wbc, label='White Blood Cells'),
    sofa = structure(sofa, label='SOFA')
  )

baseline_data$sex <- factor(baseline_data$sex, levels = c( "M", "F"), labels = c( "Male", "Female"))

baseline.sstable <- sstable.baseline(
  formula = age + sex + bmi + tetanus + icudays + outcome + timetoadm +
            maxtemp + resp + fio2 + spo2 + pao2 + wbc + sofa ~ Arm,
  data = baseline_data,
  pooledGroup = FALSE,
  flextable = TRUE,
  footer = "we can add any note here and it will appear at the bottom of the table",
  bg = "lightblue") %>% set_caption(caption = 'Baseline characteristics of study population grouped by Treatment Arm.')

baseline.sstable
```

| Characteristic | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  |
|----|----|----|----|----|
|  | n | Summary statistic | n | Summary statistic |
| Age | 136 | 49; 49 (38-60) | 135 | 49; 49 (38-58) |
| sex | 136 |  | 135 |  |
| - Male |  | 110 (81%) |  | 108 (80%) |
| - Female |  | 26 (19%) |  | 27 (20%) |
| Body Mass Index | 136 | 21; 20 (18-23) | 135 | 21; 21 (19-24) |
| Tetanus Confirmation | 136 |  | 135 |  |
| - Y |  | 136 (100%) |  | 135 (100%) |
| Days in ICU | 135 | 18; 15 (11-22) | 134 | 20; 18 (12-27) |
| Outcome | 136 |  | 135 |  |
| - 2 |  | 18 (13%) |  | 28 (21%) |
| - 3 |  | 107 (79%) |  | 97 (72%) |
| - 4 |  | 11 (8%) |  | 10 (7%) |
| Time to Admission | 136 | 4.8; 4.0 (2.0-6.0) | 135 | 5.0; 4.0 (2.0-6.0) |
| Max Temperature | 136 | 38; 38 (37-38) | 135 | 38; 38 (37-38) |
| Respiratory Rate | 136 | 22; 21 (19-24) | 135 | 22; 22 (19-25) |
| FiO2 | 136 | 26; 21 (21-30) | 135 | 24; 21 (21-25) |
| SpO2 | 136 | 96; 96 (94-99) | 135 | 96; 96 (94-98) |
| PaO2 | 14 | 100; 99 (89-114) | 12 | 104; 98 (90-112) |
| White Blood Cells | 136 | 12; 11 (9-15) | 135 | 11; 10 (8-13) |
| SOFA | 136 | 1.0; 1.0 (0.0-2.0) | 134 | 1.3; 1.0 (0.0-2.0) |
| N is number of all patients, n is number of patients with non-missing value. |  |  |  |  |
| Summary statistic is absolute count (%) for categorical variable(s) and mean; median (Q1-Q3) for numeric variable(s). |  |  |  |  |
| we can add any note here and it will appear at the bottom of the table |  |  |  |  |

Baseline characteristics of study population grouped by Treatment Arm.
{.table .cl-d8bad469 quarto-disable-processing="true"}

If we are interested in the characteristics of the whole sample as well,
we can add a column for the whole sample by setting the argument
pooledGroup = TRUE. In addition, we can change the number of decimal
places to 2 by setting the argument digits = 2. We can show frequencies
of the categorical variables for each values with their total
frequencies (denominators) by adding argument fullfreq = TRUE. Let’s see
how the table looks.

``` r

baseline.sstable <- sstable.baseline(
  formula = age + sex + bmi + tetanus + icudays + outcome + timetoadm +
            maxtemp + resp + fio2 + spo2 ~ Arm,
  data = baseline_data,
  pooledGroup = TRUE, #column total is added
  flextable = TRUE,
  fullfreq = TRUE, # as you can see in the table above in in intrathecal group female was shown as 22, but in the table below female is being shown as 22/136.
  footer = "we can add any note here and it will appear at the bottom of the table",
  bg = "lightblue")

library(flextable)
baseline.sstable <- baseline.sstable %>%
  set_caption(caption = 'Baseline characteristics of study population grouped by Treatment Arm.')

baseline.sstable
```

| Characteristic | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  | Total (N=271) |  |
|----|----|----|----|----|----|----|
|  | n | Summary statistic | n | Summary statistic | n | Summary statistic |
| Age | 136 | 49; 49 (38-60) | 135 | 49; 49 (38-58) | 271 | 49; 49 (38-59) |
| sex | 136 |  | 135 |  | 271 |  |
| - Male |  | 110/136 (81%) |  | 108/135 (80%) |  | 218/271 (80%) |
| - Female |  | 26/136 (19%) |  | 27/135 (20%) |  | 53/271 (20%) |
| Body Mass Index | 136 | 21; 20 (18-23) | 135 | 21; 21 (19-24) | 271 | 21; 21 (19-23) |
| Tetanus Confirmation | 136 |  | 135 |  | 271 |  |
| - Y |  | 136/136 (100%) |  | 135/135 (100%) |  | 271/271 (100%) |
| Days in ICU | 135 | 18; 15 (11-22) | 134 | 20; 18 (12-27) | 269 | 19; 17 (11-23) |
| Outcome | 136 |  | 135 |  | 271 |  |
| - 2 |  | 18/136 (13%) |  | 28/135 (21%) |  | 46/271 (17%) |
| - 3 |  | 107/136 (79%) |  | 97/135 (72%) |  | 204/271 (75%) |
| - 4 |  | 11/136 (8%) |  | 10/135 (7%) |  | 21/271 (8%) |
| Time to Admission | 136 | 4.8; 4.0 (2.0-6.0) | 135 | 5.0; 4.0 (2.0-6.0) | 271 | 4.9; 4.0 (2.0-6.0) |
| Max Temperature | 136 | 38; 38 (37-38) | 135 | 38; 38 (37-38) | 271 | 38; 38 (37-38) |
| Respiratory Rate | 136 | 22; 21 (19-24) | 135 | 22; 22 (19-25) | 271 | 22; 22 (19-25) |
| FiO2 | 136 | 26; 21 (21-30) | 135 | 24; 21 (21-25) | 271 | 25; 21 (21-25) |
| SpO2 | 136 | 96; 96 (94-99) | 135 | 96; 96 (94-98) | 271 | 96; 96 (94-98) |
| N is number of all patients, n is number of patients with non-missing value. |  |  |  |  |  |  |
| Summary statistic is absolute count (%) for categorical variable(s) and mean; median (Q1-Q3) for numeric variable(s). |  |  |  |  |  |  |
| we can add any note here and it will appear at the bottom of the table |  |  |  |  |  |  |

Baseline characteristics of study population grouped by Treatment Arm.
{.table .cl-d8bad469 quarto-disable-processing="true"}

**Additional Tips**  
Customization: The flextable package offers various customization
options, such as adjusting column widths, changing text alignment, and
adding colors. Refer to the flextable documentation for more details.
Exporting: we can export the table to different formats (e.g., Word,
HTML, PDF) using flextable’s export functions, making it easier to
include the table in reports and presentations.

``` r

# Example: Export the table to a Word document
save_as_docx(baseline.sstable, path = "baseline_table.docx")
```

Now that we know how to create a basic baseline table, we can try to
create our own table with different variables in baseline_data for
practice. If we are interested in creating a table with different
subgroups, we can do that as well. As we can see below, we created a
table grouped by gender.

``` r

baseline.sstable <- sstable.baseline(
  formula = age + bmi + tetanus + icudays + timetoadm + incubationperiod 
          + maxtemp + resp + fio2 + spo2 + pao2 + wbc + sofa ~ sex,
  data = baseline_data,
  pooledGroup = FALSE,
  flextable = TRUE,
  footer = "table for gender") %>% 
  set_caption(caption = 'Baseline characteristics of study population grouped by Gender.')


baseline.sstable
```

| Characteristic | Female (N=53) |  | Male (N=218) |  |
|----|----|----|----|----|
|  | n | Summary statistic | n | Summary statistic |
| Age | 53 | 48; 48 (38-59) | 218 | 49; 50 (38-59) |
| Body Mass Index | 53 | 23; 22 (20-25) | 218 | 21; 21 (18-23) |
| Tetanus Confirmation | 53 |  | 218 |  |
| - Y |  | 53 (100%) |  | 218 (100%) |
| Days in ICU | 53 | 17; 14 (10-21) | 216 | 19; 17 (12-24) |
| Time to Admission | 53 | 5.8; 4.0 (3.0-6.0) | 218 | 4.7; 4.0 (2.0-6.0) |
| incubationperiod | 34 | 9.9; 9.0 (6.2-12.0) | 175 | 9.9; 9.0 (6.0-12.0) |
| Max Temperature | 53 | 38; 38 (37-38) | 218 | 38; 38 (37-38) |
| Respiratory Rate | 53 | 22; 22 (20-25) | 218 | 22; 21 (19-24) |
| FiO2 | 53 | 25; 21 (21-30) | 218 | 25; 21 (21-25) |
| SpO2 | 53 | 96; 96 (94-99) | 218 | 96; 96 (94-98) |
| PaO2 | 4 | 97; 92 (88-101) | 22 | 102; 102 (90-112) |
| White Blood Cells | 53 | 11; 11 (8-15) | 218 | 11; 11 (9-14) |
| SOFA | 53 | 1.1; 1.0 (0.0-1.0) | 217 | 1.2; 1.0 (0.0-2.0) |
| N is number of all patients, n is number of patients with non-missing value. |  |  |  |  |
| Summary statistic is absolute count (%) for categorical variable(s) and mean; median (Q1-Q3) for numeric variable(s). |  |  |  |  |
| table for gender |  |  |  |  |

Baseline characteristics of study population grouped by Gender. {.table
.cl-d8bad469 quarto-disable-processing="true"}

## Create the Baseline Table with Additional Options

### Argument Continuous to assign variable type

Please note that if we do not specify which variables are categorical
and which are numerical, the package will set them by default. Any
“continuous” or “count” variables with more than 5 unique values will be
set as numerical variables and will follow the summarizing method for
numerical variables, which will be discussed in more detail in the next
section. Any “continuous” or “count” variables with 5 or fewer unique
values, and “factor”, “character”, or “logical” variables, will be
treated as categorical variables and will thus follow the summarizing
method for categorical variables (ratio and percentage). If we wish to
make any changes in the way of summarizing for any specific variables,
we can do so by using the cont and cate arguments. Let’s take a look at
the table below for an example. The pain_score here is being presented
as a categorical variable in percentage form.

``` r

baseline.sstable2 <- sstable.baseline(
  formula = age + bmi + sex + pain_score  ~ Arm,
  data = baseline_data,
  pooledGroup = FALSE,
  flextable = TRUE,
  footer = "we can add any note here and it will appear at the bottom of the table",
  bg = "lightblue"
)

baseline.sstable2
```

| Characteristic | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  |
|----|----|----|----|----|
|  | n | Summary statistic | n | Summary statistic |
| Age | 136 | 49; 49 (38-60) | 135 | 49; 49 (38-58) |
| Body Mass Index | 136 | 21; 20 (18-23) | 135 | 21; 21 (19-24) |
| sex | 136 |  | 135 |  |
| - Male |  | 110 (81%) |  | 108 (80%) |
| - Female |  | 26 (19%) |  | 27 (20%) |
| pain_score | 136 |  | 135 |  |
| - 1 |  | 18 (13%) |  | 16 (12%) |
| - 2 |  | 44 (32%) |  | 50 (37%) |
| - 3 |  | 36 (26%) |  | 41 (30%) |
| - 4 |  | 26 (19%) |  | 14 (10%) |
| - 5 |  | 12 (9%) |  | 14 (10%) |
| N is number of all patients, n is number of patients with non-missing value. |  |  |  |  |
| Summary statistic is absolute count (%) for categorical variable(s) and mean; median (Q1-Q3) for numeric variable(s). |  |  |  |  |
| we can add any note here and it will appear at the bottom of the table |  |  |  |  |

If we wish to summarize it using methods for numeric variables, we have
to switch on the cont argument and specify that pain_score is
continuous.

``` r

baseline.sstable <- sstable.baseline(
  formula = bmi + age  + sex +  pain_score + aids ~ Arm,
  data = baseline_data,
  cont = c("Pain_score"), # assign your variables if they are continuous, put putting them here. 
 
  digits.numeric =  c("mean(x, na.rm = TRUE) > 10 ~ 2", "sd(x, na.rm = TRUE) < 5 ~ 5") ,
  digits.nonnumeric = c("length (unique(x)) > 10 ~ 2"),
  digits.name = c('x == x ~ 3'),
  pooledGroup = FALSE,
  flextable = TRUE,
  footer = "we can add any note here and it will appear at the bottom of the table",
  bg = "lightblue")

baseline.sstable
```

| Characteristic | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  |
|----|----|----|----|----|
|  | n | Summary statistic | n | Summary statistic |
| Body Mass Index | 136 | 21.109; 20.499 (18.488-23.256) | 135 | 21.422; 21.321 (19.136-23.689) |
| Age | 136 | 48.559; 49.000 (38.000-60.000) | 135 | 48.659; 49.000 (38.500-58.500) |
| sex | 136 |  | 135 |  |
| - Male |  | 110 (80.882%) |  | 108 (80.000%) |
| - Female |  | 26 (19.118%) |  | 27 (20.000%) |
| pain_score | 136 | 2.779; 3.000 (2.000-4.000) | 135 | 2.704; 3.000 (2.000-3.000) |
| aids | 135 |  | 135 |  |
| - N |  | 135 (100.000%) |  | 135 (100.000%) |
| N is number of all patients, n is number of patients with non-missing value. |  |  |  |  |
| Summary statistic is absolute count (%) for categorical variable(s) and mean; median (Q1-Q3) for numeric variable(s). |  |  |  |  |
| we can add any note here and it will appear at the bottom of the table |  |  |  |  |

On the other hand, if we have a variable with more than 5 different
values, such as a score of 6, it will be treated as a continuous
variable by default. To report it as a categorical variable instead, we
can use the ‘cate’ argument. Let’s create a new variable named
‘severity_scores’ that ranges from 1 to 7. ‘Severity_scores’ will be
treated as continuous by default, as shown below.

``` r

baseline_data$severity_scores <- sample(1:7, nrow(baseline_data), replace = TRUE)

baseline.sstable <- sstable.baseline(
  formula = age + sex + severity_scores  ~ Arm,
  data = baseline_data,
  pooledGroup = FALSE,
  flextable = TRUE,
  footer = "we can add any note here and it will appear at the bottom of the table",
  bg = "lightblue" )

baseline.sstable
```

| Characteristic | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  |
|----|----|----|----|----|
|  | n | Summary statistic | n | Summary statistic |
| Age | 136 | 49; 49 (38-60) | 135 | 49; 49 (38-58) |
| sex | 136 |  | 135 |  |
| - Male |  | 110 (81%) |  | 108 (80%) |
| - Female |  | 26 (19%) |  | 27 (20%) |
| severity_scores | 136 | 3.9; 4.0 (2.0-6.0) | 135 | 3.9; 4.0 (2.0-5.0) |
| N is number of all patients, n is number of patients with non-missing value. |  |  |  |  |
| Summary statistic is absolute count (%) for categorical variable(s) and mean; median (Q1-Q3) for numeric variable(s). |  |  |  |  |
| we can add any note here and it will appear at the bottom of the table |  |  |  |  |

To report severity_scores as categorical variable, we use cate argument.

``` r

baseline.sstable <- sstable.baseline(
  formula = age + sex + severity_scores  ~ Arm,
  data = baseline_data,
  cat = c("severity_scores"),
  pooledGroup = FALSE,
  flextable = TRUE,
  footer = "we can add any note here and it will appear at the bottom of the table",
  bg = "lightblue" )

baseline.sstable
```

| Characteristic | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  |
|----|----|----|----|----|
|  | n | Summary statistic | n | Summary statistic |
| Age | 136 | 49; 49 (38-60) | 135 | 49; 49 (38-58) |
| sex | 136 |  | 135 |  |
| - Male |  | 110 (81%) |  | 108 (80%) |
| - Female |  | 26 (19%) |  | 27 (20%) |
| severity_scores | 136 |  | 135 |  |
| - 1 |  | 22 (16%) |  | 20 (15%) |
| - 2 |  | 27 (20%) |  | 16 (12%) |
| - 3 |  | 12 (9%) |  | 23 (17%) |
| - 4 |  | 21 (15%) |  | 20 (15%) |
| - 5 |  | 11 (8%) |  | 24 (18%) |
| - 6 |  | 18 (13%) |  | 13 (10%) |
| - 7 |  | 25 (18%) |  | 19 (14%) |
| N is number of all patients, n is number of patients with non-missing value. |  |  |  |  |
| Summary statistic is absolute count (%) for categorical variable(s) and mean; median (Q1-Q3) for numeric variable(s). |  |  |  |  |
| we can add any note here and it will appear at the bottom of the table |  |  |  |  |

### Customize summarizing method for continuous variables

We have several options to summarize our numerical variables. These
include using the statistics argument with a customized string of
desired summaries. If this argument is omitted, the default summaries
“mean, median (Q1, Q3)” will be used.

If your string contains specific keywords, the package will
automatically detect and compute the corresponding statistics, replacing
the keyword with the calculated value. Any other symbols or letters will
remain unchanged. For instance, “mean” represents the mean, “median”
represents the median, “sd” stands for standard deviation, “q1” denotes
the first quartile, “q3” refers to the third quartile, “min” indicates
the minimum value, and “max” represents the maximum value.

The choice of which measures to use in summarizing the data should be
based on the variable’s characteristics. For further details, you can
refer to the descriptive statistics section of OUCRU’s course
“Introduction to Medical Statistics” or consult with an expert if
necessary.

**Note:** categorical variable will always be presented as ratio and
percentage. Below is an example of using mean, sd, median, min and max.

``` r

baseline.sstable <- sstable.baseline(
 formula = age  ~ Arm,
  data = baseline_data,
  cont = c("Pain_score"),
  statistics = "location mean with spread sd;\n or 50-percentile median plus range (min, max)", #here odd symbols are purposely written to show that the package can detect the format
  pooledGroup = FALSE,
  flextable = TRUE,
  footer = "we can add any note here and it will appear at the bottom of the table",
  bg = "lightblue")

baseline.sstable <- baseline.sstable %>%
  add_footer_lines(values = "Note: This table summarizes the baseline characteristics of the study population by treatment arm.") %>%
  set_caption(caption = "Baseline Characteristics by Treatment Arm")

baseline.sstable
```

[TABLE]

Baseline Characteristics by Treatment Arm {.table .cl-d8bad469
quarto-disable-processing="true"}

if we would like to present them into two line, we can use line break
code in the string.

``` r

baseline.sstable <- sstable.baseline(
 formula = age + sex ~ Arm,
  data = baseline_data,
  cont = c("Pain_score"),
  statistics = "mean (SD) \nmedian (min, max)", 
  pooledGroup = FALSE,
  flextable = TRUE,
  footer = "we can add any note here and it will appear at the bottom of the table",
  bg = "lightblue")

baseline.sstable <- baseline.sstable %>%
  add_footer_lines(values = "Note: This table summarizes the baseline characteristics of the study population by treatment arm.") %>%
  set_caption(caption = "Baseline Characteristics by Treatment Arm")

baseline.sstable
```

[TABLE]

Baseline Characteristics by Treatment Arm {.table .cl-d8bad469
quarto-disable-processing="true"}

In cases we need to display a complex table with different summarizing
methods for different variables, we could call flextable = FALSE to
obtain a matrix. Then we bind them together using rbind. See example
below:

``` r

baseline.sstable1 <- sstable.baseline(
  formula = age + sex + pain_score  ~ Arm,
  data = baseline_data,
  cont = c("Pain_score"),
  pooledGroup = FALSE,
  flextable = FALSE,
  footer = "we can add any note here and it will appear at the bottom of the table",
  bg = "lightblue" ,
  test= TRUE)

baseline.sstable2 <- sstable.baseline(
  formula = bmi  ~ Arm,
  data = baseline_data,
  cont = c("bmi"), 
  statistics = "Mean (sd)",
  pooledGroup = FALSE,
  flextable = FALSE,
  footer = "we can add any note here and it will appear at the bottom of the table",
  bg = "lightblue" ,
  test= TRUE)
baseline.sstable1
```

    ## $table
    ##          ──────────────────────────────────────────────────────────────
    ##            V1           V2    V3           V4    V5           V6       
    ##          ──────────────────────────────────────────────────────────────
    ##                               Intratheca         Sham         p value  
    ##                               l                  procedure             
    ##                               treatment          (N=135)               
    ##                               (N=136)                                  
    ##            Characteri   n     Summary      n     Summary               
    ##            stic               statistic          statistic             
    ##            Age          136   49; 49       135   49; 49       0.896    
    ##                               (38-60)            (38-58)               
    ##            sex          136                135                0.879    
    ##            - Male             110 (81%)          108 (80%)             
    ##            - Female           26 (19%)           27 (20%)              
    ##            pain_score   136   2.8; 3.0     135   2.7; 3.0     0.539    
    ##                               (2.0-4.0)          (2.0-3.0)             
    ##          ──────────────────────────────────────────────────────────────
    ## 
    ## Column names: V1, V2, V3, V4, V5, V6
    ## 
    ## $footer
    ## [1] "N is number of all patients, n is number of patients with non-missing value."                                                             
    ## [2] "Summary statistic is absolute count (%) for categorical variable(s) and mean; median (Q1-Q3) for numeric variable(s)."                    
    ## [3] "p-values were based on Fisher's exact test for categorical variable(s) and Kruskal-Wallis/Mann-Whitney U-test for continuous variable(s)."
    ## [4] "we can add any note here and it will appear at the bottom of the table"                                                                   
    ## 
    ## attr(,"class")
    ## [1] "ss_baseline" "ss_obj"

``` r

baseline.sstable2
```

    ## $table
    ##          ──────────────────────────────────────────────────────────────
    ##            V1           V2    V3           V4    V5           V6       
    ##          ──────────────────────────────────────────────────────────────
    ##                               Intratheca         Sham         p value  
    ##                               l                  procedure             
    ##                               treatment          (N=135)               
    ##                               (N=136)                                  
    ##            Characteri   n     Summary      n     Summary               
    ##            stic               statistic          statistic             
    ##            Body Mass    136   21 (4)       135   21 (3)       0.332    
    ##            Index                                                       
    ##          ──────────────────────────────────────────────────────────────
    ## 
    ## Column names: V1, V2, V3, V4, V5, V6
    ## 
    ## $footer
    ## [1] "N is number of all patients, n is number of patients with non-missing value."         
    ## [2] "Summary statistic is Mean (sd) for numeric variable(s)."                              
    ## [3] "p-values were based on Kruskal-Wallis/Mann-Whitney U-test for continuous variable(s)."
    ## [4] "we can add any note here and it will appear at the bottom of the table"               
    ## 
    ## attr(,"class")
    ## [1] "ss_baseline" "ss_obj"

Now, we bind them together and reformat the combined table to flextable
using ss_flextable function in C306 package.

``` r

combined.table <- rbind(baseline.sstable2 , baseline.sstable1, footer = NULL) 
baseline.sstable
```

[TABLE]

Baseline Characteristics by Treatment Arm {.table .cl-d8bad469
quarto-disable-processing="true"}

``` r

ss.combined.table <- ss_flextable(combined.table)
ss.combined.table
```

|  | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  | p value |
|----|----|----|----|----|----|
| Characteristic | n | Summary statistic | n | Summary statistic |  |
| Body Mass Index | 136 | 21 (4) | 135 | 21 (3) | 0.332 |
| Age | 136 | 49; 49 (38-60) | 135 | 49; 49 (38-58) | 0.896 |
| sex | 136 |  | 135 |  | 0.879 |
| - Male |  | 110 (81%) |  | 108 (80%) |  |
| - Female |  | 26 (19%) |  | 27 (20%) |  |
| pain_score | 136 | 2.8; 3.0 (2.0-4.0) | 135 | 2.7; 3.0 (2.0-3.0) | 0.539 |

We can add more detail footnotes using footnote function from flextable
package.

``` r

ss.combined.table <- ss.combined.table %>%
  footnote(
    i = c(1, 2), j = 3,
    value = as_paragraph(
      c("mean (SD)", "mean, median (Q1-Q3)")
    ),
    ref_symbols = c("a", "b"),
    part = "body"
  ) %>%
  footnote(
    i = c(1), j = 6,
    value = as_paragraph(
      "p-values were based on Fisher's exact test comparing n patient between study arms for each type of adverse event"
    ),
    ref_symbols = "c",
    part = "body"
  )

                      
ss.combined.table
```

|  | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  | p value |
|----|----|----|----|----|----|
| Characteristic | n | Summary statistic | n | Summary statistic |  |
| Body Mass Index | 136 | 21 (4)a | 135 | 21 (3) | 0.332c |
| Age | 136 | 49; 49 (38-60)b | 135 | 49; 49 (38-58) | 0.896 |
| sex | 136 |  | 135 |  | 0.879 |
| - Male |  | 110 (81%) |  | 108 (80%) |  |
| - Female |  | 26 (19%) |  | 27 (20%) |  |
| pain_score | 136 | 2.8; 3.0 (2.0-4.0) | 135 | 2.7; 3.0 (2.0-3.0) | 0.539 |
| amean (SD) |  |  |  |  |  |
| bmean, median (Q1-Q3) |  |  |  |  |  |
| cp-values were based on Fisher's exact test comparing n patient between study arms for each type of adverse event |  |  |  |  |  |

## Create adverse event table

Now, we will create a table for adverse events. We assume that adverse
event information is collected from the any_ae data frame and the
baseline information is from baseline_data.

``` r

# Get the path to the extdata directory
extdata_path <- system.file("extdata", "ae_data.csv", package = "C306")

# Load the data
any_ae <- read.csv(extdata_path)
```

The function we use to create the adverse event table is sstable.ae with
the following arguments: ae_data: Data that contains adverse event data.
(Example: any_ae). In this data set, there are: a variable named
“usubjid” which contains the patients’ id, a variable named “ctcaename”
which contains specific names of adverse events, a variable named
“ctcaegrade” which contains the grade of adverse events. fullid_data:
Data that contains treatment arm data of all participants (not just
those who had adverse events). (Example: baseline_data) id.var: A
character string specifying the name of the study ID variable (should
exist in both the adverse event data and the treatment arm data).
(Example: usubjid) aetype.var: A character string specifying the name of
the adverse event type variable (exists in the adverse event data).
(Example: ctcaename) grade.var: NULL or a character string specifying
the name of the adverse event grade variable (exists in the adverse
event data). (Example: original_ctcaegrade) arm.var: A character string
specifying the name of the treatment arm variable (exists in the
treatment arm data). (Example: Arm) test: a logical value specifies
whether a statistical test will be performed to compare between
treatment arms. test.anyae.only: a logical value specifies whether a
statistical test will be performed for all variable or only for any
adverse events. sort.by: Arrange the adverse event names in ascending
order of the total observed number of episodes with that adverse event,
number of patients with that adverse event or p-value (+ep, +pt, +p for
episodes, patients, p-value) and descending order of the number of
selected measures (-ep, -pt, -p for episodes, patients, p-value). Note:
the signs (-/+) must directly precede p, ep, and pt without any spaces.
We can add a test argument to sstable.ae, just like in sstable.baseline.

Note: Pearson’s chi-square test of independence (chisq) or Fisher’s test
is useddepending on the expected number under the null hypothesis
(Fisher if any \<1) Now, let’s create our adverse event table.

``` r

ae_table <- sstable.ae(
  ae_data = any_ae,
  fullid_data = baseline_data,
  id.var = "usubjid",
  aetype.var = "ctcaename", #the variable contains names of adverse events (Common Terminology Criteria for Adverse Event names)in any_ae data frame
  grade.var = "original_ctcaegrade",
  arm.var = "Arm",
  sort.by = ~ -ep -pt, # arrange in order of descending for episodes and patients.
  digits = 2,
  test = TRUE,#if we would like, to make a test to compare among the treatment arm group then specify this argument TRUE, otherwise choose FALSE
  pdigits = 3,
  pcutoff = 0.001,
  chisq.test = TRUE, #choose TRUE for chi-square test and FALSE for Fisher, note that Fisher will be used even if chisq be selected for those expected value <1
  footer = c("Example footnote for adverse event summary table."),
  flextable = TRUE,
  bg = "#F2EFEE"
)


ae_table
```

| Type of adverse event | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  | p value |
|----|----|----|----|----|----|
|  | n episode | n patient | n episode | n patient |  |
| Any selected adverse event | 312 | 91 (66.91%) | 222 | 81 (60.00%) | 0.237 |
| - Grade I | 78 | 51 (37.50%) | 61 | 39 (28.89%) |  |
| - Grade II | 51 | 33 (24.26%) | 45 | 33 (24.44%) |  |
| - Grade III | 36 | 26 (19.12%) | 21 | 19 (14.07%) |  |
| - Grade IV | 22 | 19 (13.97%) | 14 | 12 (8.89%) |  |
| - Grade N/A | 125 | 64 (47.06%) | 81 | 43 (31.85%) |  |
| Pleural abscess | 23 | 20 (14.71%) | 16 | 14 (10.37%) |  |
| Subcutaneous emphysema | 20 | 19 (13.97%) | 16 | 12 (8.89%) |  |
| Wound bleed | 20 | 15 (11.03%) | 15 | 14 (10.37%) |  |
| Spinal disc herniation | 24 | 20 (14.71%) | 9 | 8 (5.93%) |  |
| Recurrent tetanus | 16 | 14 (10.29%) | 15 | 14 (10.37%) |  |
| Pruritus | 15 | 12 (8.82%) | 7 | 6 (4.44%) |  |
| Postoperative hemorrhage | 11 | 10 (7.35%) | 8 | 8 (5.93%) |  |
| Hyperglycaemia | 7 | 5 (3.68%) | 9 | 8 (5.93%) |  |
| Aspiration pneumonia | 11 | 11 (8.09%) | 4 | 4 (2.96%) |  |
| Cellulitis | 11 | 8 (5.88%) | 3 | 3 (2.22%) |  |
| Nausea | 8 | 8 (5.88%) | 5 | 4 (2.96%) |  |
| Arterial thromboembolism | 7 | 6 (4.41%) | 4 | 4 (2.96%) |  |
| Hematuria | 6 | 5 (3.68%) | 5 | 4 (2.96%) |  |
| Pharyngitis | 5 | 5 (3.68%) | 5 | 5 (3.70%) |  |
| Voice alteration | 4 | 4 (2.94%) | 5 | 5 (3.70%) |  |
| Gastrointestinal disorder | 3 | 3 (2.21%) | 6 | 6 (4.44%) |  |
| Pneumothorax | 5 | 5 (3.68%) | 3 | 3 (2.22%) |  |
| Fever | 4 | 4 (2.94%) | 4 | 4 (2.96%) |  |
| Myalgia | 3 | 3 (2.21%) | 5 | 5 (3.70%) |  |
| Hyponatremia | 5 | 5 (3.68%) | 2 | 2 (1.48%) |  |
| Chronic venous insufficiency | 5 | 4 (2.94%) | 2 | 2 (1.48%) |  |
| Dysphagia | 4 | 4 (2.94%) | 3 | 3 (2.22%) |  |
| Arthralgia | 5 | 5 (3.68%) | 1 | 1 (0.74%) |  |
| Cerebral infarction | 5 | 5 (3.68%) | 1 | 1 (0.74%) |  |
| Insomnia | 4 | 4 (2.94%) | 2 | 2 (1.48%) |  |
| Atrial thrombosis | 3 | 3 (2.21%) | 3 | 3 (2.22%) |  |
| Neuralgia | 2 | 2 (1.47%) | 4 | 4 (2.96%) |  |
| Constipation | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Myocardial ischaemia | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Appendicitis | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Hypoalbuminemia | 3 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Upper gastrointestinal hemorrhage | 4 | 4 (2.94%) | 0 | 0 (0.00%) |  |
| Hypokalemia | 3 | 3 (2.21%) | 1 | 1 (0.74%) |  |
| Tracheal stenosis | 3 | 3 (2.21%) | 1 | 1 (0.74%) |  |
| Oral infection | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Platelet count decreased | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Cholangitis | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Tracheal hemorrhage | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Chills | 1 | 1 (0.74%) | 3 | 3 (2.22%) |  |
| Urinary retention | 0 | 0 (0.00%) | 4 | 4 (2.96%) |  |
| Necrotic wound | 3 | 3 (2.21%) | 0 | 0 (0.00%) |  |
| Heat stroke | 3 | 3 (2.21%) | 0 | 0 (0.00%) |  |
| Torticolis | 3 | 3 (2.21%) | 0 | 0 (0.00%) |  |
| Hypotension | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Rhabdomyolysis | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| arthralgia | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Pyloric stenosis | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Hypocalcemia | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Myocarditis | 1 | 1 (0.74%) | 2 | 2 (1.48%) |  |
| Viral infection | 1 | 1 (0.74%) | 2 | 2 (1.48%) |  |
| Blood stream infection | 1 | 1 (0.74%) | 2 | 2 (1.48%) |  |
| Anemia | 0 | 0 (0.00%) | 3 | 3 (2.22%) |  |
| Skin allergy | 2 | 2 (1.47%) | 0 | 0 (0.00%) |  |
| Dizziness | 1 | 1 (0.74%) | 1 | 1 (0.74%) |  |
| Wound infection | 1 | 1 (0.74%) | 1 | 1 (0.74%) |  |
| Hypomagnesemia | 1 | 1 (0.74%) | 1 | 1 (0.74%) |  |
| Failed extubation | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Deep vein thrombosis | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Back pain | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Allergy | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Cardiac arrest | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Phlebitis | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Sinusitis | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Gastritis | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Acute renal failure | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Cerebral hemorrhage | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Creatinine increase | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Nose bleed | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Sinus bradycardia | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| UTI | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Facial nerve disorder | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Bruising | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hospital acquired pneumonia | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hypernatremia | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hypertension | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Low weight, muscle wasting | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Upper respiratory infection | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hiccup | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Atrial fibrillation | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Otitis | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Pressure ulcer | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Conjunctivitis | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Ventilator associated pneumonia | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Adrenal insufficiency | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Hyperpyrexia | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Hemorrhoids | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Headache | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Arthritis | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| n episode: total number of events |  |  |  |  |  |
| n patient: number of patients with at least one event |  |  |  |  |  |
| p-values are based on chi-square test if expected value under null hypothesis \> 1 in each cell; otherwise Fisher's exact test is used |  |  |  |  |  |
| Example footnote for adverse event summary table. |  |  |  |  |  |

Let’s make a table to summarize the adverse events based on their
relatedness to the treatment and whether the adverse event is expected
to appear, represented by the posreluntrl and unexp variables. We can
rename the variables so they appear more readable in the table. If we
don’t relabel the variables in the function, it will use the label in
the data frame if any, and the variable name if no label is present. See
below:

``` r

ae_table <- sstable.ae(
  ae_data = any_ae,
  fullid_data = baseline_data,
  id.var = "usubjid",
   aetype.var = c("Relatedness to treatment" ='posrelunrel', "Unexpected AEs" =  'unexp'),#change to posrelunrel variable: variable that classifies whether adverse events are possible related to treatments, related to treatments or unrelated to treatments, unrel means unrelated, posrel means possibly related, and rel means related
  grade.var = NULL, #set null to disable the summary of grade
  arm.var = "Arm",
  sort.by = ~ -ep -pt, # arrange in order of descending for episodes and patients.
  digits = 2,
  test = TRUE,
  pdigits = 3,
  pcutoff = 0.001,
  footer = c("Example footnote for adverse event summary table."),
  flextable = TRUE,
  bg = "#F2EFEE"
)


ae_table
```

|  | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  | p value |
|----|----|----|----|----|----|
| Type of adverse event | n episode | n patient | n episode | n patient |  |
| Any selected adverse event | 312 | 91 (66.91%) | 222 | 81 (60.00%) | 0.237 |
| Relatedness to treatment | 312 | 91 (66.91%) | 222 | 81 (60.00%) |  |
| UNREL | 182 | 76 (55.88%) | 126 | 58 (42.96%) |  |
| POSREL | 89 | 51 (37.50%) | 53 | 34 (25.19%) |  |
| REL | 41 | 33 (24.26%) | 43 | 38 (28.15%) |  |
| Unexpected AEs | 311 | 91 (66.91%) | 222 | 81 (60.00%) |  |
| N | 277 | 88 (64.71%) | 202 | 79 (58.52%) |  |
| Y | 34 | 23 (16.91%) | 20 | 19 (14.07%) |  |
| (Missing) | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| n episode: total number of events |  |  |  |  |  |
| n patient: number of patients with at least one event |  |  |  |  |  |
| p-values are based on chi-square test if expected value under null hypothesis \> 1 in each cell; otherwise Fisher's exact test is used |  |  |  |  |  |
| Example footnote for adverse event summary table. |  |  |  |  |  |

Here is an example if you label variables in the data frame. In this
case, the unexp variable does not have a label, so the table will show
unexp as it is. We can show the p-value for all rows if we specify
test.anyae.only = FALSE.

``` r

# Define labels
labels <- c("Relatedness to treatment")

# Assign labels using structure
any_ae$posrelunrel <- structure(any_ae$posrelunrel, label = labels[1])


ae_table <- sstable.ae(
  ae_data = any_ae,
  fullid_data = baseline_data,
  id.var = "usubjid",
  aetype.var = c("posrelunrel", "unexp"), 
  grade.var = "original_ctcaegrade", 
  arm.var = "Arm",
  sort.by = ~ +p -ep -pt, # arrange in order of ascending for p_value and descending for episodes and patients.
  digits = 2,
  test = TRUE,
  test.anyae.only = FALSE, #show p value for all of the rows
  pdigits = 3,
  pcutoff = 0.001,
  chisq.test = TRUE,
  footer = c("Example footnote for adverse event summary table."),
  flextable = TRUE,
  bg = "#F2EFEE"
)

ae_table
```

|  | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  | p value |
|----|----|----|----|----|----|
| Type of adverse event | n episode | n patient | n episode | n patient |  |
| Any selected adverse event | 312 | 91 (66.91%) | 222 | 81 (60.00%) | 0.237 |
| - Grade I | 78 | 51 (37.50%) | 61 | 39 (28.89%) | 0.132 |
| - Grade II | 51 | 33 (24.26%) | 45 | 33 (24.44%) | 0.973 |
| - Grade III | 36 | 26 (19.12%) | 21 | 19 (14.07%) | 0.265 |
| - Grade IV | 22 | 19 (13.97%) | 14 | 12 (8.89%) | 0.189 |
| - Grade N/A | 125 | 64 (47.06%) | 81 | 43 (31.85%) | 0.0104 |
| Relatedness to treatment | 312 | 91 (66.91%) | 222 | 81 (60.00%) | 0.237 |
| POSREL | 89 | 51 (37.50%) | 53 | 34 (25.19%) | 0.0289 |
| UNREL | 182 | 76 (55.88%) | 126 | 58 (42.96%) | 0.0334 |
| REL | 41 | 33 (24.26%) | 43 | 38 (28.15%) | 0.467 |
| unexp | 311 | 91 (66.91%) | 222 | 81 (60.00%) | 0.237 |
| N | 277 | 88 (64.71%) | 202 | 79 (58.52%) | 0.295 |
| Y | 34 | 23 (16.91%) | 20 | 19 (14.07%) | 0.519 |
| (Missing) | 1 | 1 (0.74%) | 0 | 0 (0.00%) | 1 |
| n episode: total number of events |  |  |  |  |  |
| n patient: number of patients with at least one event |  |  |  |  |  |
| p-values are based on chi-square test if expected value under null hypothesis \> 1 in each cell; otherwise Fisher's exact test is used |  |  |  |  |  |
| Example footnote for adverse event summary table. |  |  |  |  |  |

We can also classify the adverse events into groups. Assume that the
information for classifying adverse events is in the classification data
frame.

``` r

# Get the path to the extdata directory
extdata_path <- system.file("extdata", "group_data.csv", package = "C306")
classification <- read.csv(extdata_path)
```

In the data frame named classification, there are two variables, namely
ctcaename and class. We can add the classification to the table by
specifying a reference data frame that contains the group name of each
adverse event using the argument group_data = classification, and
indicating the variable that contains the name of the classification
using the argument group.var = “class”.

``` r

ae_table <- sstable.ae(
  ae_data = any_ae,
  fullid_data = baseline_data,
  group_data = classification,
  id.var = "usubjid",
  aetype.var = c("ctcaename"), 
  grade.var = NULL,
  arm.var = "Arm",
  group.var = "class",
  sort.by = ~ +p -ep -pt,
  digits = 2,
  test = TRUE,
  pdigits = 3,
  pcutoff = 0.001,
  chisq.test = FALSE,
  # footer = c("Example footnote for adverse event summary table."),
  flextable = TRUE,
  bg = "#F2EFEE"
)


ae_table
```

| Type of adverse event | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  | p value |
|----|----|----|----|----|----|
|  | n episode | n patient | n episode | n patient |  |
| Any selected adverse event | 312 | 91 (66.91%) | 222 | 81 (60.00%) | 0.258 |
| Allergic |  |  |  |  |  |
| Pruritus | 15 | 12 (8.82%) | 7 | 6 (4.44%) |  |
| Skin allergy | 2 | 2 (1.47%) | 0 | 0 (0.00%) |  |
| Allergy | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Cardiovascular |  |  |  |  |  |
| Postoperative hemorrhage | 11 | 10 (7.35%) | 8 | 8 (5.93%) |  |
| Arterial thromboembolism | 7 | 6 (4.41%) | 4 | 4 (2.96%) |  |
| Chronic venous insufficiency | 5 | 4 (2.94%) | 2 | 2 (1.48%) |  |
| Atrial thrombosis | 3 | 3 (2.21%) | 3 | 3 (2.22%) |  |
| Myocardial ischaemia | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Hypotension | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Pyloric stenosis | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Myocarditis | 1 | 1 (0.74%) | 2 | 2 (1.48%) |  |
| Deep vein thrombosis | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Cardiac arrest | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Phlebitis | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Sinus bradycardia | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hypertension | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Atrial fibrillation | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Digestive |  |  |  |  |  |
| Wound bleed | 20 | 15 (11.03%) | 15 | 14 (10.37%) |  |
| Nausea | 8 | 8 (5.88%) | 5 | 4 (2.96%) |  |
| Gastrointestinal disorder | 3 | 3 (2.21%) | 6 | 6 (4.44%) |  |
| Dysphagia | 4 | 4 (2.94%) | 3 | 3 (2.22%) |  |
| Constipation | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Appendicitis | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Upper gastrointestinal hemorrhage | 4 | 4 (2.94%) | 0 | 0 (0.00%) |  |
| Cholangitis | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Gastritis | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hiccup | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hemorrhoids | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Endocrine |  |  |  |  |  |
| Adrenal insufficiency | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| General |  |  |  |  |  |
| Fever | 4 | 4 (2.94%) | 4 | 4 (2.96%) |  |
| Chills | 1 | 1 (0.74%) | 3 | 3 (2.22%) |  |
| Heat stroke | 3 | 3 (2.21%) | 0 | 0 (0.00%) |  |
| Low weight, muscle wasting | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hyperpyrexia | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Hematologic |  |  |  |  |  |
| Platelet count decreased | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Anemia | 0 | 0 (0.00%) | 3 | 3 (2.22%) |  |
| Bruising | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Infectious |  |  |  |  |  |
| Cellulitis | 11 | 8 (5.88%) | 3 | 3 (2.22%) |  |
| Oral infection | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Necrotic wound | 3 | 3 (2.21%) | 0 | 0 (0.00%) |  |
| Viral infection | 1 | 1 (0.74%) | 2 | 2 (1.48%) |  |
| Blood stream infection | 1 | 1 (0.74%) | 2 | 2 (1.48%) |  |
| Wound infection | 1 | 1 (0.74%) | 1 | 1 (0.74%) |  |
| UTI | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hospital acquired pneumonia | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Otitis | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Conjunctivitis | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Metabolic |  |  |  |  |  |
| Hyperglycaemia | 7 | 5 (3.68%) | 9 | 8 (5.93%) |  |
| Hyponatremia | 5 | 5 (3.68%) | 2 | 2 (1.48%) |  |
| Hypoalbuminemia | 3 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Hypokalemia | 3 | 3 (2.21%) | 1 | 1 (0.74%) |  |
| Hypocalcemia | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Hypomagnesemia | 1 | 1 (0.74%) | 1 | 1 (0.74%) |  |
| Creatinine increase | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hypernatremia | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Musculoskeletal |  |  |  |  |  |
| Spinal disc herniation | 24 | 20 (14.71%) | 9 | 8 (5.93%) |  |
| Myalgia | 3 | 3 (2.21%) | 5 | 5 (3.70%) |  |
| Arthralgia | 5 | 5 (3.68%) | 1 | 1 (0.74%) |  |
| Torticolis | 3 | 3 (2.21%) | 0 | 0 (0.00%) |  |
| Rhabdomyolysis | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| arthralgia | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Back pain | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Arthritis | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Neurological |  |  |  |  |  |
| Recurrent tetanus | 16 | 14 (10.29%) | 15 | 14 (10.37%) |  |
| Voice alteration | 4 | 4 (2.94%) | 5 | 5 (3.70%) |  |
| Cerebral infarction | 5 | 5 (3.68%) | 1 | 1 (0.74%) |  |
| Insomnia | 4 | 4 (2.94%) | 2 | 2 (1.48%) |  |
| Neuralgia | 2 | 2 (1.47%) | 4 | 4 (2.96%) |  |
| Dizziness | 1 | 1 (0.74%) | 1 | 1 (0.74%) |  |
| Cerebral hemorrhage | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Facial nerve disorder | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Headache | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Respiratory |  |  |  |  |  |
| Pleural abscess | 23 | 20 (14.71%) | 16 | 14 (10.37%) |  |
| Subcutaneous emphysema | 20 | 19 (13.97%) | 16 | 12 (8.89%) |  |
| Aspiration pneumonia | 11 | 11 (8.09%) | 4 | 4 (2.96%) |  |
| Pharyngitis | 5 | 5 (3.68%) | 5 | 5 (3.70%) |  |
| Pneumothorax | 5 | 5 (3.68%) | 3 | 3 (2.22%) |  |
| Tracheal stenosis | 3 | 3 (2.21%) | 1 | 1 (0.74%) |  |
| Tracheal hemorrhage | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Failed extubation | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Sinusitis | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Nose bleed | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Upper respiratory infection | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Ventilator associated pneumonia | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Skin |  |  |  |  |  |
| Pressure ulcer | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Urinary |  |  |  |  |  |
| Hematuria | 6 | 5 (3.68%) | 5 | 4 (2.96%) |  |
| Urinary retention | 0 | 0 (0.00%) | 4 | 4 (2.96%) |  |
| Acute renal failure | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| n episode: total number of events |  |  |  |  |  |
| n patient: number of patients with at least one event |  |  |  |  |  |
| p-values are based on Fisher's exact test |  |  |  |  |  |

If we are interested in ‘Respiratory’ and ‘Neurological’ adverse events,
we can prioritize these groups in the table by factoring them. See the
example below:

``` r

categories <- c("Respiratory" , "Neurological", "Hematologic", "Digestive", 
                "Endocrine", "Metabolic", "General", "Allergic", 
                "Cardiovascular", "Urinary", "Musculoskeletal", "Skin", 
                "Infectious")

classification$class <- factor(classification$class, levels = categories)

ae_table <- sstable.ae(
  ae_data = any_ae,
  fullid_data = baseline_data,
  group_data = classification,
  id.var = "usubjid",
  aetype.var = "ctcaename", 
  grade.var = "original_ctcaegrade",
  arm.var = "Arm",
  group.var = "class",
  sort.by = ~ +p -ep -pt,
  digits = 2,
  test = TRUE,
  pdigits = 3,
  pcutoff = 0.001,
  chisq.test = FALSE,
  footer = c("Example footnote for adverse event summary table."),
  flextable = TRUE,
  bg = "#F2EFEE"
)


ae_table
```

| Type of adverse event | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  | p value |
|----|----|----|----|----|----|
|  | n episode | n patient | n episode | n patient |  |
| Any selected adverse event | 312 | 91 (66.91%) | 222 | 81 (60.00%) | 0.258 |
| - Grade I | 78 | 51 (37.50%) | 61 | 39 (28.89%) |  |
| - Grade II | 51 | 33 (24.26%) | 45 | 33 (24.44%) |  |
| - Grade III | 36 | 26 (19.12%) | 21 | 19 (14.07%) |  |
| - Grade IV | 22 | 19 (13.97%) | 14 | 12 (8.89%) |  |
| - Grade N/A | 125 | 64 (47.06%) | 81 | 43 (31.85%) |  |
| Respiratory |  |  |  |  |  |
| Pleural abscess | 23 | 20 (14.71%) | 16 | 14 (10.37%) |  |
| Subcutaneous emphysema | 20 | 19 (13.97%) | 16 | 12 (8.89%) |  |
| Aspiration pneumonia | 11 | 11 (8.09%) | 4 | 4 (2.96%) |  |
| Pharyngitis | 5 | 5 (3.68%) | 5 | 5 (3.70%) |  |
| Pneumothorax | 5 | 5 (3.68%) | 3 | 3 (2.22%) |  |
| Tracheal stenosis | 3 | 3 (2.21%) | 1 | 1 (0.74%) |  |
| Tracheal hemorrhage | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Failed extubation | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Sinusitis | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Nose bleed | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Upper respiratory infection | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Ventilator associated pneumonia | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Neurological |  |  |  |  |  |
| Recurrent tetanus | 16 | 14 (10.29%) | 15 | 14 (10.37%) |  |
| Voice alteration | 4 | 4 (2.94%) | 5 | 5 (3.70%) |  |
| Cerebral infarction | 5 | 5 (3.68%) | 1 | 1 (0.74%) |  |
| Insomnia | 4 | 4 (2.94%) | 2 | 2 (1.48%) |  |
| Neuralgia | 2 | 2 (1.47%) | 4 | 4 (2.96%) |  |
| Dizziness | 1 | 1 (0.74%) | 1 | 1 (0.74%) |  |
| Cerebral hemorrhage | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Facial nerve disorder | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Headache | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Hematologic |  |  |  |  |  |
| Platelet count decreased | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Anemia | 0 | 0 (0.00%) | 3 | 3 (2.22%) |  |
| Bruising | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Digestive |  |  |  |  |  |
| Wound bleed | 20 | 15 (11.03%) | 15 | 14 (10.37%) |  |
| Nausea | 8 | 8 (5.88%) | 5 | 4 (2.96%) |  |
| Gastrointestinal disorder | 3 | 3 (2.21%) | 6 | 6 (4.44%) |  |
| Dysphagia | 4 | 4 (2.94%) | 3 | 3 (2.22%) |  |
| Constipation | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Appendicitis | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Upper gastrointestinal hemorrhage | 4 | 4 (2.94%) | 0 | 0 (0.00%) |  |
| Cholangitis | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Gastritis | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hiccup | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hemorrhoids | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Endocrine |  |  |  |  |  |
| Adrenal insufficiency | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Metabolic |  |  |  |  |  |
| Hyperglycaemia | 7 | 5 (3.68%) | 9 | 8 (5.93%) |  |
| Hyponatremia | 5 | 5 (3.68%) | 2 | 2 (1.48%) |  |
| Hypoalbuminemia | 3 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Hypokalemia | 3 | 3 (2.21%) | 1 | 1 (0.74%) |  |
| Hypocalcemia | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Hypomagnesemia | 1 | 1 (0.74%) | 1 | 1 (0.74%) |  |
| Creatinine increase | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hypernatremia | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| General |  |  |  |  |  |
| Fever | 4 | 4 (2.94%) | 4 | 4 (2.96%) |  |
| Chills | 1 | 1 (0.74%) | 3 | 3 (2.22%) |  |
| Heat stroke | 3 | 3 (2.21%) | 0 | 0 (0.00%) |  |
| Low weight, muscle wasting | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hyperpyrexia | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Allergic |  |  |  |  |  |
| Pruritus | 15 | 12 (8.82%) | 7 | 6 (4.44%) |  |
| Skin allergy | 2 | 2 (1.47%) | 0 | 0 (0.00%) |  |
| Allergy | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Cardiovascular |  |  |  |  |  |
| Postoperative hemorrhage | 11 | 10 (7.35%) | 8 | 8 (5.93%) |  |
| Arterial thromboembolism | 7 | 6 (4.41%) | 4 | 4 (2.96%) |  |
| Chronic venous insufficiency | 5 | 4 (2.94%) | 2 | 2 (1.48%) |  |
| Atrial thrombosis | 3 | 3 (2.21%) | 3 | 3 (2.22%) |  |
| Myocardial ischaemia | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Hypotension | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Pyloric stenosis | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Myocarditis | 1 | 1 (0.74%) | 2 | 2 (1.48%) |  |
| Deep vein thrombosis | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Cardiac arrest | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Phlebitis | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Sinus bradycardia | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hypertension | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Atrial fibrillation | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Urinary |  |  |  |  |  |
| Hematuria | 6 | 5 (3.68%) | 5 | 4 (2.96%) |  |
| Urinary retention | 0 | 0 (0.00%) | 4 | 4 (2.96%) |  |
| Acute renal failure | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Musculoskeletal |  |  |  |  |  |
| Spinal disc herniation | 24 | 20 (14.71%) | 9 | 8 (5.93%) |  |
| Myalgia | 3 | 3 (2.21%) | 5 | 5 (3.70%) |  |
| Arthralgia | 5 | 5 (3.68%) | 1 | 1 (0.74%) |  |
| Torticolis | 3 | 3 (2.21%) | 0 | 0 (0.00%) |  |
| Rhabdomyolysis | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| arthralgia | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Back pain | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Arthritis | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Skin |  |  |  |  |  |
| Pressure ulcer | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Infectious |  |  |  |  |  |
| Cellulitis | 11 | 8 (5.88%) | 3 | 3 (2.22%) |  |
| Oral infection | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Necrotic wound | 3 | 3 (2.21%) | 0 | 0 (0.00%) |  |
| Viral infection | 1 | 1 (0.74%) | 2 | 2 (1.48%) |  |
| Blood stream infection | 1 | 1 (0.74%) | 2 | 2 (1.48%) |  |
| Wound infection | 1 | 1 (0.74%) | 1 | 1 (0.74%) |  |
| UTI | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hospital acquired pneumonia | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Otitis | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Conjunctivitis | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| n episode: total number of events |  |  |  |  |  |
| n patient: number of patients with at least one event |  |  |  |  |  |
| p-values are based on Fisher's exact test |  |  |  |  |  |
| Example footnote for adverse event summary table. |  |  |  |  |  |

If we don’t have an adverse event dictionary but there is a group
variable in the any_ae data itself, you can still specify the group.var
argument and leave the group_data as NULL. The package will
automatically detect the group.var in the any_ae data.

``` r

#add column name class into any_ae by merging the data frame any_ae with classsification
any_ae <- merge(any_ae, classification, by = "ctcaename", all.x = TRUE)


#set argument group_data as NULL
ae_table <- sstable.ae(
  ae_data = any_ae,
  fullid_data = baseline_data,
  group_data = NULL, 
  id.var = "usubjid",
  aetype.var = c("ctcaename"), 
  grade.var = NULL,
  arm.var = "Arm",
  group.var = "class",
  sort.by = ~ +p -ep -pt,
  digits = 2,
  test = TRUE,
  pdigits = 3,
  pcutoff = 0.001,
  chisq.test = FALSE,
  footer = c("Example footnote for adverse event summary table."),
  flextable = TRUE,
  bg = "#F2EFEE"
)


ae_table
```

| Type of adverse event | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  | p value |
|----|----|----|----|----|----|
|  | n episode | n patient | n episode | n patient |  |
| Any selected adverse event | 312 | 91 (66.91%) | 222 | 81 (60.00%) | 0.258 |
| Respiratory |  |  |  |  |  |
| Pleural abscess | 23 | 20 (14.71%) | 16 | 14 (10.37%) |  |
| Subcutaneous emphysema | 20 | 19 (13.97%) | 16 | 12 (8.89%) |  |
| Aspiration pneumonia | 11 | 11 (8.09%) | 4 | 4 (2.96%) |  |
| Pharyngitis | 5 | 5 (3.68%) | 5 | 5 (3.70%) |  |
| Pneumothorax | 5 | 5 (3.68%) | 3 | 3 (2.22%) |  |
| Tracheal stenosis | 3 | 3 (2.21%) | 1 | 1 (0.74%) |  |
| Tracheal hemorrhage | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Failed extubation | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Nose bleed | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Sinusitis | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Upper respiratory infection | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Ventilator associated pneumonia | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Neurological |  |  |  |  |  |
| Recurrent tetanus | 16 | 14 (10.29%) | 15 | 14 (10.37%) |  |
| Voice alteration | 4 | 4 (2.94%) | 5 | 5 (3.70%) |  |
| Cerebral infarction | 5 | 5 (3.68%) | 1 | 1 (0.74%) |  |
| Insomnia | 4 | 4 (2.94%) | 2 | 2 (1.48%) |  |
| Neuralgia | 2 | 2 (1.47%) | 4 | 4 (2.96%) |  |
| Dizziness | 1 | 1 (0.74%) | 1 | 1 (0.74%) |  |
| Cerebral hemorrhage | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Facial nerve disorder | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Headache | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Hematologic |  |  |  |  |  |
| Platelet count decreased | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Anemia | 0 | 0 (0.00%) | 3 | 3 (2.22%) |  |
| Bruising | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Digestive |  |  |  |  |  |
| Wound bleed | 20 | 15 (11.03%) | 15 | 14 (10.37%) |  |
| Nausea | 8 | 8 (5.88%) | 5 | 4 (2.96%) |  |
| Gastrointestinal disorder | 3 | 3 (2.21%) | 6 | 6 (4.44%) |  |
| Dysphagia | 4 | 4 (2.94%) | 3 | 3 (2.22%) |  |
| Appendicitis | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Constipation | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Upper gastrointestinal hemorrhage | 4 | 4 (2.94%) | 0 | 0 (0.00%) |  |
| Cholangitis | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Gastritis | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hiccup | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hemorrhoids | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Endocrine |  |  |  |  |  |
| Adrenal insufficiency | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Metabolic |  |  |  |  |  |
| Hyperglycaemia | 7 | 5 (3.68%) | 9 | 8 (5.93%) |  |
| Hyponatremia | 5 | 5 (3.68%) | 2 | 2 (1.48%) |  |
| Hypoalbuminemia | 3 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Hypokalemia | 3 | 3 (2.21%) | 1 | 1 (0.74%) |  |
| Hypocalcemia | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Hypomagnesemia | 1 | 1 (0.74%) | 1 | 1 (0.74%) |  |
| Creatinine increase | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hypernatremia | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| General |  |  |  |  |  |
| Fever | 4 | 4 (2.94%) | 4 | 4 (2.96%) |  |
| Chills | 1 | 1 (0.74%) | 3 | 3 (2.22%) |  |
| Heat stroke | 3 | 3 (2.21%) | 0 | 0 (0.00%) |  |
| Low weight, muscle wasting | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hyperpyrexia | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Allergic |  |  |  |  |  |
| Pruritus | 15 | 12 (8.82%) | 7 | 6 (4.44%) |  |
| Skin allergy | 2 | 2 (1.47%) | 0 | 0 (0.00%) |  |
| Allergy | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Cardiovascular |  |  |  |  |  |
| Postoperative hemorrhage | 11 | 10 (7.35%) | 8 | 8 (5.93%) |  |
| Arterial thromboembolism | 7 | 6 (4.41%) | 4 | 4 (2.96%) |  |
| Chronic venous insufficiency | 5 | 4 (2.94%) | 2 | 2 (1.48%) |  |
| Atrial thrombosis | 3 | 3 (2.21%) | 3 | 3 (2.22%) |  |
| Myocardial ischaemia | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Hypotension | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Pyloric stenosis | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Myocarditis | 1 | 1 (0.74%) | 2 | 2 (1.48%) |  |
| Deep vein thrombosis | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Cardiac arrest | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hypertension | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Phlebitis | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Sinus bradycardia | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Atrial fibrillation | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Urinary |  |  |  |  |  |
| Hematuria | 6 | 5 (3.68%) | 5 | 4 (2.96%) |  |
| Urinary retention | 0 | 0 (0.00%) | 4 | 4 (2.96%) |  |
| Acute renal failure | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Musculoskeletal |  |  |  |  |  |
| Spinal disc herniation | 24 | 20 (14.71%) | 9 | 8 (5.93%) |  |
| Myalgia | 3 | 3 (2.21%) | 5 | 5 (3.70%) |  |
| Arthralgia | 5 | 5 (3.68%) | 1 | 1 (0.74%) |  |
| Torticolis | 3 | 3 (2.21%) | 0 | 0 (0.00%) |  |
| arthralgia | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Rhabdomyolysis | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Back pain | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Arthritis | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Skin |  |  |  |  |  |
| Pressure ulcer | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Infectious |  |  |  |  |  |
| Cellulitis | 11 | 8 (5.88%) | 3 | 3 (2.22%) |  |
| Oral infection | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Necrotic wound | 3 | 3 (2.21%) | 0 | 0 (0.00%) |  |
| Blood stream infection | 1 | 1 (0.74%) | 2 | 2 (1.48%) |  |
| Viral infection | 1 | 1 (0.74%) | 2 | 2 (1.48%) |  |
| Wound infection | 1 | 1 (0.74%) | 1 | 1 (0.74%) |  |
| Hospital acquired pneumonia | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| UTI | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Conjunctivitis | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Otitis | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| n episode: total number of events |  |  |  |  |  |
| n patient: number of patients with at least one event |  |  |  |  |  |
| p-values are based on Fisher's exact test |  |  |  |  |  |
| Example footnote for adverse event summary table. |  |  |  |  |  |

If an adverse event is misclassified into another group, resulting in
one adverse event being classified into two different groups, the
package will display a warning and list all the misclassified adverse
events along with their respective groups. See the example below on how
the error will be detected and displayed:

``` r

any_ae$class <- as.character(any_ae$class)
any_ae[4, "class"] <- "Accidental entry" #create a mistake in class
any_ae [12, "class"] <- "Hematologics"

ae_table <- sstable.ae(
  ae_data = any_ae,
  fullid_data = baseline_data,
  group_data = NULL, 
  id.var = "usubjid",
  aetype.var = c("ctcaename"), 
  grade.var = NULL,
  arm.var = "Arm",
  group.var = "class",
  sort.by = ~ +p -ep -pt,
  digits = 2,
  test = TRUE,
  pdigits = 3,
  pcutoff = 0.001,
  chisq.test = FALSE,
  footer = c("Example footnote for adverse event summary table."),
  flextable = TRUE,
  bg = "#F2EFEE"
)


ae_table
```

| Type of adverse event | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  | p value |
|----|----|----|----|----|----|
|  | n episode | n patient | n episode | n patient |  |
| Any selected adverse event | 312 | 91 (66.91%) | 222 | 81 (60.00%) | 0.258 |
| Accidental entry |  |  |  |  |  |
| Allergy | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Allergic |  |  |  |  |  |
| Pruritus | 15 | 12 (8.82%) | 7 | 6 (4.44%) |  |
| Skin allergy | 2 | 2 (1.47%) | 0 | 0 (0.00%) |  |
| Allergy | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Cardiovascular |  |  |  |  |  |
| Postoperative hemorrhage | 11 | 10 (7.35%) | 8 | 8 (5.93%) |  |
| Arterial thromboembolism | 7 | 6 (4.41%) | 4 | 4 (2.96%) |  |
| Chronic venous insufficiency | 5 | 4 (2.94%) | 2 | 2 (1.48%) |  |
| Atrial thrombosis | 3 | 3 (2.21%) | 3 | 3 (2.22%) |  |
| Myocardial ischaemia | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Hypotension | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Pyloric stenosis | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Myocarditis | 1 | 1 (0.74%) | 2 | 2 (1.48%) |  |
| Deep vein thrombosis | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Cardiac arrest | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hypertension | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Phlebitis | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Sinus bradycardia | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Atrial fibrillation | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Digestive |  |  |  |  |  |
| Wound bleed | 20 | 15 (11.03%) | 15 | 14 (10.37%) |  |
| Nausea | 8 | 8 (5.88%) | 5 | 4 (2.96%) |  |
| Gastrointestinal disorder | 3 | 3 (2.21%) | 6 | 6 (4.44%) |  |
| Dysphagia | 4 | 4 (2.94%) | 3 | 3 (2.22%) |  |
| Appendicitis | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Constipation | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Upper gastrointestinal hemorrhage | 4 | 4 (2.94%) | 0 | 0 (0.00%) |  |
| Cholangitis | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Gastritis | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hiccup | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hemorrhoids | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Endocrine |  |  |  |  |  |
| Adrenal insufficiency | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| General |  |  |  |  |  |
| Fever | 4 | 4 (2.94%) | 4 | 4 (2.96%) |  |
| Chills | 1 | 1 (0.74%) | 3 | 3 (2.22%) |  |
| Heat stroke | 3 | 3 (2.21%) | 0 | 0 (0.00%) |  |
| Low weight, muscle wasting | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hyperpyrexia | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Hematologic |  |  |  |  |  |
| Platelet count decreased | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Anemia | 0 | 0 (0.00%) | 3 | 3 (2.22%) |  |
| Bruising | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hematologics |  |  |  |  |  |
| Appendicitis | 3 | 3 (2.21%) | 2 | 2 (1.48%) |  |
| Infectious |  |  |  |  |  |
| Cellulitis | 11 | 8 (5.88%) | 3 | 3 (2.22%) |  |
| Oral infection | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Necrotic wound | 3 | 3 (2.21%) | 0 | 0 (0.00%) |  |
| Blood stream infection | 1 | 1 (0.74%) | 2 | 2 (1.48%) |  |
| Viral infection | 1 | 1 (0.74%) | 2 | 2 (1.48%) |  |
| Wound infection | 1 | 1 (0.74%) | 1 | 1 (0.74%) |  |
| Hospital acquired pneumonia | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| UTI | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Conjunctivitis | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Otitis | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Metabolic |  |  |  |  |  |
| Hyperglycaemia | 7 | 5 (3.68%) | 9 | 8 (5.93%) |  |
| Hyponatremia | 5 | 5 (3.68%) | 2 | 2 (1.48%) |  |
| Hypoalbuminemia | 3 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Hypokalemia | 3 | 3 (2.21%) | 1 | 1 (0.74%) |  |
| Hypocalcemia | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Hypomagnesemia | 1 | 1 (0.74%) | 1 | 1 (0.74%) |  |
| Creatinine increase | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Hypernatremia | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Musculoskeletal |  |  |  |  |  |
| Spinal disc herniation | 24 | 20 (14.71%) | 9 | 8 (5.93%) |  |
| Myalgia | 3 | 3 (2.21%) | 5 | 5 (3.70%) |  |
| Arthralgia | 5 | 5 (3.68%) | 1 | 1 (0.74%) |  |
| Torticolis | 3 | 3 (2.21%) | 0 | 0 (0.00%) |  |
| arthralgia | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Rhabdomyolysis | 2 | 2 (1.47%) | 1 | 1 (0.74%) |  |
| Back pain | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Arthritis | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Neurological |  |  |  |  |  |
| Recurrent tetanus | 16 | 14 (10.29%) | 15 | 14 (10.37%) |  |
| Voice alteration | 4 | 4 (2.94%) | 5 | 5 (3.70%) |  |
| Cerebral infarction | 5 | 5 (3.68%) | 1 | 1 (0.74%) |  |
| Insomnia | 4 | 4 (2.94%) | 2 | 2 (1.48%) |  |
| Neuralgia | 2 | 2 (1.47%) | 4 | 4 (2.96%) |  |
| Dizziness | 1 | 1 (0.74%) | 1 | 1 (0.74%) |  |
| Cerebral hemorrhage | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Facial nerve disorder | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Headache | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Respiratory |  |  |  |  |  |
| Pleural abscess | 23 | 20 (14.71%) | 16 | 14 (10.37%) |  |
| Subcutaneous emphysema | 20 | 19 (13.97%) | 16 | 12 (8.89%) |  |
| Aspiration pneumonia | 11 | 11 (8.09%) | 4 | 4 (2.96%) |  |
| Pharyngitis | 5 | 5 (3.68%) | 5 | 5 (3.70%) |  |
| Pneumothorax | 5 | 5 (3.68%) | 3 | 3 (2.22%) |  |
| Tracheal stenosis | 3 | 3 (2.21%) | 1 | 1 (0.74%) |  |
| Tracheal hemorrhage | 2 | 2 (1.47%) | 2 | 2 (1.48%) |  |
| Failed extubation | 0 | 0 (0.00%) | 2 | 2 (1.48%) |  |
| Nose bleed | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Sinusitis | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Upper respiratory infection | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| Ventilator associated pneumonia | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Skin |  |  |  |  |  |
| Pressure ulcer | 0 | 0 (0.00%) | 1 | 1 (0.74%) |  |
| Urinary |  |  |  |  |  |
| Hematuria | 6 | 5 (3.68%) | 5 | 4 (2.96%) |  |
| Urinary retention | 0 | 0 (0.00%) | 4 | 4 (2.96%) |  |
| Acute renal failure | 1 | 1 (0.74%) | 0 | 0 (0.00%) |  |
| n episode: total number of events |  |  |  |  |  |
| n patient: number of patients with at least one event |  |  |  |  |  |
| p-values are based on Fisher's exact test |  |  |  |  |  |
| Example footnote for adverse event summary table. |  |  |  |  |  |

**Conclusion**  
By following these steps, we can create a detailed and well-formatted
baseline table and ae table to summarize the characteristics and adverse
events of our study population, separately by subgroups of a variable
(E.g treatment arms). These tables provide a clear and concise overview
of the data, facilitating better understanding and interpretation of the
study results.

## Index

### Explanation of variables in baseline_data

**usubjid**: id of patient **age**: The number of years a person has
lived.  
**sex**: The biological classification of an individual as male or
female.  
**bmi**: Body Mass Index, a measure of body fat based on height and
weight.  
**source**: The origin or cause of an individual’s medical condition or
data.  
**tetanus**: A bacterial infection characterized by muscle spasms.  
**icudays**: The number of days a patient spends in the Intensive Care
Unit.  
**outcome**: The final status of a patient’s health after treatment.  
**hypertension**: A condition where blood pressure is consistently too
high.  
**myocardialinfart**: Myocardial infarction, commonly known as a heart
attack.  
**angina**: Chest pain due to reduced blood flow to the heart muscles.  
**perivascular**: Relating to the tissues surrounding a blood vessel.  
**chronicpul**: Chronic pulmonary disease, long-term lung conditions.  
**connectivetissue**: Diseases affecting the tissues that support organs
and other parts of the body.  
**mildliver**: Mild liver disease, a less severe form of liver
disease.  
**hemiplegia**: Paralysis of one side of the body.  
**diawithchronic**: Diabetes with chronic complications.  
**severeliver**: Severe liver disease, a critical form of liver
disease.  
**aids**: Acquired Immunodeficiency Syndrome, a chronic immune system
condition.  
**cardiacfailureiii**: Stage III cardiac failure, severe heart
failure.  
**cerebrovascular**: Relating to the blood vessels of the brain.  
**severeresp**: Severe respiratory disease.  
**pepticulcer**: A sore that develops on the lining of the stomach,
small intestine, or esophagus.  
**diabetes**: A group of diseases that result in too much sugar in the
blood.  
**severekidney**: Severe kidney disease.  
**malignancy**: The presence of cancerous cells that can spread to other
parts of the body.  
**tumour**: An abnormal growth of tissue.  
**dementia**: A group of conditions characterized by impairment of at
least two brain functions, such as memory loss and judgment.  
**renalfailure**: A condition in which the kidneys fail to adequately
filter waste products from the blood.  
**electivesurgery**: Non-emergency surgery that is scheduled in
advance.  
**emergencysurgery**: Urgent surgery that is performed immediately.  
**timetoadm**: Time to admission, the period between the onset of
symptoms and hospital admission.  
**incubationperiod**: The period between exposure to an infection and
the appearance of the first symptoms.  
**incuperiodonset**: Onset of symptoms during the incubation period.  
**wound**: An injury to living tissue caused by a cut, blow, or other
impact.  
**diffbreath**: Difficulty breathing.  
**ablettscore**: Ablett score, a scale used to measure the severity of a
clinical condition.  
**asa**: American Society of Anesthesiologists score, a classification
system for assessing the fitness of patients before surgery.  
**maxtemp**: Maximum temperature recorded.  
**resp**: Respiratory rate, the number of breaths taken per minute.  
**fio2**: Fraction of inspired oxygen, the percentage of oxygen in the
air mixture that is inhaled.  
**spo2**: Peripheral capillary oxygen saturation, an estimate of the
amount of oxygen in the blood.  
**pao2**: Partial pressure of oxygen in arterial blood.  
**ph**: A measure of acidity or alkalinity of the blood.  
**plt**: Platelet count, a measure of the number of platelets in the
blood.  
**wbc**: White blood cell count, a measure of the number of white blood
cells in the blood.  
**hct**: Hematocrit, the ratio of the volume of red blood cells to the
total volume of blood.  
**maxhr**: Maximum heart rate recorded.  
**minhr**: Minimum heart rate recorded.  
**maxsbp**: Maximum systolic blood pressure recorded.  
**worstdbp**: Worst diastolic blood pressure recorded.  
**worstsbp**: Worst systolic blood pressure recorded.  
**vaso**: Use of vasopressors, medications that constrict blood vessels
and raise blood pressure.  
**na**: Sodium level in the blood.  
**k**: Potassium level in the blood.  
**creat**: Creatinine level in the blood, an indicator of kidney
function.  
**apacheii**: Acute Physiology And Chronic Health Evaluation II, a
severity-of-disease classification system.  
**sofa**: Sequential Organ Failure Assessment, a score to track a
person’s status during the stay in an ICU.  
**tss**: Total Severity Score, a measure of overall disease severity.  
**Arm**: Group assignment in a clinical trial or study.  

### Explanation of variables in any_ae

**usubjid**: id of patient  
**ctcaename**: name of the adverse event  
**ctcaegrade**: adverse event grade  
**original_ctcaegrade**: original adverse event grade  
**posrelunrel**: whether adverse event is related, possibly related or
unrelated to treatment  
**unexp**: whether adverse event is unexpected or not  

``` r

baseline.sstable1 <- sstable.baseline(
  formula = age + sex + pain_score  ~ Arm,
  data = baseline_data,
  cont = c("Pain_score"), # assign your variables if they are continuous, put putting them here.
  pooledGroup = FALSE,
  flextable = TRUE,
  footer = "we can add any note here and it will appear at the bottom of the table",
  bg = "lightblue" ,
  test= TRUE,
  matrix.raw = TRUE)

baseline.sstable2 <- sstable.baseline(
  formula = bmi  ~ Arm,
  data = baseline_data,
  cont = c("Pain_score"), # assign your variables if they are continuous, put putting them here.
  statistics = "Mean (sd)",
  pooledGroup = FALSE,
  flextable = TRUE,
  footer = "we can add any note here and it will appear at the bottom of the table",
  bg = "lightblue" ,
  test= TRUE,
  matrix.raw = TRUE)
baseline.sstable1 <- as.data.frame(baseline.sstable1)
baseline.sstable2 <- as.data.frame(baseline.sstable2)
formula = age + bmi + sex + pain_score ~ Arm
baseline.sstable <- union( baseline.sstable2 , baseline.sstable1)
baseline.sstable
```

    ##                V1  V2                 V3  V4                 V5    V6
    ## 1 Body Mass Index 136             21 (4) 135             21 (3) 0.332
    ## 2             Age 136     49; 49 (38-60) 135     49; 49 (38-58) 0.896
    ## 3             sex 136                    135                    0.879
    ## 4          - Male              110 (81%)              108 (80%)      
    ## 5        - Female               26 (19%)               27 (20%)      
    ## 6      pain_score 136 2.8; 3.0 (2.0-4.0) 135 2.7; 3.0 (2.0-3.0) 0.539

``` r

table <- sstable.baseline.edit(value=baseline.sstable, data = baseline_data, formula = formula, flextable = TRUE, test = TRUE)
table <- table %>%
  delete_part(part ="footer") 

table <- table %>%
  footnote(
    i = c(1, 2), j = 3,
    value = as_paragraph(
      c("mean (SD)", "mean, median (Q1-Q3)")
    ),
    ref_symbols = c("a", "b"),
    part = "body", inline = TRUE
  ) %>%
  footnote(
    i = c(1), j = 6,
    value = as_paragraph(
      "p-values were based on Fisher's exact test comparing n patient between study arms for each type of adverse event"
    ),
    ref_symbols = "c",
    part = "body"
  )
table
```

| Characteristic | Intrathecal treatment (N=136) |  | Sham procedure (N=135) |  | p value |
|----|----|----|----|----|----|
|  | n | Summary statistic | n | Summary statistic |  |
| Age | 136 | 49; 49 (38-60)a | 135 | 49; 49 (38-58) | 0.896c |
| Body Mass Index | 136 | 21 (4)b | 135 | 21 (3) | 0.332 |
| sex | 136 |  | 135 |  | 0.879 |
| - Male |  | 110 (81%) |  | 108 (80%) |  |
| - Female |  | 26 (19%) |  | 27 (20%) |  |
| pain_score | 136 | 2.8; 3.0 (2.0-4.0) | 135 | 2.7; 3.0 (2.0-3.0) | 0.539 |
| amean (SD); bmean, median (Q1-Q3); |  |  |  |  |  |
| cp-values were based on Fisher's exact test comparing n patient between study arms for each type of adverse event |  |  |  |  |  |
