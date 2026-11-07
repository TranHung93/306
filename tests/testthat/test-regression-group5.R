# Regression tests for bugs found during group 5 (code quality).

# Header text of a flextable, one string per header cell (row by row)
ft_header_text <- function(ft) {
  info <- flextable::information_data_chunk(ft)
  info <- info[info$.part == "header", ]
  vapply(split(info$txt, list(info$.row_id, info$.col_id), drop = TRUE),
         paste, character(1), collapse = "")
}

# Group/arm names containing a quote or a backslash used to break
# flextable = TRUE: the header labels were pasted into R code and run with
# eval(parse()).
special_labels <- c(apostrophe = "O'Brien", double_quote = 'Dr "X"', backslash = "A\\B")

for (case in names(special_labels)) {
  lab <- special_labels[[case]]

  test_that(paste("sstable.baseline(flextable = TRUE) keeps a group name with", case), {
    d <- small_baseline()
    d$arm[d$arm == "A"] <- lab
    ft <- sstable.baseline(x ~ arm, d, flextable = TRUE)
    expect_s3_class(ft, "flextable")
    expect_true(paste0(lab, " (N=5)") %in% ft_header_text(ft))
  })

  test_that(paste("sstable.ae(flextable = TRUE) keeps an arm name with", case), {
    ae <- ae_fixture()
    fid <- fullid_fixture()
    n <- sum(fid$Arm == "Sham procedure")
    fid$Arm[fid$Arm == "Sham procedure"] <- lab
    ft <- sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "ctcaename", arm.var = "Arm",
                     flextable = TRUE)
    expect_s3_class(ft, "flextable")
    expect_true(paste0(lab, " (N=", n, ")") %in% ft_header_text(ft))
  })

  test_that(paste("sstable.survcomp(flextable = TRUE) keeps an arm name with", case), {
    d <- lung_data()
    levels(d$arm)[1] <- lab
    ft <- sstable.survcomp(Surv(time, status) ~ arm, d, flextable = TRUE)
    expect_s3_class(ft, "flextable")
    expect_true(paste0(lab, " (n=", sum(d$arm == lab), ")") %in% ft_header_text(ft))
  })

  test_that(paste("sstable.survcomp.subgroup(flextable = TRUE) keeps an arm name with", case), {
    d <- lung_data()
    d <- droplevels(d[d$ph.ecog != "3", ])
    levels(d$arm)[1] <- lab
    ft <- sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ph.ecog, data = d, flextable = TRUE)
    expect_s3_class(ft, "flextable")
    expect_true(any(grepl(lab, ft_header_text(ft), fixed = TRUE)))
  })
}
