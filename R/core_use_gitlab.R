#' Title
#'
#' @param auth_token personal access token
#' @param pkg file location of package
#' @param rocker name the rocker image
#' @param rmd_to_knit the path to the .Rmd
#'
#' @return NULL
#' @export
#'
use_gitlab <- function(pkg = ".", auth_token = "xxxx", rocker = "verse", rmd_to_knit = "path_to_rmd") {
  pkg <- as.package(pkg)

  # gather relevant information for remote git repo
  username <- system("git config user.name",
                     intern = TRUE)
  pkgname <- gsub(pattern = "Package: ",
                  replacement = "",
                  readLines("DESCRIPTION")[1])

  # get R version for rocker/r-ver
  si <- utils::sessionInfo()
  r_version <- paste0(si$R.version$major, ".", si$R.version$minor)

  # get path to Rmd file to knit
  if(rmd_to_knit == "path_to_rmd"){
    dir_list   <- list.dirs()
    paper_dir  <- dir_list[grep(pattern = "/paper", dir_list)]
    rmd_path   <- regmatches(paper_dir, regexpr("analysis|vignettes|inst", paper_dir))
    rmd_parent_path <- file.path(rmd_path, "paper")
    rmd_path <-  file.path(rmd_path, "paper/paper.Rmd")
  } else {
    #  preempt the string with home directory notation or back-slash (thx Matt Harris)
    rmd_path <- gsub("^.|^/|^./|^~/","",rmd_to_knit)
  }

  # attempt to push the current branch and set the remote as upstream
  system(paste0("git push --set-upstream https://oauth2:", auth_token, "@gitlab.com/", username, "/", pkgname, ".git master"))
  system(paste0("git remote add origin https://gitlab.com/", username, "/", pkgname, ".git"))
  git2r::config(branch.master.remote = "origin")

  # assign variables for whisker
  gh <- github_info(pkg$path)
  gh$r_version <- r_version
  gh$rocker <- rocker
  gh$rmd_path <- rmd_path
  gh$rmd_parent_path <- rmd_parent_path

  # use the templated .gitlab-ci.yml file for CI/CD
  use_template("gitlab-ci.yml",
               save_as = ".gitlab-ci.yml",
               data = gh,
               ignore = TRUE,
               open = TRUE,
               pkg = pkg,
               out_path = "")

  # attempt to push the current branch and set the remote as upstream
  system(paste0("git push --set-upstream https://oauth2:", auth_token, "@gitlab.com/", username, "/", pkgname, ".git master"))
  system(paste0("git remote add origin https://gitlab.com/", username, "/", pkgname, ".git"))
  git2r::config(branch.master.remote = "origin")
}
