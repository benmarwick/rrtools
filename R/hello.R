

#' @name use_travis
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



#' @name use_analysis
#' This will create \file{analysis/paper.Rmd}, \file{{analysis/references.bib} and
#' add \pkg{bookdown} to the imported packages.
#' @rdname infrastructure
#' @export
use_analysis <- function(pkg = ".", template = 'paper.Rmd') {
  pkg <- devtools:::as.package(pkg)
  pkg$Rmd <- TRUE

  message("* Adding bookdown to Imports")
  devtools:::add_desc_package(pkg, "Imports", "bookdown")

  devtools:::use_directory("analysis", pkg = pkg)
  devtools:::use_directory("analysis/paper", pkg = pkg)
  devtools:::use_directory("analysis/figures", pkg = pkg)
  devtools:::use_directory("analysis/templates", pkg = pkg)
  devtools:::use_directory("analysis/data", pkg = pkg)
  devtools:::use_directory("analysis/data/raw_data", pkg = pkg)
  devtools:::use_directory("analysis/data/derived_data", pkg = pkg)

  # move templates for MS Word output
  invisible(file.copy(from = list.files(system.file("templates/word_templates/",
                              package = "rrtools",
                              mustWork = TRUE),
                              full.names = TRUE),
            to = "analysis/templates",
            recursive = TRUE))

  # move csl file
  invisible(file.copy(from = system.file("templates/journal-of-archaeological-science.csl",
                                                    package = "rrtools",
                                                    mustWork = TRUE),
                      to = "analysis/paper",
                      recursive = TRUE))

  template_path <- system.file("templates",
                               template,
                               package = "rrtools",
                               mustWork = TRUE)

  template_out <- whisker::whisker.render(readLines(template_path), data)

  # use_template doesn't seem to work for this...
  if(file.exists("analysis/paper/paper.Rmd")) stop("paper.Rmd exists already, quitting")
  writeLines(template_out, file("analysis/paper/paper.Rmd"))
  closeAllConnections()

  # use_template doesn't seem to work for this...
  if(file.exists("analysis/paper/references.bib")) stop("references.bib exists already, quitting")
  writeLines("", file("analysis/paper/references.bib"))
  closeAllConnections()

  message("Next: \n",
          " * Write your article/paper/thesis in Rmd file(s) in analysis/paper/", "\n",
          " * Add the citation style libray file (csl) to replace the default in analysis/paper/", "\n",
          " * Add reference details to the references.bib in analysis/paper/", "\n",
          " * For adding captions & cross-referenceing in an Rmd, see https://bookdown.org/yihui/bookdown/ ", "\n",
          " * For adding citations & reference lists in an Rmd, see http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html ")


invisible(TRUE)
}




#' @name use_dockerfile
#' This will create \file{analysis/paper.Rmd}, \file{{analysis/references.bib} and
#' add \pkg{bookdown} to the imported packages.
#' @param rocker chr, the rocker image to base this container on
#' @export
use_dockerfile <- function(pkg = ".", rocker = "verse") {
  pkg <- devtools:::as.package(pkg)

  # get R version for rocker/r-ver
  si <- sessionInfo()
  r_version <- paste0(si$R.version$major, ".", si$R.version$minor)

  gh <- devtools:::github_info(pkg$path)
  gh$r_version <- r_version
  gh$rocker <- rocker

  rrtools:::use_template("Dockerfile",
                         "Dockerfile",
                         ignore = TRUE,
                         pkg = pkg,
                         data = gh)


  message("Next: \n",
          " * Edit the dockerfile with your name & email", "\n",
          " * Edit the dockerfile to include system dependencies, such as linux libraries that are needed by the R packages you're using", "\n",
          " * Edit the last line of the  dockerfile to specify which Rmd should be rendered in the Docker container", "\n"  )

  invisible(TRUE)
}



# Given the name or vector of names, returns a named vector reporting
# whether each exists and is a directory.
dir.exists <- function(x) {
  res <- file.exists(x) & file.info(x)$isdir
  stats::setNames(res, x)
}

use_template <- function(template, save_as = template, data = list(),
                         ignore = FALSE, open = FALSE, pkg = ".") {
  pkg <- devtools::as.package(pkg)

  path <- file.path(pkg$path, save_as)
  if (!devtools:::can_overwrite(path)) {
    stop("`", save_as, "` already exists.", call. = FALSE)
  }

  template_path <- system.file("templates",
                               template,
                               package = "rrtools",
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

use_directory <- function(path, ignore = FALSE, pkg = ".") {
  pkg <- devtools::as.package(pkg)
  pkg_path <- file.path(pkg$path, path)

  if (file.exists(pkg_path)) {
    if (!devtools:::is_dir(pkg_path)) {
      stop("`", path, "` exists but is not a directory.", call. = FALSE)
    }
  } else {
    message("* Creating `", path, "`.")
    dir.create(pkg_path, showWarnings = FALSE, recursive = TRUE,  mode = "0777")
  }

  if (ignore) {
    message("* Adding `", path, "` to `.Rbuildignore`.")
    devtools::use_build_ignore(path, pkg = pkg)
  }

  invisible(TRUE)
}
