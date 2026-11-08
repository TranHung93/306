# Summarize results for a Cox survival model or restricted mean survival time with the treatment arm as the main covariate

A function to summarize results for a survival model with the treatment
arm (variable "arm") as the main covariate

## Usage

``` r
sstable.survcomp(
  model,
  data,
  add.risk = TRUE,
  time = Inf,
  reference.arm = c("B", "A"),
  compare.method = c("cox", "rmst", "cuminc"),
  compare.args = list(),
  add.prop.haz.test = TRUE,
  medsum = TRUE,
  p.compare = TRUE,
  digits = 2,
  pdigits = 3,
  pcutoff = 0.001,
  footer = NULL,
  flextable = TRUE,
  bg = "#F2EFEE"
)
```

## Arguments

- model:

  a formula which can be used to fit the survival model. This formula
  can include other covariates than arm BUT arm must be the first
  covariate in the model.

- data:

  a data frame to fit the survival model.

- add.risk:

  \[`TRUE`\] a logical value specifies whether the event probability
  ("absolute risk", in should be displayed: 1 - Kaplan-Meier, or the
  Aalen-Johansen cumulative incidence of the cause of interest for
  competing risks.

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

- add.prop.haz.test:

  \[`TRUE`\] (legacy, deprecated), please move this to compare.args

- medsum:

  \[`TRUE`\] a logical value, specifying whether median (IQR) of time to
  event should be described.

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

## Value

A flextable if \`flextable = TRUE\` (the default), otherwise a list of
class \`ss_survcomp\` with elements \`table\` (a character matrix) and
\`footer\`.

## Author

This function was originally written by Marcel Wolbers. Lam Phung Khanh
did some modification.

## Examples

``` r
library(survival)
lung2 <- transform(na.omit(lung[, c("time", "status", "sex")]),
                   arm = factor(sex, labels = c("Male", "Female")))

# Cox model: events/n (risk %), HR (95% CI) and p-value, median (IQR)
tab <- sstable.survcomp(Surv(time, status) ~ arm, data = lung2, flextable = FALSE)
tab$table
#>   ────────────────────────────────────────────────────────────────────────────
#>     Endpoint       Female         Male (n=138)   Comparison     Test for      
#>                    (n=90)                                       proportional  
#>                                                                 hazards       
#>                    events/n       events/n       HR (95%CI);    p-value       
#>                    (risk [%])     (risk [%])     p-value                      
#>     status         53/90          112/138        0.59 (0.42,    0.0906        
#>                    (91.68)        (96.43)        0.82);                       
#>                                                  p=0.00149                    
#>     time                                                                      
#>     - Median       426.00         270.00                                      
#>     (95%CI)        (348.00,       (212.00,                                    
#>                    550.00)        310.00)                                     
#>     - Lower IQR    226.00         144.00                                      
#>     (95%CI)        (186.00,       (107.00,                                    
#>                    340.00)        177.00)                                     
#>     - Upper IQR    687.00         457.00                                      
#>     (95%CI)        (550.00, NA)   (387.00,                                    
#>                                   574.00)                                     
#>   ────────────────────────────────────────────────────────────────────────────
#> 
#> Column names: V1, V2, V3, V4, V5

# restricted mean survival time difference at 1 year, as a flextable
sstable.survcomp(Surv(time, status) ~ arm, data = lung2, time = 365,
                 compare.method = "rmst")


.cl-d8bad469{}.cl-8a796ab5{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-5430bca3{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-6477613b{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-b8edab24{width:1.831in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 1.5pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f081bc35{width:2.154in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 1.5pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-82047934{width:2.863in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 1.5pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-76400b4a{width:1.831in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-ea33922f{width:2.154in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2e26b574{width:2.863in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-e60f6798{width:1.831in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-ba467ec3{width:2.154in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-ce6e6d53{width:2.863in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-846ddd75{width:1.831in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-638483c8{width:2.154in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c884d5c2{width:2.863in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-9765a40b{width:1.831in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-0490b8dd{width:2.154in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-5b5634ab{width:2.863in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}



Endpoint
```
