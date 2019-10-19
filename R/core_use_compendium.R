#' @name use_compendium
#' @title Creates an R package suitable to use as a research compendium, and
#' switches to the working directory of this new package, ready to work
#'
#' @description This is usethis::create_package() with some additional messages to simplify the transition into the new project setting
#'
#' @param path location to create new package. The last component of the path will be used as the package name
#' @param fields list of description values to override default values or add additional values
#' @param rstudio create an RStudio project file? (with \code{usethis::use_rstudio})
#' @param open if TRUE and in RStudio, the new project is opened in a new instance. If TRUE and not in RStudio, the working directory is set to the new project
#' @param quiet if FALSE, the default, prints informative messages
#'
#' @importFrom usethis create_package
#' @importFrom rstudioapi isAvailable
#' @export

use_compendium <- function(
  path,
  fields = getOption("usethis.description"),
  rstudio = rstudioapi::isAvailable(),
  open = interactive(),
  quiet = FALSE
){

  # if we have options setting the description, use that for Authors@R

  authors_at_R_preset <-  getOption("usethis.description")$`Authors@R`
  blank_authors <- 'person("First", "Last", , "first.last@example.com", c("aut", "cre"))'
  authors_at_R <- ifelse(is.null(authors_at_R_preset), blank_authors, authors_at_R_preset)


  # seems that use_description creates a different description for OSX and Linux, so we force all to have ByteCompile
  options(
    usethis.description = list(
      Version = "0.0.0.9000",
      Title =  "What the Package Does (One Line, Title Case)",
      Description = "What the package does (one paragraph).",
      `Authors@R` = authors_at_R,
      License =  "What license it uses",
      Encoding = "UTF-8",
      LazyData = "true",
      ByteCompile = "true"
    )
  )

  # everything in an unevaluated expression to suppress cat() output and messages
  create_the_package <- expression({

    name <- basename(path)

    # from googledrive (!)
    stop_glue <- function(..., .sep = "", .envir = parent.frame(),
                          call. = FALSE, .domain = NULL) {
      stop(
        glue::glue(..., .sep = .sep, .envir = .envir),
        call. = call., domain = .domain
      )
    }

    # from usethis
    value <- function(...) {
      x <- paste0(...)
      crayon::blue(encodeString(x, quote = "'"))
    }

    # from usethis
    valid_name <- function(x){
      grepl("^[[:alpha:]][[:alnum:].]+$", x) && !grepl("\\.$", x)
    }

    # from usethis, modified
    check_package_name <- function(name) {
      if (!valid_name(name)) {
        stop_glue(
          "{value(name)} is not a valid package name. It should:\n",
          "* Contain only ASCII letters, numbers, and '.'\n",
          "* Have at least two characters\n",
          "* Start with a letter\n",
          "* Not end with '.'\n"
        )
      }

    }

    check_package_name(name)

    # welcome message in new repo at first start
    if (rstudio & open & !quiet) {
      dir.create(path)
      fileConn <- file(file.path(path, ".Rprofile"))
      writeLines(
        c(
          "cat(crayon::bold('\nThis project was set up by rrtools.\n'))",
          "cat('\nYou can start working now or apply some more basic configuration.\n')",
          "cat('Check out ')",
          "cat(crayon::underline('https://github.com/benmarwick/rrtools'))",
          "cat(' for an explanation of all the project configuration functions of rrtools.\n')",
          "cat('Or run the rrtools configuration addin: ')",
          "cat(crayon::cyan('rrtools.addin::rrtools_assistant() '))",
          "cat(crayon::underline('https://github.com/nevrome/rrtools.addin\n\n'))",
          "invisible(file.remove('.Rprofile'))"
        ),
        fileConn
      )
      close(fileConn)
    }

    # create new package
    usethis::create_package(
      path = path,
      fields = fields,
      rstudio = rstudio,
      open = open
    )


    usethis::ui_done("The package {name} has been created")

    if (rstudio & open) {
      usethis::ui_done("Opening the new compendium in a new RStudio session...")
    } else {
      usethis::ui_done("Now opening the new compendium...")
      usethis::ui_done("Done. The working directory is currently {getwd()}")
    }

    cat(crayon::bold("\nNext, you need to: "), rep(crayon::green(clisymbols::symbol$arrow_down),3), "\n")
    usethis::ui_todo("Edit the DESCRIPTION file")
    usethis::ui_todo("Use other 'rrtools' functions to add components to the compendium\n")


  })

  if (quiet) {
    quietly(suppressMessages(capture.output(eval(create_the_package), file = NULL)))
  } else {
    eval(create_the_package)
  }

}
