#' Identify new lab adverse event to report
#'
#' @description A function to identify new lab adverse event to report from a vector of consecutive lab adverse event grade.
#'
#' @param data a numeric vector of consecutive lab adverse event grade.
#' @param gradecut a grade threshold to report.
#'
#' @return A factor (levels "Yes", "No") of the same length as `data`: "Yes" when the grade
#'   reaches `gradecut` and is higher than the previous grade (or is the first value), `NA`
#'   where the grade is missing.
#' @examples
#' # grades of one patient over consecutive visits; report grade >= 3
#' labAE(c(0, 1, 3, 3, 2, 4), gradecut = 3)
#'
#' # per patient, with dplyr
#' visits <- data.frame(id = rep(1:2, each = 3), grade = c(1, 3, 3, 3, 2, 4))
#' dplyr::mutate(dplyr::group_by(visits, id), new_ae = labAE(grade, gradecut = 3))
#' @export
labAE <- function(data, gradecut){
  if (!is.numeric(data) && !all(is.na(data)))
    c306_abort(sprintf("`data` must be a numeric vector of grades, not %s.", obj_type(data)))
  check_number(gradecut)
  cur <- data; pre <- dplyr::lag(cur, n = 1)
  out <- ifelse(is.na(cur), NA,
                ifelse((is.na(pre) | (!is.na(pre) & (pre < cur))) & (cur >= gradecut), "Yes", "No"))
  return(factor(out, levels = c("Yes", "No")))
}
