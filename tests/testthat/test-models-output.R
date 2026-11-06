# Output paths of logist_summary() and subgroup_effect(): printing, sstable and
# flextable output, transposition. Numbers are checked in test-correctness-models.R.

test_that("logist_summary: print, verbose, sstable and flextable outputs", {
  fit <- glm(vs ~ mpg + am, data = mtcars, family = binomial)
  ls <- logist_summary(fit)
  expect_s3_class(ls, "logist_summary")
  expect_named(ls, c("log.OR", "OR", "lower.CI", "upper.CI", "p.value"))
  expect_output(print(ls), "Likelihood ratio")
  expect_output(expect_invisible(logist_summary(fit, verbose = TRUE)), "likelihood ratio statistics")
  expect_output(print(logist_summary(fit, method = "wald")), "Wald")

  ss <- logist_summary(fit, sstable = TRUE)
  expect_s3_class(ss$table, "summary_tbl")
  expect_identical(ss$table[1, ], c("", "log.OR", "OR", "lower.CI", "upper.CI", "p.value"))
  expect_match(ss$footer[1], "likelihood ratio")
  expect_s3_class(logist_summary(fit, flextable = TRUE), "flextable")
  expect_s3_class(as_sstable(ls, include_footnote = FALSE), "summary_tbl")
})

test_that("logist_summary notes missing values and models without intercept", {
  d <- mtcars
  d$mpg[1:3] <- NA
  fit <- glm(vs ~ mpg, data = d, family = binomial)
  expect_message(logist_summary(fit), "3 observations deleted")
  fit0 <- glm(vs ~ 0 + mpg, data = mtcars, family = binomial)
  expect_match(attr(logist_summary(fit0), "footer")[2], "no intercept")
})

subgroup_fit <- function() {
  set.seed(1)
  n <- 800
  d <- data.frame(x1 = stats::rnorm(n), x2 = factor(sample(c("A", "B"), n, TRUE)),
                  x3 = factor(sample(c("C", "D", "E"), n, TRUE)))
  d$y <- stats::rbinom(n, 1, stats::plogis(0.3 * d$x1 + 0.4 * (d$x2 == "B") - 0.5 * d$x1 * (d$x3 == "E")))
  glm(y ~ x1 * x3 + x2 * x3, data = d, family = binomial)
}

test_that("subgroup_effect: list output, print, transpose, sstable and flextable", {
  fit <- subgroup_fit()
  se <- subgroup_effect(~x3, fit, method = "wald")
  expect_s3_class(se, "subgroup_logist_summary")
  expect_named(se, c("C", "D", "E"))
  expect_identical(rownames(se$C), c("x1", "x2B"))
  expect_output(print(se), "x3 = C")

  tse <- t(se)
  expect_named(tse, c("x1", "x2B"))
  expect_identical(rownames(tse$x1), c("C", "D", "E"))
  expect_identical(tse$x1["D", "OR"], se$D["x1", "OR"])
  expect_identical(subgroup_effect(~x3, fit, method = "wald", transpose = TRUE), tse)

  ss <- subgroup_effect(~x3, fit, method = "wald", sstable = TRUE)
  expect_s3_class(ss$table, "formatted_sstable")
  expect_true(all(c("x3 = C", "x3 = D", "x3 = E") %in% ss$table[, 1]))
  expect_s3_class(subgroup_effect(~x3, fit, method = "wald", flextable = TRUE), "flextable")
})

test_that("subgroup_effect: one summary variable gives a simplified table; formula models work", {
  fit <- subgroup_fit()
  se <- subgroup_effect(x1 ~ x3, fit, method = "wald")
  expect_s3_class(se, "data.frame")
  expect_identical(rownames(se), c("C", "D", "E"))
  expect_message(expect_output(print(se), "OR"), "Effect table for x1")
  expect_identical(t(se), se)

  d <- model.frame(fit)
  se2 <- subgroup_effect(x1 ~ x3, y ~ x1 * x3, data = d, method = "wald")
  ref <- subgroup_effect(x1 ~ x3, glm(y ~ x1 * x3, data = d, family = binomial), method = "wald")
  expect_identical(unclass(se2)[["OR"]], unclass(ref)[["OR"]])
  expect_error(subgroup_effect(x9 ~ x3, fit), class = "c306_input_error", regexp = "x9")
})
