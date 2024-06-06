#' Creates skeleton README files
#'
#' @description
#' \code{README.qmd} will be automatically
#' added to \code{.Rbuildignore}. The resulting README is populated with default
#' YAML frontmatter and R fenced code chunks (\code{qmd}).
#' Your readme should contain:
#' \itemize{
#' \item a high-level description of the package and its goals
#' \item R code to install from GitHub, if GitHub usage detected
#' \item a basic example
#' }
#'
#' @param pkg package description, can be path or package name.  See
#'   \code{\link{as.package}} for more information
#' @param render_readme should the README.qmd be directly rendered to
#' a github markdown document? default: TRUE
#' @importFrom rmarkdown render
#' @export
#' @examples
#' \dontrun{
#' use_readme_qmd()
#' }
#' @family infrastructure
use_readme_qmd <- function(pkg = ".", render_readme = TRUE) {
  pkg <- as.package(pkg)
  data <- pkg

  if (uses_github(pkg$path)) {
    # assign variables for whisker
    gh <- github_info(pkg$path)
    data = c(pkg, gh)
  }
  pkg$qmd <- TRUE


  use_template("omni-README",
               save_as = "README.qmd",
               data = data,
               ignore = TRUE,
               open = TRUE,
               pkg = pkg,
               out_path = "")

  use_build_ignore("^README-.*\\.png$", escape = FALSE, pkg = pkg)

  if (uses_git(pkg$path)) {
    message("* Adding pre-commit hook")
    use_git_hook("pre-commit", render_template("readme-qmd-pre-commit.sh"))
  }

  if (render_readme) {
    usethis::ui_done("\nRendering README.qmd to README.md for GitHub.")
    rmarkdown::render("README.qmd", quiet = TRUE)
    unlink("README.html")
  }

  usethis::ui_done("Adding code of conduct.")
  use_code_of_conduct(pkg)

  usethis::ui_done("Adding instructions to contributors.")
  use_contributing(pkg)

  usethis::ui_done("Adding .binder/Dockerfile for Binder")
  use_binder(pkg = pkg)
  use_build_ignore(".binder", pkg = pkg)

  invisible(TRUE)
}



#### directly related helpers ####

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


