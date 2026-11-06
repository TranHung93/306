# Generator for inst/extdata/oucru_dictionary.xlsx, a small OUCRU-style data
# dictionary (a CRFs sheet, a Grids sheet and two CRF sheets) used by the
# import.info() example and tests. Run from the package root; needs openxlsx.
out <- "inst/extdata/oucru_dictionary.xlsx"
dir.create(dirname(out), showWarnings = FALSE, recursive = TRUE)
crfs <- data.frame(CRF = c("ENR", "LAB"))
grids <- data.frame(CRF = "LAB", Grid = "G1")
enr <- data.frame(
  Variable = c("ENR_TITLE", "AGE", "SEX", "ENRDATE"),
  Caption = c("Enrolment", "Age", "Sex", "Enrolment date"),
  `Data type` = c("Title", "Integer", "RadioList", "DateTime"),
  Category = c(NA, NA, "SEX", NA),
  Format = c(NA, NA, NA, "dd/mm/yy"),
  Grid = NA, Note1 = NA, Note2 = NA,
  check.names = FALSE, stringsAsFactors = FALSE
)
lab <- data.frame(
  Variable = c("HB", "WBC"),
  Caption = c("Haemoglobin", "White cells"),
  `Data type` = c("Float", "Float"),
  Category = NA, Format = NA,
  Grid = c("G1", "G1"), Note1 = NA, Note2 = NA,
  check.names = FALSE, stringsAsFactors = FALSE
)
openxlsx::write.xlsx(list(CRFs = crfs, Grids = grids, ENR = enr, LAB = lab), out, overwrite = TRUE)
print(readxl::excel_sheets(out))
