# create survival comparison table ----------------------------------------

#' Summarize results for a Cox survival model or restricted mean survival time with the treatment arm as the main covariate
#'
#' @description A function to summarize results for a survival model with the treatment arm (variable "arm") as the main covariate
#'
#' @param model a formula which can be used to fit the survival model. This formula can include other covariates than arm BUT arm must be the first covariate in the model.
#' @param data a data frame to fit the survival model.
#' @param add.risk [\code{TRUE}] a logical value specifies whether the event probability ("absolute risk", in %) at `time`
#'   should be displayed: 1 - Kaplan-Meier, or the Aalen-Johansen cumulative incidence of the cause of interest for
#'   competing risks.
#' @param time [\code{Inf}] the truncation time, affecting the descriptive and the RMST model, set to \code{Inf} to perform analyses at maximum time available
#' (minimax of the observed time across two arms in RMST model)
#' @param reference.arm [\code{B}] reference arm, default to the second arm ("B"), change to "A" for base on the first arm
#' @param compare.method [\code{cox}] a string, either "cox" for CoxPH model, "cuminc" for cumulative incidence, or "rmst" for restricted mean survival time.
#' Note that if "cox" is specified and model is a mstate model, a Fine-Gray model is used.
#' If CoxPH is preferred, used Surv(t, ev == 'event-of-interest') on the LHS.
#'
#' @param compare.args a list of additional args for compare.methods,
#'
#'  For compare.method = 'cox', it is
#'  `add.prop.haz.test` [\code{TRUE}]: a logical value specifies whether a test for proportional hazards should be added,, additional args are fed directly to `survival::coxph`.
#'  only when model is a mstate model, `cause`, default to whatever the first cause.
#'
#'  For compare.method = 'cuminc', args are fed to \code{\link[eventglm:cumincglm]{cumincglm}}
#'  `type`: [\code{diff}] a string, "diff" for difference in cumulative incidence, "ratio' for ratio of cumulative incidence,
#'  other optional args include: model.censoring, formula.censoring, ipcw.method. See \code{\link[eventglm:cumincglm]{cumincglm}} for more details.
#'
#'  For compare.method = 'rmst', args are fed to \code{\link[eventglm:rmeanglm]{rmeanglm}} ,
#'  `type`: [\code{diff}] a string, "diff" for difference in RMST, "ratio' for ratio of RMST, "lost.diff" for difference in restricted mean time lost (RMTL, = -diff), and "lost.ratio" for ratio of RMTL
#'  other optional args include: model.censoring, formula.censoring, ipcw.method. See \code{\link[eventglm:rmeanglm]{rmeanglm}} for more details.
#' @param add.prop.haz.test [\code{TRUE}] (legacy, deprecated), please move this to compare.args
#' @param medsum [\code{TRUE}] a logical value, specifying whether median (IQR) of time to event should be described.
#' @param p.compare [\code{TRUE}] a logical value, specifying whether we should report p-value for the main comparison
#' @param digits [\code{2}] a number specifies number of significant digits for numeric statistics.
#' @param pdigits [\code{3}] a number specifies number of significant digits for p value.
#' @param pcutoff [\code{0.001}] a number specifies threshold value of p value to be displayed as "< pcutoff".
#' @param footer a [\code{NULL}] vector of strings to be used as footnote of table.
#' @param flextable [\code{TRUE}] a logical value specifies whether output will be a flextable-type table.
#' @param bg [\code{#F2EFEE}] a character specifies color of the odd rows in the body of flextable-type table.
#' @return A flextable if `flextable = TRUE` (the default), otherwise a list of class
#'   `ss_survcomp` with elements `table` (a character matrix) and `footer`.
#' @examples
#' library(survival)
#' lung2 <- transform(na.omit(lung[, c("time", "status", "sex")]),
#'                    arm = factor(sex, labels = c("Male", "Female")))
#'
#' # Cox model: events/n (risk %), HR (95% CI) and p-value, median (IQR)
#' tab <- sstable.survcomp(Surv(time, status) ~ arm, data = lung2, flextable = FALSE)
#' tab$table
#'
#' # restricted mean survival time difference at 1 year, as a flextable
#' sstable.survcomp(Surv(time, status) ~ arm, data = lung2, time = 365,
#'                  compare.method = "rmst")
#'
#' # competing risks (progression vs death): Fine-Gray model for progression
#' mg <- transform(mgus2, etime = ifelse(pstat == 0, futime, ptime),
#'                 event = factor(ifelse(pstat == 0, 2 * death, 1), 0:2,
#'                                c("censor", "progression", "death")))
#' sstable.survcomp(Surv(etime, event) ~ sex, data = mg,
#'                  compare.args = list(cause = "progression"), flextable = FALSE)$table
#'
#' @author This function was originally written by Marcel Wolbers. Lam Phung Khanh did some modification.
#' @import survival
#' @export
sstable.survcomp <- function(
    model, data, add.risk = TRUE,
    time = Inf,
    reference.arm = c('B', 'A'),
    compare.method = c('cox', 'rmst', 'cuminc'),
    compare.args = list(),
    add.prop.haz.test = TRUE, medsum = TRUE,
    p.compare = TRUE,
    digits = 2, pdigits = 3, pcutoff = 0.001, footer = NULL, flextable = TRUE, bg = "#F2EFEE"){
  ## validate inputs
  check_formula(model, sides = "two")
  lhs.fun <- if (is.call(model[[2]])) deparse(model[[2]][[1]]) else ""
  if (!lhs.fun %in% c("Surv", "survival::Surv")) {
    c306_abort("The left-hand side of `model` must be a survival object, e.g. `Surv(time, status) ~ arm`.")
  }
  check_data_frame(data)
  check_columns(data, all.vars(model))
  for (flag in c("add.risk", "add.prop.haz.test", "medsum", "p.compare", "flextable")) {
    check_flag(get(flag), arg = flag)
  }
  check_number(time, min = 0, allow_inf = TRUE)
  if (time == 0) c306_abort("`time` must be greater than 0.")
  if (!is.list(compare.args)) c306_abort("`compare.args` must be a list.")
  check_number(digits, min = 0, whole = TRUE)
  check_number(pdigits, min = 1, whole = TRUE)
  check_number(pcutoff, min = 0, max = 1)
  check_character(footer, allow_null = TRUE)
  check_string(bg)

  # Initialise the table --------------------------
  ## strip the tibble class which causes issue - trinhdhk
  data <- as.data.frame(data)
  
  mf <- model.frame(update(model, .~1), data=data)
  NAs <- attr(mf, 'na.action') |> unname()
  
  if (length(NAs)){
    warning(sprintf('Missing values on observation(s) %s',
                    paste(NAs,collapse=', ')))
    data <- dplyr::slice(data, seq_len(nrow(data))[-NAs])
  }
  
  compare.method <- match.arg(compare.method)
  reference.arm <- match.arg(reference.arm)
  
  arm.var <- formula.tools::rhs.vars(model)[[1]]
  if (!inherits(data[, arm.var], "factor")) data[, arm.var] <- factor(data[, arm.var])
  ### [trinhdhk] 2024-04: reverse level of y for better summary
  data[, arm.var] <- ._lv_rev_(data[, arm.var])
  arm.names <- levels(data[, arm.var])
  # A lot of code covers more than 2 arms, but think about what should be compared
  # in those cases (chunk test or pairwise test for instance) before implementing / trinhdhk.
  if (length(arm.names) > 2) c306_abort(sprintf(
    'At the moment, only two-arm studies are supported; `%s` has %d levels.', arm.var, length(arm.names)))
  
  
  # Prepare survfit
  time2 <- if (time == Inf) .Machine$integer.max else time
  fit.surv0 <- survival::survfit(update(model, new = as.formula(paste0(". ~ ", arm.var))), data = data)
  # [Trinhdhk] Use integer.max instead of Inf b/c summary.survfit does not want Inf anymore. 05/24
  
  # Check for competing risk aka mstate -trinhdhk
  ms <- inherits(fit.surv0, 'survfitms')
  if (ms) {
    all_causes <- attr(mf[[1]], 'states')
    if(length(unique(mf[[1]][,2]))<2)
      c306_abort('You wanted to use a multi-state (competing risks) model, but only one event type happened.')

    if (is.null(compare.args$cause)) compare.args$cause <- all_causes[[1]]
    if (!compare.args$cause %in% all_causes)
      c306_abort(c(sprintf('`compare.args$cause` ("%s") is not one of the event types: %s.', compare.args$cause,
                           paste0('"', all_causes, '"', collapse = ", ")),
                   i = 'In sstable.survcomp.subgroup(), perhaps that event did not happen in one subgroup.'))
    this_cause <- which(all_causes == compare.args$cause)+1
  }
  
  
  # Table header
  header1 <- c(paste(arm.names, " (n=", table(data[, arm.var]), ")", sep = ""), "Comparison")
  labels <- ._survcomp_labels(compare.method, compare.args$type, ms)
  compare.stat <- labels$stat

  header2 <- c(rep(ifelse(add.risk, "events/n (risk [%])", "events/n"), length(arm.names)), paste(compare.stat, if (p.compare) "(95%CI); p-value" else "(95%CI)"))
  header <- rbind(header1, header2)
  result <- rbind(header, "")
  
  ## footer
  compare.note <- labels$note
  compare.name <- labels$name
  footer <- c(
    paste0(compare.note, "; IQR = interquartile range."),
    paste(compare.stat, if (p.compare) "and p value", "were based on",
          paste0(compare.name, '.')),
    footer)
  
  
  # Descriptive analysis ---------------------------
  # add number of events and risks
  
  fit.surv <- summary(fit.surv0, time = time2, extend = TRUE)
  
  n.event <- if (ms) fit.surv$n.event[,this_cause] else fit.surv$n.event
  events.n <- paste(n.event, fit.surv$n, sep = "/")
  if (add.risk) {
    # Absolute risk at the truncation time: 1 - Kaplan-Meier for a single event,
    # Aalen-Johansen probability of the cause of interest for competing risks.
    # (Before 0.2.0 this was the cumulative hazard, which is not a risk.)
    risk <- if (ms) {
      fit.surv$pstate[, match(compare.args$cause, fit.surv$states), drop = TRUE]
    } else {
      1 - fit.surv$surv
    }
    events.n <- paste(events.n,
                      " (", formatC(100 * risk, digits, format = "f"), ")", sep = "")
  }
  idx <- which(arm.names %in% unique(data[, arm.var]))
  result[3, seq_along(arm.names)] <- rep("-", length(arm.names))
  result[3, idx] <- events.n
  
  
  
  # Comparison --------------------------------------
  # Re-base the arm factor
  if (reference.arm == 'B') data[, arm.var] <- ._lv_rev_(data[, arm.var])
  if (compare.method == "cox"){
    if (!is.null(compare.args$add.prop.haz.test))
      add.prop.haz.test <- compare.args$add.prop.haz.test
    if (length(events.n) < length(arm.names)) {
      result[3, length(arm.names) + 1] <- "-"
      if (add.prop.haz.test){result <- cbind(result, c("Test for proportional hazards", "p-value", "-"))}
    } else {
      compare.args$add.prop.haz.test <- NULL
      compare.args$formula <- model
      compare.args$data <- data
      
      # add HR, CI, p-value
      fit.coxph <- if (!ms)
        do.call(survival::coxph, compare.args) #survival::coxph(model, data)
      else{
        compare.args$etype <- compare.args$cause
        compare.args$cause <- NULL
        fml <- force(update(model, Surv(fgstart,fgstop,fgstatus)~.))
        fg <- do.call(survival::finegray, compare.args) # nolint: object_usage_linter. used in eval(substitute()) below
        eval(substitute(survival::coxph(fml, data = fg,  weights=fgwt), list(fml=fml)))
      }
      est <- coef(fit.coxph)[1:(length(arm.names)-1)] #trinhdhk: if there were more covariables than just arm, subsetting this to only get the arm
      hr <- formatC(exp(est), digits, format = "f")
      
      result[3, length(arm.names) + 1] <-
        ifelse(is.na(est),"-",
               
               {
                 se <- sqrt(fit.coxph$var[[1]]) # trinhdhk: if there were more covariables than just arm, $var returns a var-cov mat, this first element is the var of arm (given arm is the first covariable)
                 z <- abs(est/se)
                 pval <- format.pval((1 - pnorm(z)) * 2, eps = pcutoff, digits = pdigits)
                 ci <- sapply(est, \(.est) {
                   paste(formatC(exp(c(.est - qnorm(0.975) * se, .est + qnorm(0.975) * se)), digits, format = "f"), collapse = ", ")
                 })
                 if (p.compare){
                   hr.ci.p <- paste(hr, " (", ci, "); p=", pval, sep = "")
                 } else {
                   hr.ci.p <- paste(hr, " (", ci, ")", sep = "")
                 }
                 
                 hr.ci.p
               })
      
      
      # add test for proportional hazards
      if (add.prop.haz.test){
        if (is.na(est)) {
          result <- cbind(result, c("Test for proportional hazards", "p-value", "-"))
        } else {
          attr(model, ".Environment") <- environment() # needed for cox.zph to work
          p.prop.haz <-
            if(!ms){
              cox <- do.call(survival::coxph, compare.args)
              survival::cox.zph(cox)$table[1, "p"]
            } else{
              fml <- force(update(model, Surv(fgstart,fgstop,fgstatus)~.))
              fg <- do.call(survival::finegray, compare.args)
              cox <- eval(substitute(survival::coxph(fml, data = fg,  weights=fgwt), list(fml=fml)))
              survival::cox.zph(cox)$table[1, "p"]
            }
          if (is.na(p.prop.haz)) {
            p.prop.haz <- "-"
          } else {
            p.prop.haz <- format.pval(p.prop.haz, eps = pcutoff, digits = pdigits)
          }
          result <- cbind(result, c("Test for proportional hazards", "p-value", p.prop.haz))
        }
      }
    }
  } else {
    if (length(events.n) < length(arm.names)) {
      result[3, length(arm.names) + 1] <- "-"
    } else {
      compare.args$time <- time
      compare.args$add.prop.haz.test <- NULL
      compare.args$formula <- model
      compare.args$data <- data
      type <- if (is.null(compare.args$type)) 'diff' else compare.args$type
      compare.args$type <- NULL
      compare.args$link <- switch(type, "diff" = 'identity', "ratio" = 'log', 'lost.ratio' = 'log')
      if (is.null(compare.args$model.censoring)) compare.args$model.censoring <- 'stratified'
      if (is.null(compare.args$formula.censoring)) compare.args$formula.censoring <- as.formula(paste0("~`", arm.var, '`'))
      # Extract the time from Surv object with the arm included
      mf <- model.frame(update(model, new = as.formula(paste0(". ~`", arm.var, '`'))), data = data)
      mf <- cbind(unclass(mf[,1]), mf[,2])
      # Get max of stop time, is the minimum of last observed time between two arms.
      # The stop time for right cens data is the first column ($time), for interval-cens data it is the second column ($stop)
      # With laziness it is coded as mf[, ncol(mf)-2] (the last two columns are the event status from Surv object, and the arm)
      minimax.time <- min(by(mf[, ncol(mf)-2], mf[, ncol(mf)], max))
      max.time <- max(mf[, ncol(mf)-2])
      # tau for rmst is capped as minamax.time
      if (is.null(compare.args$time)) compare.args$time <- minimax.time
      else if (compare.args$time > minimax.time) {
        if (time != Inf) warning(
          sprintf('Specified time (tau) is later than maximum observed time between two arms (%.2f). Set too %.2f', minimax.time, minimax.time)
        )
        compare.args$time <- minimax.time
      }
      # If type == lost.ratio then reverse the time
      # i.e. Surv(tau - ev_time, ev) ~ .
      if (type == 'lost.ratio') {
        if (compare.method == 'cuminc') c306_abort('type "lost.ratio" is meaningless in a cumulative incidence comparison.')
        model.lhs <- formula.tools::lhs(model)
        for (i in 2:(length(model.lhs)-1)) {
          old <- model.lhs[[i]];
          model.lhs[[i]] <- substitute(max.time - old, list(old=old, max.time=max.time))
        }
        formula.tools::lhs(model) <- model.lhs
        compare.args$formula <- model
      }
      
      # Perform rmeanglm
      fitter <- if (compare.method == 'rmst') eventglm::rmeanglm else eventglm::cumincglm
      fit.rmst <- do.call(fitter, compare.args)
      est <- coef(fit.rmst)[2:(length(arm.names))] # get the coef for arm
      invlink <- fit.rmst$family$linkinv
      if (type=='lost.diff') invlink <- function(x) -x # loss.diff=-diff
      diff <- formatC(invlink(est), digits, format = "f")
      
      result[3, length(arm.names) + 1] <-
        ifelse(is.na(est),"-",
               {
                 summary.rmst <- summary(fit.rmst)$coefficients
                 p <- summary.rmst[2:length(arm.names), 'Pr(>|z|)']
                 pval <- format.pval(p, eps = pcutoff, digits = pdigits)
                 cf <- confint(fit.rmst)[2:length(arm.names),, drop=FALSE]
                 ci <- apply(cf, 1,
                             \(.cf) paste(formatC(sort(invlink(.cf)), digits, format = "f"), collapse = ", ")
                 )
                 if (is.na(p)) diff.ci.p <- paste(diff, '(-)')
                 else if (p.compare){
                   diff.ci.p <- paste(diff, " (", ci, "); p=", pval, sep = "")
                 } else {
                   diff.ci.p <- paste(diff, " (", ci, ")", sep = "")
                 }
                 diff.ci.p
               })
    }
    
  }
  
  rownames(result) <- NULL
  
  # add label
  varname <- all.vars(model)[2:1]
  varlabel <- sapply(varname, function(x){
    ifelse(is.null(attr(data[, x], "label")), x, attr(data[, x], "label"))
  })
  # output
  output <- if (medsum & !ms) {
    result <- rbind(result, "", "", "", "")
    # add median (IQR) of time-to-event
    # one row per arm present in the data (quantile() returns plain vectors,
    # not 1-row matrices, when only one arm is present)
    q <- quantile(fit.surv0, probs = c(0.5, 0.25, 0.75))
    qfit <- do.call(cbind, lapply(q, function(m) if (is.matrix(m)) m else matrix(m, nrow = 1)))
    result[5:7, seq_along(arm.names)] <- "-"
    result[5:7, idx] <- apply(formatC(qfit, digits, format = "f"), 1, function(x){
      sapply(1:3, function(z) paste(x[z], " (", x[z + 3], ", ", x[z + 6], ")", sep = ""))
    })
    cbind(c("Endpoint", "", varlabel, "- Median (95%CI)", "- Lower IQR (95%CI)", "- Upper IQR (95%CI)"), result)
  } else {
    output <- cbind(c("Endpoint", "", varlabel[1]), result)
  }
  rownames(output) <- NULL
  value <- output[-c(1:2), , drop = FALSE]
  ## flextable
  if (flextable) {
    ## header: "Endpoint" spans both header rows
    header1 <- output[1, ]; header2 <- output[2, ]
    header2[1] <- header1[1]
    tab <- ._ss_flextable_two_headers(as.data.frame(value), header1, header2, merge.h = FALSE)
    if (any(value == "-")) footer <- c(footer, "- : value cannot be estimated.")
    tab <- ._ss_flextable_footer(tab, footer, length(header1))
    tab <- ._ss_flextable_finish(tab, bg)
  } else {
    tab <- list(table = output,
                footer = footer)
    class(tab$table) <- c('survcomp_tbl', 'ss_tbl', class(tab$table))
  }
  if (!flextable) class(tab) <- c('ss_survcomp','ss_obj')
  return(tab)
}

# Labels of the comparison, shared by sstable.survcomp() and
# sstable.survcomp.subgroup(): the statistic shown in the header (`stat`), the
# abbreviation note (`note`) and the model name (`name`) used in the footer.
._survcomp_labels <- function(compare.method, type, ms, call = rlang::caller_env()) {
  stat <- switch(compare.method,
                 cox = 'HR',
                 cuminc = if (is.null(type)) 'Cumul.inc difference'
                 else switch(type,
                             diff = 'Cumul.inc difference',
                             ratio = 'Cumul.inc ratio',
                             c306_abort('Illegal type for cumulative incidence comparison model: use "diff" or "ratio".',
                                        call = call)),
                 rmst = if (is.null(type)) 'RMST difference'
                 else switch(type,
                             diff = 'RMST difference',
                             lost.diff = 'RMTL difference',
                             ratio = 'RMST ratio',
                             lost.ratio = 'RMTL ratio',
                             c306_abort('Illegal type for RMST comparison model: use "diff", "ratio", "lost.diff" or "lost.ratio".',
                                        call = call)))
  note <- switch(
    stat,
    'HR' = 'HR = hazard ratio',
    'Cumul.inc difference' = 'Cumul.inc : Cumulative incidence',
    'Cumul.inc ratio' = 'Cumul.inc : Cumulative incidence',
    'RMST difference' = 'RMST: Restricted mean survival time',
    'RMTL difference' = 'RMTL: Restricted mean time loss',
    'RMST ratio' = 'RMST: Restricted mean survival time',
    'RMTL ratio' = 'RMTL: Restricted mean time lost'
  )
  name <- switch(compare.method,
                 cuminc = 'Generalized linear models for cumulative incidence',
                 cox = if (ms) 'Fine-Gray model' else 'Cox proportional hazards model',
                 rmst = 'Restricted mean survival time model')
  list(stat = stat, note = note, name = name)
}
