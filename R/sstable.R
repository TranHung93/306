# extract x variables from formula for sstable ----------------------------

getvar <- function(formula) {
  if (!is.call(formula)) {
    deparse(formula)
  } else {
    if (identical(formula[[1]], quote(`~`)) | identical(formula[[1]], quote(`+`)) | identical(formula[[1]], quote(`|`))) {
      unlist(lapply(c(formula[[2]], formula[[3]]), getvar))
    } else {
      deparse(formula)
    }
  }
}

# extract the sign from quo/formula for sstable - trinhdhk ----------------

getsign <- function(fml){
  fml <- unclass(fml)[[2]]
  .getsign = function(x){
    c(x[[1]],
      unlist(lapply(x[-1],
                    function(.x) if(is.call(.x)) .getsign(.x))))
  }

  out <- .getsign(fml)
  out[rev(seq_along(out))]
}

# extract information from formula for sstable ----------------------------

sstable.formula <- function(formula, call = rlang::caller_env()) {
  if (length(formula) < 3) {
    c306_abort("Missing row-wise variable(s): `formula` must be of the form `rows ~ column`.", call = call)
  }

  ## get formula to extract all required variables (formula0)
  formula0 <- if (identical(formula[[3]], 1)) {
    as.formula(paste("~", deparse(formula[[2]])))
  } else {
    as.formula(paste("~", paste(getvar(formula), collapse = "+")))
  }


  ## get index of each element in formula
  xlen <- length(all.vars(formula[[2]]))
  if (xlen == 0) c306_abort("Missing row-wise variable(s): `formula` must be of the form `rows ~ column`.", call = call)

  if (length(formula[[3]]) > 1) {
    if (deparse(formula[[3]][[1]]) == "|") {
      ylen <- ifelse(identical(formula[[3]][[2]], 1), 0, length(all.vars(formula[[3]][[2]])))
      zlen <- length(all.vars(formula[[3]][[3]]))
    } else {
      ylen <- ifelse(identical(formula[[3]], 1), 0, length(all.vars(formula[[3]])))
      zlen <- 0
    }
  } else {
    ylen <- ifelse(identical(formula[[3]], 1), 0, length(all.vars(formula[[3]])))
    zlen <- 0
  }

  if (ylen > 1) c306_abort("Only 1 column-wise variable is allowed in `formula`.", call = call)
  if (zlen > 1) c306_abort("Only 1 third dimension variable is allowed in `formula`.", call = call)

  ## get all formulas required for tabulation
  xs <- getvar(formula[[2]])
  formula1 <- sapply(xs, function(x) update.formula(old = formula, new = paste(x, " ~ .")))

  ## output
  return(list(formula0 = formula0,
              index = list(x = 1:xlen,
                           y = if (ylen == 0) 0 else (xlen + 1),
                           z = if (zlen == 0) 0 else (xlen + 2)),
              formula1 = formula1))
}


# calculate summary statistics for continuous variable --------------------

#' Calculate summary statistics for continuous variable
#'
#' @description A function to calculate summary statistics for continuous variable.
#'
#' @param x a numeric vector to be summarised.
#' @param statistics a single string describing the summary, e.g. `"mean (sd)"` or
#'   `"median (Q1-Q3)"`. The words `mean`, `median`, `sd`, `q1`, `q3`, `min` and `max`
#'   (in any case, as whole words) are replaced by their values; all other text is kept as is.
#' @param digits a number specifies number of decimal places for numeric statistics.
#' @param n currently ignored; kept for backward compatibility.
#'
#' @return a string displays formatted summary statistics. Statistics that cannot be computed
#'   (e.g. all values missing) are shown as `NA`.
#' @examples
#' contSummary(c(1, 2, 3, 10), "mean; median (Q1-Q3)")
#' contSummary(c(1, 2, 3, 10), "Median [IQR: Q1-Q3], range min-max", digits = 0)
#' @export
contSummary <- function(x, statistics = NULL, digits = 1, n = TRUE) {
  if (is.null(statistics)) {
    c306_abort("Please provide a string for `statistics`, e.g. \"mean (sd)\".")
  }
  check_string(statistics)
  if (!is.numeric(x) && !is.logical(x)) {
    c306_abort(sprintf("`x` must be a numeric vector, not %s.", obj_type(x)))
  }
  check_number(digits, min = 0, whole = TRUE)

  x <- x[!is.na(x)]
  # Supported statistics; NA when there is no non-missing value
  stat_list <- list(
    mean = function(x) mean(x),
    median = function(x) stats::median(x),
    sd = function(x) stats::sd(x),
    q1 = function(x) unname(stats::quantile(x, 0.25)),
    q3 = function(x) unname(stats::quantile(x, 0.75)),
    min = function(x) min(x),
    max = function(x) max(x)
  )

  # Replace each statistic name (whole word, any case) with its value
  for (stat_name in names(stat_list)) {
    pattern <- paste0("(?i)\\b", stat_name, "\\b")
    if (!grepl(pattern, statistics, perl = TRUE)) next
    stat_value <- if (length(x)) round(stat_list[[stat_name]](x), digits) else NA_real_
    stat_value <- format(stat_value, nsmall = digits)
    statistics <- gsub(pattern, stat_value, statistics, perl = TRUE)
  }

  return(statistics)
}
