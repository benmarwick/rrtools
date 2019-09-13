#' @name use_travis
#' @aliases add_travis
#' @title Add a travis config file
#'
#' @description This has two options. One is the same as `usethis::use_travis`, a vanilla travis config that builds, installs and runs the custom package on travis. The other type of configuration directs travis to build the Docker container (according to the instructions in your Dockerfile) and push the successful result to Docker Hub. Using a Dockerfile is recommended because it gives greater isolation of the computational enviroment, and will result in much faster build times on travis.
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
  gh$repo <- tolower(gh$repo)

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
