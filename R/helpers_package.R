# unexported fns from devtools, we include them here so
# we don't have to use :::
# from https://raw.githubusercontent.com/hadley/devtools/26c507b128fdaa1911503348fedcf20d2dd30a1d/R/package.r 




#' Coerce input to a package.
#'
#' Possible specifications of package:
#' \itemize{
#'   \item path
#'   \item package object
#' }
#' @param x object to coerce to a package
#' @param create only relevant if a package structure does not exist yet: if
#'   \code{TRUE}, create a package structure; if \code{NA}, ask the user
#'   (in interactive mode only)
#' @export
#' @keywords internal
as.package <- function(x = NULL, create = NA) {
  if (is.package(x)) return(x)
  
  x <- package_file(path = x)
  load_pkg_description(x, create = create)
}

#' Find file in a package.
#'
#' It always starts by finding by walking up the path until it finds the
#' root directory, i.e. a directory containing \code{DESCRIPTION}. If it
#' cannot find the root directory, or it can't find the specified path, it
#' will throw an error.
#'
#' @param ... Components of the path.
#' @param path Place to start search for package directory.
#' @export
#' @examples
#' \dontrun{
#' package_file("figures", "figure_1")
#' }
package_file <- function(..., path = ".") {
  if (!is.character(path) || length(path) != 1) {
    stop("`path` must be a string.", call. = FALSE)
  }
  path <- strip_slashes(normalizePath(path, mustWork = FALSE))
  
  if (!file.exists(path)) {
    stop("Can't find '", path, "'.", call. = FALSE)
  }
  if (!file.info(path)$isdir) {
    stop("'", path, "' is not a directory.", call. = FALSE)
  }
  
  # Walk up to root directory
  while (!has_description(path)) {
    path <- dirname(path)
    
    if (is_root(path)) {
      stop("Could not find package root.", call. = FALSE)
    }
  }
  
  file.path(path, ...)
}

has_description <- function(path) {
  file.exists(file.path(path, 'DESCRIPTION'))
}

is_root <- function(path) {
  identical(path, dirname(path))
}

strip_slashes <- function(x) {
  x <- sub("/*$", "", x)
  x
}

# Load package DESCRIPTION into convenient form.
load_pkg_description <- function(path, create) {
  path_desc <- file.path(path, "DESCRIPTION")
  
  if (!file.exists(path_desc)) {
    if (is.na(create)) {
      if (interactive()) {
        message("No package infrastructure found in ", path, ". Create it?")
        create <- (menu(c("Yes", "No")) == 1)
      } else {
        create <- FALSE
      }
    }
    
    if (create) {
      setup(path = path)
    } else {
      stop("No description at ", path_desc, call. = FALSE)
    }
  }
  
  desc <- as.list(read.dcf(path_desc)[1, ])
  names(desc) <- tolower(names(desc))
  desc$path <- path
  
  structure(desc, class = "package")
}


#' Is the object a package?
#'
#' @keywords internal
#' @export
is.package <- function(x) inherits(x, "package")

# Mockable variant of interactive
interactive <- function() .Primitive("interactive")()


# unexported fns from devtools, we include them here so
# we don't have to use :::
# from https://github.com/hadley/devtools/blob/26c507b128fdaa1911503348fedcf20d2dd30a1d/R/package-deps.r

#' Parse package dependency strings.
#'
#' @param string to parse. Should look like \code{"R (>= 3.0), ggplot2"} etc.
#' @return list of two character vectors: \code{name} package names,
#'   and \code{version} package versions. If version is not specified,
#'   it will be stored as NA.
#' @keywords internal
#' @export
#' @examples
#' parse_deps("httr (< 2.1),\nRCurl (>= 3)")
#' # only package dependencies are returned
#' parse_deps("utils (== 2.12.1),\ntools,\nR (>= 2.10),\nmemoise")
parse_deps <- function(string) {
  if (is.null(string)) return()
  stopifnot(is.character(string), length(string) == 1)
  if (grepl("^\\s*$", string)) return()
  
  pieces <- strsplit(string, "[[:space:]]*,[[:space:]]*")[[1]]
  
  # Get the names
  names <- gsub("\\s*\\(.*?\\)", "", pieces)
  names <- gsub("^\\s+|\\s+$", "", names)
  
  # Get the versions and comparison operators
  versions_str <- pieces
  have_version <- grepl("\\(.*\\)", versions_str)
  versions_str[!have_version] <- NA
  
  compare  <- sub(".*\\((\\S+)\\s+.*\\)", "\\1", versions_str)
  versions <- sub(".*\\(\\S+\\s+(.*)\\)", "\\1", versions_str)
  
  # Check that non-NA comparison operators are valid
  compare_nna   <- compare[!is.na(compare)]
  compare_valid <- compare_nna %in% c(">", ">=", "==", "<=", "<")
  if(!all(compare_valid)) {
    stop("Invalid comparison operator in dependency: ",
         paste(compare_nna[!compare_valid], collapse = ", "))
  }
  
  deps <- data.frame(name = names, compare = compare,
                     version = versions, stringsAsFactors = FALSE)
  
  # Remove R dependency
  deps[names != "R", ]
}


#' Check that the version of an imported package satisfies the requirements
#'
#' @param dep_name The name of the package with objects to import
#' @param dep_ver The version of the package
#' @param dep_compare The comparison operator to use to check the version
#' @keywords internal
check_dep_version <- function(dep_name, dep_ver = NA, dep_compare = NA) {
  if (!requireNamespace(dep_name, quietly = TRUE)) {
    stop("Dependency package ", dep_name, " not available.")
  }
  
  if (xor(is.na(dep_ver), is.na(dep_compare))) {
    stop("dep_ver and dep_compare must be both NA or both non-NA")
    
  } else if(!is.na(dep_ver) && !is.na(dep_compare)) {
    
    compare <- match.fun(dep_compare)
    if (!compare(
      as.numeric_version(getNamespaceVersion(dep_name)),
      as.numeric_version(dep_ver))) {
      
      warning("Need ", dep_name, " ", dep_compare,
              " ", dep_ver,
              " but loaded version is ", getNamespaceVersion(dep_name))
    }
  }
  return(TRUE)
}

