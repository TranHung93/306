#' Summarize results for a survival model by treatment arm and subgroup
#'
#' @description A function to summarize results for a survival model by treatment arm (variable "arm") and subgroup.
#'
#' @param base.model a formula from which sub-group specific estimates are extracted (!! arm must be the first covariate in the model).
#' @param overall.model an optional one-sided formula for additional terms for overall population only
#' @param subgroup.model a formula of the form "~subgrouping.variable1+subgrouping.variable2" (!! subgrouping.variable must be factors and there should be nothing on the left-hand side of the formula).
#' @param data a data frame to fit the survival model.
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
#' @param p.compare [\code{TRUE}] a logical value, specifying whether we should report p-value for the main comparison
#' @param digits [\code{2}] a number specifies number of significant digits for numeric statistics.
#' @param pdigits [\code{3}] a number specifies number of significant digits for p value.
#' @param pcutoff [\code{0.001}] a number specifies threshold value of p value to be displayed as "< pcutoff".
#' @param footer a [\code{NULL}] vector of strings to be used as footnote of table.
#' @param flextable [\code{TRUE}] a logical value specifies whether output will be a flextable-type table.
#' @param bg [\code{#F2EFEE}] a character specifies color of the odd rows in the body of flextable-type table.
#' @param overall [\code{TRUE}] where to print overall model
#' @param ... arguments that are passed to sstable.survcomp
#'
#' @return A flextable if `flextable = TRUE` (the default), otherwise a list of class
#'   `ss_survcomp` with elements `table` (a character matrix) and `footer`.
#' @examples
#' library(survival)
#' lung2 <- transform(na.omit(lung[, c("time", "status", "sex", "ph.ecog")]),
#'                    arm = factor(sex, labels = c("Male", "Female")),
#'                    ecog = factor(ph.ecog))
#' lung2 <- droplevels(subset(lung2, ecog != "3"))
#'
#' # HR by ECOG status, with a test for heterogeneity
#' tab <- sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ ecog, data = lung2,
#'                                  flextable = FALSE)
#' tab$table
#'
#' @author This function was originally written by Marcel Wolbers. Trinh Dong and Lam Phung Khanh did some modification.
#' @import survival
#' @export
sstable.survcomp.subgroup <- function(base.model, subgroup.model, overall.model, data,
                                      time = Inf,
                                      reference.arm = c('B', 'A'),
                                      compare.method = c('cox', 'rmst', 'cuminc'),
                                      compare.args = list(),
                                      p.compare = TRUE,
                                      digits = 2, pdigits = 3, pcutoff = 0.001, footer = NULL, flextable = TRUE, bg = "#F2EFEE", overall = TRUE,...){

  ## validate inputs (sstable.survcomp() checks the remaining arguments)
  check_formula(base.model, sides = "two")
  check_formula(subgroup.model, sides = "one")
  if (!missing(overall.model)) check_formula(overall.model)
  check_data_frame(data)
  check_columns(data, c(all.vars(base.model), all.vars(subgroup.model),
                        if (!missing(overall.model)) all.vars(overall.model)))
  for (flag in c("p.compare", "flextable", "overall")) check_flag(get(flag), arg = flag)
  check_number(pdigits, min = 1, whole = TRUE)
  check_number(pcutoff, min = 0, max = 1)

  ## strip the tibble class which causes issue - trinhdhk
  data <- as.data.frame(data)
  NAs <- model.frame(update(base.model, .~1), data=data) |> attr('na.action') |> unname()
  if (length(NAs)){
    warning(sprintf('Missing values on observation(s) %s',
                    paste(NAs,collapse=', ')))
    # data <- data[seq_len(nrow(data))[-NAs],]
    data <- dplyr::slice(data, seq_len(nrow(data))[-NAs])
  }
  compare.method <- match.arg(compare.method)
  fit.surv0 <- survfit(update(base.model, .~1), data=data)
  ms <- inherits(fit.surv0, 'survfitms')
  
  # arm.var <- if (length(base.model[[3]]) > 1) {
  #   deparse(base.model[[3]][[2]])
  # } else {
  #     deparse(base.model[[3]])
  #   }
  arm.var <- formula.tools::rhs.vars(base.model)[[1]]
  if (!inherits(data[, arm.var], "factor")) data[, arm.var] <- factor(data[, arm.var])
  
  # result in entire population
  if (!missing(overall.model)){
    added.terms <- terms(overall.model) |> attr('term.labels')
    overall.model <- update(base.model,
                            as.formula(paste('. ~ . +',
                                             paste(added.terms,
                                                   collapse='+'))))
  } else overall.model <- base.model
  result <- sstable.survcomp(model = overall.model, data = data, time=time, reference.arm=reference.arm,
                             medsum = FALSE, digits = digits,
                             compare.method = compare.method, compare.args = compare.args,
                             p.compare = p.compare,
                             pdigits = pdigits, pcutoff = pcutoff, flextable = FALSE, ...)$table[,-1]
  result <- cbind(c("Subgroup", "", "All patients"), result, c("Test for heterogeneity", "p-value", ""))
  
  # Preparation of models and data
  subgroup.char <- all.vars(subgroup.model)
  
  for (k in 1:length(subgroup.char)){
    main.model <- update(base.model, as.formula(paste(". ~ . +", subgroup.char[k], sep = "")))
    ia.model <- update(base.model, as.formula(paste(". ~ . +`", arm.var,  "`*", subgroup.char[k], sep = "")))
    data$.subgroup.var <- data[, subgroup.char[k]]
    if (!inherits(data[, subgroup.char[k]], 'factor'))  data[, subgroup.char[k]] <- factor(data[, subgroup.char[k]])
    factor.levels <- levels(data[, subgroup.char[k]])
    compare.args.subgroup <- compare.args
    # Add interaction test for heterogeneity
    result <- rbind(result, "")
    result[nrow(result), 1] <- ifelse(is.null(attr(data[, subgroup.char[k]], "label")),
                                      subgroup.char[k], attr(data[, subgroup.char[k]], "label"))
    ia.pval <-
      if (compare.method == 'cox'){
        if (ms){
          etype <- compare.args$cause
          fg.ia <- survival::finegray(ia.model, data=data, etype=etype)
          fg.main <- survival::finegray(main.model, data=data, etype=etype)
          
          anova(
            survival::coxph(update(ia.model, Surv(fgstart,fgstop,fgstatus)~.),
                            data=fg.ia, weights=fgwt),
            survival::coxph(update(main.model, Surv(fgstart,fgstop,fgstatus)~.),
                            data=fg.main, weights=fgwt),
            test = "Chisq")[2, "Pr(>|Chi|)"]
        } else {
          anova(survival::coxph(ia.model, data = data),
                survival::coxph(main.model, data = data),
                test = "Chisq")[2, "Pr(>|Chi|)"]
        }
      } else {
        ia.args <- compare.args
        ia.args$add.prop.haz.test <- NULL
        # ia.args$formula <- ia.model
        ia.args$data <- data
        
        type <- if (is.null(ia.args$type)) 'diff' else ia.args$type
        ia.args$type <- NULL
        ia.args$link <- switch(type, "diff" = 'identity', "ratio" = 'log', 'lost.ratio' = 'log')
        if (is.null(ia.args$model.censoring)) ia.args$model.censoring <- 'stratified'
        ia.args$formula.censoring <-
          if (is.null(ia.args$formula.censoring)) update(main.model, NULL ~.) else
            update(ia.args$formula.censoring, as.formula(paste("NULL ~ . +", subgroup.char[k], sep = "")))
        mf <- model.frame(update(base.model, new = as.formula(paste0(". ~`", arm.var, '`'))), data = data)
        mf <- cbind(unclass(mf[,1]), mf[,2])
        # Get max of stop time, is the minimum of last observed time between two arms.
        # The stop time for right cens data is the first column ($time), for interval-cens data it is the second column ($stop)
        # With laziness it is coded as mf[, ncol(mf)-2] (the last two columns are the event status from Surv object, and the arm)
        minimax.time <- min(by(mf[, ncol(mf)-2], mf[, ncol(mf)], max))
        
        # tau for rmst is capped as minamax.time
        if (is.null(ia.args$time)) ia.args$time <- minimax.time
        else if (ia.args$time > minimax.time) {
          ia.args$time <- minimax.time
        }
        
        # Remove missing value from predictor bc this causes problem in censoring model
        NAs <- model.frame(main.model, data=data) |> attr('na.action') |> unname()
        if (length(NAs)){
          warning(sprintf('Missing %s on observation(s) %s',
                          subgroup.char[k],
                          paste(NAs,collapse=', ')))
          # data <- data[seq_len(nrow(data))[-NAs],]
          ia.args$data <- dplyr::slice(data, seq_len(nrow(data))[-NAs])
        }
        
        # browsere)
        # Perform multivariate wald test for interaction term
        tryCatch({
          fitter <- switch(compare.method,
                           'rmst' = eventglm::rmeanglm,
                           'cuminc' = eventglm::cumincglm)
          ia.fit <-
            do.call(fitter, append(ia.args, c(formula=ia.model)))
          main.terms <- colnames(model.matrix(main.model, data=ia.args$data))
          ia.terms <- coef(ia.fit)
          test.terms <- which(!names(ia.terms) %in% main.terms)
          test <- aod::wald.test(vcov(ia.fit), b=ia.terms, Terms=test.terms)
          test$result$chi2['P']
        },
        error=\(e) NA
        )
        
      }
    
    result[nrow(result), ncol(result)] <-
      if (is.na(ia.pval)) '-' else
        format.pval(ia.pval, digits = pdigits, eps = pcutoff)
    
    # Add results for each subgroup level
    for (j in 1:length(factor.levels)){
      result <- rbind(result, "")
      result[nrow(result), 1] <- paste("-", factor.levels[j])
      d.subgroup <- subset(data, .subgroup.var == factor.levels[j])
      if (nrow(d.subgroup) == 0) {
        # empty subgroup level: nothing can be estimated
        result[nrow(result), 2:(ncol(result) - 1)] <- "-"
        next
      }
      result[nrow(result), 2:(ncol(result) - 1)] <- sstable.survcomp(model = base.model, data = d.subgroup, time=time,
                                                                     reference.arm = reference.arm,
                                                                     compare.method = compare.method, compare.args = compare.args,
                                                                     p.compare = p.compare,
                                                                     medsum = FALSE, digits = digits, pdigits = pdigits, pcutoff = pcutoff,
                                                                     flextable = FALSE, ...)$table[3,-1]
    }
  }
  ## footer
  labels <- ._survcomp_labels(compare.method, compare.args$type, ms)
  footer <- c(
    labels$note,
    paste(labels$stat, "and p value were based on", paste0(labels$name, '.')),
    sprintf(
      "Test for heterogeneity is an %s test for interaction between treatment effect and each subgroup in the survival model not including other variables.",
      if (compare.method == 'cox') 'Likelihood-ratio' else 'multivariate Wald'
    ),
    footer)
  
  # flextable
  if (!overall) result <- result[-3,]
  if (flextable) {
    ## header: "Subgroup" spans both header rows
    value <- result[-c(1, 2), ]
    header1 <- result[1, ]; header2 <- result[2, ]
    header2[1] <- header1[1]
    tab <- ._ss_flextable_two_headers(as.data.frame(value), header1, header2, merge.h = FALSE)
    if (any(value == "-")) footer <- c(footer, "- : value cannot be estimated.")
    tab <- ._ss_flextable_footer(tab, footer, length(header1))
    tab <- ._ss_flextable_finish(tab, bg)
  } else {
    tab <- list(table = result,
                footer = footer)
    class(tab$table) <- c('survcomp_tbl', 'ss_tbl', class(tab$table))
  }
  if (!flextable) class(tab) <- c('ss_survcomp','ss_obj')
  return(tab)
}

#' Print an sstable matrix
#'
#' @description Print method for objects of class `ss_tbl`. When `pretty` is
#'   `TRUE` and the \pkg{huxtable} package is installed, the table is printed as
#'   a huxtable; otherwise it is printed as a plain matrix.
#' @param x an object of class `ss_tbl`.
#' @param pretty a logical value: print as a huxtable? Defaults to the
#'   `ss_pretty.print` option, or `TRUE` if that option is unset.
#' @param ... unused; kept for compatibility with [print()]. Passing the table
#'   as `sstable = ` is deprecated, use `x` instead.
#' @return `x`, invisibly.
#' @examples
#' library(survival)
#' tab <- sstable.survcomp(Surv(time, status) ~ sex, data = lung, medsum = FALSE,
#'                         flextable = FALSE)$table
#' print(tab, pretty = FALSE)
#' if (requireNamespace("huxtable", quietly = TRUE)) print(tab)
#' @export
print.ss_tbl <- function(x, pretty = getOption('ss_pretty.print', TRUE), ...){
  if (missing(x)) {
    dots <- list(...)
    if (is.null(dots$sstable)) rlang::abort("Argument `x` is missing, with no default.")
    lifecycle::deprecate_warn("0.1.6", "print.ss_tbl(sstable)", "print.ss_tbl(x)")
    x <- dots$sstable
  }
  if (!isTRUE(pretty) || !requireNamespace("huxtable", quietly = TRUE)) {
    print.default(x)
    return(invisible(x))
  }
  tryCatch(
    print(huxtable::theme_article(huxtable::as_hux(x))),
    error = function(e) print.default(x)
  )
  invisible(x)
}

