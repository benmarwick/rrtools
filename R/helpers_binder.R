

use_binder <- function(pkg = ".") {
  pkg <- as.package(pkg)

  # get R version for rocker/r-ver
  si <- utils::sessionInfo()
  r_version <- paste0(si$R.version$major, ".", si$R.version$minor)

  # assign variables for whisker
  gh <- github_info(pkg$path)
  gh$r_version <- r_version
  gh$maintainer <- if (!is.null(pkg$maintainer)) pkg$maintainer else "Your Name <your_email@somewhere.com>"
  data = c(pkg, gh)

  use_directory(".binder", pkg = pkg)

  use_template("Dockerfile-for-binder",
               save_as = ".binder/Dockerfile",
               ignore = TRUE,
               pkg = pkg,
               open = TRUE,
               data = data,
               out_path = "")

  invisible(TRUE)
}
