#' Searches for external packages and adds them to the Imports field in the description
#'
#' Scans script files (.R, .Rmd, .Rnw, .Rpres) for external package dependencies indicated by
#' \code{library()}, \code{require()} or \code{::} and adds those packages to the Imports field in
#' the package DESCRIPTION.
#'
#' @param path location of individual file or directory where to search for scripts.
#' @param description_file location of description file to be updated.
#' @param just_packages just give back a character vector of the found packages.
#'
#' @export
add_dependencies_to_description <- function(path = getwd(), description_file = "DESCRIPTION", just_packages = FALSE) {
  R_files <- get_R_files(path)
  pkgs <- get_pkgs_from_R_files(R_files)
  if (just_packages) { return(pkgs) }
  write_packages_to_DESCRIPTION(pkgs, description_file)
}

#### helper functions ####

write_packages_to_DESCRIPTION <- function(pkgs, description_file) {
  # read DESCRIPTION file
  desc <- readLines(description_file)
  # check, if Imports fields is available
  if (any(grepl("Imports:", desc))) {
    imports_already_existed <- TRUE
  } else {
    imports_already_existed <- FALSE
    # if no: add it
    desc[length(desc)+1] <- "Imports:"
  }
  # get line where Imports starts
  i_begin <- grep("Imports:", desc)
  # get line where Imports ends (determination via search for next ":")
  # if Imports is the last tag, set i_end to the last line
  if((i_begin + 1) >= length(desc)) {
    i_end <- length(desc)
  } else {
    i_end <- i_begin + grep(":", desc[(i_begin + 1):length(desc)])[1] - 1
    if(is.na(i_end)) {
      i_end <- length(desc)
    }
  }
  # check which packages are already present in DESCRIPTION
  missing_pkgs <- reduce_to_missing_in_DESCRIPTION(pkgs, desc)
  # stop if all packages already in DESCRIPTION
  if(length(missing_pkgs) == 0) {
    stop("All used packages are already in the DESCRIPTION somewhere (Imports, Suggests, Depends).")
  }
  # create string with missing packages and their version number in correct layout
  to_add_package_string <- create_to_add_package_string(missing_pkgs)
  to_add_package_string <- paste0("\n    ", paste0(to_add_package_string, collapse = ",\n    "))
  # add newly created package string to last line of Imports
  if (imports_already_existed) {
    desc[i_end] <- paste0(desc[i_end], ",", to_add_package_string)
  } else {
    desc[i_end] <- paste0(desc[i_end], to_add_package_string)
  }
  # write result back into DESCRIPTION file
  writeLines(text = desc, con = description_file)
}

create_to_add_package_string <- function(missing_pkgs) {
  unlist(lapply(missing_pkgs,
    function(x) {
      # check if package is installed
      if(x %in% rownames(installed.packages())) {
        paste0(x, " (>= ", utils::packageDescription(x)$Version, ")")
      } else {x}
    }
  ))
}

reduce_to_missing_in_DESCRIPTION <- function(pkgs, desc) {
  present <- unlist(lapply(pkgs,
    function(x) {
      doublespace <- paste0(" ", x, " ")
      space <- any(grep(doublespace, desc))
      spacecomma <- paste0(" ", x, ",")
      comma <- any(grep(spacecomma, desc))
      spacelinebreak <- paste0(" ", x, "$")
      linebreak <- any(grep(spacelinebreak, desc))
      return(space | comma | linebreak)
    }
  ))
  return(pkgs[!present])
}

get_R_files <- function(path, pattern = "\\.[rR]$|\\.[rR]md$|\\.[rR]nw$|\\.[rR]pres$") {
  # check if directory or single file
  if (dir.exists(path)) {
    # if directory, search for all possible R or Rmd files
    R_files <- list.files(
      path,
      pattern = pattern,
      ignore.case = TRUE,
      recursive = TRUE,
      full.names = TRUE
    )
  } else if (file.exists(path)) {
    # if file, just copy it into the files list
    R_files <- path
  } else {
    # stop if path doesn't exist at all
    stop("File or directory doesn't exist.")
  }

  return(R_files)
}

get_pkgs_from_R_files <- function(R_files) {
  # loop over every file
  pkgs <- lapply(
    R_files,
    function(y) {
      # read files libe by line
      current_file <- readLines(y, warn = FALSE)
      # get libraries explicitly called via library()
      library_lines <- gsub("library\\(\\)", "", current_file)
      library_lines <- grep("library\\(", library_lines, value = TRUE)
      l_libs <- unlist(strsplit(library_lines, split = "library\\("))
      l_libs <- grep("[A-Za-z0-9\\.]*\\)", l_libs, value = TRUE)
      l_libs <- unlist(lapply(l_libs, function(x) { gsub("(.+?)(\\).*)", "\\1", x) }))
      # get libraries explicitly called via require()
      require_lines <- gsub("require\\(\\)", "", current_file)
      require_lines <- grep("require\\(", require_lines, value = TRUE)
      r_libs <- unlist(strsplit(require_lines, split = "require\\("))
      r_libs <- grep("[A-Za-z0-9\\.]*\\)", r_libs, value = TRUE)
      r_libs <- unlist(lapply(r_libs, function(x) { gsub("(.+?)(\\).*)", "\\1", x) }))
      # get libraries implicitly called via ::
      point2_lines <- grep(pattern = "::", x = current_file, value = TRUE)
      # search for all collections of alphanumeric signs in between the
      # line start/a non-alphanumeric sign and ::
      p2_libs <- unlist(regmatches(
        point2_lines,
        gregexpr("(?<=^|[^a-zA-Z0-9])[a-zA-Z0-9]*?(?=::)", point2_lines, perl = TRUE)
      ))
      # get libraries implicitly called via :::
      point3_lines <- grep(pattern = ":::", x = current_file, value = TRUE)
      p3_libs <- unlist(regmatches(
        point3_lines,
        gregexpr("(?<=^|[^a-zA-Z0-9])[a-zA-Z0-9]*?(?=:::)", point3_lines, perl = TRUE)
      ))
      # merge results for current file
      res <- c(l_libs, r_libs, p2_libs, p3_libs)
      return(unique(res))
    }
  )
  # merge results of every file
  pkgs <- unique(unlist(pkgs))
  # remove NA and empty string
  pkgs <- pkgs[pkgs != "" & !is.na(pkgs)]
  # remove packages that are not valid package names
  pkgs <- pkgs[sapply(pkgs, function(y) { valid_name(y) } )]
  # remove packages that are not on CRAN
  # if (curl::has_internet() == TRUE & RCurl::url.exists("https://cran.r-project.org") == TRUE ) {
  #   pkgs <- pkgs[pkgs %in% utils::available.packages(repos = "https://cran.r-project.org")[,1] == TRUE]
  # }
  # order alphabetically
  pkgs <- sort(pkgs)

  return(pkgs)
}
