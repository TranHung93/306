#' Plot the Aalen-Johansen curve with ggplot for competing risks
#' @description
#' Extend \link[survminer:ggsurvplot]{ggsurvplot} functionality to plot competing risk curve
#'
#' @param formula A standard model formula, with survival on the left and covariates on the right
#' @param data an optional data frame, list or environment (or object coercible by as.data.frame to a data frame) containing the variables in the model
#' @param weights,subset,na.action,etype,count,id,timefix parameter passed to finegray model. See \code{\link[survival:finegray]{finegray}},
#' @param ... optional parameters passed to \code{ggsurvplot}.
#' @return A `ggsurvplot` object (see \code{\link[survminer:ggsurvplot]{ggsurvplot}}). The curves
#'   are 1 - the Aalen-Johansen cumulative incidence of `etype` in each group; use
#'   `fun = "event"` to plot the cumulative incidence itself.
#' @examples
#' library(survival)
#' mg <- transform(mgus2, etime = ifelse(pstat == 0, futime, ptime),
#'                 event = factor(ifelse(pstat == 0, 2 * death, 1), 0:2,
#'                                c("censor", "progression", "death")))
#' gg_ajsurvplot(Surv(etime, event) ~ sex, data = mg, etype = "progression", fun = "event")
#' @export
gg_ajsurvplot <- function(formula, data, weights, subset, na.action, etype, count, id, timefix, ...){
  dot <- list(...)
  fgargs <- match.call()[-1]
  fgargs <- as.list(fgargs[setdiff(names(fgargs), names(dot))])
  # evaluate in the caller's environment (data may not be a global variable)
  fgargs <- lapply(fgargs, eval, envir = parent.frame())
  fgargs$formula <- ._aj_censoring_strata(fgargs$formula)
  fg <- do.call(survival::finegray, fgargs)
  fml <- force(update(formula, Surv(fgstart,fgstop,fgstatus)~.))
  sf <- eval(substitute(survival::survfit(fml, data = fg,  weights=fgwt), list(fml=fml)))
  survminer::ggsurvplot(
    sf,
    data=fg,
    ...
  )
}

# For descriptive curves, estimate the censoring distribution separately in each
# group plotted (strata of all right-hand-side variables): the Fine-Gray
# weighted Kaplan-Meier curve of a group then equals its Aalen-Johansen
# estimate. With pooled censoring weights (the finegray() default) the curves
# drift away from Aalen-Johansen when censoring differs between groups.
._aj_censoring_strata <- function(formula) {
  rhs <- all.vars(formula[[3]])
  if (!length(rhs)) return(formula)
  stats::update(formula, stats::as.formula(paste(". ~ . + strata(", paste(rhs, collapse = ", "), ")")))
}

#' ggsurvfit with strata saved
#' @description
#' Same as \link[ggsurvfit:ggsurvfit]{ggsurvfit} but with strata saved, so you can facet by covariables.
#'
#' @param x,type,linetype_aes,theme,... parameters passed directly \link[ggsurvfit:ggsurvfit]{ggsurvfit}.
#' @return A ggplot object. Each stratum variable is a column of the plot data, so the plot
#'   can be faceted with e.g. `ggplot2::facet_wrap(~ sex)`.
#' @examples
#' library(survival)
#' fit <- survfit(Surv(time, status) ~ sex + ph.ecog, data = subset(lung, ph.ecog < 3))
#' ggsurvfit2(fit) + ggplot2::facet_wrap(~ sex)
#' @export
ggsurvfit2 <- rlang::new_function(
  args = rlang::fn_fmls(ggsurvfit::ggsurvfit),
  body = {
    tt <- ggsurvfit::ggsurvfit |>
    rlang::fn_body() |>
    as.character() |>
    gsub('tidy_survfit', 'C306::tidy_survfit2', x=_)|>
    c('}') |> paste(collapse = '\n') |>
    rlang::parse_expr()
    environment(tt) <- asNamespace('ggsurvfit')
    tt
    }
)

environment(ggsurvfit2) <- asNamespace('ggsurvfit')

#' Untidy the tidy_survfit
#' @noRd
untidy_strata <- function(x, strata.col='strata') {
  if (!'strata' %in% names(x)) return(x)
  x2 <- x |>
    mutate(strata.split = strsplit(as.character(strata), ', ')) |>
    tidyr::unnest(cols=strata.split) |>
    mutate(
      strata.split = unlist(strata.split),
      strata.names = strsplit(strata.split, '=') %>% purrr::transpose() %>% `[[`(1) |> unlist(),
      strata.values = strsplit(strata.split, '=') %>% purrr::transpose() %>% `[[`(2)  |> unlist(),
      strata.split=NULL
    ) |>
    tidyr::pivot_wider(names_from = strata.names, values_from = strata.values)

  x2
}

#' Tidy survfit with strata save
#' @description
#' Same as \link[ggsurvfit:tidy_survfit]{tidy_survfit} but with strata saved.
#' @param x,times,type same as \link[ggsurvfit:tidy_survfit]{tidy_survfit}
#' @return A tibble as from \link[ggsurvfit:tidy_survfit]{tidy_survfit}, with one extra column
#'   per stratum variable (e.g. `sex`, `ph.ecog`).
#' @examples
#' library(survival)
#' fit <- survfit(Surv(time, status) ~ sex + ph.ecog, data = subset(lung, ph.ecog < 3))
#' head(tidy_survfit2(fit))
#' @export
tidy_survfit2 <- function(x, times=NULL, type='survival'){
  ggsurvfit::tidy_survfit(x, times=times, type) |>
    untidy_strata()
}

#' Plot 2 Aalen-Johansen curves with ggplot for competing risks
#' @description
#' Extend \link[ggsurvfit:ggsurvfit]{ggsurvfit} functionality to plot competing risk curve, with main risk and competing risk in one plot
#'
#' @param formula A standard model formula, with survival on the left and covariates on the right
#' @param data an optional data frame, list or environment (or object coercible by as.data.frame to a data frame) containing the variables in the model
#' @param weights,subset,na.action,count,id,timefix parameter passed to finegray model. See \code{\link[survival:finegray]{finegray}},
#' @param main.event,competing.event main and competing event to plot
#' @param facet.by formula. default to all strata
#' @param ... currently unused.
#' @param .return_data [FALSE] if TRUE, get the data instead.
#' @return A ggplot object: the cumulative incidence of `main.event` rising from the bottom and
#'   1 - the cumulative incidence of `competing.event` falling from the top (both Aalen-Johansen
#'   estimates for each group). With `.return_data = TRUE`, the plotted data.
#' @examples
#' library(survival)
#' mg <- transform(mgus2, etime = ifelse(pstat == 0, futime, ptime),
#'                 event = factor(ifelse(pstat == 0, 2 * death, 1), 0:2,
#'                                c("censor", "progression", "death")))
#' gg_ajsurvplot2(Surv(etime, event) ~ sex, data = mg,
#'                main.event = "progression", competing.event = "death")
#' @import ggplot2
#' @export
gg_ajsurvplot2 <- function(formula, data, weights, subset, na.action, main.event, competing.event, facet.by = ~strata, count, id, timefix, ..., .return_data=FALSE){
  dot <- list(...)
  fgargs <- match.call()[-1]
  fgargs$facet.by <- NULL
  fgargs$.return_data <- NULL
  fgargs <- as.list(fgargs[setdiff(names(fgargs), names(dot))])
  # evaluate in the caller's environment (data may not be a global variable)
  fgargs <- lapply(fgargs, eval, envir = parent.frame())
  fgargs$formula <- ._aj_censoring_strata(fgargs$formula)

  etypes <- with(fgargs, list(main.event, competing.event))
  fgargs.each <- lapply(etypes, function(etype) {
    new.arg <- fgargs
    new.arg$etype <- etype
    new.arg$main.event <- new.arg$competing.event <- NULL
    new.arg
  })

  # fg1 and fg2 are used inside eval(substitute()) below
  fg1 <- do.call(survival::finegray, fgargs.each[[1]]) # nolint: object_usage_linter.
  fg2 <- do.call(survival::finegray, fgargs.each[[2]]) # nolint: object_usage_linter.
  fml <- force(update(formula, survival::Surv(fgstart,fgstop,fgstatus)~.))

  sf1 <- eval(substitute(survival::survfit(fml, data = fg1,  weights=fgwt), list(fml=fml)))
  sf2 <- eval(substitute(survival::survfit(fml, data = fg2,  weights=fgwt), list(fml=fml)))

  tidy1 <- tidy_survfit2(sf1, type='risk') |> mutate(Event = main.event)
  tidy2 <- tidy_survfit2(sf2, type='survival') |> mutate(Event = competing.event)

  dt <- rbind(tidy1, tidy2)
  if (.return_data) return(dt)

  # facet <- if (formula.tools::is.formula(facet.by)) if (length(formula.tools::lhs.vars(facet.by)))
    # facet_grid(facet.by) else facet_wrap(facet.by)
  facet <- if (!is.null(facet.by))
    if (length(formula.tools::lhs.vars(facet.by))) facet_grid(facet.by) else facet_wrap(facet.by)

  if (is.null(facet.by))
    return(
      ggplot(dt,aes(x=time, y=estimate, ymin=conf.low, ymax=conf.high, fill=Event, color=strata)) +
        geom_step(linewidth=1) +
        ggsurvfit::theme_ggsurvfit_default()
    )
  facet.vars <- formula.tools::get.vars(facet.by)
  for (v in facet.vars) dt$strata <- gsub(
    paste0('(,\\s)?',v,'=.*(,\\s|$)'), '', dt$strata, perl=TRUE)
  plt <- if (all(dt$strata == ''))
   ggplot(dt,aes(x=time, y=estimate, ymin=conf.low, ymax=conf.high, group=Event))
  else
    ggplot(dt,aes(x=time, y=estimate, ymin=conf.low, ymax=conf.high, fill=Event, color=strata))
  plt +
    geom_step(linewidth=1) +
    ggsurvfit::theme_ggsurvfit_default() + facet

}
