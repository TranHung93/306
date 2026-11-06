# Correctness of the numbers in sstable.survcomp() / sstable.survcomp.subgroup(),
# checked against survival::survfit / coxph / cox.zph / finegray computed directly
# on the same data. Tables are built with digits = 6 so that the printed values
# can be compared with a tight tolerance.

tol <- 1e-5

# arm levels are "1", "2"; the table shows arm "2" first, and with the default
# reference.arm = "B" the comparison is arm 2 vs arm 1 (reference = arm 1).

test_that("Cox: events, risk %, HR, 95% CI, p-value and PH test match coxph", {
  d <- lung_data()
  tab <- sstable.survcomp(Surv(time, status) ~ arm, d, digits = 6, pdigits = 6,
                          pcutoff = 1e-10, flextable = FALSE)$table
  row <- tab_row(tab, "status")

  # events / n and risk (%) per arm
  for (j in 1:2) {
    a <- c("2", "1")[j]
    km <- survival::survfit(survival::Surv(time, status) ~ 1, data = d[d$arm == a, ])
    v <- cell_num(row[j + 1])
    expect_equal(v[1:2], c(sum(d$status[d$arm == a] == 2), sum(d$arm == a)))
    expect_equal(v[3], 100 * (1 - utils::tail(km$surv, 1)), tolerance = tol)
  }

  cx <- survival::coxph(survival::Surv(time, status) ~ arm, data = d)
  v <- cell_num(row[4])
  expect_equal(v[1], unname(exp(coef(cx))), tolerance = tol)
  expect_equal(v[2:3], unname(exp(confint(cx))[1, ]), tolerance = tol)
  expect_equal(v[4], unname(summary(cx)$coefficients[1, "Pr(>|z|)"]), tolerance = 1e-4)
  expect_equal(cell_num(row[5]), unname(survival::cox.zph(cx)$table[1, "p"]), tolerance = 1e-4)
})

test_that("Cox: reference.arm = 'A' gives the reciprocal HR", {
  d <- lung_data()
  tab <- sstable.survcomp(Surv(time, status) ~ arm, d, reference.arm = "A", digits = 6,
                          flextable = FALSE)$table
  cx <- survival::coxph(survival::Surv(time, status) ~ arm, data = d)
  v <- cell_num(tab_row(tab, "status")[4])
  expect_equal(v[1], unname(exp(-coef(cx))), tolerance = tol)
  expect_equal(v[2:3], rev(unname(exp(-confint(cx))[1, ])), tolerance = tol)
})

test_that("Median and IQR (with 95% CI) match quantile(survfit)", {
  d <- lung_data()
  tab <- sstable.survcomp(Surv(time, status) ~ arm, d, digits = 6, flextable = FALSE)$table
  q <- quantile(survival::survfit(survival::Surv(time, status) ~ arm, data = d),
                probs = c(0.5, 0.25, 0.75))
  rows <- c("- Median (95%CI)", "- Lower IQR (95%CI)", "- Upper IQR (95%CI)")
  for (k in 1:3) {
    r <- tab_row(tab, rows[k])
    for (j in 1:2) {
      a <- paste0("arm=", c("2", "1")[j])
      expected <- c(q$quantile[a, k], q$lower[a, k], q$upper[a, k])
      got <- cell_num(r[j + 1])
      expect_equal(got, unname(expected), tolerance = tol, label = paste(rows[k], a))
    }
  }
})

test_that("RMST difference, CI and p-value match survfit rmean and rmeanglm", {
  d <- lung_data()
  tab <- sstable.survcomp(Surv(time, status) ~ arm, d, compare.method = "rmst", digits = 6,
                          pdigits = 6, pcutoff = 1e-10, flextable = FALSE)$table
  v <- cell_num(tab_row(tab, "status")[4])
  # tau = minimum over arms of the last observed time
  tau <- min(tapply(d$time, d$arm, max))
  rm <- summary(survival::survfit(survival::Surv(time, status) ~ arm, data = d),
                rmean = tau)$table[, "rmean"]
  expect_equal(v[1], unname(rm["arm=2"] - rm["arm=1"]), tolerance = tol)

  fit <- eventglm::rmeanglm(survival::Surv(time, status) ~ arm, time = tau, data = d,
                            model.censoring = "stratified", formula.censoring = ~arm)
  expect_equal(v[2:3], unname(confint(fit)[2, ]), tolerance = tol)
  expect_equal(v[4], unname(summary(fit)$coefficients[2, "Pr(>|z|)"]), tolerance = 1e-4)
})

test_that("RMST 'lost.diff' is minus the RMST difference", {
  d <- lung_data()
  diff <- cell_num(tab_row(sstable.survcomp(Surv(time, status) ~ arm, d, compare.method = "rmst",
                                            digits = 6, flextable = FALSE)$table, "status")[4])[1]
  lost <- cell_num(tab_row(sstable.survcomp(Surv(time, status) ~ arm, d, compare.method = "rmst",
                                            compare.args = list(type = "lost.diff"), digits = 6,
                                            flextable = FALSE)$table, "status")[4])[1]
  expect_equal(lost, -diff, tolerance = tol)
})

test_that("Cumulative incidence difference matches 1 - Kaplan-Meier at `time`", {
  d <- lung_data()
  tab <- sstable.survcomp(Surv(time, status) ~ arm, d, compare.method = "cuminc", time = 365,
                          digits = 6, pdigits = 6, flextable = FALSE)$table
  row <- tab_row(tab, "status")
  s <- summary(survival::survfit(survival::Surv(time, status) ~ arm, data = d), times = 365)
  risk <- stats::setNames(1 - s$surv, c("1", "2"))
  # risk % at time = 365 in the descriptive columns
  expect_equal(cell_num(row[2])[3], 100 * unname(risk["2"]), tolerance = tol)
  expect_equal(cell_num(row[3])[3], 100 * unname(risk["1"]), tolerance = tol)
  # difference arm 2 - arm 1
  expect_equal(cell_num(row[4])[1], unname(risk["2"] - risk["1"]), tolerance = tol)
})

test_that("Competing risks: risk % (Aalen-Johansen) and Fine-Gray HR match survival", {
  d <- mgus_data()
  tab <- suppressWarnings(
    sstable.survcomp(Surv(etime, event) ~ arm, d, compare.args = list(cause = "pcm"),
                     digits = 6, pdigits = 6, pcutoff = 1e-10, flextable = FALSE)$table
  )
  row <- tab[3, ]
  arms <- sub(" \\(n=.*", "", tab[1, 2:3])
  for (j in 1:2) {
    sub <- d[d$arm == arms[j], ]
    aj <- survival::survfit(survival::Surv(etime, event) ~ 1, data = sub)
    v <- cell_num(row[j + 1])
    expect_equal(v[1], sum(sub$event == "pcm"))
    expect_equal(v[3], 100 * utils::tail(aj$pstate[, aj$states == "pcm"], 1), tolerance = tol)
  }
  # Fine-Gray: comparison arm (first column) vs reference (second column)
  d2 <- d
  d2$arm <- factor(d2$arm, levels = rev(arms))
  fg <- survival::finegray(survival::Surv(etime, event) ~ arm, data = d2, etype = "pcm")
  fgfit <- survival::coxph(survival::Surv(fgstart, fgstop, fgstatus) ~ arm, data = fg, weight = fgwt)
  v <- cell_num(row[4])
  expect_equal(v[1], unname(exp(coef(fgfit))), tolerance = tol)
})

test_that("survcomp.subgroup: per-level HRs and heterogeneity p match coxph / anova", {
  d <- lung_data()
  d <- droplevels(d[d$ph.ecog != "3", ])
  res <- sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ph.ecog, data = d, digits = 6,
                                   pdigits = 6, pcutoff = 1e-10, flextable = FALSE)$table
  for (lv in levels(d$ph.ecog)) {
    cx <- survival::coxph(survival::Surv(time, status) ~ arm, data = d[d$ph.ecog == lv, ])
    expect_equal(cell_num(tab_row(res, paste("-", lv))[4])[1], unname(exp(coef(cx))),
                 tolerance = tol, label = paste("HR in ph.ecog =", lv))
  }
  ia <- survival::coxph(survival::Surv(time, status) ~ arm * ph.ecog, data = d)
  main <- survival::coxph(survival::Surv(time, status) ~ arm + ph.ecog, data = d)
  p_het <- anova(ia, main, test = "Chisq")[2, "Pr(>|Chi|)"]
  het <- tab_row(res, "ph.ecog")
  expect_equal(cell_num(het[length(het)]), p_het, tolerance = 1e-4)
})
