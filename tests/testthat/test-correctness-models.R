# Correctness of sstable.ae(), logist_summary() and subgroup_effect(), checked
# against counts and stats::chisq.test / fisher.test / glm computed directly.

# sstable.ae -----------------------------------------------------------------

test_that("sstable.ae: episodes, patients, % and p-values match direct counts and tests", {
  ae <- ae_fixture()
  fid <- fullid_fixture()
  tab <- sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "ctcaename", arm.var = "Arm",
                    digits = 4, pdigits = 6, pcutoff = 1e-12, test.anyae.only = FALSE,
                    flextable = FALSE)$table
  arms <- c("Sham procedure", "Intrathecal treatment") # reversed alphabetical order
  expect_match(tab[1, 3], paste0("^", arms[1], " \\(N=", sum(fid$Arm == arms[1]), "\\)$"))
  N <- c(sum(fid$Arm == arms[1]), sum(fid$Arm == arms[2]))
  arm_of <- stats::setNames(fid$Arm, fid$usubjid)
  ae$arm <- arm_of[as.character(ae$usubjid)]

  check_row <- function(label, rows) {
    row <- tab_row(tab, label)
    n_pt <- integer(2)
    for (j in 1:2) {
      sub <- rows[rows$arm == arms[j], ]
      n_pt[j] <- length(unique(sub$usubjid))
      expect_equal(as.numeric(row[2 * j]), nrow(sub), label = paste(label, arms[j], "episodes"))
      expect_equal(cell_num(row[2 * j + 1]), c(n_pt[j], round(100 * n_pt[j] / N[j], 4)),
                   tolerance = 1e-8, label = paste(label, arms[j], "patients"))
    }
    mat <- matrix(c(n_pt, N - n_pt), nrow = 2, byrow = TRUE)
    chi <- suppressWarnings(stats::chisq.test(mat, correct = FALSE))
    p <- if (any(chi$expected < 1)) stats::fisher.test(mat)$p.value else chi$p.value
    expect_equal(cell_num(row[6]), p, tolerance = 1e-4, label = paste(label, "p-value"))
  }
  check_row("Any selected adverse event", ae)
  top <- names(sort(table(ae$ctcaename), decreasing = TRUE))[1:3]
  for (a in top) check_row(a, ae[ae$ctcaename == a, ])
})

test_that("sstable.ae: chisq.test = FALSE uses Fisher's exact test", {
  ae <- ae_fixture()
  fid <- fullid_fixture()
  tab <- sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "ctcaename", arm.var = "Arm",
                    chisq.test = FALSE, pdigits = 6, pcutoff = 1e-12, flextable = FALSE)$table
  arms <- c("Sham procedure", "Intrathecal treatment")
  n_pt <- vapply(arms, function(a) length(unique(ae$usubjid[ae$usubjid %in% fid$usubjid[fid$Arm == a]])),
                 numeric(1))
  N <- vapply(arms, function(a) sum(fid$Arm == a), numeric(1))
  p <- stats::fisher.test(matrix(c(n_pt, N - n_pt), nrow = 2, byrow = TRUE))$p.value
  expect_equal(cell_num(tab_row(tab, "Any selected adverse event")[6]), p, tolerance = 1e-4)
})

test_that("sstable.ae: grade rows count patients with an event of that grade", {
  ae <- ae_fixture()
  fid <- fullid_fixture()
  tab <- sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "ctcaename", grade.var = "ctcaegrade",
                    arm.var = "Arm", flextable = FALSE)$table
  arms <- c("Sham procedure", "Intrathecal treatment")
  g <- sort(unique(ae$ctcaegrade))[1]
  label <- if (grepl("grade", g, ignore.case = TRUE)) paste("-", g) else paste("- Grade", g)
  row <- tab_row(tab, label)
  for (j in 1:2) {
    ids <- fid$usubjid[fid$Arm == arms[j]]
    sub <- ae[ae$ctcaegrade %in% g & ae$usubjid %in% ids, ] # %in%: grades can be NA
    expect_equal(as.numeric(row[2 * j]), nrow(sub))
    expect_equal(cell_num(row[2 * j + 1])[1], length(unique(sub$usubjid)))
  }
})

# logist_summary --------------------------------------------------------------

test_that("logist_summary (likelihood ratio): OR, profile CI and LR-test p match glm", {
  fit <- glm(vs ~ mpg + am, data = mtcars, family = binomial)
  ls <- logist_summary(fit, stat_digits = 6, p_digits = 8)
  ci <- suppressMessages(confint(fit))
  lrt <- drop1(fit, test = "LRT")
  for (v in c("mpg", "am")) {
    expect_equal(as.numeric(ls[v, "OR"]), unname(exp(coef(fit)[v])), tolerance = 1e-5)
    expect_equal(as.numeric(ls[v, c("lower.CI", "upper.CI")]), unname(exp(ci[v, ])), tolerance = 1e-5)
    expect_equal(as.numeric(ls[v, "p.value"]), lrt[v, "Pr(>Chi)"], tolerance = 1e-5)
  }
})

test_that("logist_summary (Wald): OR, Wald CI and p match confint.default / summary", {
  fit <- glm(vs ~ mpg + am, data = mtcars, family = binomial)
  ls <- logist_summary(fit, method = "wald", stat_digits = 6, p_digits = 8)
  ci <- confint.default(fit)
  p <- summary(fit)$coefficients[, "Pr(>|z|)"]
  for (v in c("(Intercept)", "mpg", "am")) {
    expect_equal(as.numeric(ls[v, "log.OR"]), unname(coef(fit)[v]), tolerance = 1e-5)
    expect_equal(as.numeric(ls[v, c("lower.CI", "upper.CI")]), unname(exp(ci[v, ])), tolerance = 1e-5)
    expect_equal(as.numeric(ls[v, "p.value"]), unname(p[v]), tolerance = 1e-5)
  }
})

# subgroup_effect -------------------------------------------------------------

subgroup_data <- function() {
  set.seed(42)
  n <- 600
  dd <- data.frame(x1 = stats::rnorm(n), x3 = factor(sample(c("C", "D", "E"), n, TRUE)))
  dd$y <- stats::rbinom(n, 1, stats::plogis(-0.3 + 0.5 * dd$x1 + 0.4 * (dd$x3 == "D") -
                                              0.6 * dd$x1 * (dd$x3 == "E")))
  dd
}

test_that("subgroup_effect: OR, CI (on the OR scale) and p within each level match glm", {
  dd <- subgroup_data()
  fit <- glm(y ~ x1 * x3, data = dd, family = binomial)
  for (method in c("wald", "lik.ratio")) {
    se <- subgroup_effect(~x3, fit, method = method, stat_digits = 6, p_digits = 8)
    for (lv in levels(dd$x3)) {
      f <- glm(y ~ x1 * x3, data = transform(dd, x3 = relevel(x3, lv)), family = binomial)
      ci <- if (method == "wald") confint.default(f)["x1", ] else suppressMessages(confint(f))["x1", ]
      expect_equal(as.numeric(se[lv, "OR"]), unname(exp(coef(f)["x1"])), tolerance = 1e-5)
      expect_equal(as.numeric(se[lv, c("CI.lower", "CI.upper")]), unname(exp(ci)), tolerance = 1e-5,
                   label = paste(method, "CI in level", lv))
      if (method == "wald") {
        expect_equal(as.numeric(se[lv, "p.value"]), summary(f)$coefficients["x1", "Pr(>|z|)"],
                     tolerance = 1e-5)
      }
    }
  }
})
