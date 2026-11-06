# Group 2 (robustness): invalid input gives a clear error of class
# "c306_input_error" instead of a cryptic error, a warning, or silent garbage.

E <- "c306_input_error"

# sstable.baseline ---------------------------------------------------------

test_that("sstable.baseline validates its inputs", {
  d <- small_baseline()
  expect_error(sstable.baseline("x ~ arm", d), class = E, regexp = "formula")
  expect_error(sstable.baseline(~arm, d), class = E, regexp = "row-wise")
  expect_error(sstable.baseline(x ~ arm, 1:10), class = E, regexp = "data frame")
  expect_error(sstable.baseline(x + nope ~ arm, d), class = E, regexp = "nope")
  expect_error(sstable.baseline(x ~ arm, d[0, ]), class = E, regexp = "no rows")
  expect_error(sstable.baseline(x ~ arm, d, test = "yes"), class = E, regexp = "`test`")
  expect_error(sstable.baseline(x ~ arm, d, test = TRUE, pdigits = -1), class = E, regexp = "`pdigits`")
  expect_error(sstable.baseline(x ~ arm, d, pcutoff = 2), class = E, regexp = "`pcutoff`")
  expect_error(sstable.baseline(x ~ arm, d, statistics = c("mean", "sd")), class = E, regexp = "`statistics`")
})

test_that("sstable.baseline still accepts tibbles", {
  d <- small_baseline()
  expect_no_error(sstable.baseline(x + g ~ arm, dplyr::as_tibble(d)))
})

# sstable.ae ---------------------------------------------------------------

test_that("sstable.ae validates its inputs", {
  ae <- data.frame(id = 1:4, aetype = c("Rash", "Rash", "Fever", "Cough"))
  full <- data.frame(id = 1:6, arm = rep(c("A", "B"), 3))
  run <- function(...) {
    args <- list(ae_data = ae, fullid_data = full, id.var = "id",
                 aetype.var = "aetype", arm.var = "arm", flextable = FALSE)
    new <- list(...)
    args[names(new)] <- new # (modifyList would merge data frames column-wise)
    do.call(sstable.ae, args)
  }
  expect_error(run(ae_data = "x"), class = E, regexp = "`ae_data` must be a data frame")
  expect_error(run(id.var = "nope"), class = E, regexp = "nope")
  expect_error(run(aetype.var = c("aetype", "nope")), class = E, regexp = "nope")
  expect_error(run(id.var = c("id", "id")), class = E, regexp = "`id.var`")
  expect_error(run(fullid_data = full[0, ]), class = E, regexp = "no rows")
  expect_error(run(ae_data = ae[0, ]), class = E, regexp = "no rows")
  expect_error(run(flextable = "no"), class = E, regexp = "`flextable`")
  expect_error(run(digits = -1), class = E, regexp = "`digits`")
})

# sstable.survcomp ---------------------------------------------------------

test_that("sstable.survcomp validates its inputs", {
  d <- lung_data()
  expect_error(sstable.survcomp("Surv(time, status) ~ arm", d), class = E, regexp = "formula")
  expect_error(sstable.survcomp(time ~ arm, d), class = E, regexp = "Surv")
  expect_error(sstable.survcomp(Surv(time, status) ~ nope, d), class = E, regexp = "nope")
  expect_error(sstable.survcomp(Surv(time, status) ~ arm, d[0, ]), class = E, regexp = "no rows")
  expect_error(sstable.survcomp(Surv(time, status) ~ arm, d, time = -1), class = E, regexp = "`time`")
  expect_error(sstable.survcomp(Surv(time, status) ~ arm, d, add.risk = NA), class = E, regexp = "`add.risk`")
  expect_error(sstable.survcomp(Surv(time, status) ~ arm, d, compare.args = "x"), class = E,
               regexp = "`compare.args`")
  d3 <- d
  d3$arm <- factor(rep(1:3, length.out = nrow(d)))
  expect_error(sstable.survcomp(Surv(time, status) ~ arm, d3), class = E, regexp = "two-arm")
})

test_that("sstable.survcomp still works with one arm (used for subgroups)", {
  d <- lung_data()
  one <- d[d$arm == "1", ]
  expect_no_error(tab <- sstable.survcomp(Surv(time, status) ~ arm, one, flextable = FALSE))
})

test_that("sstable.survcomp.subgroup validates its inputs", {
  d <- lung_data()
  expect_error(sstable.survcomp.subgroup(Surv(time, status) ~ arm, y ~ sex, data = d),
               class = E, regexp = "one-sided")
  expect_error(sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~nope, data = d),
               class = E, regexp = "nope")
  expect_error(sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ph.ecog, data = d, overall = "y"),
               class = E, regexp = "`overall`")
})

test_that("sstable.survcomp.subgroup shows '-' for an empty subgroup level", {
  d <- lung_data()
  d <- droplevels(d[d$ph.ecog != "3", ])
  d$ph.ecog <- factor(d$ph.ecog, levels = c(levels(d$ph.ecog), "empty"))
  res <- sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ph.ecog, data = d,
                                   flextable = FALSE)$table
  row <- res[res[, 1] == "- empty", ]
  expect_true(all(row[2:(length(row) - 1)] == "-"))
})

# logist_summary / subgroup_effect ----------------------------------------

test_that("logist_summary validates its inputs", {
  m_lm <- lm(Sepal.Width ~ Sepal.Length, iris)
  mg <- glm(am ~ wt, data = mtcars, family = binomial)
  expect_error(logist_summary(m_lm), class = E, regexp = "logistic regression")
  expect_error(logist_summary(mg, stat_digits = -1), class = E, regexp = "`stat_digits`")
  expect_error(logist_summary(mg, verbose = "a"), class = E, regexp = "`verbose`")
})

test_that("subgroup_effect validates its inputs", {
  m_lm <- lm(Sepal.Width ~ Sepal.Length, iris)
  mg <- glm(am ~ wt, data = mtcars, family = binomial)
  expect_error(subgroup_effect(~x, m_lm), class = E, regexp = "logistic regression")
  expect_error(subgroup_effect("~x", mg), class = E, regexp = "formula")
})

# pct / simple_recode / contSummary / labAE --------------------------------

test_that("pct validates its inputs", {
  expect_error(pct(numeric(0)), class = E, regexp = "at least one")
  expect_error(pct(c(1, 0, 1), na.rm = "x"), class = E, regexp = "`na.rm`")
})

test_that("simple_recode validates the map", {
  expect_error(simple_recode(c("a", "b")), class = E, regexp = "map")
  expect_error(simple_recode(c("a", "b"), map = 5), class = E, regexp = "map")
  expect_error(simple_recode(c("a", "b"), map = data.frame(a = 1, b = 2)), class = E,
               regexp = "from.*to")
})

test_that("contSummary validates its inputs", {
  expect_error(contSummary(1:3), class = E, regexp = "statistics")
  expect_error(contSummary(c("a", "b"), "mean"), class = E, regexp = "numeric")
  expect_error(contSummary(1:3, "mean", digits = -1), class = E, regexp = "`digits`")
})

test_that("contSummary replaces whole statistic names only and keeps the user's text", {
  expect_identical(contSummary(c(1, 2, 3), "Median [IQR: Q1-Q3], minimum min"),
                   "2.0 [IQR: 1.5-2.5], minimum 1.0")
  # default statistics are unchanged
  expect_identical(contSummary(c(1, 2, 3, 10), "mean; median (Q1-Q3)"), "4.0; 2.5 (1.8-4.8)")
})

test_that("contSummary on all-missing data gives NA without warnings", {
  expect_no_warning(out <- contSummary(c(NA_real_, NA_real_), "median (min-max)"))
  expect_identical(out, "NA (NA-NA)")
  expect_no_warning(contSummary(numeric(0), "mean"))
})

test_that("labAE validates its inputs", {
  expect_error(labAE(c("a", "b"), 2), class = E, regexp = "numeric")
  expect_error(labAE(1:3, c(1, 2)), class = E, regexp = "`gradecut`")
  expect_identical(labAE(numeric(0), 2), factor(character(0), levels = c("Yes", "No")))
})

# createProject (silent failures) -----------------------------------------

test_that("createProject fails clearly for an unknown structure and creates nothing", {
  td <- file.path(tempdir(), "c306_bad_structure")
  unlink(td, recursive = TRUE)
  expect_error(createProject(td, structure = "nope"), class = E, regexp = "nope")
  expect_false(dir.exists(td))
})

test_that("createProject copies the structure and refuses a non-empty folder", {
  td <- file.path(tempdir(), "c306_proj")
  unlink(td, recursive = TRUE)
  on.exit(unlink(td, recursive = TRUE), add = TRUE)
  expect_message(createProject(td), "c306_proj")
  expect_true(file.exists(file.path(td, "c306_proj.Rproj")))
  expect_true(dir.exists(file.path(td, "Analysis")))
  expect_error(createProject(td), class = E, regexp = "not empty")
})
