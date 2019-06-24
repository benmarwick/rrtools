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
