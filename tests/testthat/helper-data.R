# Shared fixtures for the C306 test suite ---------------------------------

# Two-arm survival data with no missing values (arm is a factor with levels 1, 2)
lung_data <- function() {
  d <- stats::na.omit(survival::lung[, c("time", "status", "sex", "ph.ecog")])
  d$arm <- factor(d$sex)
  d$ph.ecog <- factor(d$ph.ecog)
  d
}

# Competing-risks data: progression (pcm) vs death, arm = sex
mgus_data <- function() {
  d <- survival::mgus2
  d$etime <- ifelse(d$pstat == 0, d$futime, d$ptime)
  d$event <- factor(ifelse(d$pstat == 0, 2 * d$death, 1), 0:2,
                    c("censor", "pcm", "death"))
  d$arm <- factor(d$sex)
  d[, c("etime", "event", "arm")]
}

ae_fixture <- function() {
  utils::read.csv(system.file("extdata", "ae_data.csv", package = "C306"))
}

fullid_fixture <- function() {
  utils::read.csv(system.file("extdata", "baseline_data.csv", package = "C306"))
}

small_baseline <- function() {
  data.frame(arm = rep(c("A", "B"), 5),
             x = c(12, 15, 11, 19, 14, 13, 17, 16, 18, 10),
             g = rep(c("u", "v"), each = 5),
             stringsAsFactors = FALSE)
}

# All numbers in a formatted table cell, e.g. "0.59 (0.42, 0.82); p=0.0015" ->
# c(0.59, 0.42, 0.82, 0.0015). "NA" gives NA. A "-" directly after a digit is a
# range separator ("12-17" -> 12, 17), otherwise it is a minus sign.
cell_num <- function(s) {
  m <- regmatches(s, gregexpr("NA|(?<![0-9.])-?[0-9]+(\\.[0-9]+)?(e-?[0-9]+)?", s, perl = TRUE))[[1]]
  suppressWarnings(as.numeric(m))
}

# Row of a table (matrix or data frame) whose first column equals `label`
tab_row <- function(tab, label) {
  m <- as.matrix(tab)
  i <- which(m[, 1] == label)
  if (length(i) != 1) stop("row '", label, "' found ", length(i), " times")
  unname(m[i, ])
}

# A fresh, empty folder under tempdir() for functions that write files
withr_local_tempdir <- function() {
  d <- tempfile("c306test_")
  dir.create(d)
  d
}

baseline_fixture <- function() {
  utils::read.csv(system.file("extdata", "baseline_data.csv", package = "C306"))
}

# Text of each footer line of a flextable
ft_footer_text <- function(ft) {
  info <- flextable::information_data_chunk(ft)
  info <- info[info$.part == "footer", ]
  unique(vapply(split(info$txt, info$.row_id), paste, character(1), collapse = ""))
}

# Background colours used in the body of a flextable
ft_body_bg <- function(ft) {
  unique(as.vector(ft$body$styles$cells$background.color$data))
}
