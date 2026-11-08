# Plot 2 Aalen-Johansen curves with ggplot for competing risks

Extend
[ggsurvfit](http://www.danieldsjoberg.com/ggsurvfit/reference/ggsurvfit.md)
functionality to plot competing risk curve, with main risk and competing
risk in one plot

## Usage

``` r
gg_ajsurvplot2(
  formula,
  data,
  weights,
  subset,
  na.action,
  main.event,
  competing.event,
  facet.by = ~strata,
  count,
  id,
  timefix,
  ...,
  .return_data = FALSE
)
```

## Arguments

- formula:

  A standard model formula, with survival on the left and covariates on
  the right

- data:

  an optional data frame, list or environment (or object coercible by
  as.data.frame to a data frame) containing the variables in the model

- weights, subset, na.action, count, id, timefix:

  parameter passed to finegray model. See
  [`finegray`](https://rdrr.io/pkg/survival/man/finegray.html),

- main.event, competing.event:

  main and competing event to plot

- facet.by:

  formula. default to all strata

- ...:

  currently unused.

- .return_data:

  \[FALSE\] if TRUE, get the data instead.

## Value

A ggplot object: the cumulative incidence of \`main.event\` rising from
the bottom and 1 - the cumulative incidence of \`competing.event\`
falling from the top (both Aalen-Johansen estimates for each group).
With \`.return_data = TRUE\`, the plotted data.

## Examples

``` r
library(survival)
mg <- transform(mgus2, etime = ifelse(pstat == 0, futime, ptime),
                event = factor(ifelse(pstat == 0, 2 * death, 1), 0:2,
                               c("censor", "progression", "death")))
gg_ajsurvplot2(Surv(etime, event) ~ sex, data = mg,
               main.event = "progression", competing.event = "death")
```
