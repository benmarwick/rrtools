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
#' @import utils
#' @export

  use_dockerfile <- function(pkg = ".", rocker = "verse", rmd_to_knit = "path_to_rmd") {
  pkg <- as.package(pkg)

  # get R version for rocker/r-ver
  si <- utils::sessionInfo()
  r_version <- paste0(si$R.version$major, ".", si$R.version$minor)

  # get path to Rmd file to knit
  if(rmd_to_knit == "path_to_rmd"){
    dir_list   <- list.dirs()
    paper_dir  <- dir_list[grep(pattern = "/paper$", dir_list)]
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
