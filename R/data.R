#' Simulated baseline data of a two-arm trial
#'
#' Simulated baseline characteristics of 271 participants in a two-arm
#' randomised trial in tetanus ("Intrathecal treatment" vs "Sham procedure"),
#' used in the examples, tests and vignette. The data are entirely simulated
#' (see `data-raw/simulate_data.R` in the source package); they do not describe
#' real people. The same data are in `inst/extdata/baseline_data.csv`.
#'
#' @format A data frame with 271 rows and 61 columns:
#' \describe{
#'   \item{usubjid}{participant ID, `"SIM-001"` to `"SIM-271"`}
#'   \item{age}{age in years (integer)}
#'   \item{sex}{`"F"` or `"M"`}
#'   \item{bmi}{body mass index (kg/m^2)}
#'   \item{source}{source of admission, coded 1 or 2}
#'   \item{tetanus}{tetanus diagnosis, always `"Y"`}
#'   \item{icudays}{days in the intensive care unit (a few missing)}
#'   \item{outcome}{outcome, coded 2, 3 or 4}
#'   \item{hypertension, myocardialinfart, angina, perivascular, chronicpul,
#'     connectivetissue, mildliver, hemiplegia, diawithchronic, severeliver,
#'     aids, cardiacfailureiii, cerebrovascular, severeresp, pepticulcer,
#'     diabetes, severekidney, malignancy, tumour, dementia, renalfailure,
#'     electivesurgery, emergencysurgery}{comorbidities, `"Y"` or `"N"` (a few
#'     missing)}
#'   \item{timetoadm}{days from onset to admission}
#'   \item{incubationperiod, incuperiodonset}{incubation period and period of
#'     onset (often missing)}
#'   \item{wound}{`"Deep"` or `"Superficial/other"`}
#'   \item{diffbreath}{difficulty breathing, `"Y"` or `"N"`}
#'   \item{ablettscore}{Ablett score, `"I"`, `"II"` or `"III"`}
#'   \item{asa}{ASA physical status, 1 to 3}
#'   \item{maxtemp, resp, fio2, spo2, pao2, ph, plt, wbc, hct, maxhr, minhr,
#'     maxsbp, worstdbp, worstsbp, na, k, creat}{vital signs and laboratory
#'     values (`pao2` and `ph` mostly missing)}
#'   \item{vaso}{vasopressors, `"Y"` or `"N"`}
#'   \item{apacheii, sofa, tss}{APACHE II, SOFA and tetanus severity scores}
#'   \item{Arm}{randomised arm, `"Intrathecal treatment"` or `"Sham procedure"`}
#'   \item{pain_score}{pain score, 1 to 5}
#' }
#' @source Simulated with `data-raw/simulate_data.R`.
#' @seealso [ae_data], [sstable.baseline()]
"baseline_data"

#' Simulated adverse events of a two-arm trial
#'
#' Simulated adverse events (534 events in 172 of the 271 participants of
#' [baseline_data]), used in the examples, tests and vignette. The data are
#' entirely simulated (see `data-raw/simulate_data.R` in the source package);
#' they do not describe real people. The same data are in
#' `inst/extdata/ae_data.csv`; `inst/extdata/group_data.csv` classifies the
#' event terms.
#'
#' @format A data frame with 534 rows and 6 columns:
#' \describe{
#'   \item{usubjid}{participant ID, as in [baseline_data]}
#'   \item{ctcaename}{CTCAE term of the event}
#'   \item{ctcaegrade}{grade, `"I"` to `"IV"` (a few missing)}
#'   \item{original_ctcaegrade}{grade originally reported (often missing)}
#'   \item{posrelunrel}{relation to treatment: `"POSREL"`, `"REL"` or `"UNREL"`}
#'   \item{unexp}{unexpected event, `"Y"` or `"N"`}
#' }
#' @source Simulated with `data-raw/simulate_data.R`.
#' @seealso [baseline_data], [sstable.ae()]
"ae_data"
