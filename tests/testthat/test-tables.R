# Table options and layout. Numbers are checked in test-correctness-*.R; the
# snapshots here only guard the layout and formatting of the tables.

plain <- function(x) {
  m <- as.matrix(x)
  dimnames(m) <- NULL
  m
}

# sstable.ae ------------------------------------------------------------------

test_that("sstable.ae: groups from group_data, group titles and totals", {
  ae <- ae_fixture()
  fid <- fullid_fixture()
  grp <- utils::read.csv(system.file("extdata", "group_data.csv", package = "C306"))
  tab <- sstable.ae(ae, fid, group_data = grp, id.var = "usubjid", aetype.var = "ctcaename",
                    group.var = "class", arm.var = "Arm", flextable = FALSE)$table
  m <- plain(tab)
  # each group title row carries the number of episodes of its AEs
  ae$class <- grp$class[match(ae$ctcaename, grp$ctcaename)]
  arm_of <- stats::setNames(fid$Arm, fid$usubjid)
  for (g in c("Digestive", "Neurological")) {
    row <- m[m[, 1] == g, ]
    expect_equal(as.numeric(row[2]), sum(ae$class == g & arm_of[as.character(ae$usubjid)] == "Sham procedure"))
  }
  ft <- sstable.ae(ae, fid, group_data = grp, id.var = "usubjid", aetype.var = "ctcaename",
                   group.var = "class", group.var.priority = "Neurological", arm.var = "Arm")
  expect_s3_class(ft, "flextable")
  body <- ft$body$dataset[[1]]
  expect_lt(which(body == "Neurological"), which(body == "Digestive"))
})

test_that("sstable.ae: sort.by orders AEs by number of patients (descending)", {
  ae <- ae_fixture()
  fid <- fullid_fixture()
  tab <- sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "ctcaename", arm.var = "Arm",
                    sort.by = ~ -pt, flextable = FALSE)$table
  m <- plain(tab)
  body <- m[-(1:3), ]
  n_pt <- cell_num(body[, 3])[c(TRUE, FALSE)] + cell_num(body[, 5])[c(TRUE, FALSE)]
  expect_true(all(diff(n_pt) <= 0))
  expect_error(sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "ctcaename", arm.var = "Arm",
                          sort.by = ~ -nope), class = "c306_input_error")
})

test_that("sstable.ae: several AE type variables, named header, grades and missing types", {
  ae <- ae_fixture()
  fid <- fullid_fixture()
  ae$ctcaename[1:2] <- NA
  tab <- sstable.ae(ae, fid, id.var = "usubjid",
                    aetype.var = c("Event" = "ctcaename", "Related" = "posrelunrel"),
                    grade.var = "ctcaegrade", arm.var = "Arm", flextable = FALSE)
  m <- plain(tab$table)
  expect_true(all(c("Event", "Related", "(Missing)") %in% m[, 1]))
  expect_identical(m[nrow(m), 1] == "(Missing)" || "(Missing)" %in% m[, 1], TRUE)
  expect_s3_class(sstable.ae(ae, fid, id.var = "usubjid", aetype.var = c("ctcaename", "posrelunrel"),
                             grade.var = "ctcaegrade", arm.var = "Arm"), "flextable")
  raw <- sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "ctcaename", arm.var = "Arm",
                    matrix.raw = TRUE)
  expect_true(is.matrix(raw))
  expect_false(any(grepl("header", rownames(raw))))
})

test_that("sstable.ae (several AE type variables) flextable merges only section rows", {
  ae <- ae_fixture()
  fid <- fullid_fixture()
  ft <- sstable.ae(ae, fid, id.var = "usubjid", aetype.var = c("ctcaename", "posrelunrel"),
                   grade.var = "ctcaegrade", arm.var = "Arm")
  spans <- ft$body$spans$rows
  body <- as.matrix(ft$body$dataset)
  merged <- which(apply(spans, 1, function(r) any(r != 1)))
  expect_true(all(spans[-merged, , drop = FALSE] == 1) || !length(merged))
  for (i in merged) {
    expect_true(all(body[i, -1] == ""), label = paste("merged body row", i, "is a section row"))
  }
})

test_that("sstable.ae layout", {
  ae <- ae_fixture()
  fid <- fullid_fixture()
  tab <- sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "ctcaename", grade.var = "ctcaegrade",
                    arm.var = "Arm", fullfreq = TRUE, flextable = FALSE)
  expect_snapshot(print(plain(tab$table)[1:10, ]))
  expect_snapshot(ft_footer_text(sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "ctcaename",
                                            arm.var = "Arm", footer = "My note")))
})

# sstable.baseline -----------------------------------------------------------

test_that("sstable.baseline: third dimension, by-row layout, flextable and raw matrix", {
  d <- baseline_fixture()
  d$died <- d$outcome == 4
  z <- sstable.baseline(sex ~ Arm | died, d, digits.nonnumeric = "TRUE ~ 1")$table
  zm <- plain(z)
  expect_true(any(grepl("^- F \\(n=", zm[, 1])))
  # count of deaths among women in the first arm
  f_row <- zm[grepl("^- F", zm[, 1]), ]
  expect_equal(cell_num(f_row[3])[1], sum(d$died & d$sex == "F" & d$Arm == "Sham procedure"))

  zc <- sstable.baseline(sex ~ Arm | age, d, test = TRUE)$table
  expect_true(any(grepl("^- M", plain(zc)[, 1])))
  expect_error(sstable.baseline(age ~ Arm | sex, d), class = "c306_input_error", regexp = "categorical")

  expect_error(sstable.baseline(age ~ Arm, d, bycol = FALSE), class = "c306_input_error", regexp = "by-row")
  ft <- sstable.baseline(age + sex ~ Arm, d, flextable = TRUE, test = TRUE, footer = "note")
  expect_s3_class(ft, "flextable")
  expect_true("note" %in% ft_footer_text(ft))
  raw <- sstable.baseline(age + sex ~ Arm, d, matrix.raw = TRUE)
  expect_true(is.matrix(raw))
  expect_equal(nrow(raw), 4)

  total <- sstable.baseline(age + sex ~ 1, d)$table
  expect_match(plain(total)[1, 3], "^Total \\(N=271\\)$")
  expect_error(sstable.baseline(age ~ icudays, d), class = "c306_input_error", regexp = "categorical")
})

test_that("sstable.baseline: cont / cat override the automatic type, labels are used", {
  d <- baseline_fixture()
  tab <- sstable.baseline(outcome + age ~ Arm, d, cont = "outcome", cat = "age")
  m <- plain(tab$table)
  expect_false(any(grepl("^- 3$", m[, 1])))   # outcome summarised as continuous
  expect_true(any(grepl("^- 16$", m[, 1])))   # age shown by category
  attr(d$age, "label") <- "Age (years)"
  m2 <- plain(sstable.baseline(age ~ Arm, d)$table)
  expect_true("Age (years)" %in% m2[, 1])
})

test_that("sstable.baseline layout", {
  d <- baseline_fixture()
  tab <- sstable.baseline(age + sex + bmi ~ Arm, d, test = TRUE, pooledGroup = TRUE)
  expect_snapshot(print(plain(tab$table)))
  expect_snapshot(tab$footer)
})

# sstable.survcomp ------------------------------------------------------------

test_that("sstable.survcomp: flextable output, footers, add.risk/medsum/p.compare switches", {
  d <- lung_data()
  ft <- sstable.survcomp(Surv(time, status) ~ arm, d, footer = "note")
  expect_s3_class(ft, "flextable")
  expect_true("note" %in% ft_footer_text(ft))
  expect_true(any(grepl("hazard ratio", ft_footer_text(ft))))
  tab <- sstable.survcomp(Surv(time, status) ~ arm, d, add.risk = FALSE, medsum = FALSE,
                          p.compare = FALSE, compare.args = list(add.prop.haz.test = FALSE),
                          flextable = FALSE)$table
  m <- plain(tab)
  expect_identical(dim(m), c(3L, 4L))
  expect_identical(m[2, 2], "events/n")
  expect_false(grepl("p=", m[3, 4]))
  expect_warning(sstable.survcomp(Surv(time, status) ~ arm, d, compare.method = "rmst", time = 5000,
                                  flextable = FALSE), "later than maximum")
  expect_error(sstable.survcomp(Surv(time, status) ~ arm, d, compare.method = "rmst",
                                compare.args = list(type = "bad")), "Illegal type")
  dna <- d
  dna$time[1] <- NA
  expect_warning(sstable.survcomp(Surv(time, status) ~ arm, dna, flextable = FALSE), "Missing values")
})

test_that("sstable.survcomp layout", {
  d <- lung_data()
  expect_snapshot(print(plain(sstable.survcomp(Surv(time, status) ~ arm, d, flextable = FALSE)$table)))
  expect_snapshot(print(plain(sstable.survcomp(Surv(time, status) ~ arm, d, compare.method = "rmst",
                                               compare.args = list(type = "ratio"),
                                               flextable = FALSE)$table)))
})

test_that("sstable.survcomp.subgroup: rmst and cuminc methods, overall model, flextable", {
  skip_on_cran() # slow (several eventglm fits per subgroup)
  d <- lung_data()
  d <- droplevels(d[d$ph.ecog != "3", ])
  d$age <- survival::lung$age[as.numeric(rownames(d))]
  rm <- suppressWarnings(sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ph.ecog, data = d,
                                                   compare.method = "rmst", flextable = FALSE))
  expect_match(rm$footer[3], "multivariate Wald")
  het <- tab_row(rm$table, "ph.ecog")
  expect_false(is.na(cell_num(het[length(het)])))
  ci <- suppressWarnings(sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ph.ecog, data = d,
                                                   compare.method = "cuminc", time = 365, flextable = FALSE))
  expect_match(ci$footer[1], "Cumulative incidence")

  adj <- sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ph.ecog, overall.model = ~age, data = d,
                                   flextable = FALSE)$table
  cx <- survival::coxph(survival::Surv(time, status) ~ arm + age, data = d)
  expect_equal(cell_num(tab_row(adj, "All patients")[4])[1], round(unname(exp(coef(cx)[1])), 2))
  expect_false("All patients" %in% plain(sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ph.ecog,
                                                                   data = d, overall = FALSE,
                                                                   flextable = FALSE)$table)[, 1])
  expect_s3_class(sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ph.ecog, data = d), "flextable")
})

test_that("sstable.survcomp.subgroup layout", {
  d <- lung_data()
  d <- droplevels(d[d$ph.ecog != "3", ])
  expect_snapshot(print(plain(sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ph.ecog, data = d,
                                                        flextable = FALSE)$table)))
})

# sstable plumbing -----------------------------------------------------------

test_that("ss_format guesses header / section / body rows; ss_flextable and ss_huxtable build tables", {
  m <- rbind(c("", "Group A", "", "Group B", ""),
             c("Characteristic", "n", "stat", "n", "stat"),
             c("Age", "10", "50", "12", "48"),
             c("Sex", "", "", "", ""),
             c("- F", "", "5 (50%)", "", "6 (50%)"))
  f <- ss_format(m)
  expect_s3_class(f, "formatted_sstable")
  expect_identical(rownames(f), c("header.1", "header.2", "body.1", "section.1", "body.2"))
  expect_error(ss_format(m, .guess = FALSE), "not classified")
  f2 <- ss_format(m, header = 1:2, section = 4, body = c(3, 5), .guess = FALSE)
  expect_identical(rownames(f2)[4], "section.1")
  expect_s3_class(ss_template(m, "ae"), "ae_tbl")

  ft <- ss_flextable(m, footer = c("note 1", "note 2"))
  expect_s3_class(ft, "flextable")
  expect_identical(ft_footer_text(ft), c("note 1", "note 2"))
  # the empty section row "Sex" (row 2 of the body) is the merged one, not "- F"
  spans <- ft$body$spans$rows
  expect_equal(spans[2, ], c(5, 0, 0, 0, 0))
  expect_true(all(spans[c(1, 3), ] == 1))
  expect_s3_class(ss_flextable(list(table = m, footer = "x"), add_footer = "y"), "flextable")

  ht <- ss_huxtable(m, footer = "note", caption = "My table", caption_pos = "top", wrap = TRUE)
  expect_s3_class(ht, "huxtable")
  expect_identical(huxtable::caption(ht), "My table")
  expect_s3_class(ss_huxtable(list(table = m, footer = "x")), "huxtable")
  expect_s3_class(ht_theme_kable(huxtable::as_hux(data.frame(a = 1:3, b = 4:6)), header_rows = 1), "huxtable")
})

test_that("as_sstable converts lists with header / body parts and plain tables", {
  x <- list(header = list(c("", "A", "B")),
            body = list("Section 1" = matrix(c("r1", "1", "2"), nrow = 1),
                        "Section 2" = matrix(c("r2", "3", "4"), nrow = 1)),
            footer = "f")
  s <- as_sstable(x)
  expect_identical(rownames(s$table), c("header1", "section1", "body11", "section2", "body21"))
  expect_identical(s$footer, "f")
  expect_s3_class(as_sstable(x, flextable = TRUE), "flextable")

  # a row-label column is added only when the table has row names
  d <- as_sstable(structure(list(table = data.frame(a = 1:2, b = 3:4, row.names = c("r1", "r2"))),
                            footer = "ff"))
  expect_identical(d$table[1, ], c("", "a", "b"))
  expect_identical(d$table[2, ], c("r1", "1", "3"))
  expect_identical(d$footer, "ff")
  ov <- structure(data.frame(est = "1.0"), footer = "ov", class = c("overlap_summary", "data.frame"))
  expect_identical(as_sstable(ov)$footer, "ov")
  expect_s3_class(as_sstable(ov, include_footnote = FALSE), "summary_tbl")
})
