# Plotting functions. Plotted values are checked against direct computations
# (MASS::boxcox, Aalen-Johansen via survival::survfit); appearance is not tested.

test_that("gg_boxcox log-likelihood matches MASS::boxcox", {
  skip_if_not_installed("MASS")
  lambda <- seq(-0.25, 0.25, length = 10)
  p <- gg_boxcox(Volume ~ log(Height) + log(Girth), data = trees, lambda = lambda, interp = FALSE)
  expect_s3_class(p, "ggplot")
  line <- ggplot2::ggplot_build(p)$data[[1]]
  ref <- MASS::boxcox(Volume ~ log(Height) + log(Girth), data = trees, lambda = lambda, plotit = FALSE)
  expect_equal(line$x, ref$x, tolerance = 1e-8)
  expect_equal(line$y, ref$y, tolerance = 1e-8)

  fit <- lm(Volume ~ log(Height) + log(Girth), data = trees)
  p_lm <- gg_boxcox(fit, lambda = lambda, interp = FALSE)
  expect_equal(ggplot2::ggplot_build(p_lm)$data[[1]]$y, ref$y, tolerance = 1e-8)
  # default lambda grid with spline interpolation, and the 95% CI markers
  expect_s3_class(gg_boxcox(Volume ~ log(Height) + log(Girth), data = trees), "ggplot")
  expect_error(gg_boxcox(I(Volume - 100) ~ Height, data = trees), class = "c306_input_error",
               regexp = "positive")
})

test_that("tidy_survfit2 keeps strata as columns; ggsurvfit2 plots by stratum", {
  d <- lung_data()
  sf <- survival::survfit(survival::Surv(time, status) ~ arm + ph.ecog, data = d)
  td <- tidy_survfit2(sf)
  expect_true(all(c("arm", "ph.ecog", "estimate", "time") %in% names(td)))
  expect_setequal(unique(td$arm), c("1", "2"))
  # the estimate at the last time of a stratum is the Kaplan-Meier survival
  s <- summary(survival::survfit(survival::Surv(time, status) ~ 1, data = d[d$arm == "1" & d$ph.ecog == "0", ]))
  last <- td[td$arm == "1" & td$ph.ecog == "0", ]
  expect_equal(min(last$estimate), min(s$surv), tolerance = 1e-8)
  expect_identical(untidy_strata(data.frame(a = 1)), data.frame(a = 1))
  p <- ggsurvfit2(survival::survfit(survival::Surv(time, status) ~ arm, data = d))
  expect_s3_class(p, "ggplot")
})

test_that("gg_ajsurvplot2 data: risk of the main event is the Aalen-Johansen estimate", {
  skip_on_cran() # slow (two finegray expansions of 1384 subjects)
  d <- mgus_data()
  dt <- suppressWarnings(gg_ajsurvplot2(Surv(etime, event) ~ arm, data = d, main.event = "pcm",
                                        competing.event = "death", .return_data = TRUE))
  expect_setequal(unique(dt$Event), c("pcm", "death"))
  for (a in levels(d$arm)) {
    aj <- survival::survfit(survival::Surv(etime, event) ~ 1, data = d[d$arm == a, ])
    main <- dt[dt$Event == "pcm" & dt$arm == a, ]
    expect_equal(max(main$estimate), utils::tail(aj$pstate[, aj$states == "pcm"], 1), tolerance = 1e-4,
                 label = paste("pcm risk, arm", a))
    comp <- dt[dt$Event == "death" & dt$arm == a, ]
    # plotted from the top: 1 - cumulative incidence of the competing event
    expect_equal(min(comp$estimate), 1 - utils::tail(aj$pstate[, aj$states == "death"], 1), tolerance = 1e-4,
                 label = paste("death, arm", a))
  }
  p <- suppressWarnings(gg_ajsurvplot2(Surv(etime, event) ~ arm, data = d, main.event = "pcm",
                                       competing.event = "death"))
  expect_s3_class(p, "ggplot")
  p0 <- suppressWarnings(gg_ajsurvplot2(Surv(etime, event) ~ arm, data = d, main.event = "pcm",
                                        competing.event = "death", facet.by = NULL))
  expect_s3_class(p0, "ggplot")
})

test_that("gg_ajsurvplot returns a survminer plot", {
  d <- mgus_data()
  p <- suppressWarnings(gg_ajsurvplot(Surv(etime, event) ~ arm, data = d, etype = "pcm"))
  expect_s3_class(p, "ggsurvplot")
})
