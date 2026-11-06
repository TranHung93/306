#' Transform an object to its explicit form
#' @description A function to transform an object to its explicit form if possible
#' @param x An object
#' @param ... additional arguments passed to methods.
#' @return The explicit form of `x`; see the methods.
#' @seealso \link{explicit.lm}
#' @export
explicit <- function(x, ...){
  UseMethod('explicit')
}

#' Transform a model to its explicit form
#' @description
#' A function to transform an lm model formula to its explicit form.
#' This is useful when you want to use stats::drop1 to drop additional terms in interaction models.
#' @param x An object of class "lm"
#' @param ... unused. Passing the model as `fit = ` is deprecated, use `x` instead.
#' @examples
#' iris.model <- lm(Sepal.Width ~ Sepal.Length*Petal.Width, data=iris)
#' explicit(iris.model)
#' @return A model with explicit formula
#' @seealso \link[stats]{add1}
#' @export
explicit.lm <- function(x, ...){
  if (missing(x)) {
    dots <- list(...)
    if (is.null(dots$fit)) rlang::abort("Argument `x` is missing, with no default.")
    lifecycle::deprecate_warn("0.1.6", "explicit.lm(fit)", "explicit.lm(x)")
    x <- dots$fit
  }
  ._explicit_lm(x, .meta = FALSE)
}

._explicit_lm <- function(lm, .meta = FALSE, ...)
{
  formula <- formula(lm)
  mf <- match.call(expand.dots = FALSE)
  m <- match(c("lm", "data", "weights", "na.action",
               "offset"), names(mf), 0L)
  mf <- mf[c(1, m)]
  mf$drop.unused.levels <- TRUE
  # browser()
  mf[[1L]] <- as.name("model.frame")
  names(mf)[2L] <- "formula"
  mf <- eval(mf, parent.frame())
  y <- model.response(mf)
  x <- model.matrix(lm)
  new_data <- cbind(mf, model.matrix(lm)[,!colnames(x) %in% c('(Intercept)', colnames(mf)), drop=FALSE])
  x_names <- paste0('`', gsub('(^`)|(`$)', '', colnames(x)[-1]), '`')
  names(x_names) <- colnames(x)[-1]
  # browser()
  new_fml <- formula(call('~',
                          parse(text = paste(x_names,
                                             collapse = '+'),
                                keep.source = FALSE)[[1L]]
                          ))
  new_lm <- update(lm, new_fml, data = new_data)
  new_lm$call$data <- lm$call$data
  if (.meta) attr(new_lm, 'name.map') <- structure(names(x_names), names = unname(x_names))
  return(new_lm)
}
