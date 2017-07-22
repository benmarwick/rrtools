
#' @name use_compendium
#' @title Creates an R package suitable to use as a research compendium
#'
#' This is devtools::create() with an additional step to either start the project in RStudio, or set the working directory to the pkg location, if not using RStudio
#' @param browse open a browser window to enable Travis builds for the package
#' automatically.
#' @import devtools rstudioapi
#' @export
#' @aliases add_travis
use_compendium <- function(path, description = getOption("devtools.desc"),
                           check = FALSE, rstudio = TRUE, quiet = FALSE){

  devtools::create(path, description = getOption("devtools.desc"),
                   check, rstudio, quiet)

  message("The package", path, " has been created \n",
          "Next: \n",
          " * Edit the DESCRIPTION file \n",
          " * Use other rrtools functions to add components to the compendium \n \n",
          "Now opening the new compendium...")

  Sys.sleep(1) #

  # if we're using RStudio, open the Rproj, otherwise setwd()
  if(rstudioapi::isAvailable()) rstudioapi::callFun("openProject", paste0("./", path))
  setwd(path)

  message("Done. The working directory is currently ", getwd())

}



#' @name use_travis
#' @title Add a travis config file
#'
#' This differs from devtools by directing travis to build the Docker container and push the successful result to Docker Hub.
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
#' @title Adds and analysis directory (and sub-directories), and an Rmd file ready to write
#'
#' This will create \file{analysis/paper.Rmd}, \file{analysis/references.bib}
#' and several others, and add \pkg{bookdown} to the imported packages.
#' @export
use_analysis <- function(pkg = ".", template = 'paper.Rmd', data = list()) {
  pkg <- devtools:::as.package(pkg)
  pkg$Rmd <- TRUE
  gh <- devtools:::github_info(pkg$path)

  message("* Adding bookdown to Imports")
  devtools:::add_desc_package(pkg, "Imports", "bookdown")

  message("* Creating analysis/ directory")
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


  if(file.exists("analysis/paper/paper.Rmd")) stop("paper.Rmd exists already, quitting")
  # inject the pkg name into the Rmd
  rmd <- readLines(template_path)
  rmd <- c(rmd[1:32], paste0("\nlibrary(", gh$repo, ")"), rmd[33:length(rmd)])
  # use_template doesn't seem to work for this...
  writeLines(rmd, file("analysis/paper/paper.Rmd"))
  closeAllConnections()

  # use_template doesn't seem to work for this...
  if(file.exists("analysis/paper/references.bib")) stop("references.bib exists already, quitting")
  writeLines("", file("analysis/paper/references.bib"))
  closeAllConnections()


  devtools:::use_build_ignore("analysis", escape = FALSE, pkg = pkg)

  message("Next: \n",
          " * Write your article/paper/thesis in Rmd file(s) in analysis/paper/", "\n",
          " * Add the citation style libray file (csl) to replace the default in analysis/paper/", "\n",
          " * Add reference details to the references.bib in analysis/paper/", "\n",
          " * For adding captions & cross-referenceing in an Rmd, see https://bookdown.org/yihui/bookdown/ ", "\n",
          " * For adding citations & reference lists in an Rmd, see http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html ")

  devtools:::open_in_rstudio("analysis/paper/paper.Rmd")


invisible(TRUE)
}




#' @name use_dockerfile
#' @title Add a Dockerfile
#'
#' This will create a basic \file{Dockerfile} based on rocker/verse
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
                         data = gh,
                         open = TRUE)

  message("Next: \n",
          " * Edit the dockerfile with your name & email", "\n",
          " * Edit the dockerfile to include system dependencies, such as linux libraries that are needed by the R packages you're using", "\n",
          " * Edit the last line of the  dockerfile to specify which Rmd should be rendered in the Docker container", "\n"  )

  invisible(TRUE)
}

#' Creates skeleton README files with sections for
#' \itemize{
#' \item a high-level description of the package and its goals
#' \item R code to install from GitHub, if GitHub usage detected
#' \item a basic example
#' }
#' Use \code{Rmd} if you want a rich intermingling of code and data. Use
#' \code{md} for a basic README. \code{README.Rmd} will be automatically
#' added to \code{.Rbuildignore}. The resulting README is populated with default
#' YAML frontmatter and R fenced code blocks (\code{md}) or chunks (\code{Rmd}).
#'
#' @param pkg package description, can be path or package name.  See
#'   \code{\link{as.package}} for more information
#' @import devtools
#' @export
#' @examples
#' \dontrun{
#' use_readme_rmd()
#' use_readme_md()
#' }
#' @family infrastructure
use_readme_rmd <- function(pkg = ".") {
  pkg <- devtools:::as.package(pkg)

  if (devtools:::uses_github(pkg$path)) {
    pkg$github <- devtools:::github_info(pkg$path)
  }
  pkg$Rmd <- TRUE

  rrtools:::use_template("omni-README", save_as = "README.Rmd", data = pkg,
               ignore = TRUE, open = TRUE, pkg = pkg)
  devtools:::use_build_ignore("^README-.*\\.png$", escape = FALSE, pkg = pkg)

  if (devtools:::uses_git(pkg$path) && !file.exists(pkg$path, ".git", "hooks", "pre-commit")) {
    message("* Adding pre-commit hook")
    devtools:::use_git_hook("pre-commit", devtools:::render_template("readme-rmd-pre-commit.sh"),
                 pkg = pkg)
  }

  message("* Rendering README.Rmd to README.md for GitHub.")
  rmarkdown::render("README.Rmd")

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
    devtools:::open_in_rstudio(path)
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




