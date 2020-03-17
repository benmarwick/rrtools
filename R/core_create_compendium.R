#' @name create_compendium
#' @title Quickly create a basic research compendium by combining several rrtools functions into one.
#'
#' @description In one step, this will create an R package in an empty, git initialized directory, attach the MIT license to it, add the rrtools' README to it, create the 'analysis' directory structure, and populate it with an R Markdown file and bib file. This function will not create a GitHub repository for the compendium, a Dockerfile, a Travis config file, or any package tests. Those require some interaction outside of R and are left to the user.
#'
#' @param pkgname path to an empty, git initialized directory. The last component of the path will be used as the package name
#' @param data_in_git should git track the files in the data directory? Default is TRUE
#'
#' @importFrom usethis use_mit_license use_git
#' @export

create_compendium <- function(pkgname, data_in_git = TRUE) {

  # create new project
  rrtools::use_compendium(pkgname)

  # move us into the new project
  setwd(pkgname)

  # initialize the new project with useful features
  usethis::use_mit_license(name = usethis:::git_config_get("user.name", global = TRUE))
  rrtools::use_readme_rmd()
  rrtools::use_analysis(data_in_git = data_in_git)

  # install the package and its dependencies
  devtools::install(quiet = TRUE)

}
