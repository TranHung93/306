# Data dictionary tools: myformat.data(), inspect.data(), getlabel(),
# import.info(), convert.info(). Files are only written to tempdir().
# (dict_info() and raw_data() are in helper-data.R)

test_that("myformat.data formats each type, codes missing values and keeps labels", {
  # sex = 3 is not in the dictionary: kept as an extra level, with a warning
  expect_warning(out <- myformat.data(raw_data(), dict_info()), "not in the dictionary")
  expect_named(out, c("id", "AGE", "sex", "visit")) # `extra` (not in info) is dropped
  expect_identical(out$AGE, structure(c(30, NA, 150, 45), label = "Age", unit = "years",
                                      scale = 1, center = 0))
  expect_s3_class(out$sex, "factor")
  expect_identical(levels(out$sex), c("Male", "Female", "3"))
  expect_identical(as.character(out$sex), c("Male", "Female", "Female", "3"))
  expect_identical(as.character(as.Date(out$visit)), c("2024-01-05", "2024-02-10", NA, "2024-03-01"))
  expect_identical(attr(out$visit, "label"), "Visit date")
})

test_that("myformat.data rejects data without any variable from info and unknown types", {
  expect_error(myformat.data(data.frame(zz = 1), dict_info()), "No variable")
  bad <- dict_info()
  bad$type[2] <- "complex"
  expect_error(myformat.data(raw_data(), bad), "not implemented")
})

test_that("inspect.data reports missing and out-of-range values and writes its files to outdir", {
  info <- dict_info()
  dat <- suppressWarnings(myformat.data(raw_data(), info)) # sex = 3 kept as a level
  dat$sex <- as.character(raw_data()$sex) # unformatted codes, to see the range check
  outdir <- withr_local_tempdir()
  res <- inspect.data(dat, info, id = "id", prefix = "t", outdir = outdir, plot = TRUE)
  expect_true(any(res$error == "Missing value for age" & res$index == 2))
  expect_true(any(res$error == "Out of range: age > 100" & res$index == 3))
  expect_true(any(grepl("Out of range: sex = 3", res$error) & res$index == 4))
  expect_true(any(res$error == "Missing value for visit" & res$index == 3))
  expect_true(file.exists(file.path(outdir, "t_error.csv")))
  expect_true(file.exists(file.path(outdir, "t_distribution.pdf")))
})

test_that("inspect.data honours check_missing = FALSE and conditions", {
  info <- dict_info()
  dat <- suppressWarnings(myformat.data(raw_data(), info)) # sex = 3 kept as a level
  outdir <- withr_local_tempdir()
  res <- inspect.data(dat, info, check_missing = FALSE, prefix = "t", outdir = outdir)
  expect_false(any(grepl("^Missing", res$error)))
  clean <- data.frame(id = "a", age = 30)
  expect_message(expect_null(inspect.data(clean, dict_info()[1:2, ], check_missing = FALSE,
                                          prefix = "t3", outdir = outdir)),
                 "No error was found")
  info$condition <- c(NA, "sex == 'Male'", NA, NA) # check age only for males
  res2 <- inspect.data(dat, info, check_missing = FALSE, prefix = "t2", outdir = outdir)
  expect_false(any(res2$error == "Out of range: age > 100"))
})

test_that("getlabel uses attributes, units and meta", {
  x <- structure(c(1, 2), label = "Weight", unit = "kg", scale = 10)
  expect_identical(getlabel(x), "Weight [kg]")
  expect_identical(getlabel(x, unit = FALSE), "Weight")
  expect_identical(getlabel(x, fit = TRUE), "Weight [+10 kg]")
  expect_identical(getlabel(factor("a")), "")
  df <- data.frame(a = 1, b = 2)
  attr(df$a, "label") <- "A"
  expect_identical(unname(getlabel(df)), c("A", "b"))
  meta <- data.frame(varname = c("a", "b"), label = c("Alpha", "Beta"), unit = c("kg", NA),
                     scale = c(10, NA), type = c("numeric", "factor"))
  expect_identical(getlabel("a", meta = meta), "Alpha [kg]")
  expect_identical(getlabel("b", meta = meta), "Beta")
  expect_identical(getlabel(df, meta = meta, fit = TRUE), c("Alpha [+10 kg]", "Beta"))
  expect_identical(getlabel(df, meta = meta, unit = FALSE), c("Alpha", "Beta"))
})

test_that("import.info reads an OUCRU dictionary (incl. grids) and saves it", {
  xlsx <- system.file("extdata", "oucru_dictionary.xlsx", package = "C306")
  out <- file.path(withr_local_tempdir(), "info.RData")
  import.info(c("ENR", "LAB", "LAB_G1"), input = xlsx, output = out)
  env <- new.env()
  load(out, envir = env)
  expect_setequal(env$sheet_info_name, c("ENR_info", "LAB_info", "LAB_G1_info"))
  expect_false("Title" %in% env$ENR_info$`Data type`) # title rows are dropped
  expect_identical(env$ENR_info$Variable, c("AGE", "SEX", "ENRDATE"))
  expect_true(all(c("HB", "WBC", "LAB_G1_SEQ", "USUBJID") %in% env$LAB_G1_info$Variable))
})

test_that("import.info works when the dictionary has grids but none is requested", {
  xlsx <- system.file("extdata", "oucru_dictionary.xlsx", package = "C306")
  out <- file.path(withr_local_tempdir(), "info.RData")
  expect_no_error(import.info("ENR", input = xlsx, output = out))
  env <- new.env()
  load(out, envir = env)
  expect_identical(env$sheet_info_name, "ENR_info")
})

test_that("convert.info cleans category labels (ASCII, no control characters or colons)", {
  oucru_info <- data.frame(Category = "SEX", Variable = "SEX", Caption = "Sex",
                           `Data type` = "RadioList", Format = NA, check.names = FALSE)
  cat_vn <- data.frame(category = c("SEX", "SEX"), submissionvalue = c("1", "2"),
                       text = c("Nam: male", "Nữ\tfemale"))
  info <- convert.info(oucru_info, cat_vn)
  expect_identical(info$value, "1='Nam male';2='Nufemale'")
})

test_that("convert.info turns an OUCRU dictionary into the C306 format", {
  oucru_info <- data.frame(
    Category = c(NA, "SEX", NA, NA), Variable = c("AGE", "SEX", "ENRDATE", "NOTE"),
    Caption = c("Age", "Sex", "Enrolment date", "Note"),
    `Data type` = c("Integer", "RadioList", "DateTime", "Free Text"),
    Format = c(NA, NA, "dd/mm/yy", NA), check.names = FALSE, stringsAsFactors = FALSE)
  oucru_category <- data.frame(category = c("SEX", "SEX"), submissionvalue = c("1", "2"),
                               text = c("Male", "Female"), stringsAsFactors = FALSE)
  info <- convert.info(oucru_info, oucru_category)
  info <- info[match(c("AGE", "SEX", "ENRDATE", "NOTE"), info$varname), ]
  expect_identical(info$type, c("numeric", "factor", "datetime", "character"))
  expect_identical(info$value[2], "1='Male';2='Female'")
  expect_identical(info$levels[2], "'Male';'Female'")
  expect_identical(info$value[3], "ymd_hms")
  expect_true(all(info$strict == "Yes"))
})

test_that("labAE flags a new AE only when the grade rises to the cut-off", {
  expect_identical(as.character(labAE(c(0, 1, 3, 3, 2, 4, NA, 3), gradecut = 3)),
                   c("No", "No", "Yes", "No", "No", "Yes", NA, "Yes"))
})
