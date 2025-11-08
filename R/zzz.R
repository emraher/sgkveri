# -------------------------------------------------------------------------- ###
# PACKAGE HOOKS & OPTIONS----
# Set a default download dir under tempdir() unless user supplies one.
# -------------------------------------------------------------------------- ###
.onLoad <- function(...) {
  op <- options()
  ops <- list(sgkveriR.download_dir = file.path(tempdir(), "sgkveriR_dl"))
  toset <- !(names(ops) %in% names(op))
  if (any(toset)) options(ops[toset])
  if (!dir.exists(getOption("sgkveriR.download_dir"))) {
    dir.create(getOption("sgkveriR.download_dir"), recursive = TRUE, showWarnings = FALSE)
  }
  invisible()
}
