# Simulated example data for C306.
#
# Generates inst/extdata/baseline_data.csv, inst/extdata/ae_data.csv and
# data/baseline_data.rda, data/ae_data.rda. The data are entirely simulated:
# no real participant's values are used. They have the structure of a
# two-arm randomised trial in tetanus (same column names, types, levels and
# similar missing-data patterns as the trial data shipped before C306 0.2.0),
# with values drawn from plausible distributions.
#
# Run from the package root: Rscript data-raw/simulate_data.R
# AE terms are taken from inst/extdata/group_data.csv (a lookup table of CTCAE
# terms and their classes, not participant data).

set.seed(306)
n <- 271L

# helpers -------------------------------------------------------------------
clip <- function(x, lo, hi) pmin(pmax(x, lo), hi)
rint <- function(n, mean, sd, lo, hi) as.integer(round(clip(rnorm(n, mean, sd), lo, hi)))
rdbl <- function(n, mean, sd, lo, hi, digits) round(clip(rnorm(n, mean, sd), lo, hi), digits)
rlnint <- function(n, median, sdlog, lo, hi) as.integer(round(clip(rlnorm(n, log(median), sdlog), lo, hi)))
yn <- function(n, p_yes) ifelse(runif(n) < p_yes, "Y", "N")
# set `k` randomly chosen values to NA (k = number of missing values)
with_na <- function(x, k, rows = NULL) {
  if (k > 0) x[if (is.null(rows)) sample(length(x), k) else rows] <- NA
  x
}

# baseline data -------------------------------------------------------------
arm <- sample(rep(c("Intrathecal treatment", "Sham procedure"), length.out = n))
it <- arm == "Intrathecal treatment"

# participants without a laboratory/score panel, and with a blood gas
no_lab <- sample(n, 1)
gas <- sample(n, 26)

bl <- data.frame(
  usubjid = sprintf("SIM-%03d", seq_len(n)),
  age = rint(n, 50, 15, 16, 88),
  sex = ifelse(runif(n) < 0.78, "M", "F"),
  stringsAsFactors = FALSE
)
height <- ifelse(bl$sex == "M", rnorm(n, 1.64, 0.06), rnorm(n, 1.54, 0.06))
weight <- clip(rnorm(n, 55, 9), 35, 95)
bl$bmi <- round(clip(weight / height^2, 14, 35), 4)
bl$source <- sample(1:2, n, replace = TRUE, prob = c(0.6, 0.4))
bl$tetanus <- "Y"
# shorter ICU stay with intrathecal treatment (an arbitrary simulated effect)
bl$icudays <- with_na(rlnint(n, ifelse(it, 16, 19), 0.55, 1, 75), 2)
bl$outcome <- sample(2:4, n, replace = TRUE, prob = c(0.15, 0.75, 0.10))

comorbid <- list(  # column = c(probability of "Y", number of missing values)
  hypertension = c(0.18, 5), myocardialinfart = c(0.02, 3), angina = c(0, 2),
  perivascular = c(0.02, 4), chronicpul = c(0.03, 3), connectivetissue = c(0, 2),
  mildliver = c(0.03, 2), hemiplegia = c(0.01, 2), diawithchronic = c(0.02, 4),
  severeliver = c(0.01, 1), aids = c(0, 1), cardiacfailureiii = c(0, 1),
  cerebrovascular = c(0.02, 2), severeresp = c(0, 1), pepticulcer = c(0.03, 1),
  diabetes = c(0.06, 3), severekidney = c(0.01, 1), malignancy = c(0.01, 1),
  tumour = c(0, 2), dementia = c(0.01, 1), renalfailure = c(0.02, 0),
  electivesurgery = c(0.02, 0), emergencysurgery = c(0.03, 0)
)
for (v in names(comorbid)) bl[[v]] <- with_na(yn(n, comorbid[[v]][1]), comorbid[[v]][2])

bl$timetoadm <- rlnint(n, 4, 0.6, 1, 21)
bl$incubationperiod <- with_na(rlnint(n, 9, 0.5, 2, 30), 62)
bl$incuperiodonset <- with_na(rlnint(n, 60, 0.7, 12, 410), 33)
bl$wound <- ifelse(runif(n) < 0.3, "Deep", "Superficial/other")
bl$diffbreath <- yn(n, 0.25)
bl$ablettscore <- sample(c("I", "II", "III"), n, replace = TRUE, prob = c(0.35, 0.45, 0.20))
bl$asa <- sample(1:3, n, replace = TRUE, prob = c(0.55, 0.35, 0.10))
bl$maxtemp <- rdbl(n, 37.8, 0.6, 37, 40, 1)
bl$resp <- rint(n, 22, 4, 14, 35)
bl$fio2 <- sample(c(21L, 25L, 30L, 33L, 35L, 36L, 40L, 50L), n, replace = TRUE,
                  prob = c(0.70, 0.05, 0.08, 0.03, 0.04, 0.02, 0.05, 0.03))
bl$spo2 <- rint(n, 96, 3, 80, 99)
bl$pao2 <- NA_integer_; bl$pao2[gas] <- rint(length(gas), 100, 20, 68, 170)
bl$ph <- NA_real_; bl$ph[gas] <- rdbl(length(gas), 7.42, 0.06, 7.2, 7.6, 2)
bl$ph[gas[1]] <- NA  # one blood gas without pH
bl$plt <- rint(n, 260, 90, 89, 890)
bl$wbc <- rdbl(n, 11, 4, 4, 64, 1)
bl$hct <- rdbl(n, 40, 5, 25, 53, 1)
bl$maxhr <- rint(n, 100, 18, 54, 160)
bl$minhr <- pmin(bl$maxhr, rint(n, 75, 12, 44, 120))
bl$maxsbp <- rint(n, 145, 25, 100, 260)
bl$worstdbp <- rint(n, 80, 15, 40, 150)
bl$worstsbp <- pmin(bl$maxsbp, rint(n, 125, 25, 70, 260))
bl$vaso <- yn(n, 0.12)
bl$na <- with_na(rdbl(n, 138, 4, 130, 160, 1), 1, no_lab)
bl$k <- with_na(rdbl(n, 3.8, 0.4, 2.2, 5.1, 1), 1, no_lab)
bl$creat <- with_na(rlnint(n, 75, 0.35, 37, 700), 1, no_lab)
bl$apacheii <- with_na(rint(n, 6, 4, 0, 20), 1, no_lab)
bl$sofa <- with_na(sample(c(0:5, 7L), n, replace = TRUE, prob = c(0.45, 0.25, 0.14, 0.08, 0.04, 0.03, 0.01)), 1, no_lab)
bl$tss <- with_na(rint(n, 4, 5, -6, 21), 1, no_lab)
bl$Arm <- arm
bl$pain_score <- sample(1:5, n, replace = TRUE, prob = c(0.15, 0.30, 0.30, 0.15, 0.10))

# adverse events ------------------------------------------------------------
terms <- utils::read.csv("inst/extdata/group_data.csv", stringsAsFactors = FALSE)$ctcaename
n_ae <- 534L
with_ae <- sample(bl$usubjid, 172)
# every participant with an AE has at least one; the rest are spread unevenly
ids <- c(with_ae, sample(with_ae, n_ae - length(with_ae), replace = TRUE,
                         prob = rexp(length(with_ae))))
# every term occurs at least once; some terms are much more common than others
term_w <- rexp(length(terms))^2
ae_terms <- c(terms, sample(terms, n_ae - length(terms), replace = TRUE, prob = term_w))
grade <- sample(c("I", "II", "III", "IV"), n_ae, replace = TRUE, prob = c(0.45, 0.35, 0.15, 0.05))
original <- ifelse(runif(n_ae) < 0.85, grade,
                   sample(c("I", "II", "III", "IV"), n_ae, replace = TRUE))
ae <- data.frame(
  usubjid = ids,
  ctcaename = ae_terms[sample(n_ae)],
  ctcaegrade = with_na(grade, 6),
  original_ctcaegrade = with_na(original, 206),
  posrelunrel = sample(c("POSREL", "REL", "UNREL"), n_ae, replace = TRUE, prob = c(0.25, 0.15, 0.60)),
  unexp = with_na(yn(n_ae, 0.1), 1),
  stringsAsFactors = FALSE
)
ae <- ae[order(ae$usubjid), ]
rownames(ae) <- NULL

# write ---------------------------------------------------------------------
baseline_data <- bl
ae_data <- ae
utils::write.csv(baseline_data, "inst/extdata/baseline_data.csv", row.names = FALSE, na = "NA")
utils::write.csv(ae_data, "inst/extdata/ae_data.csv", row.names = FALSE, na = "NA")
dir.create("data", showWarnings = FALSE)
save(baseline_data, file = "data/baseline_data.rda", compress = "xz", version = 2)
save(ae_data, file = "data/ae_data.rda", compress = "xz", version = 2)
