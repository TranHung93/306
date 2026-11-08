# Summarize results for a survival model by treatment arm and subgroup

A function to summarize results for a survival model by treatment arm
(variable "arm") and subgroup.

## Usage

``` r
sstable.survcomp.subgroup(
  base.model,
  subgroup.model,
  overall.model,
  data,
  time = Inf,
  reference.arm = c("B", "A"),
  compare.method = c("cox", "rmst", "cuminc"),
  compare.args = list(),
  p.compare = TRUE,
  digits = 2,
  pdigits = 3,
  pcutoff = 0.001,
  footer = NULL,
  flextable = TRUE,
  bg = "#F2EFEE",
  overall = TRUE,
  ...
)
```

## Arguments

- base.model:

  a formula from which sub-group specific estimates are extracted (!!
  arm must be the first covariate in the model).

- subgroup.model:

  a formula of the form "~subgrouping.variable1+subgrouping.variable2"
  (!! subgrouping.variable must be factors and there should be nothing
  on the left-hand side of the formula).

- overall.model:

  an optional one-sided formula for additional terms for overall
  population only

- data:

  a data frame to fit the survival model.

- time:

  \[`Inf`\] the truncation time, affecting the descriptive and the RMST
  model, set to `Inf` to perform analyses at maximum time available
  (minimax of the observed time across two arms in RMST model)

- reference.arm:

  \[`B`\] reference arm, default to the second arm ("B"), change to "A"
  for base on the first arm

- compare.method:

  \[`cox`\] a string, either "cox" for CoxPH model, "cuminc" for
  cumulative incidence, or "rmst" for restricted mean survival time.
  Note that if "cox" is specified and model is a mstate model, a
  Fine-Gray model is used. If CoxPH is preferred, used Surv(t, ev ==
  'event-of-interest') on the LHS.

- compare.args:

  a list of additional args for compare.methods,

  For compare.method = 'cox', it is \`add.prop.haz.test\` \[`TRUE`\]: a
  logical value specifies whether a test for proportional hazards should
  be added,, additional args are fed directly to \`survival::coxph\`.
  only when model is a mstate model, \`cause\`, default to whatever the
  first cause.

  For compare.method = 'cuminc', args are fed to
  [`cumincglm`](https://sachsmc.github.io/eventglm/reference/cumincglm.html)
  \`type\`: \[`diff`\] a string, "diff" for difference in cumulative
  incidence, "ratio' for ratio of cumulative incidence, other optional
  args include: model.censoring, formula.censoring, ipcw.method. See
  [`cumincglm`](https://sachsmc.github.io/eventglm/reference/cumincglm.html)
  for more details.

  For compare.method = 'rmst', args are fed to
  [`rmeanglm`](https://sachsmc.github.io/eventglm/reference/rmeanglm.html)
  , \`type\`: \[`diff`\] a string, "diff" for difference in RMST,
  "ratio' for ratio of RMST, "lost.diff" for difference in restricted
  mean time lost (RMTL, = -diff), and "lost.ratio" for ratio of RMTL
  other optional args include: model.censoring, formula.censoring,
  ipcw.method. See
  [`rmeanglm`](https://sachsmc.github.io/eventglm/reference/rmeanglm.html)
  for more details.

- p.compare:

  \[`TRUE`\] a logical value, specifying whether we should report
  p-value for the main comparison

- digits:

  \[`2`\] a number specifies number of significant digits for numeric
  statistics.

- pdigits:

  \[`3`\] a number specifies number of significant digits for p value.

- pcutoff:

  \[`0.001`\] a number specifies threshold value of p value to be
  displayed as "\< pcutoff".

- footer:

  a \[`NULL`\] vector of strings to be used as footnote of table.

- flextable:

  \[`TRUE`\] a logical value specifies whether output will be a
  flextable-type table.

- bg:

  \[`#F2EFEE`\] a character specifies color of the odd rows in the body
  of flextable-type table.

- overall:

  \[`TRUE`\] where to print overall model

- ...:

  arguments that are passed to sstable.survcomp

## Value

A flextable if \`flextable = TRUE\` (the default), otherwise a list of
class \`ss_survcomp\` with elements \`table\` (a character matrix) and
\`footer\`.

## Author

This function was originally written by Marcel Wolbers. Trinh Dong and
Lam Phung Khanh did some modification.

## Examples

``` r
library(survival)
lung2 <- transform(na.omit(lung[, c("time", "status", "sex", "ph.ecog")]),
                   arm = factor(sex, labels = c("Male", "Female")),
                   ecog = factor(ph.ecog))
lung2 <- droplevels(subset(lung2, ecog != "3"))

# HR by ECOG status, with a test for heterogeneity
tab <- sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ ecog, data = lung2,
                                 flextable = FALSE)
tab$table
#> ───────────────────────────────────────────────────────────────────────────────
#>   Subgroup     Female       Male         Comparison   Test for     Test for    
#>                (n=90)       (n=136)                   proportion   heterogene  
#>                                                       al hazards   ity         
#>                events/n     events/n     HR           p-value      p-value     
#>                (risk [%])   (risk [%])   (95%CI);                              
#>                                          p-value                               
#>   All          53/90        110/136      0.60         0.108                    
#>   patients     (91.68)      (96.38)      (0.43,                                
#>                                          0.83);                                
#>                                          p=0.00205                             
#>   ecog                                                             0.756       
#>   - 0          9/27         28/36        0.54         0.831                    
#>                (74.24)      (94.28)      (0.25,                                
#>                                          1.15);                                
#>                                          p=0.112                               
#>   - 1          28/42        54/71        0.53         0.226                    
#>                (93.59)      (94.82)      (0.33,                                
#>                                          0.85);                                
#>                                          p=0.0076                              
#>   - 2          16/21        28/29        0.70         0.0731                   
#>                (100.00)     (100.00)     (0.37,                                
#>                                          1.30);                                
#>                                          p=0.254                               
#> ───────────────────────────────────────────────────────────────────────────────
#> 
#> Column names: V1, V2, V3, V4, V5, V6
```
