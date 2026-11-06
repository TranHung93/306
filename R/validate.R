# Input validation helpers ----------------------------------------------------
#
# All errors raised here have class "c306_input_error" so that callers and
# tests can tell a deliberate input error from an unexpected failure. The
# `arg` defaults capture the name of the argument as written by the caller,
# and `call` points the error at the exported function the user called.

c306_abort <- function(message, ..., call = rlang::caller_env()) {
  rlang::abort(message, class = "c306_input_error", ..., call = call)
}

obj_type <- function(x) {
  if (is.null(x)) "NULL" else paste0("an object of class <", class(x)[[1]], ">")
}

check_data_frame <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env(),
                             allow_empty = FALSE) {
  if (!is.data.frame(x)) {
    c306_abort(sprintf("`%s` must be a data frame, not %s.", arg, obj_type(x)), call = call)
  }
  if (!allow_empty && nrow(x) == 0) {
    c306_abort(sprintf("`%s` has no rows.", arg), call = call)
  }
  invisible(x)
}

check_formula <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env(),
                          sides = c("any", "two", "one")) {
  sides <- match.arg(sides)
  if (!inherits(x, "formula")) {
    c306_abort(sprintf("`%s` must be a formula, not %s.", arg, obj_type(x)), call = call)
  }
  if (sides == "two" && length(x) < 3) {
    c306_abort(sprintf("`%s` must be a two-sided formula (`lhs ~ rhs`).", arg), call = call)
  }
  if (sides == "one" && length(x) != 2) {
    c306_abort(sprintf("`%s` must be a one-sided formula (`~ rhs`).", arg), call = call)
  }
  invisible(x)
}

check_flag <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!(is.logical(x) && length(x) == 1 && !is.na(x))) {
    c306_abort(sprintf("`%s` must be a single TRUE or FALSE.", arg), call = call)
  }
  invisible(x)
}

check_string <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env(),
                         allow_null = FALSE) {
  if (allow_null && is.null(x)) return(invisible(x))
  if (!(is.character(x) && length(x) == 1 && !is.na(x))) {
    c306_abort(sprintf("`%s` must be a single string.", arg), call = call)
  }
  invisible(x)
}

check_character <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env(),
                            allow_null = FALSE) {
  if (allow_null && is.null(x)) return(invisible(x))
  if (!(is.character(x) && length(x) >= 1 && !anyNA(x))) {
    c306_abort(sprintf("`%s` must be a character vector without missing values.", arg), call = call)
  }
  invisible(x)
}

# A single number, optionally a whole number, within [min, max]
check_number <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env(),
                         min = -Inf, max = Inf, whole = FALSE, allow_null = FALSE,
                         allow_inf = FALSE) {
  if (allow_null && is.null(x)) return(invisible(x))
  ok <- is.numeric(x) && length(x) == 1 && !is.na(x) && (allow_inf || is.finite(x)) &&
    x >= min && x <= max && (!whole || !is.finite(x) || x == round(x))
  if (!ok) {
    what <- if (whole) "a single whole number" else "a single number"
    range <- if (is.finite(min) && is.finite(max)) sprintf(" between %s and %s", min, max)
             else if (is.finite(min)) sprintf(" >= %s", min)
             else if (is.finite(max)) sprintf(" <= %s", max)
             else ""
    c306_abort(sprintf("`%s` must be %s%s.", arg, what, range), call = call)
  }
  invisible(x)
}

# All variables used by a formula (or listed in `vars`) must be columns of data
check_columns <- function(data, vars, data_arg = "data", call = rlang::caller_env()) {
  missing <- setdiff(vars, names(data))
  if (length(missing)) {
    c306_abort(sprintf("Variable(s) not found in `%s`: %s.", data_arg,
                       paste0("`", missing, "`", collapse = ", ")), call = call)
  }
  invisible(data)
}

# A fitted glm with a binomial family or a logit link
check_logistic <- function(fit, arg = rlang::caller_arg(fit), call = rlang::caller_env()) {
  fam <- if (inherits(fit, "glm")) fit$family else NULL
  ok <- inherits(fam, "family") && (identical(fam$family, "binomial") || identical(fam$link, "logit"))
  if (!ok) {
    c306_abort(sprintf("This function only works for logistic regression: `%s` must be a binomial/logit `glm`, not %s.",
                       arg, obj_type(fit)), call = call)
  }
  invisible(fit)
}

check_huxtable <- function() {
  rlang::check_installed("huxtable", reason = "to build huxtable tables.")
}
