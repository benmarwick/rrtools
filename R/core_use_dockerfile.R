#' @name use_dockerfile
#' @title Add a Dockerfile
#'
#' @description This will create a basic \file{Dockerfile} based on rocker/verse
#'
#' @param pkg defaults to the package in the current working directory
#' @param rocker chr, the rocker image to base this container on
#' @param qmd_to_knit, chr, path to the qmd file to render in the Docker
#' container, relative to the top level of the compendium
#' (i.e. "analysis/paper/paper.qmd"). There's no need to specify this if your qmd
#' to render is at "analysis/paper/paper.qmd", "vignettes/paper/paper.qmd" or
#' "inst/paper/paper.qmd". If you have a custom directory structure, and a custom
#' file name for the qmd file, you can specify that file path and name here so
#' Docker can find the file to render in the container.B
#' @param use_gh_action, lgl, create a configuration figure to activate GitHub Actions
#' continuous integration? Uses the Dockerfile to generate a Docker container, and
#' renders the qmd file in that.
#'
#' @import utils
#' @export

  use_dockerfile <- function(pkg = ".",
                             rocker = "verse",
                             qmd_to_knit = "path_to_qmd",
                             use_gh_action = TRUE) {
  pkg <- as.package(pkg)

  # get R version for rocker/r-ver
  si <- utils::sessionInfo()
  r_version <- paste0(si$R.version$major, ".", si$R.version$minor)

  # get path to qmd file to knit
  if(qmd_to_knit == "path_to_qmd"){
    dir_list   <- list.dirs()
    paper_dir  <- dir_list[grep(pattern = "/paper$", dir_list)]
    qmd_path   <- regmatches(paper_dir, regexpr("analysis|vignettes|inst", paper_dir))
    qmd_path <-  file.path(qmd_path, "paper/paper.qmd")
  } else {
    #  preempt the string with home directory notation or back-slash (thx Matt Harris)
    qmd_path <- gsub("^.|^/|^./|^~/","",qmd_to_knit)
  }


  # assign variables for whisker
  gh <- github_info(pkg$path)
  gh$r_version <- r_version
  gh$rocker <- rocker
  gh$qmd_path <- qmd_path
  gh$maintainer <- if (!is.null(pkg$maintainer)) pkg$maintainer else "Your Name <your_email@somewhere.com>"

  use_template("Dockerfile",
               "Dockerfile",
               ignore = TRUE,
               pkg = pkg,
               data = gh,
               open = TRUE,
               out_path = "")

# create yaml for GitHub Actions that uses the dockerfile

  if(use_gh_action){

  use_directory(".github/workflows", pkg = pkg)
  use_template("render-in-docker.yaml",
               "render-in-docker.yaml",
               ignore = TRUE,
               pkg = pkg,
               data = gh,
               open = TRUE,
               out_path = ".github/workflows")
  } else {
    # do nothing
  }

  message("Next: \n",
          " * Edit the dockerfile with your name & email if needed", "\n",
          " * Edit the dockerfile to include system dependencies, such as linux libraries that are needed by the R packages you're using", "\n",
          " * Check the last line of the dockerfile to specify which qmd should be rendered in the Docker container, edit if necessary", "\n",
          " * Look at the GitHub Actions page of your compendium at github.com to inspect the output", "\n")

  invisible(TRUE)
}
