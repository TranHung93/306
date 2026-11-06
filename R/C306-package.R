#' @keywords internal
"_PACKAGE"

#' @importFrom stats anova as.formula binomial coef confint confint.default
#'   fisher.test formula glm glm.fit kruskal.test lm logLik median model.frame
#'   model.matrix model.response na.omit naprint pchisq pnorm qchisq qnorm
#'   quantile relevel sd spline terms update update.formula vcov
#' @importFrom utils head write.csv
#' @importFrom graphics barplot boxplot layout text
#' @importFrom grDevices dev.off grey pdf
#' @importFrom methods as
#' @importFrom data.table setDT
NULL

# Column names used inside dplyr / ggplot2 / subset() calls (non-standard
# evaluation), declared so that R CMD check does not report them.
utils::globalVariables(c(
  ".", ".subgroup.var", ".tmp.group", "Caption", "Category", "Data type",
  "Event", "Format", "Grid", "V1", "Var1", "Var2", "Variable", "aename",
  "aetype", "arm", "category", "conf.high", "conf.low", "ep.all", "estimate",
  "fgwt", "from", "id", "level", "n_episode", "n_patient", "pt.all",
  "strata.names", "strata.split", "strata.values", "submissionvalue", "time",
  "type", "value", "varname"
))
