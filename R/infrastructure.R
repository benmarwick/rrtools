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

