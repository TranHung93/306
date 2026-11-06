# Regression tests for the group-1 (critical) bugs found in the 2026-11 review.
# Each test is labelled with its plan item number.

# 1.1 ---------------------------------------------------------------------

test_that("[1.1] survcomp risk column is 1 - Kaplan-Meier, not the cumulative hazard", {
  d <- lung_data()
  tab <- sstable.survcomp(Surv(time, status) ~ arm, data = d, flextable = FALSE)$table
  arms <- sub(" \\(n=.*", "", tab[1, 2:3])
  for (j in seq_along(arms)) {
    km <- survival::survfit(survival::Surv(time, status) ~ 1, data = d[d$arm == arms[j], ])
    expected <- formatC(100 * (1 - utils::tail(km$surv, 1)), 2, format = "f")
    expect_match(tab[3, j + 1], paste0("(", expected, ")"), fixed = TRUE)
  }
})

test_that("[1.1] survcomp risk column is the Aalen-Johansen probability for competing risks", {
  skip_on_cran() # slow (finegray on 1384 subjects)
  d <- mgus_data()
  tab <- suppressWarnings(
    sstable.survcomp(Surv(etime, event) ~ arm, data = d, flextable = FALSE,
                     compare.args = list(cause = "pcm"))$table
  )
  arms <- sub(" \\(n=.*", "", tab[1, 2:3])
  for (j in seq_along(arms)) {
    aj <- survival::survfit(survival::Surv(etime, event) ~ 1, data = d[d$arm == arms[j], ])
    p <- utils::tail(aj$pstate[, which(aj$states == "pcm")], 1)
    expected <- formatC(100 * p, 2, format = "f")
    expect_match(tab[3, j + 1], paste0("(", expected, ")"), fixed = TRUE)
  }
})

# 1.2 ---------------------------------------------------------------------

test_that("[1.2] survcomp.subgroup passes reference.arm to the subgroup rows", {
  d <- lung_data()
  d <- droplevels(d[d$ph.ecog != "3", ])
  res <- sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ph.ecog, data = d,
                                   reference.arm = "A", flextable = FALSE)$table
  for (lv in levels(d$ph.ecog)) {
    expected <- sstable.survcomp(Surv(time, status) ~ arm, data = d[d$ph.ecog == lv, ],
                                 reference.arm = "A", medsum = FALSE,
                                 flextable = FALSE)$table[3, 4]
    expect_identical(res[res[, 1] == paste("-", lv), 4], expected, label = paste("ph.ecog =", lv))
  }
})

# 1.3 ---------------------------------------------------------------------

test_that("[1.3] survcomp.subgroup honours pdigits for the 'All patients' row", {
  d <- lung_data()
  d <- droplevels(d[d$ph.ecog != "3", ])
  res <- sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ph.ecog, data = d,
                                   pdigits = 5, flextable = FALSE)$table
  expected <- sstable.survcomp(Surv(time, status) ~ arm, data = d, pdigits = 5,
                               medsum = FALSE, flextable = FALSE)$table[3, 4]
  expect_identical(res[res[, 1] == "All patients", 4], expected)
})

# 1.4 ---------------------------------------------------------------------

test_that("[1.4] survcomp.subgroup keeps a user-supplied model.censoring", {
  d <- lung_data()
  d <- droplevels(d[d$ph.ecog != "3", ])
  het <- function(...) {
    r <- suppressWarnings(
      sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ph.ecog, data = d,
                                compare.method = "rmst", flextable = FALSE, ...)$table
    )
    r[r[, 1] == "ph.ecog", ncol(r)]
  }
  default <- het()
  expect_identical(het(compare.args = list(model.censoring = "stratified")), default)
  expect_false(identical(het(compare.args = list(model.censoring = "independent")), default))
})

# 1.5 ---------------------------------------------------------------------

test_that("[1.5] sstable.baseline works with a single row variable", {
  d <- small_baseline()
  expect_no_error(tab <- sstable.baseline(x ~ arm, data = d))
  expect_true("x" %in% as.matrix(tab$table)[, 1])
  expect_no_error(tab2 <- sstable.baseline(g ~ arm, data = d))
  expect_true(all(c("g", "- u", "- v") %in% as.matrix(tab2$table)[, 1]))
})

test_that("[B] sstable.baseline orders character arms like factor arms (reversed)", {
  d <- small_baseline()
  chr <- as.matrix(sstable.baseline(x + g ~ arm, data = d)$table)[1, ]
  d$arm <- factor(d$arm)
  fct <- as.matrix(sstable.baseline(x + g ~ arm, data = d)$table)[1, ]
  expect_identical(chr, fct)
  expect_identical(chr[c(3, 5)], c(V3 = "B (N=5)", V5 = "A (N=5)"))
})

# 1.6 ---------------------------------------------------------------------

test_that("[1.6] sstable.baseline does not write to the global environment", {
  d <- data.frame(arm = rep(c("A", "B"), 5),
                  zz_c306_cont = c(12, 15, 11, 19, 14, 13, 17, 16, 18, 10),
                  zz_c306_cat = rep(c("u", "v"), each = 5))
  before <- ls(globalenv(), all.names = TRUE)
  sstable.baseline(zz_c306_cont + zz_c306_cat ~ arm, data = d)
  expect_identical(ls(globalenv(), all.names = TRUE), before)
})

# 1.7 ---------------------------------------------------------------------

test_that("[1.7] sstable.ae builds a flextable without flextable being attached", {
  skip_if("package:flextable" %in% search())
  ae <- ae_fixture()
  fid <- fullid_fixture()
  expect_s3_class(
    sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "ctcaename", arm.var = "Arm"),
    "flextable"
  )
  expect_s3_class(
    sstable.ae(ae, fid, id.var = "usubjid", aetype.var = c("ctcaename", "posrelunrel"),
               arm.var = "Arm"),
    "flextable"
  )
})

# 1.8 ---------------------------------------------------------------------

test_that("[1.8] sstable.ae does not change options(warn) or print with cat()", {
  ae <- data.frame(id = 1:4, aetype = c("Rash", "Rash", "Fever", "Cough"),
                   soc = c("Skin", "Other", "General", "Resp"))
  full <- data.frame(id = 1:6, arm = rep(c("A", "B"), 3))
  op <- options(warn = 0)
  on.exit(options(op), add = TRUE)
  expect_warning(
    out <- utils::capture.output(invisible(
      sstable.ae(ae, full, id.var = "id", aetype.var = "aetype", group.var = "soc",
                 arm.var = "arm", flextable = FALSE)
    )),
    "two different SOCs"
  )
  expect_identical(out, character(0))
  expect_equal(getOption("warn"), 0)
})

# 1.9 ---------------------------------------------------------------------

test_that("[1.9] sstable.ae footer reflects the test and chisq.test settings", {
  ae <- ae_fixture()
  fid <- fullid_fixture()
  no_test <- ft_footer_text(
    sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "ctcaename", arm.var = "Arm", test = FALSE)
  )
  expect_false(any(grepl("p-value", no_test)))

  fisher <- ft_footer_text(
    sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "ctcaename", arm.var = "Arm",
               chisq.test = FALSE)
  )
  expect_true(any(grepl("Fisher's exact test", fisher, fixed = TRUE)))
  expect_false(any(grepl("chi-square", fisher)))

  multi <- ft_footer_text(
    sstable.ae(ae, fid, id.var = "usubjid", aetype.var = c("ctcaename", "posrelunrel"),
               arm.var = "Arm", test = FALSE)
  )
  expect_false(any(grepl("p-value", multi)))
})

# 1.10 / 1.11 -------------------------------------------------------------

test_that("[1.10] simple_recode keeps numeric input numeric", {
  out <- simple_recode(c(1, 2, 3), map = list("9" = "1"))
  expect_type(out, "double")
  expect_identical(out, c(9, 2, 3))
})

test_that("[1.11] simple_recode keeps a 2-level factor as a factor", {
  out <- simple_recode(factor(c("a", "b", "a")), map = list(x = "a"))
  expect_identical(out, factor(c("x", "b", "x"), levels = c("x", "b")))
  # logical maps on 2-level factors still give a logical vector
  expect_identical(simple_recode(factor(c("yes", "no")), map = list("TRUE" = "yes", "FALSE" = "no")),
                   c(TRUE, FALSE))
})

# 1.12 --------------------------------------------------------------------

test_that("[1.12] pct handles NA and character input", {
  expect_equal(pct(factor(c("a", "b", "c", NA)), method = "fct"),
               c(a = 100 / 3, b = 100 / 3, c = 100 / 3))
  expect_equal(pct(c("a", "b", "c", "a"), method = "fct"),
               c(a = 50, b = 25, c = 25))
  with_na <- pct(factor(c("a", "b", NA)), method = "fct", na.rm = FALSE)
  expect_equal(unname(with_na), rep(100 / 3, 3))
  expect_identical(names(with_na), c("a", "b", NA))
})

# 1.13 --------------------------------------------------------------------

test_that("[1.13] labAE works with current dplyr", {
  expect_identical(labAE(c(1, 2, 2, 3), gradecut = 2),
                   factor(c("No", "Yes", "No", "Yes"), levels = c("Yes", "No")))
  expect_identical(labAE(c(NA, 3), gradecut = 2),
                   factor(c(NA, "Yes"), levels = c("Yes", "No")))
})

# 1.14 --------------------------------------------------------------------

test_that("[1.14] getlabel works on a data frame with meta, keeping column order", {
  meta <- data.frame(varname = c("a", "b"), label = c("A", "B"), unit = c("kg", "cm"),
                     scale = NA, type = "numeric")
  expect_identical(getlabel(data.frame(b = 1, a = 2), meta = meta), c("B [cm]", "A [kg]"))
})

# 1.15 --------------------------------------------------------------------

test_that("[1.15] ss_flextable honours bg", {
  tab <- sstable.baseline(x + g ~ arm, data = small_baseline())
  expect_true("#FF0000" %in% ft_body_bg(ss_flextable(tab, bg = "#FF0000")))
})

test_that("[1.15] ss_header/ss_body/ss_section keep the sstable class", {
  m <- matrix(c("", "A", "x", "1"), nrow = 2, byrow = TRUE)
  expect_s3_class(ss_header(m, 1), "ss_tbl")
  expect_s3_class(ss_body(m, 2), "ss_tbl")
  expect_s3_class(ss_section(m, 2), "ss_tbl")
})

# Behaviour check, not a regression test: the old `length(bg > 1)` condition was
# wrong in the code but gave the same output (striping with one colour is plain).
test_that("[1.15] ht_theme_markdown uses a plain background when bg has length 1", {
  skip_if_not_installed("huxtable")
  ht <- huxtable::as_hux(data.frame(a = 1:3, b = 4:6))
  ht <- ht_theme_markdown(ht, header_rows = 1, bg = "white")
  expect_true(all(huxtable::background_color(ht) == "white"))
})

# 1.16 --------------------------------------------------------------------

test_that("[1.16] explicit() works when the model data is a local variable", {
  f <- function() {
    dd <- iris
    m <- lm(Sepal.Width ~ Sepal.Length * Petal.Width, data = dd)
    list(m = m, e = explicit(m))
  }
  r <- f()
  expect_equal(unname(fitted(r$e)), unname(fitted(r$m)))
  expect_length(coef(r$e), 4)
})
