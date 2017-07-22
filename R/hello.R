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
  pkg <- devtools::as.package(pkg)

  gh <- devtools:::github_info(pkg$path)
  travis_url <- file.path("https://travis-ci.org", gh$fullname)

  rrtools:::use_template("travis.yml",
                         ".travis.yml",
                         ignore = TRUE,
                         pkg = pkg,
                         data = gh)



  message("Next: \n",
          " * Add a travis shield to your README.Rmd:\n",
          "[![Travis-CI Build Status]",
          "(https://travis-ci.org/", gh$fullname, ".svg?branch=master)]",
          "(https://travis-ci.org/", gh$fullname, ")\n",
          " * Turn on travis for your repo at ", travis_url, "\n",
          " * At travis, add your environment variables: DOCKER_EMAIL, DOCKER_USER, DOCKER_PASS to enable pushing to the Docker Hub"
  )
  if (browse) {
    utils::browseURL(travis_url)
  }

  invisible(TRUE)
}



use_template <- function(template, save_as = template, data = list(),
                         ignore = FALSE, open = FALSE, pkg = ".") {
  pkg <- devtools::as.package(pkg)

  path <- file.path(pkg$path, save_as)
  if (!devtools:::can_overwrite(path)) {
    stop("`", save_as, "` already exists.", call. = FALSE)
  }

  template_path <- system.file("templates", template, package = "rrtools",
                               mustWork = TRUE)
  template_out <- whisker::whisker.render(readLines(template_path), data)

  message("* Creating `", save_as, "` from template.")
  writeLines(template_out, path)

  if (ignore) {
    message("* Adding `", save_as, "` to `.Rbuildignore`.")
    devtools::use_build_ignore(save_as, pkg = pkg)
  }

  if (open) {
    message("* Modify `", save_as, "`.")
    devtools::open_in_rstudio(path)
  }

  invisible(TRUE)
}
