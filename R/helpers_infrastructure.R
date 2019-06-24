#### helper functions
# - 

# unexported fns from devtools, we include them here so
# we don't have to use :::
# from https://github.com/hadley/devtools/blob/ad6f28ef9de6a02e1ea300af45d34deccc40bd2f/R/infrastructure.R

yesno <- function(...) {
  yeses <- c("Yes", "Definitely", "For sure", "Yup", "Yeah", "I agree", "Absolutely")
  nos <- c("No way", "Not yet", "I forget", "No", "Nope", "Uhhhh... Maybe?")

  cat(paste0(..., collapse = ""))
  qs <- c(sample(yeses, 1), sample(nos, 2))
  rand <- sample(length(qs))

  menu(qs[rand]) != which(rand == 1)
}

union_write <- function(path, new_lines) {
  if (file.exists(path)) {
    lines <- readLines(path, warn = FALSE)
  } else {
    lines <- character()
  }

  all <- union(lines, new_lines)
  writeLines(all, path)
}


add_desc_package <- function(pkg = ".", field, name) {
  pkg <- as.package(pkg)
  desc_path <- file.path(pkg$path, "DESCRIPTION")

  desc <- read_dcf(desc_path)
  old <- desc[[field]]
  if (is.null(old)) {
    new <- name
    changed <- TRUE
  } else {
    if (!grepl(paste0('\\b', name, '\\b'), old)) {
      new <- paste0(old, ",\n    ", name)
      changed <- TRUE
    } else {
      changed <- FALSE
    }
  }
  if (changed) {
    desc[[field]] <- new
    write_dcf(desc_path, desc)
  }
  invisible(changed)
}


#' Add a file to \code{.Rbuildignore}
#'
#' \code{.Rbuildignore} has a regular expression on each line, but it's
#' usually easier to work with specific file names. By default, will (crudely)
#' turn a filename into a regular expression that will only match that
#' path. Repeated entries will be silently removed.
#'
#' @param pkg package description, can be path or package name.  See
#'   \code{\link{as.package}} for more information
#' @param files Name of file.
#' @param escape If \code{TRUE}, the default, will escape \code{.} to
#'   \code{\\.} and surround with \code{^} and \code{$}.
#' @return Nothing, called for its side effect.
#' @export
#' @aliases add_build_ignore
#' @family infrastructure
#' @keywords internal
use_build_ignore <- function(files, escape = TRUE, pkg = ".") {
  pkg <- as.package(pkg)

  if (escape) {
    files <- paste0("^", gsub("\\.", "\\\\.", files), "$")
  }

  path <- file.path(pkg$path, ".Rbuildignore")
  union_write(path, files)

  invisible(TRUE)
}


open_in_rstudio <- function(path) {
  if (!rstudioapi::isAvailable())
    return()

  if (!rstudioapi::hasFun("navigateToFile"))
    return()

  rstudioapi::navigateToFile(path)

}

can_overwrite <- function(path, ask = TRUE) {
  name <- basename(path)

  if (!file.exists(path)) {
    TRUE
  } else if (ask && (interactive() && !yesno("Overwrite `", name, "`?"))) {
    TRUE
  } else {
    FALSE
  }
}

###

warning_bullet <- function() crayon::yellow(clisymbols::symbol$warning)
red_cross <- function() crayon::red(clisymbols::symbol$cross)
green_tick  <- function() crayon::green(clisymbols::symbol$tick)



# capture the cat & message output
# from http://r.789695.n4.nabble.com/Suppressing-output-e-g-from-cat-tp859876p859882.html
quietly <- function(x) {
  sink(tempfile())
  on.exit(sink())
  invisible(force(suppressMessages(x)))
}

# unexported fns from devtools, we include them here so
# we don't have to use :::
# from https://github.com/hadley/devtools/blob/ba7a5a4abd8258c52cb156e7b26bb4bf47a79f0b/R/utils.r


is_dir <- function(x) file.info(x)$isdir

render_template <- function(name, data = list()) {
  path <- system.file("templates", name, package = "devtools")
  template <- readLines(path)
  whisker::whisker.render(template, data)
}

read_dcf <- function(path) {
  fields <- colnames(read.dcf(path))
  as.list(read.dcf(path, keep.white = fields)[1, ])
}

write_dcf <- function(path, desc) {
  desc <- unlist(desc)
  # Add back in continuation characters
  desc <- gsub("\n[ \t]*\n", "\n .\n ", desc, perl = TRUE, useBytes = TRUE)
  desc <- gsub("\n \\.([^\n])", "\n  .\\1", desc, perl = TRUE, useBytes = TRUE)

  starts_with_whitespace <- grepl("^\\s", desc, perl = TRUE, useBytes = TRUE)
  delimiters <- ifelse(starts_with_whitespace, ":", ": ")
  text <- paste0(names(desc), delimiters, desc, collapse = "\n")

  # If the description file has a declared encoding, set it so nchar() works
  # properly.
  if ("Encoding" %in% names(desc)) {
    Encoding(text) <- desc[["Encoding"]]
  }

  if (substr(text, nchar(text), 1) != "\n") {
    text <- paste0(text, "\n")
  }

  cat(text, file = path)
}

dots <- function(...) {
  eval(substitute(alist(...)))
}


suggests_dep <- function(pkg) {

  suggests <- read_dcf(system.file("DESCRIPTION", package = "devtools"))$Suggests
  deps <- parse_deps(suggests)

  found <- which(deps$name == pkg)[1L]

  if (!length(found)) {
    stop(sQuote(pkg), " is not in Suggests: for devtools!", call. = FALSE)
  }
  deps[found, ]
}


is_installed <- function(pkg, version = 0) {
  installed_version <- tryCatch(utils::packageVersion(pkg), error = function(e) NA)
  !is.na(installed_version) && installed_version >= version
}



check_suggested <- function(pkg, version = NULL, compare = NA) {

  if (is.null(version)) {
    if (!is.na(compare)) {
      stop("Cannot set ", sQuote(compare), " without setting ",
           sQuote(version), call. = FALSE)
    }

    dep <- suggests_dep(pkg)

    version <- dep$version
    compare <- dep$compare
  }

  if (!is_installed(pkg) || !check_dep_version(pkg, version, compare)) {
    msg <- paste0(sQuote(pkg),
                  if (is.na(version)) "" else paste0(" >= ", version),
                  " must be installed for this functionality.")

    if (interactive()) {
      message(msg, "\nWould you like to install it?")
      if (menu(c("Yes", "No")) == 1) {
        install.packages(pkg)
      } else {
        stop(msg, call. = FALSE)
      }
    } else {
      stop(msg, call. = FALSE)
    }
  }
}

