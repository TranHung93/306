#' Create project's folder based on pre-defined folder structure
#'
#' @description A generic function to create a project's folder based on pre-defined folder structure.
#'
#' @param dir a character specifies where to create the project's folder. It must not exist yet,
#'   or be an empty folder.
#' @param structure a character specifies the pre-defined folder structure to be used.
#'
#' @return The path of the created project folder, invisibly. A message confirms where the
#'   project was created.
#' @examples
#' proj <- file.path(tempdir(), "myStudy")
#' createProject(proj)
#' list.files(proj)
#' unlink(proj, recursive = TRUE)
#' @export
createProject <- function(dir, structure = c("OUCRU_RCT_wInterim")){
  ## to create project directory
  ## initial version: 23 July 2015

  check_string(dir)
  if (length(structure) > 1) {structure <- "OUCRU_RCT_wInterim"}
  check_string(structure)

  ## the structure must ship with the package
  available <- list.dirs(system.file("structure", package = "C306"), full.names = FALSE, recursive = FALSE)
  if (!structure %in% available) {
    c306_abort(sprintf("Unknown `structure` \"%s\". Available structure(s): %s.",
                       structure, paste0("\"", available, "\"", collapse = ", ")))
  }

  ## refuse to write into a non-empty folder (files would silently not be copied)
  if (dir.exists(dir) && length(list.files(dir, all.files = TRUE, no.. = TRUE))) {
    c306_abort(sprintf("`dir` (%s) already exists and is not empty.", dir))
  }

  ## create destination folder
  if (!dir.exists(dir) && !dir.create(dir, recursive = TRUE)) {
    c306_abort(sprintf("Could not create the folder %s.", dir))
  }

  ## copy folder structure into destination folder
  copied <- file.copy(from = file.path(system.file(package = "C306"), "structure", structure, "."),
                      to = dir, recursive = TRUE)
  if (!all(copied)) {
    c306_abort(sprintf("Could not copy the project structure into %s.", dir))
  }
  rproj <- file.path(dir, paste0(structure, ".Rproj"))
  if (!file.exists(rproj) ||
      !file.rename(from = rproj, to = file.path(dir, paste0(basename(dir), ".Rproj")))) {
    c306_abort(sprintf("Could not create the RStudio project file %s.Rproj in %s.", basename(dir), dir))
  }

  # inform
  message(paste("Project", basename(dir), "was created in", dirname(dir)))
  invisible(dir)
}
