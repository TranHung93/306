
# import OUCRU data dictionary --------------------------------------------

#' Import OUCRU's data dictionary into R
#'
#' @description A function to import OUCRU's data dictionary into R.
#'
#' @param table_name a character vector specifies names of Excel sheets (in OUCRU's data dictionary) to be imported.
#'   A grid is named `<CRF>_<Grid>`; its CRF sheet must be requested too.
#' @param input a character value specifies path to the OUCRU's data dictionary file (in Excel format).
#' @param output a character value specifies the `.RData` file in which to save imported data.
#'
#' @return Nothing (called for its side effect). The file `output` contains one data frame
#'   `<sheet>_info` per imported sheet, and `sheet_info_name`, the names of those data frames.
#' @examples
#' dict <- system.file("extdata", "oucru_dictionary.xlsx", package = "C306")
#' out <- tempfile(fileext = ".RData")
#' import.info(c("ENR", "LAB", "LAB_G1"), input = dict, output = out)
#' load(out)
#' sheet_info_name
#' ENR_info
#' @export
import.info <- function(table_name, input, output) {
  ### get all available sheets
  crfs <- readxl::read_excel(path = input, sheet = "CRFs")
  ### check Grids table
  input_sheet <- readxl::excel_sheets(input)
  grid_id <- grep(pattern = "grids", x = input_sheet, ignore.case = TRUE)
  if (length(grid_id) > 0) {
    grids <- readxl::read_excel(path = input, sheet = grid_id)
    sheet_grid <- grids$sheet_grid <- with(grids, paste(CRF, Grid, sep = "_"))
  } else {
    sheet_grid <- NULL
  }
  sheet_final <- intersect(unique(c(crfs$CRF, sheet_grid)),
                           table_name)

  ### import
  #### no-grid sheets
  for (i in sheet_final[!sheet_final %in% sheet_grid] ) {
    assign(paste(i, "info", sep = "_"),
           subset(readxl::read_excel(path = input, sheet = i), (!`Data type` %in% "Title")))
  }
  #### grid sheets
  #browser()
  if (!is.null(sheet_grid)) {
    grids <- grids[grids$sheet_grid %in% sheet_final, ]
    for (i in seq_len(nrow(grids))) {
      tmp <- rbind(subset(get(paste(grids$CRF[i], "info", sep = "_")),
                          Grid == grids$Grid[i]),
                   c(paste(grids$CRF[i], grids$Grid[i], "SEQ", sep = "_"), "", "Number", rep("", 5)),
                   c("USUBJID", "Unique subject id", "Free Text", rep("", 5)))
      assign(paste(grids$CRF[i], grids$Grid[i], "info", sep = "_"),
             tmp)
    }
  }
  #### all info-sheet names
  sheet_info_name <- paste(sheet_final, "info", sep = "_")

  ### save
  save(list = c(sheet_info_name, "sheet_info_name"), file = output)
}

# Category label made safe for recode strings: transliterated to ASCII, then
# only printable ASCII is kept and colons are removed. (The former pattern
# "[\x01-\x1f\x7f-\xff:]" is invalid in UTF-8 locales.)
._ascii_label <- function(x) {
  x <- stringi::stri_trans_general(x, id = "Latin-ASCII")
  gsub(":", "", gsub("[^ -~]", "", x))
}

# OUCRU data types -> C306 types (any other type gives NA)
._oucru_types <- c(
  Category = "factor", ExCategory = "factor", RadioList = "factor",
  `Free Text` = "character", Title = "character", CombinedKey = "character",
  Time = "character", Check = "character", Other = "character",
  EDateTime = "datetime", SDateTime = "datetime", DateTime = "datetime",
  DateTime2 = "datetime", DateTime3 = "datetime",
  Integer = "numeric", Float = "numeric", Number = "numeric"
)

# convert OUCRU's data dictionary to a general data dictionary -----------------

#' Convert imported OUCRU's data dictionary into a general data dictionary
#'
#' @description A function to convert imported OUCRU's data dictionary into a general data dictionary.
#'
#' @param oucru_info a data frame contains imported data of a sheet from OUCRU's data dictionary.
#' @param oucru_category a data frame specifies how categorical variables are coded in OUCRU's database.
#'
#' @return A data frame contains data dictionary information in a general format (columns
#'   `varname`, `label`, `type`, `unit`, `value`, `levels`, `missing`, `scale`, `condition`,
#'   `strict`), ready for [myformat.data()] and [inspect.data()].
#' @examples
#' oucru_info <- data.frame(
#'   Category = c(NA, "SEX"), Variable = c("AGE", "SEX"), Caption = c("Age", "Sex"),
#'   `Data type` = c("Integer", "RadioList"), Format = NA, check.names = FALSE)
#' oucru_category <- data.frame(category = "SEX", submissionvalue = c("1", "2"),
#'                              text = c("Male", "Female"))
#' convert.info(oucru_info, oucru_category)
#' @import dplyr
#' @export
convert.info <- function(oucru_info, oucru_category) {
  ## get value & level for factors
  cat_tmp <- distinct(oucru_category) %>%
    rename(Category = category) %>%
    mutate(submissionvalue = ifelse(is.na(suppressWarnings(as.numeric(submissionvalue))),
                                    paste0("'", submissionvalue, "'", sep = ""),
                                    submissionvalue),
           text = paste0("'", gsub(pattern = "=", replacement = " equal ",
                                   x = ._ascii_label(gsub(pattern = ";", replacement = ",", x = text))), "'")) %>%
    group_by(Category) %>%
    summarise(value = paste(submissionvalue, text, sep = "=", collapse = ";"),
              level = paste(text, collapse = ";")) %>%
    ungroup()

  ## convert
  output <- merge(oucru_info, cat_tmp, by = "Category", all.x = TRUE) %>%
    mutate(Format = tolower(Format)) %>%
    transmute(varname = Variable,
              label   = Caption,
              type    = unname(._oucru_types[`Data type`]),
              unit    = NA,
              value   = ifelse(is.na(type), NA,
                               ifelse(type == "factor", value,
                                      ifelse(type == "character", NA,
                                             ifelse(type == "datetime" & Format %in% c("dd/mm/yy"), "ymd_hms",
                                                    ifelse(type == "datetime" & Format %in% c("hh:mm"), "ymd_hms",
                                                           ifelse(type == "numeric", NA, NA)))))),
              levels  = ifelse(is.na(type), NA,
                               ifelse(type != "factor", NA, level)),
              missing = NA,
              scale = NA,
              condition = NA,
              strict = "Yes")
  return(subset(output, !is.na(varname)))
}
