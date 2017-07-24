#' @name use_compendium
#' @title Creates an R package suitable to use as a research compendium
#'
#' @description This is devtools::create() with an additional step to either start the project in RStudio, or set the working directory to the pkg location, if not using RStudio
#'
#' @param path location to create new package. The last component of the path will be used as the package name
#' @param description list of description values to override default values or add additional values
#' @param check if TRUE, will automatically run \code{devtools::check}
#' @param rstudio create an RStudio project file? (with \code{devtools::use_rstudio})
#' @param quiet if FALSE, the default, prints informative messages
#'
#' @import devtools rstudioapi
#' @export
use_compendium <- function(path, description = getOption("devtools.desc"),
                           check = FALSE, rstudio = TRUE, quiet = FALSE){

  devtools::create(path, description = getOption("devtools.desc"),
                   check, rstudio, quiet)

  message("The package", path, " has been created \n",
          "Next: \n",
          " * Edit the DESCRIPTION file \n",
          " * Use other rrtools functions to add components to the compendium \n \n",
          "Now opening the new compendium...")

  Sys.sleep(3) #

  # if we're using RStudio, open the Rproj, otherwise setwd()
  if(rstudioapi::isAvailable()) rstudioapi::callFun("openProject", paste0("./", path))
  setwd(path)

  message("Done. The working directory is currently ", getwd())

}



#' @name use_travis
#' @aliases add_travis
#' @title Add a travis config file
#'
#' @description This has two options. One is the same as `devtools::use_travis`, a vanilla travis config that builds, installs and runs the custom package on travis. The other type of configuration directs travis to build the Docker container (according to the instructions in your Dockerfile) and push the successful result to Docker Hub. Using a Dockerfile is recommended because it gives greater isolation of the computational enviroment, and will result in much faster build times on travis.
#'
#' @param pkg defaults to the package in the current working directory
#' @param browse open a browser window to enable Travis builds for the package automatically
#' @param docker logical, if TRUE (the default) the travis config will build a Docker container according to the instructions in the Dockerfile, and build and install the package in that container. If FALSE, the standard config for R on travis is used.
#'
#' @import devtools
#' @export
use_travis <- function(pkg = ".", browse = interactive(), docker = TRUE) {
  pkg <- devtools::as.package(pkg)

  gh <- devtools:::github_info(pkg$path)
  travis_url <- file.path("https://travis-ci.org", gh$fullname)

  if(docker){
    use_template("travis.yml-with-docker",
                         ".travis.yml",
                         ignore = TRUE,
                         pkg = pkg,
                         data = gh)
  } else {
    gh$date <- format(Sys.Date(), "%Y-%m-%d")
    use_template("travis.yml-no-docker",
                           ".travis.yml",
                           ignore = TRUE,
                           pkg = pkg,
                           data = gh)
  }

  message("Next: \n",
          " * Add a travis shield to your README.Rmd:\n",
          "[![Travis-CI Build Status]",
          "(https://travis-ci.org/", gh$fullname, ".svg?branch=master)]",
          "(https://travis-ci.org/", gh$fullname, ")\n",
          " * Turn on travis for your repo at ", travis_url, "\n",
          ifelse(docker,
          " * To connect Docker, go to https://travis-ci.org/, and add your environment variables: DOCKER_EMAIL, DOCKER_USER, DOCKER_PASS to enable pushing to the Docker Hub",
          "")
  )

  if (browse) {
    utils::browseURL(travis_url)
  }

  invisible(TRUE)
}



#' @name use_analysis
#' @aliases add_analysis
#' @title Adds and analysis directory (and sub-directories), and an Rmd file ready to write
#'
#' @description This will create \file{analysis/paper.Rmd}, \file{analysis/references.bib}
#' and several others, and add \pkg{bookdown} to the imported packages listed in the DESCRIPTION file.
#'
#' @param pkg defaults to the package in the current working directory
#' @param template the template file to use to create the main anlaysis document. Defaults to 'paper.Rmd', ready to write R Markdown and knit to MS Word using bookdown
#' @param data forwarded to \code{whisker::whisker.render}
#'
#' @export
use_analysis <- function(pkg = ".", template = 'paper.Rmd', data = list()) {
  pkg <- devtools::as.package(pkg)
  pkg$Rmd <- TRUE
  gh <- devtools:::github_info(pkg$path)

  message("* Adding bookdown to Imports")
  devtools:::add_desc_package(pkg, "Imports", "bookdown")

  message("* Creating analysis/ directory and contents")
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

  # create a file that inform of best practices
  invisible(file.create("analysis/data/DO-NOT-EDIT-ANY-FILES-IN-HERE-BY-HAND"))


  devtools::use_build_ignore("analysis", escape = FALSE, pkg = pkg)

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
#' @description This will create a basic \file{Dockerfile} based on rocker/verse
#'
#' @param pkg defaults to the package in the current working directory
#' @param rocker chr, the rocker image to base this container on
#'
#' @import utils devtools
#' @export
use_dockerfile <- function(pkg = ".", rocker = "verse") {
  pkg <- devtools::as.package(pkg)

  # get R version for rocker/r-ver
  si <- utils::sessionInfo()
  r_version <- paste0(si$R.version$major, ".", si$R.version$minor)

  gh <- devtools:::github_info(pkg$path)
  gh$r_version <- r_version
  gh$rocker <- rocker

  use_template("Dockerfile",
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
#'
#' @description \itemize{
#' \item a high-level description of the package and its goals
#' \item R code to install from GitHub, if GitHub usage detected
#' \item a basic example
#' }
#' \code{README.Rmd} will be automatically
#' added to \code{.Rbuildignore}. The resulting README is populated with default
#' YAML frontmatter and R fenced code chunks (\code{Rmd}).
#'
#' @param pkg package description, can be path or package name.  See
#'   \code{\link{as.package}} for more information
#' @import devtools
#' @export
#' @examples
#' \dontrun{
#' use_readme_rmd()
#' }
#' @family infrastructure
use_readme_rmd <- function(pkg = ".") {
  pkg <- devtools::as.package(pkg)

  if (devtools:::uses_github(pkg$path)) {
    pkg$github <- devtools:::github_info(pkg$path)
  }
  pkg$Rmd <- TRUE

  use_template("omni-README", save_as = "README.Rmd", data = pkg,
               ignore = TRUE, open = TRUE, pkg = pkg)

  devtools::use_build_ignore("^README-.*\\.png$", escape = FALSE, pkg = pkg)

  if (devtools:::uses_git(pkg$path) && !file.exists(pkg$path, ".git", "hooks", "pre-commit")) {
    message("* Adding pre-commit hook")
    devtools::use_git_hook("pre-commit", devtools:::render_template("readme-rmd-pre-commit.sh"),
                 pkg = pkg)
  }


  message("* Rendering README.Rmd to README.md for GitHub.")
  rmarkdown::render("README.Rmd", output_format = NULL)

  message("* Adding code of conduct.")
  use_code_of_conduct()

  message("* Adding instructions to contributors.")
  use_contributing()


  invisible(TRUE)
}

# helpers, not exported -------------------------------------------------------

use_code_of_conduct <- function(pkg = "."){
  pkg <- devtools::as.package(pkg)
  use_template("CONDUCT.md", ignore = TRUE, pkg = pkg)
}

use_contributing <- function(pkg = "."){
  pkg <- devtools::as.package(pkg)
  gh <- devtools:::github_info(pkg$path)
  use_template("CONTRIBUTING.md", ignore = TRUE, pkg = pkg, data = gh)
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




