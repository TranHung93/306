# Open items raised in the group-3 review (fixed before group 4).

test_that("[OI-1] inspect.data reports codes missing from the dictionary as out of range", {
  info <- dict_info()
  out <- suppressWarnings(myformat.data(raw_data(), info))
  res <- inspect.data(out, info, id = "id", prefix = "oi1", outdir = withr_local_tempdir())
  expect_true(any(res$error == "Out of range: sex = 3" & res$index == 4))
  expect_false(any(res$error == "Missing value for sex"))
})

test_that("[OI-1] myformat.data warns once per variable with unknown codes and keeps real NAs", {
  raw <- raw_data()
  raw$sex <- c(1, NA, 5, 3)
  w <- character(0)
  out <- withCallingHandlers(myformat.data(raw, dict_info()),
                             warning = function(cnd) { w <<- c(w, conditionMessage(cnd)); invokeRestart("muffleWarning") })
  expect_length(w, 1)
  expect_match(w, "sex.*3, 5")
  expect_identical(as.character(out$sex), c("Male", NA, "5", "3"))
  expect_identical(levels(out$sex), c("Male", "Female", "3", "5"))
})

test_that("[OI-2] logist_summary: likelihood-ratio rows are in model term order, like Wald", {
  fit <- glm(vs ~ mpg + am + wt, data = mtcars, family = binomial)
  expect_identical(rownames(logist_summary(fit)), names(coef(fit)))
  expect_identical(rownames(logist_summary(fit, method = "wald")), names(coef(fit)))
  expect_identical(logist_summary(fit, sstable = TRUE)$table[-1, 1], names(coef(fit)))
})

test_that("[OI-3] logist_summary without intercept: footer is accurate and LR p-values are correct", {
  fit0 <- glm(vs ~ 0 + mpg + am, data = mtcars, family = binomial)
  ls <- logist_summary(fit0, p_digits = 8)
  footer <- attr(ls, "footer")
  expect_false(any(grepl("not calculated", footer)))
  expect_true(any(grepl("no intercept", footer)))
  drop_mpg <- glm(vs ~ 0 + am, data = mtcars, family = binomial)
  p <- stats::pchisq(2 * as.numeric(logLik(fit0) - logLik(drop_mpg)), 1, lower.tail = FALSE)
  expect_equal(as.numeric(ls["mpg", "p.value"]), p, tolerance = 1e-6)
  expect_output(logist_summary(fit0, verbose = TRUE), "no intercept")
})

test_that("ss_huxtable accepts the objects returned by the sstable functions", {
  skip_if_not_installed("huxtable")
  tab <- sstable.baseline(x + g ~ arm, data = small_baseline())
  expect_s3_class(tab, "ss_obj")
  ht <- ss_huxtable(tab, add_footer = "extra note")
  expect_s3_class(ht, "huxtable")
  expect_true(any(grepl("extra note", unlist(ht))))
})

test_that("[OI-4] AE grades are in clinical order with missing grade last", {
  ae <- ae_fixture()
  fid <- fullid_fixture()
  tab <- sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "ctcaename", grade.var = "ctcaegrade",
                    arm.var = "Arm", flextable = FALSE)$table
  first <- unname(as.matrix(tab)[, 1])
  expect_identical(first[4:8], c("- Grade I", "- Grade II", "- Grade III", "- Grade IV", "- Grade N/A"))
})

test_that("[OI-4] numeric, 'Grade n' and factor grades are ordered sensibly", {
  expect_identical(._grade_order(c("10", "2", "1", "Grade N/A")), c("1", "2", "10", "Grade N/A"))
  expect_identical(._grade_order(c("Grade 3", "Grade 12", "Grade 1")), c("Grade 1", "Grade 3", "Grade 12"))
  expect_identical(._grade_order(c("V", "II", "IV", "I", "III")), c("I", "II", "III", "IV", "V"))
  expect_identical(._grade_order(c("Low", "High"), levels = c("Low", "High")), c("Low", "High"))
  expect_identical(._grade_order(c("b", "a")), c("a", "b"))

  ae <- data.frame(id = c(1, 2, 3, 4), aetype = c("Rash", "Rash", "Fever", "Cough"),
                   grade = factor(c("Severe", "Mild", NA, "Moderate"), levels = c("Mild", "Moderate", "Severe")))
  full <- data.frame(id = 1:6, arm = rep(c("A", "B"), 3))
  tab <- sstable.ae(ae, full, id.var = "id", aetype.var = "aetype", grade.var = "grade",
                    arm.var = "arm", flextable = FALSE)$table
  expect_identical(unname(as.matrix(tab)[4:7, 1]), c("- Grade Mild", "- Grade Moderate", "- Grade Severe", "- Grade N/A"))
})
