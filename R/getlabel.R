#' Obtain label of variable(s) based on metadata information
#'
#' @description A function to obtain label of one vector or each variable in one data frame based on pre-defined metadata information.
#'
#' @param x a vector or data frame to get label.
#' @param meta a data frame contains metadata of the dataset. This data frame should have the following variables: varname (character variable specifies name of each variable), label (character variable specifies label of each variables), type (character variable specifies type of each variable [numeric, factor, character, datetime], unit (character variable specifies units of each continuous variable), scale (numeric variable specifies how each variable will be scaled).
#' @param unit a logical value specifies whether unit will be appended in the label of continuous variables.
#' @param fit a logical value specifies whether the label will use presentation as in model fitting.
#'
#' @return A character vector of labels: one for a vector, one per column for a data frame
#'   (the column name when a column has no label). With `meta`, `x` is a variable name (or a
#'   data frame whose column names are looked up in `meta$varname`).
#' @examples
#' wt <- structure(c(60, 72), label = "Weight", unit = "kg", scale = 10)
#' getlabel(wt)
#' getlabel(wt, fit = TRUE)      # as in a model with weight per 10 kg
#'
#' meta <- data.frame(varname = c("age", "sex"), label = c("Age", "Sex"),
#'                    unit = c("years", NA), scale = c(10, NA), type = c("numeric", "factor"))
#' getlabel("age", meta = meta)
#' getlabel(data.frame(age = 50, sex = "F"), meta = meta)
#' @export
getlabel <- function(x, meta = NULL, unit = TRUE, fit = FALSE){
  if (is.null(dim(x))) {
    getlabel.one(x, meta = meta, unit = unit, fit = fit)
  } else {
    getlabel.data(x, meta = meta, unit = unit, fit = fit)
  }
}

getlabel.default <- function(x, unit = TRUE, fit = FALSE){
  if (is.null(attr(x, "type"))) attr(x, "type") <- ""
  if (is.null(attr(x, "label"))) attr(x, "label") <- ""

  # to create polished label
  if ((is.factor(x) | attr(x, 'type') == 'factor') | unit == FALSE) {
    # if factor or do not need unit
    as.character(attr(x, 'label'))
  } else {
    # if not factor and need unit
    new_unit <- ifelse(fit == FALSE, ifelse(is.null(attr(x, 'unit')), '', attr(x, 'unit')),
                       paste('+',
                             ifelse(is.null(attr(x, 'scale')), 1, attr(x, 'scale')),
                             ' ',
                             ifelse(is.null(attr(x, 'unit')), '', attr(x, 'unit')), sep = ''))
    ifelse(new_unit == "",
           as.character(attr(x, 'label')),
           as.character(paste(attr(x, 'label'), ' [', new_unit, ']', sep = '')))

  }
}

getlabel.one <- function(x, meta = NULL, unit = TRUE, fit = FALSE){
  # to create polished label for variable x from meta information

  if (!is.null(meta)) {
    # extract meta info
    .label <- ifelse(is.na(meta$label[meta$varname == x]), '', meta$label[meta$varname == x])
    .unit <- ifelse(is.na(meta$unit[meta$varname == x]), '', meta$unit[meta$varname == x])
    .scale <- ifelse(is.na(meta$scale[meta$varname == x]), 1, meta$scale[meta$varname == x])
    .type <- meta$type[meta$varname == x]

    # create label
    if (.type == 'factor' | unit == FALSE) {
      # if factor or do not need unit
      out <- as.character(.label)
    } else {
      # if not factor and need unit
      new_unit <- ifelse(fit == FALSE, .unit, paste('+', .scale, ' ', .unit, sep = ''))
      out <- as.character(paste(.label, ' [', new_unit, ']', sep = ''))
    }
  } else {
    # if no meta information
    out <- getlabel.default(x, unit = unit, fit = fit)
  }

  # return
  out
}

getlabel.data <- function(data, meta = NULL, unit = TRUE, fit = FALSE){
  # to create polished label for variables in data frame data from meta information

  out <- names(data)

  if (!is.null(meta)) {
    # meta rows in the column order of data (NA where a column has no meta)
    idx <- match(out, meta$varname)
    meta_col <- function(col, default) {
      v <- if (is.null(meta[[col]])) rep(NA, length(idx)) else meta[[col]][idx]
      ifelse(is.na(v), default, v)
    }

    # extract meta info
    .label <- meta_col('label', NA)
    .label <- ifelse(is.na(.label), out, as.character(.label))
    .unit <- meta_col('unit', '')
    .scale <- meta_col('scale', 1)
    .type <- meta_col('type', '')

    # create label
    if (unit == FALSE) {
      out <- .label
    } else {
      if (fit) .unit <- paste('+', .scale, ' ', .unit, sep = '')
      out <- ifelse(.type == 'factor', .label, paste0(.label, ' [', .unit, ']'))
    }
  } else {
    if (ncol(data) == 1) {
      out <- getlabel.default(data)
    } else {
      out <- sapply(data, getlabel.default)
    }
    if (any(out == "")){
      tmp <- colnames(data)
      out <- ifelse(out == "", tmp, out)
    }
  }

  # return
  out
}
