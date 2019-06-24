#' @name create_compendium
#' @title Quickly create a basic research compendium by combining several rrtools functions into one.
#'
#' @description In one step, this will create an R package, attach the MIT license to it, add the rrtools' README to it, initiate a Git repository and make an initial commit to track files in the package, and create the 'analysis' directory structure, and populate it with an R Markdown file and bib file. This function will not create a GitHub repository for the compendium, a Dockerfile, a Travis config file, or any package tests. Those require some interaction outside of R and are left to the user.
#'
#' @param pkgname location to create new package. The last component of the path will be used as the package name
#' @param data_in_git should git track the files in the data directory? Default is TRUE
#'
#' @importFrom usethis use_mit_license use_git
#' @export

create_compendium <- function(pkgname, data_in_git = TRUE){
  rrtools::use_compendium(pkgname)
  # move us into the new project
  setwd(pkgname)
  my_name <-  usethis::use_git_config()$`user.name`
  usethis::use_mit_license(name = my_name)
  rrtools::use_readme_rmd()
  rrtools::use_git_quietly()
  rrtools::use_analysis(data_in_git = data_in_git)
  devtools::install(quiet = TRUE)

}
