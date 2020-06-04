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
use_circleci <- function(pkg = ".", browse = interactive(), docker_hub = FALSE) {
  pkg <- as.package(pkg)

  gh <- github_info(pkg$path)
  circleci_url <- paste0("https://circleci.com/gh/", gh$username)

  if (!dir.exists(file.path(".circleci"))) {
    dir.create(".circleci")
  }

  if(docker_hub){

    use_template("circle.yml-with-docker-hub",
                 file.path(".circleci", "config.yml"),
                 ignore = TRUE,
                 pkg = pkg,
                 data = gh,
                 out_path = "")

  } else {

    use_template("circle.yml-without-docker-hub",
                 file.path(".circleci", "config.yml"),
                 ignore = TRUE,
                 pkg = pkg,
                 data = gh,
                 out_path = "")

  }

  cat(crayon::bold("\nNext, you need to: "), rep(crayon::green(clisymbols::symbol$arrow_down),3), "\n")
  usethis::ui_todo("Commit and push the new file 'config.yml' and the change to '.Rbuildignore'")
  usethis::ui_todo(paste0("Add your environment variable DOCKER_USER at ", circleci_url))
  if (docker_hub) {
    usethis::ui_todo("Add the additional environment variables DOCKER_EMAIL and DOCKER_PASS.")
    cat("Your Docker container will be pushed to the Docker Hub if the build completes successfully", "\n")
    cat("The container will be kept private and NOT be pushed to the Docker Hub. \n")
  }
  usethis::ui_todo("Configure circleci to start building with your config.yml.")
  usethis::ui_todo(paste0(
    "Optional: Add a circleci shield to your README.Rmd: [![Circle-CI Build Status](https://circleci.com/gh/",
    gh$fullname,
    ".svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/",
    gh$fullname,
    ")"
  ))

  if (browse) {
    if(curl::has_internet()) {
      utils::browseURL(circleci_url)
    } else {
      message("No internet connection. Can't open ", circleci_url)
    }
  }

  invisible(TRUE)
}
