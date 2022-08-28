#' @name create_compendium
#' @title Quickly create a basic research compendium by combining several rrtools functions into one.
#'
#' @description In one step, this will create an R package in an empty, git initialized directory, attach the MIT license to it, add the rrtools' README to it, create the 'analysis' directory structure, and populate it with an R Markdown file and bib file. This function will not create a GitHub repository for the compendium, a Dockerfile, a Travis config file, or any package tests. Those require some interaction outside of R and are left to the user.
#'
#' @param pkgname path to an empty, git initialized directory. The last component of the path will be used as the package name. Default is the current directory name.
#' @param data_in_git should git track the files in the data directory? Default is TRUE
#' @param rstudio create an RStudio project file? (with \code{usethis::use_rstudio})
#' @param open if TRUE and in RStudio, the new project is opened in a new instance.
#' If TRUE and not in RStudio, the working directory is set to the new project
#' @param simple if TRUE, the default, the R/ directory is not created, because it's not necessary for many if not most research repositories
#'
#' @importFrom usethis use_mit_license use_git
#' @export

create_compendium <- function(
  pkgname = getwd(),
  data_in_git = TRUE,
  rstudio = rstudioapi::isAvailable(),
  open = TRUE,
  simple = TRUE
) {

  if (!dir.exists(pkgname)) {
    dir.create(pkgname)
    message("The directory ", pkgname, " has been created.")
  } else {
    message("Creating the compendium in the current directory: ", pkgname)
  }

  # initialize the new project with useful features
  if (rstudio & open) {

    fileConn <- file(file.path(pkgname, ".Rprofile"))
    writeLines(
      c(
        # run additional commands
        paste0("usethis::use_mit_license(copyright_holder = '", get_git_config('user.name', global = TRUE), "')"),
        "cat('\n')",
        "rrtools::use_readme_rmd(render_readme = FALSE)",
        "cat('\n')",
        paste0("rrtools::use_analysis(data_in_git = ", data_in_git, ")"),
        "cat('\n')",
        # print welcome message
        "cat(crayon::bold('\nThis project was set up by rrtools.\n'))",
        "cat('\nYou can start working now or apply some more basic configuration.\n')",
        "cat('Check out ')",
        "cat(crayon::underline('https://github.com/benmarwick/rrtools'))",
        "cat(' for an explanation of all the project configuration functions of rrtools.\n')",
        "invisible(file.remove('.Rprofile'))"
      ),
      fileConn
    )
    close(fileConn)

    # create new project
    rrtools::use_compendium(
      pkgname,
      rstudio = rstudio,
      open = open,
      simple = simple,
      welcome_message = FALSE
    )

  } else {

    # create new project
    rrtools::use_compendium(
      pkgname,
      rstudio = rstudio,
      open = open,
      simple = simple,
      welcome_message = TRUE
    )

    # switch to new dir
    setwd(pkgname)

    # run additional commands
    usethis::use_mit_license(copyright_holder = get_git_config('user.name', global = TRUE))
    cat('\n')
    rrtools::use_readme_rmd(render_readme = FALSE)
    cat('\n')
    rrtools::use_analysis(data_in_git = data_in_git)
    cat('\n')

    usethis::ui_done("The working directory is now {getwd()}")

  }

}
