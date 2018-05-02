globalVariables(c("gh", "opts", "getProjectDir", "libDir", ".packrat_mutables", "pkgDescriptionDependencies", "union_write", "yesno", "github_POST", "github_GET", "dropSystemPackages", "readDcf", "recursivePackageDependencies", "silent", "sort_c")) # suppress some warnings

#' @name use_compendium
#' @title Creates an R package suitable to use as a research compendium, and
#' switches to the working directory of this new package, ready to work
#'
#' @description This is devtools::create() with an additional step to either start the project in RStudio, or set the working directory to the pkg location, if not using RStudio
#'
#' @param path location to create new package. The last component of the path will be used as the package name
#' @param description list of description values to override default values or add additional values
#' @param check if TRUE, will automatically run \code{devtools::check}
#' @param rstudio create an RStudio project file? (with \code{devtools::use_rstudio})
#' @param quiet if FALSE, the default, prints informative messages
#'
#' @importFrom devtools create
#' @importFrom rstudioapi isAvailable
#' @export
use_compendium <- function(path, description = getOption("devtools.desc"),
                           check = FALSE, rstudio = TRUE, quiet = FALSE){

  devtools::create(path,
                   description = getOption("devtools.desc"),
                   check,
                   rstudio,
                   quiet)

  message("The package ", path, " has been created \n",
          "Next: \n\n",
          " * Edit the DESCRIPTION file \n",
          " * Use other rrtools functions to add components to the compendium \n",
          " Please wait a moment...  \n")

  Sys.sleep(3) # give the user a chance to read the console output

  # if we're using RStudio, open the Rproj, otherwise setwd()
  # when the release includes openProject", use this
  # rstudioapi::callFun("openProject", paste0("./", path))
  if(rstudioapi::isAvailable()) {
   message(" Opening the new compendium in a new RStudio session...")
   browseURL(paste0(path, "/", basename(path), ".Rproj"))
  } else {
   message("Now opening the new compendium...")
   setwd(path)
   message("Done. The working directory is currently ", getwd())
  }

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
#' @param rmd_to_knit path to .Rmd file that should be knitted by the virtual build environment: default is "path_to_rmd" which causes the function to search for a paper.Rmd file by itself.
#' @param ask should the function ask with \code{yesno()} if an old .travis.yml should be overwritten with a new one? default: TRUE
#'
#' @importFrom curl has_internet
#' @importFrom utils browseURL
#' @export
use_travis <- function(
  pkg = ".",
  browse = interactive(),
  docker = TRUE,
  rmd_to_knit = "path_to_rmd",
  ask = TRUE
) {
  pkg <- as.package(pkg)

  # get path to Rmd file to knit
  if(rmd_to_knit == "path_to_rmd"){
    dir_list   <- list.dirs()
    paper_dir  <- dir_list[grep(pattern = "/paper", dir_list)]
    rmd_path   <- regmatches(paper_dir, regexpr("analysis|vignettes|inst", paper_dir))
    rmd_path <-  file.path(rmd_path, "paper/paper.Rmd")
  } else {
    #  preempt the string with home directory notation or back-slash (thx Matt Harris)
    rmd_path <- gsub("^.|^/|^./|^~/","",rmd_to_knit)
  }

  gh <- github_info(pkg$path)
  gh$rmd_path <- rmd_path
  travis_url <- file.path("https://travis-ci.org", gh$fullname)

  if(docker){
    use_template("travis.yml-with-docker",
                         ".travis.yml",
                         ignore = TRUE,
                         pkg = pkg,
                         data = gh,
                         out_path = "",
                         ask = ask)
  } else {
    gh$date <- format(Sys.Date(), "%Y-%m-%d")
    use_template("travis.yml-no-docker",
                           ".travis.yml",
                           ignore = TRUE,
                           pkg = pkg,
                           data = gh,
                           out_path = "",
                           ask = ask)
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
    if(curl::has_internet()) {
      utils::browseURL(travis_url)
    } else {
      message("No internet connection. Can't open https://travis-ci.org.")
    }
  }

  invisible(TRUE)
}


#' @name use_circleci
#' @aliases use_circleci
#' @title Add a circleci config file
#'
#' @description This will build the Docker container on the Circle-CI service.
#' The advantage of Circle-CI over Travis is that Circle-CI will freely work with
#' private GitHub repositories. Only the paid service from Travis will work
#' with private GitHub repositories. Before using this function you need
#' to create an account with Circle-CI, using your GitHub account. If you want
#' Circle-CI to run on a private GitHub repo, make sure you give Circle-CI
#' access to 'all repos' when you log in with your GitHub credentials.
#'
#' @param pkg defaults to the package in the current working directory
#' @param browse open a browser window to enable Circle-CI builds for the package automatically
#' @param docker_hub should circleci push to Docker Hub after a successful build?
#'
#' @importFrom curl has_internet
#' @importFrom utils browseURL
#' @export
use_circleci <- function(pkg = ".", browse = interactive(), docker_hub = TRUE) {
  pkg <- as.package(pkg)

  gh <- github_info(pkg$path)
  circleci_url <- file.path("https://circleci.com/gh/", gh$username)

  if(docker_hub){

    use_template("circle.yml-with-docker-hub",
                 "circle.yml",
                 ignore = TRUE,
                 pkg = pkg,
                 data = gh,
                 out_path = "")

  } else {

    use_template("circle.yml-without-docker-hub",
                 "circle.yml",
                 ignore = TRUE,
                 pkg = pkg,
                 data = gh,
                 out_path = "")

  }


  message("Next: \n",
          " * Add a circleci shield to your README.Rmd:\n",
          "[![Circle-CI Build Status]",
          "(https://circleci.com/gh/", gh$fullname, ".svg?style=shield&circle-token=:circle-token)]",
          "(https://circleci.com/gh/", gh$fullname, ")\n",
          " * Turn on circleci for your repo at ", circleci_url, "\n",
          "   and add your environment variables: DOCKER_EMAIL, ", "\n",
          "   DOCKER_USER, DOCKER_PASS.",  "\n",
          ifelse(docker_hub,
          paste0(" * Your Docker container will be pushed to the Docker Hub", "\n",
          "   if the build completes successfully", "\n" ),
          paste0(" * Your Docker container will be kept private and NOT be pushed to the Docker Hub", "\n" )))

  if (browse) {
    if(curl::has_internet()) {
      utils::browseURL(circleci_url)
    } else {
      message("No internet connection. Can't open ", circleci_url)
    }
  }

  invisible(TRUE)
}




#' @name use_analysis
#' @aliases add_analysis
#' @title Adds an analysis directory (and sub-directories), and an Rmd file ready to write
#'
#' @description This will create \file{paper.Rmd}, \file{references.bib}
#' and several others, and add \pkg{bookdown} to the imported packages listed in the DESCRIPTION file.
#'
#' @param pkg defaults to the package in the current working directory
#' @param template the template file to use to create the main analysis document. Defaults to 'paper.Rmd', ready to write R Markdown and knit to MS Word using bookdown
#' @param location the location where the directories and files will be written to. Defaults to a top-level 'analysis' directory. Other options are 'inst' (for the inst/ directory, so that all the contents will be included in the installed package) and 'vignettes' (as in a regular package vignette, all contents will be included in the installed package).
#' @param data forwarded to \code{whisker::whisker.render}
#' @param data_in_git should git track the files in the data directory?
#' @export
use_analysis <- function(pkg = ".", location = "top_level", template = 'paper.Rmd', data = list(), data_in_git = TRUE) {
  pkg <- as.package(pkg)
  pkg$Rmd <- TRUE
  gh <- github_info(pkg$path)

  message("* Adding bookdown to Imports")
  add_desc_package(pkg, "Imports", "bookdown")

  location <- ifelse(location == "top_level", "analysis",
                     ifelse(location == "vignettes", "vignettes",
                            ifelse(location == "inst", "inst",
                                   stop("invalid 'location' argument"))))

  # create file structure...
 create_directories(location, pkg)

 # add template files for paper.Rmd, .bib, etc. ...
 switch(
   location,
   vignettes =  use_vignette_rmd(location,
                                 pkg,
                                 gh,
                                 template),
   analysis =   {use_paper_rmd(pkg,
                                location = file.path(location, "paper"),
                                gh,
                                template);
                use_build_ignore("analysis",
                                 escape = FALSE,
                                 pkg = pkg)
     },
   inst =       use_paper_rmd(pkg,
                               location = file.path(location, "paper"),
                               gh,
                               template)
 )

 if (!data_in_git) use_git_ignore("*/data/*")

  message("Next: \n",
          " * Write your article/paper/thesis in Rmd file(s)", "\n",
          " * Add the citation style libray file (csl) to replace the default provided here", "\n",
          " * Add reference details to the references.bib", "\n",
          " * For adding captions & cross-referenceing in an Rmd, see https://bookdown.org/yihui/bookdown/ ", "\n",
          " * For adding citations & reference lists in an Rmd, see http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html ", "\n",
          ifelse(!data_in_git,
          " * Your data files are NOT tracked by Git and will not be pushed to GitHub", ""))



invisible(TRUE)
}

#' @name use_dockerfile
#' @title Add a Dockerfile
#'
#' @description This will create a basic \file{Dockerfile} based on rocker/verse
#'
#' @param pkg defaults to the package in the current working directory
#' @param rocker chr, the rocker image to base this container on
#' @param rmd_to_knit, chr, path to the Rmd file to render in the Docker
#' container, relative to the top level of the compendium
#' (i.e. "analysis/paper/paper.Rmd"). There's no need to specify this if your Rmd
#' to render is at "analysis/paper/paper.Rmd", "vignettes/paper/paper.Rmd" or
#' "inst/paper/paper.Rmd". If you have a custom directory structure, and a custom
#' file name for the Rmd file, you can specify that file path and name here so
#' Docker can find the file to render in the container.B
#'
#' @import utils devtools
#' @export

  use_dockerfile <- function(pkg = ".", rocker = "verse", rmd_to_knit = "path_to_rmd") {
  pkg <- as.package(pkg)

  # get R version for rocker/r-ver
  si <- utils::sessionInfo()
  r_version <- paste0(si$R.version$major, ".", si$R.version$minor)

  # get path to Rmd file to knit
  if(rmd_to_knit == "path_to_rmd"){
    dir_list   <- list.dirs()
    paper_dir  <- dir_list[grep(pattern = "/paper", dir_list)]
    rmd_path   <- regmatches(paper_dir, regexpr("analysis|vignettes|inst", paper_dir))
    rmd_path <-  file.path(rmd_path, "paper/paper.Rmd")
  } else {
    #  preempt the string with home directory notation or back-slash (thx Matt Harris)
    rmd_path <- gsub("^.|^/|^./|^~/","",rmd_to_knit)
  }


  # assign variables for whisker
  gh <- github_info(pkg$path)
  gh$r_version <- r_version
  gh$rocker <- rocker
  gh$rmd_path <- rmd_path

  use_template("Dockerfile",
               "Dockerfile",
               ignore = TRUE,
               pkg = pkg,
               data = gh,
               open = TRUE,
               out_path = "")

  message("Next: \n",
          " * Edit the dockerfile with your name & email", "\n",
          " * Edit the dockerfile to include system dependencies, such as linux libraries that are needed by the R packages you're using", "\n",
          " * Check the last line of the dockerfile to specify which Rmd should be rendered in the Docker container, edit if necessary", "\n"  )

  invisible(TRUE)
}
#' Creates skeleton README files
#'
#' @description
#' \code{README.Rmd} will be automatically
#' added to \code{.Rbuildignore}. The resulting README is populated with default
#' YAML frontmatter and R fenced code chunks (\code{Rmd}).
#' Your readme should contain:
#' \itemize{
#' \item a high-level description of the package and its goals
#' \item R code to install from GitHub, if GitHub usage detected
#' \item a basic example
#' }
#'
#' @param pkg package description, can be path or package name.  See
#'   \code{\link{as.package}} for more information
#' @param render_readme should the README.Rmd be directly rendered to
#' a github markdown document? default: TRUE
#' @importFrom rmarkdown render
#' @export
#' @examples
#' \dontrun{
#' use_readme_rmd()
#' }
#' @family infrastructure
use_readme_rmd <- function(pkg = ".", render_readme = TRUE) {
  pkg <- as.package(pkg)

  if (uses_github(pkg$path)) {
    pkg$github <- github_info(pkg$path)
  }
  pkg$Rmd <- TRUE


  use_template("omni-README",
               save_as = "README.Rmd",
               data = pkg,
               ignore = TRUE,
               open = TRUE,
               pkg = pkg,
               out_path = "")

  use_build_ignore("^README-.*\\.png$", escape = FALSE, pkg = pkg)

  if (uses_git(pkg$path) && !file.exists(pkg$path, ".git", "hooks", "pre-commit")) {
    message("* Adding pre-commit hook")
    use_git_hook("pre-commit", render_template("readme-rmd-pre-commit.sh"),
                 pkg = pkg)
  }

  if (render_readme) {
    message("* Rendering README.Rmd to README.md for GitHub.")
    rmarkdown::render("README.Rmd")
    unlink("README.html")
  }

  message("* Adding code of conduct.")
  use_code_of_conduct(pkg)

  message("* Adding instructions to contributors.")
  use_contributing(pkg)

  invisible(TRUE)
}

# helpers, not exported -------------------------------------------------------

use_code_of_conduct <- function(pkg){
  pkg <- as.package(pkg)
  use_template("CONDUCT.md", ignore = TRUE, pkg = pkg,
                         out_path = "")
}

use_contributing <- function(pkg){
  pkg <- as.package(pkg)
  gh <-  github_info(pkg$path)
  use_template("CONTRIBUTING.md", ignore = TRUE, pkg = pkg, data = gh,
                         out_path = "")
}


# Given the name or vector of names, returns a named vector reporting
# whether each exists and is a directory.
dir.exists <- function(x) {
  res <- file.exists(x) & file.info(x)$isdir
  stats::setNames(res, x)
}


use_template <- function(template, save_as = template, data = list(),
                         ignore = FALSE, open = FALSE, pkg = ".",
                         out_path, ask = TRUE) {
  pkg <- as.package(pkg)

  path <- file.path(pkg$path, out_path, save_as)
  if (!can_overwrite(path, ask = ask)) {
    stop("`", save_as, "` already exists.", call. = FALSE)
  }

  template_path <- template_path_fn(template)

  template_out <- whisker::whisker.render(readLines(template_path), data)

  message("* Creating `", save_as, "` from template.")
  writeLines(template_out, path)

  if (ignore) {
    message("* Adding `", save_as, "` to `.Rbuildignore`.")
    use_build_ignore(save_as, pkg = pkg)
  }

  if (open) {
    message("* Modify `", save_as, "`.")
    open_in_rstudio(path)
  }

  invisible(TRUE)
}

use_directory <- function(path, ignore = FALSE, pkg = ".") {
  pkg <- as.package(pkg)
  pkg_path <- file.path(pkg$path, path)

  if (file.exists(pkg_path)) {
    if (!is_dir(pkg_path)) {
      stop("`", path, "` exists but is not a directory.", call. = FALSE)
    }
  } else {
    message("* Creating `", path, "`.")
    dir.create(pkg_path, showWarnings = FALSE, recursive = TRUE,  mode = "0777")
  }

  if (ignore) {
    message("* Adding `", path, "` to `.Rbuildignore`.")
    use_build_ignore(path, pkg = pkg)
  }

  invisible(TRUE)
}


create_directories <- function(location, pkg){

  if (location %in% c("analysis", "vignettes", "inst")) {
  message("* Creating ", location, "/ directory and contents")
  use_directory(location, pkg = pkg)
  use_directory(paste0(location, "/paper"), pkg = pkg)
  use_directory(paste0(location, "/figures"), pkg = pkg)
  use_directory(paste0(location, "/templates"), pkg = pkg)
  use_directory(paste0(location, "/data"), pkg = pkg)
  use_directory(paste0(location, "/data/raw_data"), pkg = pkg)
  use_directory(paste0(location, "/data/derived_data"), pkg = pkg)

  # create a file that inform of best practices
  invisible(file.create(paste0(pkg$path, "/", location, "/data/DO-NOT-EDIT-ANY-FILES-IN-HERE-BY-HAND")))

  # move templates for MS Word output
  invisible(file.copy(from = list.files(system.file("templates/word_templates/",
                                                    package = "rrtools",
                                                    mustWork = TRUE),
                                        full.names = TRUE),
                      to = paste0(pkg$path, "/", location, "/templates"),
                      recursive = TRUE))

  # move csl file
  invisible(file.copy(from = system.file("templates/journal-of-archaeological-science.csl",
                                         package = "rrtools",
                                         mustWork = TRUE),
                      to = paste0(pkg$path, "/", location, "/templates"),
                      recursive = TRUE))


  # move bib file in there also
  use_template("references.bib", pkg = pkg, data = gh,
               out_path = file.path(location, "paper"))

  } else # else do this..
  {
    # BM: I think we want to let the user have some more control
    # over this, and leave thesis/book out of here?
    # message("* Creating ", location, "/ directory and contents")
    # use_directory(location, pkg = pkg)
    # invisible(file.copy(from = system.file("templates/thesis_template/.",
    #                                        package = "rrtools",
    #                                        mustWork = TRUE),
    #                     to = paste0(location),
    #                     recursive = TRUE))


  }
}


use_paper_rmd <- function(pkg, location, gh, template){

  use_template("paper.Rmd", pkg = pkg, data = list(gh),
                         out_path = location)

  # inject the pkg name into the Rmd
  rmd <- readLines(file.path(pkg$path, location, "paper.Rmd"))
  rmd <- c(rmd[1:32], paste0("\nlibrary(", pkg$package, ") # Or use devtools::load_all('.', quiet = T) if your code is in script files, rather than as functions in the `/R` diretory"), rmd[33:length(rmd)])
  # use_template doesn't seem to work for this...
  writeLines(rmd, file.path(pkg$path, location, "paper.Rmd"))
  closeAllConnections()


}


use_vignette_rmd <- function(location, pkg, gh, template, vignette_yml = "vignette-yaml"){

  pkg <- as.package(pkg)
  check_suggested("rmarkdown")
  add_desc_package(pkg, "Suggests", "knitr")
  add_desc_package(pkg, "Suggests", "rmarkdown")
  add_desc_package(pkg, "VignetteBuilder", "knitr")
  use_directory("vignettes", pkg = pkg)
  use_git_ignore("inst/doc", pkg = pkg)

  template_path <- template_path_fn(template)
  rmd <- readLines(template_path)
  vignette_yml <- readLines(template_path_fn(vignette_yml))

  # we inject a bit of vignette yml in our main paper.Rmd template:
  rmd <- c(rmd[1:18], vignette_yml, rmd[19:32], paste0("\nlibrary(", pkg$package, ")"), rmd[33:length(rmd)])
  # use_template doesn't seem to work for this...
  writeLines(rmd, file(paste0(location, "/paper/paper.Rmd")))
  closeAllConnections()

  open_in_rstudio(paste0(location, "/paper/paper.Rmd"))
}


template_path_fn <- function(template){
  system.file("templates",
               template,
               package = "rrtools",
               mustWork = TRUE)
}
