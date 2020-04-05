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
  circleci_url <- paste0("https://circleci.com/gh/", gh$username)

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
