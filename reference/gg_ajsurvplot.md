# Plot the Aalen-Johansen curve with ggplot for competing risks

Extend [ggsurvplot](https://rdrr.io/pkg/survminer/man/ggsurvplot.html)
functionality to plot competing risk curve

## Usage

``` r
gg_ajsurvplot(
  formula,
  data,
  weights,
  subset,
  na.action,
  etype,
  count,
  id,
  timefix,
  ...
)
```

## Arguments

- formula:

  A standard model formula, with survival on the left and covariates on
  the right

- data:

  an optional data frame, list or environment (or object coercible by
  as.data.frame to a data frame) containing the variables in the model

- weights, subset, na.action, etype, count, id, timefix:

  parameter passed to finegray model. See
  [`finegray`](https://rdrr.io/pkg/survival/man/finegray.html),

- ...:

  optional parameters passed to `ggsurvplot`.

## Value

A \`ggsurvplot\` object (see
[`ggsurvplot`](https://rdrr.io/pkg/survminer/man/ggsurvplot.html)). The
curves are 1 - the Aalen-Johansen cumulative incidence of \`etype\` in
each group; use \`fun = "event"\` to plot the cumulative incidence
itself.

## Examples

``` r
library(survival)
mg <- transform(mgus2, etime = ifelse(pstat == 0, futime, ptime),
                event = factor(ifelse(pstat == 0, 2 * death, 1), 0:2,
                               c("censor", "progression", "death")))
gg_ajsurvplot(Surv(etime, event) ~ sex, data = mg, etype = "progression", fun = "event")
```
