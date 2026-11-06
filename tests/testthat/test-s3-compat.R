# [1.18] S3 methods were changed to match their generics. These tests check
# that positional calls keep working, and that the old argument names still
# work with a deprecation warning.

test_that("[1.18] explicit.lm: positional calls work, `fit =` is deprecated", {
  rlang::local_options(lifecycle_verbosity = "warning")
  m <- lm(Sepal.Width ~ Sepal.Length * Petal.Width, data = iris)
  ref <- explicit(m)
  expect_equal(coef(explicit.lm(m)), coef(ref))
  expect_warning(old <- explicit.lm(fit = m), class = "lifecycle_warning_deprecated")
  expect_equal(coef(old), coef(ref))
})

test_that("[1.18] simple_relevel.data.frame: positional calls work, `data =` is deprecated", {
  rlang::local_options(lifecycle_verbosity = "warning")
  df <- data.frame(g = factor(c("b", "a", "b", "a"), levels = c("b", "a")),
                   x = c("x1", "y1", "x2", "y2"))
  expected <- c("x1", "x2", "y1", "y2")
  expect_identical(levels(simple_relevel(df, x, by = g)$x), expected)
  expect_identical(levels(simple_relevel.data.frame(df, x, by = g)$x), expected)
  expect_warning(old <- simple_relevel.data.frame(data = df, x, by = g),
                 class = "lifecycle_warning_deprecated")
  expect_identical(levels(old$x), expected)
})

test_that("[1.18] simple_relevel.default: positional calls work", {
  x <- c("p", "q", "r")
  by <- factor(c("B", "A", "B"), levels = c("B", "A"))
  map <- list(A = "q", B = c("p", "r"))
  expect_identical(simple_relevel(x, by, map, "levels"), c("p", "r", "q"))
  expect_identical(simple_relevel.default(x, by, map, "levels"), c("p", "r", "q"))
  expect_identical(levels(simple_relevel(x, by, map)), c("p", "r", "q"))
})

test_that("[1.18] print.ss_tbl: positional calls work, `sstable =` is deprecated", {
  rlang::local_options(lifecycle_verbosity = "warning")
  tbl <- sstable.baseline(x + g ~ arm, data = small_baseline(), matrix.raw = TRUE)
  class(tbl) <- c("ss_tbl", class(tbl))
  expect_output(print(tbl))
  expect_output(print(tbl, FALSE))
  expect_output(print.ss_tbl(tbl, FALSE))
  expect_output(expect_invisible(print(tbl, FALSE)))
  expect_warning(expect_output(print.ss_tbl(sstable = tbl, pretty = FALSE)),
                 class = "lifecycle_warning_deprecated")
})

test_that("[1.18] rbind methods: positional and named calls keep working", {
  ae <- ae_fixture()
  fid <- fullid_fixture()
  t1 <- sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "ctcaename", arm.var = "Arm",
                   flextable = FALSE)
  t2 <- sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "posrelunrel", arm.var = "Arm",
                   flextable = FALSE)
  ref_ae <- ._do_rbind(t1, t2, header = 1:3)
  expect_identical(rbind(t1, t2), ref_ae)
  expect_identical(rbind.ss_ae(t1, t2), ref_ae)
  expect_identical(rbind.ss_ae(t1, t2, 1:3), ref_ae)
  expect_identical(rbind.ss_ae(tbl1 = t1, tbl2 = t2), ref_ae)
  expect_identical(rbind.ss_ae(t1, t2, footer = "f")$footer, "f")

  d <- lung_data()
  s1 <- sstable.survcomp(Surv(time, status) ~ arm, data = d, flextable = FALSE)
  ref_s <- ._do_rbind(s1, s1, header = 1:3)
  expect_identical(rbind(s1, s1), ref_s)
  expect_identical(rbind.ss_survcomp(s1, s1), ref_s)
  expect_identical(rbind.ss_survcomp(s1, s1, 1:3), ref_s)

  b1 <- sstable.baseline(x + g ~ arm, data = small_baseline())
  ref_b <- ._do_rbind(b1, b1, header = 1:2)
  expect_identical(rbind(b1, b1), ref_b)
  expect_identical(rbind.ss_baseline(b1, b1), ref_b)
  expect_identical(rbind.ss_baseline(b1, b1, 1:2), ref_b)

  expect_identical(rbind.ss_obj(t1, t2), ref_ae)
  expect_error(rbind.ss_obj(t1, s1), "same class")
})
