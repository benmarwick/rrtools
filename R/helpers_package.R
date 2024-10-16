# from https://github.com/r-lib/usethis/blob/master/R/ignore.R
# Add a file to \code{.Rbuildignore}
# \code{.Rbuildignore} has a regular expression on each line, but it's
# usually easier to work with specific file names. By default, will (crudely)
# turn a filename into a regular expression that will only match that
# path. Repeated entries will be silently removed.
# @param pkg package description, can be path or package name.  See
# \code{\link{as.package}} for more information
# @param files Name of file.
# @param escape If \code{TRUE}, the default, will escape \code{.} to
# \code{\\.} and surround with \code{^} and \code{$}.
use_build_ignore <- function(files, escape = TRUE, pkg = ".") {
  pkg <- as.package(pkg)

  if (escape) {
    files <- paste0("^", gsub("\\.", "\\\\.", files), "$")
  }

  path <- file.path(pkg$path, ".Rbuildignore")
  union_write(path, files)

  invisible(TRUE)
}

# from https://github.com/r-lib/devtools/blob/master/R/infrastructure.R
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

# from https://github.com/r-lib/devtools/blob/master/R/utils.R
suggests_dep <- function(pkg) {

  suggests <- read_dcf(system.file("DESCRIPTION", package = "devtools"))$Suggests
  deps <- parse_deps(suggests)

  found <- which(deps$name == pkg)[1L]

  if (!length(found)) {
    stop(sQuote(pkg), " is not in Suggests: for devtools!", call. = FALSE)
  }
  deps[found, ]
}

# from https://github.com/r-lib/devtools/blob/master/R/utils.R but this
# function was removed some time ago, so I've just updated it to keep it
# working
is_installed <- function(pkg, version = "0.0.0") {
  installed_version <- tryCatch(utils::packageVersion(pkg), error = function(e) NA)
  required_version <- as.package_version(version)
  !is.na(installed_version) && installed_version >= required_version
}


# from https://github.com/r-lib/devtools/blob/master/R/pkgload.R
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

# from https://github.com/r-lib/devtools/blob/master/R/package.R
# Coerce input to a package.
# Possible specifications of package:
# \itemize{
#   \item path
#   \item package object
# }
# @param x object to coerce to a package
# @param create only relevant if a package structure does not exist yet: if
# \code{TRUE}, create a package structure; if \code{NA}, ask the user
# (in interactive mode only)
as.package <- function(x = NULL, create = NA) {
  if (is.package(x)) return(x)

  x <- package_file(path = x)
  load_pkg_description(x, create = create)
}

# from https://github.com/r-lib/devtools/blob/master/R/package.R
# Find file in a package.
# It always starts by finding by walking up the path until it finds the
# root directory, i.e. a directory containing \code{DESCRIPTION}. If it
# cannot find the root directory, or it can't find the specified path, it
# will throw an error.
# @param ... Components of the path.
# @param path Place to start search for package directory.
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

# from https://github.com/r-lib/devtools/blob/master/R/package.R
has_description <- function(path) {
  file.exists(file.path(path, 'DESCRIPTION'))
}

# from https://github.com/r-lib/devtools/blob/master/R/package.R
is_root <- function(path) {
  identical(path, dirname(path))
}

# from https://github.com/r-lib/devtools/blob/master/R/package.R
strip_slashes <- function(x) {
  x <- sub("/*$", "", x)
  x
}

# from https://github.com/r-lib/devtools/blob/master/R/package.R
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

# from https://github.com/r-lib/devtools/blob/master/R/package.R
# Is the object a package?
is.package <- function(x) inherits(x, "package")

# from https://github.com/r-lib/devtools/blob/master/R/package.R
# Mockable variant of interactive
interactive <- function() .Primitive("interactive")()

# from https://github.com/r-lib/devtools/blob/master/R/package-deps.R
# Parse package dependency strings.
# @param string to parse. Should look like \code{"R (>= 3.0), ggplot2"} etc.
# @return list of two character vectors: \code{name} package names,
# and \code{version} package versions. If version is not specified,
# it will be stored as NA.
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

# from https://github.com/r-lib/devtools/blob/master/R/package-deps.R
# Check that the version of an imported package satisfies the requirements
# @param dep_name The name of the package with objects to import
# @param dep_ver The version of the package
# @param dep_compare The comparison operator to use to check the version
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
