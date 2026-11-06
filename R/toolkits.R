#' Do a simple recode via pattern for data
#'
#' @description
#' A function to re-encode data by using a map. Patterns are accepted. Unmentioned data are left intact.
#'
#' Method for class data.frame supports a robust replacement for data by providing relevant map in the form of var = map.
#'
#' @param x a vector
#' @param map
#' A map.
#'
#' Map can be a list in the form of recoded_text = c(to_be_recoded_text)
#'
#' Or as a data frame having 2 columns named "from" and "to".
#'
#' @param as A character string defining the post-recoded data type of x. Default is keeping as-is:
#' numeric input stays numeric when possible, and factor input stays a factor (a 2-level factor
#' recoded to "TRUE"/"FALSE" becomes logical).
#' @param .data A data frame to modify
#' @param ...
#' For method for data.frame: Replacement in the form of var = map. Maps must follow the syntax stipulated in the map parameter.
#'
#' For default method: Additional parameters passed to factor()
#'
#' @param ignore.case Specify whether the pattern is case-insensitive. Default is FALSE (case sensitive). Passed to [gsub()].
#' @param fixed If TRUE, patterns are matched as is rather than as regular expressions. Passed to [gsub()].
#' @param perl Are patterns follow the Perl-style regular expression. Passed to [gsub()].
#' @seealso \link{regex} \link[dplyr]{case_when}
#'
#' @return
#' If input is a vector, return a vector of the same length.
#'
#' If input is a data frame, return a data frame with relevant variables recoded.
#'
#' @examples
#' # patterns are regular expressions; text that matches no pattern is kept
#' simple_recode(c("yes", "Yes", "no", NA), map = list(Y = "^[Yy]es$", N = "^no$", Unknown = NA))
#'
#' # a factor stays a factor, with recoded levels
#' simple_recode(factor(c("m", "f", "f")), map = list(Male = "^m$", Female = "^f$"))
#'
#' # several variables of a data frame at once
#' df <- data.frame(sex = c("m", "f"), smoker = c("y", "n"))
#' simple_recode(df, sex = list(Male = "m", Female = "f"), smoker = list(Yes = "y", No = "n"))
#' @export
simple_recode <- function(...){
  UseMethod('simple_recode')
}

#' @rdname simple_recode
#' @aliases recode_var var_recode
#' @method simple_recode data.frame
#' @export
simple_recode.data.frame <- function(.data, ..., ignore.case = FALSE, fixed = FALSE, perl = TRUE){
  .maps <- list(...)
  .vars <- names(.maps)
  if (length(.maps) && (is.null(.vars) || any(!nzchar(.vars))))
    c306_abort('Replacements must be given as `variable = map`.')
  check_columns(.data, .vars, data_arg = ".data")
  for (.var in .vars){
    .data[[.var]] <- simple_recode.default(x = .data[[.var]], map = .maps[[.var]], ignore.case = ignore.case, fixed = fixed, perl = perl)
  }
  return(.data)
}

#' @rdname simple_recode
#' @method simple_recode default
#' @export
simple_recode.default <- function(x, map, as = c('as_is', 'numeric', 'factor', 'character', 'logical'), ignore.case = FALSE, fixed = FALSE, perl = TRUE, ...){
  as <- match.arg(as)
  if (missing(map)) c306_abort('A conversion `map` should be provided.')
  for (flag in c("ignore.case", "fixed", "perl")) check_flag(get(flag), arg = flag)

  if (is.data.frame(map)) {
    if (!all(c("from", "to") %in% names(map)))
      c306_abort('A data frame `map` must have columns named "from" and "to".')
    Map <- map
  } else {
    if (!is.list(map) && !(is.atomic(map) && !is.null(names(map))))
      c306_abort('`map` must be a named list (recoded_text = c(patterns)) or a data frame with columns "from" and "to".')
    if (is.null(names(map)) || any(!nzchar(names(map))))
      c306_abort('Every element of `map` must be named with its recoded text.')
    Map <- data.frame(
      to = unlist(lapply(names(map),
                         function(name) rep(name, length(map[[name]])))),
      from = unlist(map),
      stringsAsFactors = FALSE
    )}

  if (length(Map$from) != length(unique(Map$from))) c306_abort('Patterns in `map` should be unique.')

  x.recoded <- x
  for (i in 1:nrow(Map)){
    if (is.na(Map$from[i])) x.recoded <- tidyr::replace_na(x.recoded, Map$to[i])
    else x.recoded <- gsub(Map$from[i], Map$to[i], x.recoded, ignore.case = ignore.case, fixed = fixed, perl=perl)
  }


  if (as != 'as_is') {
    x.recoded <-
      switch(as,
             numeric = as.numeric(x.recoded),
             character = as.character(x.recoded),
             factor = factor(x.recoded, ...),
             logical = as.logical(x.recoded))
  } else {
    if (is.factor(x)) {
      recoded.values <- unique(x.recoded[!is.na(x.recoded)])
      if (length(levels(x)) == 2 && length(recoded.values) &&
          all(recoded.values %in% c("TRUE", "FALSE"))) {
        # a 2-level factor mapped onto TRUE/FALSE becomes logical
        x.recoded <- as.logical(x.recoded)
      } else {
        # otherwise stay a factor, with levels recoded in their original order
        levels.recoded <- unique(simple_recode.default(levels(x), map = Map, ignore.case = ignore.case,
                                                       fixed = fixed, perl = perl))
        x.recoded <- factor(x.recoded, levels = levels.recoded)
      }
    } else if (is.numeric(x)) {
      x.recoded <- tryCatch(as.numeric(x.recoded), warning = function(w) x.recoded)
    }
  }
  return(x.recoded)
}


`do_to<-` <- function(x, value){
  match.fun(value)(x)
}

#' Get or set the reference level
#' @description A function to quickly get or set the reference level of a factor
#' @export
ref_lv <- function(x){
  UseMethod('ref_lv')
}

#' @rdname ref_lv
#' @param x A factor
#' @return `ref_lv()`: a string, the reference (first) level. `ref_lv<-`: the factor with
#'   `value` as its first level.
#' @examples
#' arm <- factor(c("Placebo", "Drug", "Drug"))
#' ref_lv(arm)
#' ref_lv(arm) <- "Placebo"
#' levels(arm)
#' @export
ref_lv.factor <- function(x){
  levels(x)[[1]]
}

#' @rdname ref_lv
#' @export
`ref_lv<-` <- function(x, value){
  UseMethod('ref_lv<-')
}

#' @rdname ref_lv
#' @param value An existing level to be set as reference
#' @export
`ref_lv<-.factor` <- function(x, value){
  relevel(x, value)
}

#' Get the proportion for each level or range of a vector
#' @description A function to calculate the proportion of each value range
#' @param x An object
#' @param method
#' A method to calculate the percentage.
#' Default is 'auto' which will attempt to choose the most fit method.
#' 'bin' is only meaningful for vector that only has to values.
#' 'fct' is meaningful for descrete variable
#' 'cont' is used for continuous variables. This will break the variable into several ranges
#' depended on the breaks specified in ...
#' @param na.rm A logical value deciding whether NA should be removed
#' @param ... Additional parameters passed to \link{cut}. Only work if method = 'cont'
#' See \link{cut}
#' @return
#' If method == 'bin': the percentage of non-reference level
#'
#' If method == 'fct': the percentages of all levels
#'
#' If method == 'cont': the percentages of all ranges based on specified breaks
#' @examples
#' pct(c(TRUE, FALSE, TRUE, NA))                 # binary: % TRUE among non-missing
#' pct(factor(c("a", "b", "b", "c")))            # one % per level
#' pct(survival::lung$age, method = "cont", breaks = c(0, 50, 65, 100))
#' @export
pct <- function(x, method = c('auto', 'bin', 'cont', 'fct'), na.rm = TRUE, ...){
  method <- match.arg(method)
  check_flag(na.rm)
  if (length(x) == 0) c306_abort("`x` must have at least one value.")
  if (method == 'auto') method <- ._pct_get_method(unlist(x))

  if (method == 'bin' & !is.logical(x) & !setequal(unique(x), c(0,1))){
    if (length(unique(x)) > 2) c306_abort('Forcing the binary method for a variable with more than 2 values is meaningless.')
    if (length(unique(x)) == 1) return(100)
    if (length(unique(x)) != length(levels(x))) x <- factor(x, levels = unique(x), exclude=NULL)
    if (all(!is.na(levels(x))))
      warning('Binary method apply to non logical variable. This will calculate the pct of x != ref_lv')
    x <- x == levels(x)[2]
  }

  res <- switch(method,
                bin = ._pct_bin(x, na.rm),
                cont = ._pct_cont(x, na.rm, ...),
                fct = ._pct_fct(x, na.rm))

  return(res)
}

._pct_get_method <- function(x){
  if (is.logical(x) | length(unique(x)) <= 2) return('bin')
  if (is.factor(x) | is.character(x) | (is.numeric(x) & length(unique(x)) <= 5)) return('fct')
  return('cont')
}

._pct_bin <- function(x, na.rm = TRUE){
  n <- if (na.rm) sum(!is.na(x)) else length(x)
  return(sum(x, na.rm = TRUE)/n*100)
}

._pct_fct <- function(x, na.rm = TRUE){
  if (!is.factor(x)) x <- factor(x)
  x.chr <- as.character(x) # NA levels (exclude = NULL) become NA here
  n <- if (na.rm) sum(!is.na(x.chr)) else length(x.chr)
  lvs <- if (na.rm) levels(x)[!is.na(levels(x))] else levels(addNA(x, ifany = TRUE))
  vapply(lvs,
         function(lv){
           if (is.na(lv)) sum(is.na(x.chr))/n*100 else sum(x.chr == lv, na.rm = TRUE)/n*100
         }, numeric(1))
}

._pct_cont <- function(x, na.rm = TRUE, ...){
  if (na.rm) x <- na.omit(x)
  x <- cut(x, ...)
  lv <- levels(addNA(as.factor(x), ifany = TRUE))
  if (any(is.na(lv))) lv <- c(NA, lv[!is.na(lv)])
  x2 <- factor(x, levels = lv, exclude = NULL)
  # one percentage per range ('auto' would pick the binary method for 2 ranges)
  pct(x2, method = 'fct', na.rm = FALSE)
}

# Reverse levels
# For public use, please use forcats::fct_rev
._lv_rev_ <- function(x){
  new_x <- factor(x, levels=rev(levels(x)), exclude=NULL)
  attributes(new_x) <- utils::modifyList(attributes(x), attributes(new_x))
  new_x
}
