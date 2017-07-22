#' @rdname infrastructure
#' @section \code{use_travis}:
#' Add basic travis template to a package. Also adds \code{.travis.yml} to
#' \code{.Rbuildignore} so it isn't included in the built package.
#' @param browse open a browser window to enable Travis builds for the package
#' automatically.
#' @import devtools
#' @export
#' @aliases add_travis
use_travis <- function(pkg = ".", browse = interactive()) {
  pkg <- as.package(pkg)

  use_template("travis.yml", ".travis.yml", ignore = TRUE, pkg = pkg)

  gh <- github_info(pkg$path)
  travis_url <- file.path("https://travis-ci.org", gh$fullname)

  message("Next: \n",
          " * Add a travis shield to your README.md:\n",
          "[![Travis-CI Build Status]",
          "(https://travis-ci.org/", gh$fullname, ".svg?branch=master)]",
          "(https://travis-ci.org/", gh$fullname, ")\n",
          " * Turn on travis for your repo at ", travis_url, "\n"
  )
  if (browse) {
    utils::browseURL(travis_url)
  }

  invisible(TRUE)
}