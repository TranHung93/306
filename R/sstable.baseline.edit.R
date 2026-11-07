# create baseline table ---------------------------------------------------

#' Create baseline table
#'
#' @description Adds the header and footer to the summary matrix built by
#'   [sstable.baseline()] (with `matrix.raw = TRUE`), optionally as a flextable.
#'   Usually called by [sstable.baseline()] itself.
#'
#' @param value the summary matrix returned by `sstable.baseline(..., matrix.raw = TRUE)`.
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
#' @param cate a vector specifies whether each row variables is categorical.
#' @param fullfreq a logical value specifies whether to show total frequency as a denominator.
#' @param digits a number specifies number of significant digits for numeric statistics.
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
#'
#' @return A flextable if `flextable = TRUE`, otherwise a list of class `ss_baseline` with
#'   elements `table` and `footer` (see [sstable.baseline()]).
#' @examples
#' bl <- read.csv(system.file("extdata", "baseline_data.csv", package = "C306"))
#' raw <- sstable.baseline(age + sex ~ Arm, data = bl, matrix.raw = TRUE)
#' # ... edit `raw` here if needed, then add the header and footer:
#' tab <- sstable.baseline.edit(raw, age + sex ~ Arm, data = bl)
#' tab$table
#' @export
sstable.baseline.edit <- function(value, formula, data, bycol = TRUE, pooledGroup = FALSE, keepEmptyGroup = FALSE,
                                  statistics = "mean, median (Q1-Q3)", cont = NULL, cate = NULL, fullfreq = TRUE, digits = 1,
                                  test = FALSE, pdigits = 3, pcutoff = 0.0001, keepEmptyString = T,
                                  chisq.test = FALSE, correct = FALSE, simulate.p.value = FALSE, B = 2000,
                                  workspace = 1000000, hybrid = FALSE, footer = NULL, flextable = FALSE, bg = "#F2EFEE") {
  ## data, row variables (x), column variable (y), third dimension (z)
  prep <- ._baseline_prepare(formula, data, keepEmptyGroup = keepEmptyGroup, cont = cont,
                             cate = cate, bycol = bycol)
  data <- prep$data; dat <- prep$dat; x <- prep$x
  y <- prep$y; z <- prep$z; continuous <- prep$continuous

  ## digits
  if (length(digits) == 1) {
    digits <- rep(digits, ncol(x))
  } else {
    if (length(digits) != ncol(x)) c306_abort("`digits` must have length 1 or one value per row-wise variable.")
  }

  ## if pooledGroup
  if (pooledGroup) {
    x <- rbind(x, x)
    ypool <- ifelse("total" %in% tolower(levels(y)), "pooledGroup", "Total")
    y <- factor(c(as.character(y), rep(ypool, nrow(dat))), levels = c(levels(y), ypool), exclude = NULL)
    z <- if (!is.null(z)) factor(c(z, z), levels = unique(na.omit(z))) else NULL
  }

  ## get variable name
  ## (same labels as the first column built by sstable.baseline)
  varname <- unique(._baseline_labels(getvar(formula)[seq_len(ncol(x))], data))

  # update order of variable customize for sstable.baseline.edit - hungtt
  value <- as.data.frame(value)
  dummy_df <- data.frame(V1= varname, order =seq_along(varname)*1000)
  value <- full_join(value, dummy_df, by = "V1")

  for (i in seq_len(nrow(value)))
    {if (is.na(value[i,ncol(value)])) {value[i,ncol(value)] <- (value[i-1,ncol(value)]) + 1}}

  # Identify duplicated values in column V1 that are also in varname
  duplicates_to_keep <- value %>%
    filter(V1 %in% varname) %>%
    distinct(V1, .keep_all = TRUE)

  # Remove duplicates and keep only the first occurrence
  value <- value %>%
    filter(!(V1 %in% varname)) %>%
    bind_rows(duplicates_to_keep)

  if (!keepEmptyString) {value <- value %>% filter(V1 != "- ")}  #remove empty string -hungtt
  # arrange in order of appearing in formula argument and remove dummy column
  value <- value %>% arrange(value[[ncol(value)]])
  value <- value[, -ncol(value)]
  value

  ## output
  ### header
  gr.lev <- levels(y)
  header1 <- c("", c(rbind(rep("", length(gr.lev)), paste(gr.lev, " (N=", table(y), ")", sep = ""))))
  header2 <- c("Characteristic", rep(c("n", "Summary statistic"), length(gr.lev)))
  if (test) {
    header1 <- c(header1, "p value")
    header2 <- c(header2, "")
  }

  ### footer
  footer2 <- footer1 <- footer1.after <- footer.con <- footer.cat <- NULL

  #### summary statistics
  if ((is.null(z) & any(continuous)) | (!is.null(z) & !is.factor(z))) {
    footer.con <- paste0(
      paste(statistics, collapse = ", "),
      " for numeric variable(s)."
    )
  }

  if ((is.null(z) & any(continuous == FALSE)) | (!is.null(z) & is.factor(z))) {
    footer.cat <- "absolute count (%) for categorical variable(s)"
  }

  footer1.after <- if (is.null(footer.con)) {
    paste0(footer.cat, ".")
  } else {
    if (is.null(footer.cat)) {
      footer.con
    } else {
      paste0(footer.cat, " and ", footer.con)
    }
  }
  footer1 <- paste("Summary statistic is", footer1.after)

  #### test
  if (test) {
    footer2.cat <- paste(
      ifelse(chisq.test == FALSE, "Fisher's exact test", "Chi-squared test"),
      "for categorical variable(s)"
    )
    footer2.con <- "Kruskal-Wallis/Mann-Whitney U-test for continuous variable(s)."
    footer2.after <- if (is.null(footer.con)) {
      paste0(footer2.cat, ".")
    } else {
      if (is.null(footer.cat)) {
        footer2.con
      } else {
        paste0(footer2.cat, " and ", footer2.con)
      }
    }
    footer2 <- paste("p-values were based on", footer2.after)
  }

  footer <- c(
    "N is number of all patients, n is number of patients with non-missing value.",
    footer1,
    if (any(value == "-")) {"- : value cannot be estimated."} else NULL,
    footer2,
    footer
  )

  ### flextable
  if (flextable) {
    ## header: the group name spans its two columns, "Characteristic" spans both rows
    header1[1] <- header2[1]
    header1[seq(from = 2, to = 2 * length(gr.lev), by = 2)] <- header1[seq(from = 2, to = 2 * length(gr.lev), by = 2) + 1]
    if (test) header2[length(header1)] <- header1[length(header1)]
    tab <- ._ss_flextable_two_headers(as.data.frame(value), header1, header2)
    tab <- ._ss_flextable_footer(tab, footer, length(header1))
    tab <- ._ss_flextable_finish(tab, bg)
  } else {
    tab <- list(table = rbind(header1, header2, value),
                footer = footer)
    class(tab$table) <- c('baseline_tbl', 'ss_tbl', class(tab$table))
  }
  ## output
  if (!flextable) class(tab) <- c('ss_baseline','ss_obj')
  return(tab)
}
