#' Connect a local repo with GitLab
#'
#' `use_gitlab()` takes a local project, creates an associated PRIVATE repo on GitLab.com,
#' adds it to your local repo as the `origin` remote, and makes an initial push
#' to synchronize. `use_gitlab()` requires that your project already be a Git
#' repository, which you can accomplish with [usethis::use_git()], if needed. See the
#' Authentication section below for other necessary setup.
#'
#' In addition, `use_gitlab()` creates a `.gitlab-ci.yml` and will run two
#' Gitlab.com CI/CD jobs, `check-package` and `render-paper`.
#' These should both succeed, indicating that you have produced a reproducible paper using Docker.
#'
#' Should you desire, you may change the values of three variables from "no" to "yes".
#' This allows you to simply push the Docker image to your GitLab registry, produce a code coverage
#' report, and publish your paper to https://USERname.gitlab.io/REPOname.
#'
#' @section Authentication:
#' A new GitLab repo will be created via the GitLab API, therefore you must
#' make a [GitLab personal access token
#' (PAT)](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#personal-access-tokens) available. You must
#' provide this directly via the `auth_token` argument (`auth_token = readLines("filepath_to_token" works).
#'
#' @param auth_token personal access token. Go to GitLab "User Settings" (currently click avatar at top-right of webpage), then click "Access Tokens" on the left sidebar, enter a "Name", "Expiration Date", check "api" under "Scopes", and click "Create personal access token". You will need to copy this alphanumeric and save it to your device(s) now as you will never have access again. (https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#creating-a-personal-access-token)
#' @param pkg file location of package
#' @param rocker name the rocker image
#' @param rmd_to_knit the path to the .Rmd
#'
#' @return NULL
#' @export
#' @examples
#' \dontrun{
#' # create a rrtools compendium
#' rrtools::create_compendium("testpkg")
#'
#' # create GitLab.com repository, configure as git remote
#' rrtools::use_gitlab(auth_token = readLines("filepath_to_token"))
#' }
use_gitlab <- function(pkg = ".", auth_token = "xxxx", rocker = "verse", rmd_to_knit = "path_to_rmd") {
  if (auth_token == "xxxx") {
    stop('This function fails without setting auth_token to your GitLab.com personal access token, e.g., `auth_token = "abcd12345"`. See `?rrtools::use_gitlab` for more details.')
  }

  if (is.null(git2r::discover_repository(usethis::proj_get()))) {
    stop("You have not initialized the local git repository yet.")
  }
  pkg <- as.package(pkg)

  # gather relevant information for remote git repo
  if (is.null(getOption("gitlab.username"))) {
    username <- readline(prompt = "   ...   Please enter your GitLab username: ")
    options(gitlab.username = username)
  } else {
    username <- getOption("gitlab.username")
  }
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
  if (length(grep("^origin\thttps", system("git remote --verbose", intern = TRUE)[2])) > 0) {
    stop("There is already an `origin` remote associated with this local repo. Please remove it and try again.")
  } else {
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
    # use the templated Dockerfile file for CI/CD
    use_template("Dockerfile",
                 save_as = "Dockerfile",
                 data = gh,
                 ignore = TRUE,
                 open = TRUE,
                 pkg = pkg,
                 out_path = "")
    # replace the README.md
    file.rename("CONDUCT.md", "CONDUCT.md.bak")
    file.rename("CONTRIBUTING.md", "CONTRIBUTING.md.bak")
    file.rename("README.md", "README.md.bak")
    file.rename("README.Rmd", "README.Rmd.bak")
    rrtools::use_readme_rmd()

    # alert user to purpose of .gitlab-ci.yml
    save_as <- ".gitlab-ci.yml"
    usethis::ui_done("{usethis::ui_value(save_as)} currently checks your package, builds and runs `Dockerfile` to produce your paper.")
    usethis::ui_todo('Change relevant variables in {usethis::ui_value(save_as)} to "yes" to push Docker image to gitlab.com container registry plus publish your paper to https://USERname.gitlab.io/REPOname plus produce a code coverage report.')
  }
}
