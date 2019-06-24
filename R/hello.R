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

  usethis::ui_done("Creating {usethis::ui_value(save_as)} from template.")
  writeLines(template_out, path)

  if (ignore) {
    usethis::ui_done("Adding {usethis::ui_value(save_as)} to `.Rbuildignore`.")
    use_build_ignore(save_as, pkg = pkg)
  }

  if (open) {
    usethis::ui_todo("Modify ", usethis::ui_value(save_as))
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
    usethis::ui_done("Creating {usethis::ui_value(path)}")
    dir.create(pkg_path, showWarnings = FALSE, recursive = TRUE,  mode = "0777")
  }

  if (ignore) {
    usethis::ui_done("Adding {usethis::ui_value(path)} to `.Rbuildignore`")
    use_build_ignore(path, pkg = pkg)
  }

  invisible(TRUE)
}


create_directories <- function(location, pkg){

  if (location %in% c("analysis", "vignettes", "inst")) {
  usethis::ui_done("Creating {usethis::ui_value(location)} directory and contents")
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

  # in case we want to inject some text in the Rmd, we can do that here
  rmd <- readLines(file.path(pkg$path, location, "paper.Rmd"))
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
