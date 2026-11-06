#' Relevel in correspondence to another factor
#'
#' @description Function to relevel a variable in accordance to a another variable of class "factor".
#' @return An object of the same class as the input
#' @examples
#' df <- data.frame(g = factor(c("b", "a", "b", "a"), levels = c("b", "a")),
#'                  x = c("x1", "y1", "x2", "y2"))
#' levels(simple_relevel(df, x, by = g)$x)
#' simple_relevel(c("p", "q", "r"), by = factor(c("B", "A", "B"), levels = c("B", "A")),
#'                map = list(A = "q", B = c("p", "r")), value = "levels")
#' @export
simple_relevel <- function(x, ...){
  UseMethod('simple_relevel')
}

#' @rdname simple_relevel
#'
#' @param x For the data.frame method: a data.frame (passing it as `data = ` is deprecated).
#' For the default method: a vector that will be relevelled.
#' @param by For the data.frame method: an unquoted variable name the relevelling process will
#' base on. For the default method: a vector that the relevelling process will base on.
#' @param ... For the data.frame method: unquoted variable names that will be relevelled.
#' Unused by the default method.
#' @export
simple_relevel.data.frame <- function(x, ..., by){
  #... variables to relevel
  # by: variable that is based on
  dep.vars <- rlang::enquos(...)
  if ("data" %in% names(dep.vars)) {
    # deprecated form simple_relevel.data.frame(data = df, var, by = ...):
    # `data` lands in `...` and the first variable lands in `x`
    lifecycle::deprecate_warn("0.1.6", "simple_relevel.data.frame(data)",
                              "simple_relevel.data.frame(x)")
    data.quo <- dep.vars[["data"]]
    dep.vars <- dep.vars[names(dep.vars) != "data"]
    if (!missing(x)) dep.vars <- c(list(rlang::enquo(x)), as.list(dep.vars))
    x <- rlang::eval_tidy(data.quo)
  }
  data <- x
  dep.vars.2 <- sapply(dep.vars, function(dep.var) rlang::quo_name(dep.var))
  by <- rlang::enquo(by)
  by.2 <- rlang::quo_name(by)
  # browser()
  if (!is.factor(data[[by.2]])) data[[by.2]] <- as.factor(data[[by.2]])
  for(i in seq_along(dep.vars.2)){
    # browser()
    dep.var.2 <- dep.vars.2[[i]]
    dep.var <- dep.vars[[i]]
    isolated.data <-
      data[c(by.2, dep.var.2)] %>%
      unique() %>% #remove all dup
      arrange({{dep.var}}) %>% arrange({{by}})# first, sort the data by dep.var to retain prev levels, second by "by"
    dep.var.lv <- isolated.data[[dep.var.2]]
    # browser()
    data[[dep.var.2]] <- factor(data[[dep.var.2]], levels = dep.var.lv)
  }
  data
}

#' @rdname simple_relevel
#'
#' @param map a list that links by to x in the form of list(by.1 = c(x1.1, x1.2...), by.2 = c(x2.1, x2.2...))
#' or a data.frame with two columns "from" and "to" serving the same purpose.
#' @param value a string: whether to return
#'
#' - "levels": new levels only
#'
#' - "unsorted" (default): an unsorted, relevelled factor
#'
#' - "sorted": a sorted, relevelled factor
#' @return A factor or a numeric vector of order
#' @export
simple_relevel.default <- function(x, by, map, value = c('unsorted', 'sorted', 'levels'), ...){
  value <- match.arg(value)
  if (!is.data.frame(map)){
    map <- do.call(rbind,
                   lapply(seq_along(map),
                          function(i){
                            .map <- map[i]
                            name <- names(.map)
                            data.frame(from = rep(name, length(map[[i]])), to = map[[i]])
                          }))
  }
  # browser()
  stopifnot(setequal(unique(x), map$to))
  stopifnot(setequal(unique(by), map$from))
  map$from <- factor(map$from, levels = levels(by))
  X <- data.frame(to = x)
  data <- merge(X, map, by = 'to', all.x = TRUE)
  to <- simple_relevel.data.frame(data, to, by = from)$to
  if (value == 'sorted') return(to)
  lv <- levels(to)
  if (value == 'levels') return(lv)
  factor(x, levels = lv)
}

#' Sort a vector in a user-defined order
#' @description A function to sort a vector in an user-defined order
#' @param x A vector to be sorted
#' @param order A manually defined order vector
#' @return A vector
#' @export
simple_sort <- function(x, order = levels(as.factor(x))){
  stopifnot(length(order) == length(unique(x)))
  x_factor <- factor(x, levels = order)
  x_sort <- sort(x_factor)
  x_retrieve <- as(levels(x_sort), typeof(x))[x_sort]
  attributes(x_retrieve) <- attributes(x)
  x_retrieve
}
