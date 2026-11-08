# Create an adverse event summary table

A function to create a simple adverse event summary table.

## Usage

``` r
sstable.ae(
  ae_data,
  fullid_data,
  group_data = NULL,
  id.var,
  aetype.var,
  grade.var = NULL,
  group.var = NULL,
  group.var.priority = NULL,
  arm.var,
  sort.by,
  digits = 0,
  fullfreq = FALSE,
  test = TRUE,
  test.anyae.only = TRUE,
  pdigits = 3,
  pcutoff = 0.001,
  chisq.test = TRUE,
  correct = FALSE,
  simulate.p.value = FALSE,
  B = 2000,
  workspace = 1e+06,
  hybrid = FALSE,
  print.aetype.header = length(aetype.var) > 1 | any(length(names(aetype.var)) > 0) |
    any(isTRUE(nchar(names(aetype.var)) > 0)),
  na.text = "(Missing)",
  matrix.raw = FALSE,
  footer = NULL,
  flextable = TRUE,
  bg = "#F2EFEE"
)
```

## Arguments

- ae_data:

  a data frame contains adverse event data.

- fullid_data:

  a data frame contains treatment arm data of all participants (not just
  those had adverse event).

- group_data:

  a reference data frame contains the group name of each ae.

- id.var:

  a character specifies name of study id variable (exists in both
  adverse event data and treatment arm data).

- aetype.var:

  a character specifies name of adverse event type variable (exists in
  adverse event data).

- grade.var:

  NULL or character specifies name of adverse event grade variable
  (exists in adverse event data).

- group.var:

  a character specifies group (exists in adverse event data if
  group_data = NULL or group_data otherwise).

- group.var.priority:

  a vector that specifies which groups will be appear first in the
  table.

- arm.var:

  a character specifies name of treatment arm variable (exists in
  treatment arm data).

- sort.by:

  An unquoted formula of sorting options.

  Available options are \`ep\`, \`pt\`, \`p\`, or a combination of them
  (eg ep+pt-p); A minus sign indicates a descending order.

- digits:

  a number specifies number of significant digits for numeric
  statistics.

- fullfreq:

  a logical value specifies whether to show total frequency as a
  denominator

- test:

  a logical value specifies whether a statistical test will be performed
  to compare between treatment arms.

- test.anyae.only:

  a logical value specifies whether a statistical test will be performed
  for all variable or only for any adverse events.

  Be aware that even when chisq.test==TRUE, if expected values are \< 1,
  the later test will take over.

- pdigits:

  a number specifies number of significant digits for p value.

- pcutoff:

  a number specifies threshold value of p value to be displayed as "\<
  pcutoff".

- chisq.test:

  a logical value specifies whether Chi-squared test or Fisher's exact
  test will be used to compare between treatment arms.

  Be aware that even when chisq.test==TRUE, if expected values are \< 1,
  the later test will take over.

- correct:

  a parameter for chisq.test().

- simulate.p.value:

  a parameter for chisq.test() and fisher.test().

- B:

  a parameter for chisq.test() and fisher.test().

- workspace:

  a parameter for fisher.test().

- hybrid:

  a parameter for fisher.test().

- print.aetype.header:

  a logical value, whether to print the label of aetype.header.

- na.text:

  \[\`(Missing)\`\] in-placed text for missing AE

- matrix.raw:

  a logical values specifies whether output will be a draw dataframe.

- footer:

  a vector of strings to be used as footnote of table.

- flextable:

  a logical value specifies whether output will be a flextable-type
  table.

- bg:

  a character specifies color of the odd rows in the body of
  flextable-type table.

## Value

If \`flextable = TRUE\` (the default), a flextable. If \`matrix.raw =
TRUE\`, the summary matrix without header. Otherwise a list of class
\`ss_ae\` with elements \`table\` and \`footer\`.

## Examples

``` r
ae <- read.csv(system.file("extdata", "ae_data.csv", package = "C306"))
bl <- read.csv(system.file("extdata", "baseline_data.csv", package = "C306"))

# number of episodes and patients by arm, with grades
tab <- sstable.ae(ae_data = ae, fullid_data = bl, id.var = "usubjid",
                  aetype.var = "ctcaename", grade.var = "ctcaegrade", arm.var = "Arm",
                  flextable = FALSE)
head(tab$table, 10)
#>         [,1]                         [,2]        [,3]                    
#> header1 ""                           ""          "Sham procedure (N=135)"
#> header2 "Type of adverse event"      "n episode" "n patient"             
#>         "Any selected adverse event" "222"       "81 (60%)"              
#>         "- Grade I"                  "101"       "56 (41%)"              
#>         "- Grade II"                 "72"        "46 (34%)"              
#>         "- Grade III"                "29"        "25 (19%)"              
#>         "- Grade IV"                 "17"        "14 (10%)"              
#>         "- Grade N/A"                "3"         "3 (2%)"                
#>         "Hypotension"                "1"         "1 (1%)"                
#>         "Pleural abscess"            "16"        "14 (10%)"              
#>         [,4]        [,5]                            [,6]     
#> header1 ""          "Intrathecal treatment (N=136)" "p value"
#> header2 "n episode" "n patient"                     ""       
#>         "312"       "91 (67%)"                      "0.237"  
#>         "143"       "67 (49%)"                      ""       
#>         "96"        "53 (39%)"                      ""       
#>         "52"        "32 (24%)"                      ""       
#>         "18"        "16 (12%)"                      ""       
#>         "3"         "3 (2%)"                        ""       
#>         "2"         "2 (1%)"                        ""       
#>         "23"        "20 (15%)"                      ""       

# grouped by organ class, most frequent first, as a flextable
grp <- read.csv(system.file("extdata", "group_data.csv", package = "C306"))
sstable.ae(ae_data = ae, fullid_data = bl, group_data = grp, id.var = "usubjid",
           aetype.var = "ctcaename", group.var = "class", arm.var = "Arm",
           sort.by = ~ -pt)


.cl-d8bad469{}.cl-8a796ab5{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-5430bca3{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-6477613b{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-97cea159{width:2.979in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 1.5pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2feebd48{width:1.028in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 1.5pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-ff817994{width:0.987in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 1.5pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2c10a327{width:0.848in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 1.5pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-573242f0{width:2.979in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3b4d763c{width:1.028in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-8e20102b{width:0.987in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-9181d09d{width:0.848in;background-color:rgba(242, 239, 238, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-9d1fd723{width:2.979in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-db423b23{width:1.028in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-6c465b8b{width:0.987in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3db63b0b{width:0.848in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-f6752446{width:2.979in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-243b0a9f{width:1.028in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b387b3c0{width:0.987in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-426bd853{width:0.848in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-ab217bda{width:2.979in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c6f6b0a2{width:1.028in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-9d86672a{width:0.987in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-580db9f9{width:0.848in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}



Type of adverse event
```
