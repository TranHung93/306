# create baseline table ---------------------------------------------------

#' Create baseline table
#'
#' @description A function to create a simple summary baseline table.
#'
#' @param formula a formula specifies variables for rows, variable for column and third-dimension variable.
#'
#' If formula is in the form of x+y ~ a, the function will summary x and y with respects to each value of a
#'
#' If formula is in the form of x+y ~ a|z, the function will summary z with respects to each value of \{a, x\} and \{a, y\}
#' @param data a data frame to derive baseline table from.
#' @param bycol a logical value specifies whether the summary will be by column or by row.
#' @param pooledGroup a logical value specifies whether to pool all subgroups of column variable.
#' @param keepEmptyGroup a logical value specifying whether should keep empty groups
#' @param keepEmptyString a logical value specifying whether should keep empty string values in categorical variables.
#' @param statistics a character specifies summary statistics for continuous row variables.
#' @param cont a vector specifies whether each row variables is continuous.
#' @param cat a vector specifies whether each row variables is categorical.
#' @param fullfreq a logical value specifies whether to show total frequency as a denominator
#' @param digits.numeric a list of characters to specify the numerical conditions for how many decimal places of summarizing statistics will display
#' @param digits.nonnumeric a list of characters to specify the nonnumerical conditions for how many decimal places of summarizing statistics will display
#' @param digits.name a list of names of variables to specify for how many decimal places of summarizing statistics will display for those variable names
#' @param test a logical value specifies whether a statistical test will be performed to compare between treatment arms.
#' @param pdigits a number specifies number of significant digits for p value.
#' @param pcutoff a number specifies threshold value of p value to be displayed as "< pcutoff".
#' @param chisq.test a logical value specifies whether Chi-squared test or Fisher's exact test will be used to compare between treatment arms.
#' @param correct a parameter for chisq.test().
#' @param simulate.p.value a parameter for chisq.test() and fisher.test().
#' @param B a parameter for chisq.test() and fisher.test().
#' @param workspace a parameter for fisher.test().
#' @param hybrid a parameter for fisher.test().
#' @param footer a vector of strings to be used as footnote of table.
#' @param flextable a logical value specifies whether output will be a flextable-type table.
#' @param bg a character specifies color of the odd rows in the body of flextable-type table.
#' @param matrix.raw a logical values specifies whether output will be a draw dataframe.
#'
#' @return If `flextable = TRUE`, a flextable. If `matrix.raw = TRUE`, the summary matrix without
#'   header and footer. Otherwise a list of class `ss_baseline` with elements `table` (the table
#'   as a character matrix, header rows first) and `footer`; use [ss_flextable()] or
#'   [ss_huxtable()] to render it later.
#' @examples
#' bl <- read.csv(system.file("extdata", "baseline_data.csv", package = "C306"))
#'
#' # summary by arm, with tests
#' tab <- sstable.baseline(age + sex + bmi ~ Arm, data = bl, test = TRUE)
#' tab$table
#' tab$footer
#'
#' # median (Q1-Q3), a "Total" column, and a flextable
#' sstable.baseline(age + sex + icudays ~ Arm, data = bl, statistics = "median (Q1-Q3)",
#'                  pooledGroup = TRUE, flextable = TRUE)
#'
#' # proportion of deaths (outcome == 4) by sex within each arm
#' bl$died <- bl$outcome == 4
#' sstable.baseline(sex ~ Arm | died, data = bl)$table
#' @export
sstable.baseline <- function(formula, data, bycol = TRUE, pooledGroup = FALSE, keepEmptyGroup = FALSE,
                             statistics = "mean; median (Q1-Q3)", cont = NULL, cat = NULL, fullfreq = FALSE,
                             digits.numeric = c("mean(x, na.rm = TRUE) > 10 ~ 0",
                                                 "mean(x, na.rm=T) > 1 & mean(x, na.rm=T) <= 10 ~ 1",
                                                 "mean(x, na.rm=T) <= 1 ~ 2"),
                             digits.nonnumeric = c("!is.numeric(x) ~ 0"), digits.name = NULL,
                             test = FALSE, pdigits = 3, pcutoff = 0.0001,
                             chisq.test = FALSE, correct = FALSE, simulate.p.value = FALSE, B = 2000,
                             workspace = 1000000, hybrid = FALSE, keepEmptyString = FALSE,
                             footer = NULL, flextable = FALSE, bg = "#F2EFEE", matrix.raw = FALSE) {

  ## validate inputs
  check_formula(formula)
  if (length(formula) < 3) {
    c306_abort("Missing row-wise variable(s): `formula` must be of the form `rows ~ column`.")
  }
  check_data_frame(data)
  check_columns(data, all.vars(formula))
  for (flag in c("bycol", "pooledGroup", "keepEmptyGroup", "fullfreq", "test", "chisq.test",
                 "correct", "simulate.p.value", "hybrid", "keepEmptyString", "flextable",
                 "matrix.raw")) {
    check_flag(get(flag), arg = flag)
  }
  check_string(statistics)
  check_character(cont, allow_null = TRUE)
  check_character(cat, allow_null = TRUE)
  check_character(digits.numeric)
  check_character(digits.nonnumeric)
  check_character(digits.name, allow_null = TRUE)
  check_number(pdigits, min = 1, whole = TRUE)
  check_number(pcutoff, min = 0, max = 1)
  check_number(B, min = 1, whole = TRUE)
  check_character(footer, allow_null = TRUE)
  check_string(bg)

  ## data, row variables (x), column variable (y), third dimension (z)
  prep <- ._baseline_prepare(formula, data, keepEmptyGroup = keepEmptyGroup, cont = cont,
                             cate = cat, bycol = bycol)
  data <- prep$data; dat <- prep$dat; x <- prep$x; xlabel <- prep$xlabel
  y <- prep$y; z <- prep$z; continuous <- prep$continuous; varlist <- prep$varlist

  ## digits - hungtt
  # Function to convert formulas and results to the desired format
  convert_to_function_list <- function(formula_list_numeric, formula_list_non_numeric,
                                       formula_list_name) {
    # Helper function to parse and convert a single formula and result
    convert_single <- function(fml_result) {
      # Split the formula and result
      parts <- strsplit(fml_result, "~")[[1]]
      formula_str <- trimws(parts[1])
      result <- as.numeric(trimws(parts[2]))

      # Create the function from the formula string
      formula_function <- eval(parse(text = paste0("function(x) { ", formula_str, " }")))

      # Return the list containing the function and result
      list(formula_function, result)
    }

    # Apply the conversion to each element in the list for numeric criteria
    converted_list_numeric <- lapply(formula_list_numeric, convert_single)

    # Apply the conversion to each element in the list for non-numeric criteria
    converted_list_non_numeric <- lapply(formula_list_non_numeric, convert_single)

    # Apply the conversion to each element in the list for non-numeric criteria
    converted_list_name <- lapply(formula_list_name, convert_single)


    return(list(numeric = converted_list_numeric, non_numeric = converted_list_non_numeric,
                digits_name = converted_list_name))
  }


  digits.check <- function(df, criteria_results_numeric, criteria_results_non_numeric,
                           criteria_results_name) {
    # Initialize a vector to store the results
    digits <- numeric(ncol(df))

    # Criteria may refer to columns by name: evaluate them in a local
    # environment holding the columns (never in the global environment).
    with_columns <- function(fn) {
      environment(fn) <- list2env(as.list(df), parent = environment(fn))
      fn
    }
    criteria_results_numeric <- lapply(criteria_results_numeric, function(cr) list(with_columns(cr[[1]]), cr[[2]]))
    criteria_results_non_numeric <- lapply(criteria_results_non_numeric, function(cr) list(with_columns(cr[[1]]), cr[[2]]))
    criteria_results_name <- lapply(criteria_results_name, function(cr) list(with_columns(cr[[1]]), cr[[2]]))

  # Iterate over each variable in the data frame
  for (i in seq_along(df)) {
    variable_name <- colnames(df)[i]
    variable <- df[[i]]

      # Determine if the variable is numeric or not
      if (is.numeric(variable)) {
        criteria_results <- criteria_results_numeric
      } else {
        criteria_results <- criteria_results_non_numeric
      }

      # Assume that we set `matched` to FALSE initially
      matched <- FALSE

      # Check each criterion/result pair for the appropriate type
      for (criterion_result in criteria_results) {
        criterion <- criterion_result[[1]]
        result <- criterion_result[[2]]

        # Apply the criterion function to the variable
        if (criterion(variable)) {
          digits[i] <- result
          matched <- TRUE
          break
        }
      }

      criteria_results <- criteria_results_name
      # Check each variable if it is listed in the digits.name
      for (criterion_result in criteria_results) {
        criterion <- criterion_result[[1]]
        result <- criterion_result[[2]]

        # Apply the criterion function to the variable
        if (criterion(variable_name)) {
          digits[i] <- result
          matched <- TRUE
          break
        }
      }

      # If no criteria matched, set to 0
      if (!matched) {
        digits[i] <- 0
      }
    }

    return(digits)
  }

  criteria <- convert_to_function_list(digits.numeric, digits.nonnumeric, digits.name)
  digits <- digits.check(x, criteria[[1]], criteria[[2]], criteria[[3]])

  ## if pooledGroup
  if (pooledGroup) {
    x <- rbind(x, x)
    ypool <- ifelse("total" %in% tolower(levels(y)), "pooledGroup", "Total")
    y <- factor(c(as.character(y), rep(ypool, nrow(dat))), levels = c(levels(y), ypool), exclude = NULL)
    z <- if (!is.null(z)) factor(c(z, z), levels = unique(na.omit(z))) else NULL
  }
  # else{
  #   z <- if (!is.null(z)) factor(z, levels = unique(na.omit(z))) else NULL
  # }

  ## get variable name
  varname <- if (ncol(xlabel) == 1) getlabel(xlabel[, 1]) else getlabel(xlabel)


  # Row label of each variable: its "label" attribute, or else its name
  label_list <- ._baseline_labels(varlist, data)

  ## get summary
  value <- do.call(rbind,
                   lapply(1:ncol(x), function(i) {
                     sstable.baseline.each(varname = varname[i][[1]], label_list = label_list[i][[1]],
                                           x = x[, i], y = y, z = z, bycol = bycol,
                                           pooledGroup = pooledGroup, statistics = statistics,
                                           continuous = continuous[i], fullfreq = fullfreq, test = test,
                                           digits = digits[i], pdigits = pdigits, pcutoff = pcutoff,
                                           chisq.test = chisq.test, correct = correct,
                                           workspace = workspace, hybrid = hybrid,
                                           simulate.p.value = simulate.p.value, B = B)
                   }))

  ## indication of unestimatable values
  value_dim <- dim(value)
  value <- apply(value, 2, function(x) ifelse(is.na(x) | x %in% c("NA (NA, NA)", "0/0 (NaN%)"), "-", x))
  dim(value) <- value_dim

  # add option to call dataframe before adding header, footer -hungtt
  if (matrix.raw) { tab <- value}
  else { tab <- sstable.baseline.edit(value = value, formula = formula, data =data, bycol = bycol, pooledGroup = pooledGroup , keepEmptyGroup = keepEmptyGroup,
                                      statistics = statistics, cont = cont, cate = cat, fullfreq = fullfreq, digits = digits,
                                      test = test, pdigits = pdigits, pcutoff = pcutoff, keepEmptyString = keepEmptyString,
                                      chisq.test = chisq.test, correct = correct, simulate.p.value = simulate.p.value, B = B,
                                      workspace = workspace, hybrid = hybrid, footer = footer, flextable = flextable, bg = bg)
  }

  return (tab)
}


# Preprocessing shared by sstable.baseline() and sstable.baseline.edit():
# extract the variables of `formula` from `data`; order the levels of the
# column variable y (reversed, as in sstable.ae()); decide which row variables
# are continuous (`cont` / `cate`, else automatically) and make the others
# factors; make a discrete third-dimension variable z a factor.
._baseline_prepare <- function(formula, data, keepEmptyGroup, cont, cate, bycol,
                               call = rlang::caller_env()) {
  ## get information from formula
  info <- sstable.formula(formula, call = call)

  ## strip the tibble class which causes issue - trinhdhk
  data <- as.data.frame(data)

  ## get data
  dat <- model.frame(info$formula0, data = data, na.action = NULL)
  x <- xlabel <- dat[, info$index$x, drop = FALSE]
  y <- if (info$index$y > 0) dat[, info$index$y] else NULL
  z <- if (info$index$z > 0) dat[, info$index$z] else NULL

  ## y must be categorical variable
  if (!is.null(y)) {
    if (all(!c("character", "factor", "logical") %in% class(y)) |
        (any(c("numeric", "integer") %in% class(y)) & length(unique(na.omit(y))) > 5)) {
      c306_abort("Column-wise variable must be categorical (character, factor, logical, or numeric with at most 5 values).",
                 call = call)
    }
    if (is.factor(y)){
      ### [trinhdhk] 2024-04: reverse level of y for better summary
      y <- ._lv_rev_(y)
      if (!keepEmptyGroup) y <- droplevels(y)
      y <- addNA(y, ifany = TRUE)
    } else {
      ### reversed like factor arms (and like sstable.ae)
      y <- factor(as.character(y), levels = sort(unique(as.character(y)), decreasing = TRUE, na.last = TRUE), exclude = NULL)
    }
  } else {
    y <- factor(rep("Total", nrow(dat)))
  }

  ## determine type of x (argument: cont and cate)
  varlist <- getvar(formula) #hungtt
  varlist <- varlist[-length(varlist)] #remove the y name

  # Convert varlist, cont, and cate to lowercase for case-insensitive comparison
  varlist_lower <- tolower(varlist)
  cont_lower <- tolower(cont)
  cate_lower <- tolower(cate)

  continuous <- ifelse(varlist_lower %in% cont_lower, TRUE, ifelse(varlist_lower %in% cate_lower, FALSE, NA)) #assign var type

  continuous <- sapply(1:ncol(x), function(i) {
    out <- ifelse(is.na(continuous[i]),
                  ifelse(any(c("factor", "character", "logical") %in% class(x[, i])) |
                           (any(c("numeric", "integer") %in% class(x[, i])) & length(unique(na.omit(x[, i]))) <= 5), FALSE, TRUE),
                  continuous[i])
    return(out)
  })

  for (i in (1:ncol(x))) {
    if (continuous[i] == FALSE & !is.factor(x[, i])) x[, i] <- factor(x[, i], levels = sort(unique(na.omit(x[, i]))))
  }

  ## if z exists, x must be categorical
  if (!is.null(z) & any(continuous == TRUE))
    c306_abort("Row-wise variable must be categorical when a third dimension variable exists.", call = call)

  ## if use by-row layout, x must be categorical
  if (bycol == FALSE & any(sapply(1:ncol(x), function(i) is.factor(x[,i])) == FALSE))
    c306_abort("Row-wise variable must be categorical in by-row layout (`bycol = FALSE`).", call = call)

  ## determine type of z
  if (!is.null(z)) {
    zdiscrete <- any(c("factor", "character", "logical") %in% class(unclass(z))) |
      (any(c("numeric", "integer") %in% class(unclass(z))) & length(unique(na.omit(z))) <= 5)
    if (zdiscrete) z <- factor(z, levels = unique(na.omit(z)))
  }

  list(info = info, data = data, dat = dat, x = x, xlabel = xlabel, y = y, z = z,
       continuous = continuous, varlist = varlist)
}

# Row label of each variable: its "label" attribute if non-empty, else its name.
# Shared by sstable.baseline() and sstable.baseline.edit() so that both build
# exactly the same labels (sstable.baseline.edit() matches rows on them).
._baseline_labels <- function(vars, data) {
  vapply(vars, function(v) {
    lbl <- attr(data[[v]], "label")
    if (!is.null(lbl) && length(lbl) && !is.na(lbl[[1]]) && nzchar(lbl[[1]])) {
      as.character(lbl[[1]])
    } else {
      v
    }
  }, character(1), USE.NAMES = FALSE)
}

sstable.baseline.each <- function(varname, label_list, x, y, z, bycol = TRUE, pooledGroup = FALSE,
                                  statistics = "mean, median (Q1-Q3)", continuous = NA, fullfreq = TRUE, test = FALSE,
                                  digits = 1, pdigits = pdigits, pcutoff = 0.0001, chisq.test = FALSE, correct = FALSE, workspace = 1000000,
                                  hybrid = FALSE, simulate.p.value = FALSE, B = 2000) {

  mycont.summary <- function(x, y, z) {
    ngroup <- length(levels(y))

    if (is.null(z)) {
      summarystat.nice <- by(unclass(x), y, contSummary, statistics = statistics, digits = digits, n = FALSE)
      n <- table(y[!is.na(x)])

      result <- matrix("", ncol = ngroup * 2 + 1, nrow = 1)
      result[1, seq(2, ncol(result), by = 2)] <- n

      # Check if summarystat.nice has more than one value per row and flatten it if necessary
      if (length(summarystat.nice) > 1) {
        result[1, seq(3, ncol(result), by = 2)] <- unlist(lapply(summarystat.nice, function(x) paste(x, collapse = ", ")))
      } else {
        result[1, seq(3, ncol(result), by = 2)] <- unlist(summarystat.nice)
      }

    } else {
      summarystat.nice <- by(unclass(z), list(x, y), contSummary, statistics = statistics, digits = digits, n = FALSE)
      n <- table(x, y)

      result <- matrix("", ncol = ngroup * 2 + 1, nrow = length(levels(x)) + 1)
      result[1, seq(2, ncol(result), by = 2)] <- apply(n, 2, sum)
      result[2:nrow(result), seq(2, ncol(result), by = 2)] <- n
      result[2:nrow(result), 1] <- paste0("- ", levels(x), " (n = ", apply(n, 1, sum), ")")

      # Check if summarystat.nice has more than one value per row and flatten it if necessary
      if (length(summarystat.nice) > 1) {
        result[2:nrow(result), seq(3, ncol(result), by = 2)] <- unlist(lapply(summarystat.nice, function(x) paste(x, collapse = ", ")))
      } else {
        result[2:nrow(result), seq(3, ncol(result), by = 2)] <- unlist(summarystat.nice)
      }
    }

    if (test == TRUE & ngroup > 1) {
      # overall Kruskal-Wallis test for group differences
      if (is.null(z)) {
        m <- 1:(length(x) * (1 - 0.5 * as.numeric(pooledGroup)))
        pval <- tryCatch(format.pval(kruskal.test(x = x[m], g = y[m])$p.value,
                                     eps = pcutoff, digits = pdigits, scientific = FALSE),
                         error = function(c) NA)
        result <- cbind(result, pval)
      } else {
        pval <- sapply(1:length(levels(x)), function(i) {
          q <- which(x == levels(x)[i])
          if (length(q) == 0) {
            out <- NA
          } else {
            m <- q[q %in% 1:(length(z) * (1 - 0.5 * as.numeric(pooledGroup)))]
            out <- tryCatch(format.pval(kruskal.test(x = z[m], g = y[m])$p.value,
                                        eps = pcutoff, digits = pdigits, scientific = FALSE),
                            error = function(c) NA)
          }
          return(out)
        })
        result <- cbind(result, c("", pval))
      }

    }

    return(result)
  }

  mycat.summary <- function(x, y, z, fullfreq = fullfreq) {
    ngroup <- length(levels(y))
    result <- matrix("", ncol = ngroup * 2 + 1, nrow = length(levels(x)) + 1)

    if (is.null(z)) {
      ta <- table(x, y)
      n <- if (bycol) {
        apply(ta, 2, sum)
      } else {
        if (pooledGroup) {apply(ta[, -ncol(ta)], 1, sum)} else {apply(ta, 1, sum)}
      }
      ta.prop <- if (bycol) {
        unclass(ta/rep(n, each = length(levels(x))))
      } else {
        unclass(ta/rep(n, ngroup))
      }

      ta.nice <- matrix(paste0(" (", formatC(100 * unclass(ta.prop), digits, format = "f"), "%)"),
                        nrow = nrow(ta), ncol = ncol(ta))
      result[2:nrow(result), 1] <- paste0("- ", levels(x))
      if (bycol) {
        result[1, seq(2, ncol(result), by = 2)] <- n
        if (fullfreq) {
          result[2:nrow(result), seq(3, ncol(result), by = 2)] <- paste0(ta, "/", rep(apply(ta, 2, sum), each = length(levels(x))), ta.nice)
        } else {
          result[2:nrow(result), seq(3, ncol(result), by = 2)] <- paste0(ta, ta.nice)
        }

      } else {
        result[2:nrow(result), 1] <- paste0(result[2:nrow(result), 1], " (n=", n, ")")
        if (fullfreq) {
          result[2:nrow(result), seq(3, ncol(result), by = 2)] <- paste0(ta, "/", rep(n, ngroup), ta.nice)
        } else {
          result[2:nrow(result), seq(3, ncol(result), by = 2)] <- paste0(ta, ta.nice)
        }

      }
    } else {
      tn <- table(x, y)
      tn2 <- if (pooledGroup) {tn[, -ncol(tn)]} else {tn}
      ta.nice <- matrix(by(z, list(x, y), function(z) {
        ta <- sum(z == TRUE, na.rm = TRUE)
        n <- length(na.omit(z))
        if (fullfreq) {
          output <- paste0(ta, "/", n, " (", formatC(100 * (ta/n), digits, format = "f"), "%)")
        } else {
          output <- paste0(ta, " (", formatC(100 * (ta/n), digits, format = "f"), "%)")
        }
        return(output)
      }), ncol = ngroup)
      result[2:nrow(result), 1] <- paste0("- ", levels(x), " (n=", apply(tn2, 1, sum), ")")
      result[2:nrow(result), seq(3, ncol(result), by = 2)] <- ta.nice
      result[1, seq(2, ncol(result), by = 2)] <- apply(tn, 2, sum)
      result[2:nrow(result), seq(2, ncol(result), by = 2)] <- tn
    }

    if (test == TRUE & ngroup > 1) {
      if (is.null(z)) {
        m <- 1:(length(x) * (1 - 0.5 * as.numeric(pooledGroup)))
        pval <- if (chisq.test) {
          tryCatch(format.pval(chisq.test(x = x[m], y = y[m], correct = correct,
                                          simulate.p.value = simulate.p.value, B = B)$p.value,
                               eps = pcutoff, digits = pdigits, scientific = FALSE),
                   error = function(c) NA)
        } else {
          tryCatch(format.pval(fisher.test(x = x[m], y = y[m], workspace = workspace, hybrid = hybrid,
                                           simulate.p.value = simulate.p.value, B = B)$p.value,
                               eps = pcutoff, digits = pdigits, scientific = FALSE),
                   error = function(c) NA)
        }
        result <- cbind(result, "")
        result[1,ngroup * 2 + 2] <- pval
      } else {
        pval <- sapply(1:length(levels(x)), function(i) {
          q <- which(x == levels(x)[i])
          if (length(q) == 0) {
            out <- NA
          } else {
            m <- q[q %in% 1:(length(z) * (1 - 0.5 * as.numeric(pooledGroup)))]
            out <- if (chisq.test) {
              tryCatch(format.pval(chisq.test(x = z[m], y = y[m], correct = correct,
                                              simulate.p.value = simulate.p.value, B = B)$p.value,
                                   eps = pcutoff, digits = pdigits, scientific = FALSE),
                       error = function(c) NA)
            } else {
              tryCatch(format.pval(fisher.test(x = z[m], y = y[m], workspace = workspace, hybrid = hybrid,
                                               simulate.p.value = simulate.p.value, B = B)$p.value,
                                   eps = pcutoff, digits = pdigits, scientific = FALSE),
                       error = function(c) NA)
            }
          }
          return(out)
        })
        result <- cbind(result, c("", pval))
      }
    }
    result
  }

  if (is.null(z)) {
    out <- if (continuous) {
      mycont.summary(x = x, y = y, z = NULL)
    } else {
      mycat.summary(x = x, y = y, z = NULL, fullfreq = fullfreq)
    }
  } else {
    out <- if (is.factor(z)) {
      mycat.summary(x = x, y = y, z = z, fullfreq = fullfreq)
    } else {
      mycont.summary(x = x, y = y, z = z)
    }
  }



  out[1, 1] <- label_list
  return(out)
}
