# Small helpers: pct, ref_lv, simple_sort, simple_recode (data frame), mutate_f,
# summarise_f, formula helpers.

test_that("pct: binary, factor and continuous methods", {
  expect_equal(pct(c(TRUE, FALSE, TRUE, NA)), 100 * 2 / 3)
  expect_equal(pct(c(TRUE, FALSE, TRUE, NA), na.rm = FALSE), 100 * 2 / 4)
  expect_equal(pct(c(1, 0, 0, 1)), 50)
  expect_warning(out <- pct(factor(c("a", "b", "b", "b")), method = "bin"), "non logical")
  expect_equal(out, 75)
  expect_equal(pct("a", method = "bin"), 100)
  expect_error(pct(factor(c("a", "b", "c")), method = "bin"), "meaningless")
  expect_equal(pct(factor(c("a", "b", "c", "c", "d", "e"))), c(a = 100, b = 100, c = 200, d = 100, e = 100) / 6)
  x <- c(1:10, NA)
  cont <- pct(x, method = "cont", breaks = c(0, 5, 10))
  expect_equal(unname(cont), c(50, 50))
  cont_na <- pct(x, method = "cont", na.rm = FALSE, breaks = c(0, 5, 10))
  expect_equal(unname(cont_na), c(1, 5, 5) / 11 * 100)
})

test_that("ref_lv gets and sets the reference level", {
  f <- factor(c("a", "b", "c"))
  expect_identical(ref_lv(f), "a")
  ref_lv(f) <- "c"
  expect_identical(levels(f), c("c", "a", "b"))
})

test_that("simple_sort sorts in a user-defined order and keeps attributes", {
  x <- structure(c("b", "a", "c", "a"), label = "letters")
  out <- simple_sort(x, order = c("c", "a", "b"))
  expect_identical(as.vector(out), c("c", "a", "a", "b"))
  expect_identical(attr(out, "label"), "letters")
  expect_identical(simple_sort(c(3, 1, 2)), c(1, 2, 3))
})

test_that("simple_recode: data frame method, data frame maps, NA patterns and `as`", {
  df <- data.frame(a = c("yes", "no", NA), b = c("x1", "x2", "y1"))
  out <- simple_recode(df, a = list(Y = "yes", N = "no", U = NA), b = list(X = "^x"))
  expect_identical(out$a, c("Y", "N", "U"))
  expect_identical(out$b, c("X1", "X2", "y1"))
  expect_error(simple_recode(df, nope = list(z = "a")), class = "c306_input_error", regexp = "nope")
  map <- data.frame(from = c("^a.*", "^b.*"), to = c("1", "2")) # patterns replace the match only
  expect_identical(simple_recode(c("ax", "bx"), map, as = "numeric"), c(1, 2))
  expect_identical(simple_recode(c("a", "b"), list(TRUE_ = "a"), as = "character"), c("TRUE_", "b"))
  expect_identical(simple_recode(c("a", "b"), list(z = "a"), as = "factor", levels = c("z", "b")),
                   factor(c("z", "b"), levels = c("z", "b")))
  expect_identical(simple_recode(c("A", "b"), list(z = "a"), ignore.case = TRUE), c("z", "b"))
  expect_error(simple_recode(c("a"), list(x = "a", y = "a")), class = "c306_input_error", regexp = "unique")
})

test_that("mutate_f assigns several columns at once, by group, for each data type", {
  df <- data.frame(baz = 1:6, foo = rep(1:2, each = 3))
  grouped <- dplyr::group_by(df, foo)
  out <- mutate_f(grouped, c("cs", "dbl") := list(cumsum(baz), baz * 2))
  expect_s3_class(out, "grouped_df")
  expect_identical(dplyr::group_vars(out), "foo")
  expect_equal(out$cs, c(1, 3, 6, 4, 9, 15))
  expect_equal(out$dbl, df$baz * 2)

  plain <- mutate_f(df, c("cs") := list(cumsum(baz)))
  expect_s3_class(plain, "data.frame")
  expect_equal(plain$cs, cumsum(df$baz))
  expect_s3_class(mutate_f(dplyr::as_tibble(df), "cs" := cumsum(baz)), "tbl_df")
  expect_s3_class(mutate_f(data.table::as.data.table(df), "cs" := cumsum(baz)), "data.table")
})

test_that("summarise_f summarises by group and matches dplyr::summarise", {
  df <- data.frame(baz = 1:6, foo = rep(1:2, each = 3), bar = 4:9)
  out <- summarise_f(dplyr::group_by(df, foo), list(mean_baz = mean(baz), max_bar = max(bar)))
  ref <- dplyr::summarise(dplyr::group_by(df, foo), mean_baz = mean(baz), max_bar = max(bar))
  expect_s3_class(out, "grouped_df")
  expect_equal(out$mean_baz, ref$mean_baz)
  expect_equal(out$max_bar, ref$max_bar)
  expect_s3_class(summarise_f(df, list(n = length(baz))), "data.table")
  expect_s3_class(summarise_f(dplyr::as_tibble(df), list(n = length(baz))), "tbl_df")
  expect_s3_class(summarise_f(data.table::as.data.table(df), list(n = length(baz))), "data.table")
})

test_that("formula helpers parse sstable formulas", {
  expect_identical(getvar(a + b ~ arm | z), c("a", "b", "arm", "z"))
  info <- sstable.formula(a + b ~ arm | z)
  expect_identical(info$index, list(x = 1:2, y = 3, z = 4))
  expect_identical(sstable.formula(a ~ 1)$index$y, 0)
  expect_error(sstable.formula(a ~ x + y), class = "c306_input_error", regexp = "column-wise")
  expect_error(sstable.formula(a ~ x | y + z), class = "c306_input_error", regexp = "third dimension")
  expect_identical(vapply(getsign(rlang::quo(ep + pt - p)), deparse, ""), c("+", "-"))
})
