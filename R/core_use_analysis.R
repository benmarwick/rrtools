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

  usethis::ui_done("Adding bookdown to Imports\n")
  add_desc_package(pkg, "Imports", "bookdown")
  lapply(X = c("devtools", "git2r"),
         FUN = add_desc_package, pkg = pkg, field = "Suggests")

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

 cat(crayon::bold("\nNext, you need to: "), rep(crayon::green(clisymbols::symbol$arrow_down),4), "\n")
  usethis::ui_todo("Write your article/report/thesis, start at the paper.Rmd file")
  usethis::ui_todo("Add the citation style library file (csl) to replace the default provided here, see {crayon::bgBlue('https://github.com/citation-style-language/')}")
  usethis::ui_todo("Add bibliographic details of cited items to the {usethis::ui_value('references.bib')} file")
  usethis::ui_todo("For adding captions & cross-referencing in an Rmd, see {crayon::bgBlue('https://bookdown.org/yihui/bookdown/')}")
  usethis::ui_todo("For adding citations & reference lists in an Rmd, see {crayon::bgBlue('http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html')}")

  # message about whether data files are tracked by Git:
  cat(crayon::bold("\nNote that:\n"))
  if(!data_in_git) {cat(paste0(warning_bullet(), " Your data files ", crayon::red("are not"), " tracked by Git and ", crayon::red("will not"), " be pushed to GitHub \n"))
    } else {
  cat(paste0(warning_bullet(), " Your data files ", crayon::green("are"), " tracked by Git and ", crayon::green("will"), " be pushed to GitHub \n"))
    }


invisible(TRUE)
}



#### directly related helpers ####

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

  # move lua filters
  invisible(file.copy(from = system.file("templates/pagebreak.lua",
                                         package = "rrtools",
                                         mustWork = TRUE),
                      to = paste0(pkg$path, "/", location, "/templates"),
                      recursive = TRUE))

  invisible(file.copy(from = system.file("templates/author-info-blocks.lua",
                                         package = "rrtools",
                                         mustWork = TRUE),
                      to = paste0(pkg$path, "/", location, "/templates"),
                      recursive = TRUE))

  invisible(file.copy(from = system.file("templates/scholarly-metadata.lua",
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
  # use_git_ignore("inst/doc", pkg = pkg) # test to suppress testing error

  template_path <- template_path_fn(template)
  rmd <- readLines(template_path)
  vignette_yml <- readLines(template_path_fn(vignette_yml))

  # in case we want to inject some text in the Rmd, we can do that here
  # use_template doesn't seem to work for this...
  writeLines(rmd, file.path(pkg$path, location, "/paper/paper.Rmd"))
  closeAllConnections()

  open_in_rstudio(paste0(location, "/paper/paper.Rmd"))
}
