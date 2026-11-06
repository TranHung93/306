# Correctness of the numbers in sstable.baseline(), checked against base R
# (table, quantile, wilcox.test, fisher.test, chisq.test) on the same data.

baseline_tab <- function(formula, ...) {
  d <- baseline_fixture()
  sstable.baseline(formula, d, statistics = "median (Q1-Q3)",
                   digits.numeric = "TRUE ~ 4", digits.nonnumeric = "TRUE ~ 4",
                   pdigits = 6, pcutoff = 1e-12, ...)$table
}

test_that("continuous variable: n, median, Q1, Q3 and Kruskal-Wallis p-value", {
  d <- baseline_fixture()
  tab <- baseline_tab(age + bmi ~ Arm, test = TRUE)
  arms <- unname(sub(" \\(N=.*", "", as.matrix(tab)[1, c(3, 5)]))
  expect_identical(arms, c("Sham procedure", "Intrathecal treatment"))
  for (v in c("age", "bmi")) {
    row <- tab_row(tab, v)
    for (j in 1:2) {
      x <- d[[v]][d$Arm == arms[j]]
      expect_equal(as.numeric(row[2 * j]), sum(!is.na(x)))
      expect_equal(cell_num(row[2 * j + 1]),
                   round(unname(stats::quantile(x, c(0.5, 0.25, 0.75), na.rm = TRUE)), 4),
                   tolerance = 1e-8, label = paste(v, arms[j]))
    }
    # Kruskal-Wallis with 2 groups = Wilcoxon rank-sum without continuity correction
    p <- stats::wilcox.test(d[[v]] ~ d$Arm, exact = FALSE, correct = FALSE)$p.value
    expect_equal(cell_num(row[6]), p, tolerance = 1e-4, label = paste(v, "p-value"))
    expect_equal(cell_num(row[6]), stats::kruskal.test(d[[v]], factor(d$Arm))$p.value, tolerance = 1e-4)
  }
})

test_that("categorical variable: counts, column % and Fisher / chi-squared p-values", {
  d <- baseline_fixture()
  arms <- c("Sham procedure", "Intrathecal treatment")
  ct <- table(d$sex, d$Arm)[, arms]

  tab <- baseline_tab(sex ~ Arm, test = TRUE)
  head <- tab_row(tab, "sex")
  expect_equal(as.numeric(head[c(2, 4)]), unname(colSums(ct)))
  for (lv in rownames(ct)) {
    row <- tab_row(tab, paste("-", lv))
    for (j in 1:2) {
      expect_equal(cell_num(row[2 * j + 1]),
                   c(ct[lv, j], round(100 * ct[lv, j] / sum(ct[, j]), 4)),
                   tolerance = 1e-8, label = paste(lv, arms[j]))
    }
  }
  expect_equal(cell_num(head[6]), stats::fisher.test(ct)$p.value, tolerance = 1e-4)

  tab_chi <- baseline_tab(sex ~ Arm, test = TRUE, chisq.test = TRUE)
  expect_equal(cell_num(tab_row(tab_chi, "sex")[6]),
               stats::chisq.test(ct, correct = FALSE)$p.value, tolerance = 1e-4)
})

test_that("fullfreq shows count/denominator and bycol = FALSE gives row %", {
  d <- baseline_fixture()
  arms <- c("Sham procedure", "Intrathecal treatment")
  ct <- table(d$sex, d$Arm)[, arms]

  full <- baseline_tab(sex ~ Arm, fullfreq = TRUE)
  expect_equal(cell_num(tab_row(full, "- F")[3]),
               c(ct["F", 1], sum(ct[, 1]), round(100 * ct["F", 1] / sum(ct[, 1]), 4)),
               tolerance = 1e-8)

  byrow <- baseline_tab(sex ~ Arm, bycol = FALSE)
  row <- as.matrix(byrow)[grepl("^- F", as.matrix(byrow)[, 1]), ]
  expect_equal(cell_num(row[3])[2], round(100 * ct["F", 1] / sum(ct["F", ]), 4), tolerance = 1e-8)
})

test_that("pooledGroup adds a Total column with the overall summary", {
  d <- baseline_fixture()
  tab <- baseline_tab(age ~ Arm, pooledGroup = TRUE)
  expect_match(as.matrix(tab)[1, 7], "^Total \\(N=271\\)$")
  row <- tab_row(tab, "age")
  expect_equal(as.numeric(row[6]), sum(!is.na(d$age)))
  expect_equal(cell_num(row[7]), round(unname(stats::quantile(d$age, c(0.5, 0.25, 0.75), na.rm = TRUE)), 4))
})

test_that("missing values are excluded from n and percentages", {
  d <- small_baseline()
  d$x[1:2] <- NA
  d$g[3] <- NA
  tab <- sstable.baseline(x + g ~ arm, d, digits.nonnumeric = "TRUE ~ 1")$table
  arms <- sub(" \\(N=.*", "", as.matrix(tab)[1, c(3, 5)])
  xrow <- tab_row(tab, "x")
  grow <- tab_row(tab, "g")
  for (j in 1:2) {
    expect_equal(as.numeric(xrow[2 * j]), sum(!is.na(d$x[d$arm == arms[j]])))
    expect_equal(as.numeric(grow[2 * j]), sum(!is.na(d$g[d$arm == arms[j]])))
  }
})
