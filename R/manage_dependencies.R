#' Searches for external packages and adds them to the Imports field in the description
#'
#' Scans script files (.R, .Rmd, .Rnw, .Rpres, etc.) for external package dependencies indicated by
#' \code{library()}, \code{require()} or \code{::} and adds those packages to the Imports field in
#' the package DESCRIPTION.
#'
#' @param path location of individual file or directory where to search for scripts.
#' @param description_file location of description file to be updated.
#' @param just_packages just give back a character vector of the found packages.
#'
#' @export
add_dependencies_to_description <- function(
  path = getwd(),
  description_file = "DESCRIPTION",
  just_packages = FALSE
) {

  # check if directory or single file
  if (utils::file_test("-d", path)) {
    # if directory, search for all possible R or Rmd files
    pattern <- "\\.[rR]$|\\.[rR]md$|\\.[rR]nw$|\\.[rR]pres$"
    R_files <- list.files(
      path,
      pattern = pattern,
      ignore.case = TRUE,
      recursive = TRUE,
      full.names = TRUE
    )
  } else if (utils::file_test("-f", path)) {
    # if file, just copy it into the files list
    R_files <- path
  } else {
    # stop if path doesn't exist at all
    stop("File or directory doesn't exist.")
  }

  # loop over every file
  pkgs <- lapply(
    R_files,
    function(y) {
      # read files libe by line
      current_file <- readLines(y)
      # get libraries explicitly called via library()
      library_lines <- grep(pattern = "library", x = current_file, value = TRUE)
      l_libs <- strsplit(library_lines, split = "library\\(")
      l_libs <- lapply(l_libs, function(x){strsplit(x[2], split = "\\)")})
      l_libs <- unlist(l_libs)
      # get libraries explicitly called via require()
      require_lines <- grep(pattern = "require", x = current_file, value = TRUE)
      r_libs <- strsplit(require_lines, split = "require\\(")
      r_libs <- lapply(r_libs, function(x){strsplit(x[2], split = "\\)")})
      r_libs <- unlist(r_libs)
      # get libraries implicitly called via ::
      point_lines <- grep(pattern = "::", x = current_file, value = TRUE)
      # search for all collections of alphanumeric signs in between the
      # line start/a non-alphanumeric sign and ::
      p_libs <- regmatches(
        point_lines,
        gregexpr("(?<=^|[^a-zA-Z0-9])[a-zA-Z0-9]*?(?=::)", point_lines, perl = TRUE)
      )
      p_libs <- unlist(p_libs)
      # merge results for current file
      res <- c(l_libs, r_libs, p_libs)
      return(unique(res))
    }
  )

  # merge results of every file
  pkgs <- unique(unlist(pkgs))
  # remove NA and empty string
  pkgs <- pkgs[pkgs != "" & !is.na(pkgs)]
  # order alphabetically
  pkgs <- sort(pkgs)

  # remove packages that are not on CRAN
  # TODO: keep an eye on that one: https://github.com/ropenscilabs/available
  if (curl::has_internet()==TRUE & RCurl::url.exists("https://cran.r-project.org") ==TRUE ) {
    pkgs <- pkgs[pkgs %in% utils::available.packages(repos = "https://cran.r-project.org")[,1]==TRUE]
  }

  # if the just_packages option is selected, just give back the list of packages
  if (just_packages) {
    return(pkgs)
  }

  # read DESCRIPTION file
  tmp <- readLines(description_file)
  # check, if Imports fields is available
  if (length(grep("Imports", tmp)) == 0) {
    # if no: add it
    tmp[length(tmp)+1] <- "Imports:"
  }
  # get line where Imports starts
  i_begin <- grep("Imports", tmp)
  # get line where Imports ends (determination via search for next ":")
  # if Imports is the last tag, set i_end to the last line
  if((i_begin + 1) >= length(tmp)) {
    i_end <- length(tmp)
  } else {
    i_end <- i_begin + grep(":", tmp[(i_begin + 1):length(tmp)])[1] - 1
    if(is.na(i_end)) {
      i_end <- length(tmp)
    }
  }
  # check which packages are already present in DESCRIPTION
  present <- unlist(lapply(
    pkgs,
    function(x) {
      doublespace <- paste0(" ", x, " ")
      space <- any(grep(doublespace, tmp))
      spacecomma <- paste0(" ", x, ",")
      comma <- any(grep(spacecomma, tmp))
      spacelinebreak <- paste0(" ", x, "$")
      linebreak <- any(grep(spacelinebreak, tmp))
      return(space | comma | linebreak)
    }
  ))
  # stop if all packages already in DESCRIPTION
  if(all(present)) {
    stop("All used packages are already in the DESCRIPTION somewhere (Imports, Suggests, Depends).")
  }
  # create string with missing packages and their version number in correct layout
  to_add_version <- unlist(lapply(
    pkgs[!present],
    function(x) {
      # check if package is installed
      if(x %in% rownames(installed.packages())) {
        paste0(x, " (>= ", utils::packageDescription(x)$Version, ")")
      } else {x}
    }
  ))
  to_add_final <- paste0("\n    ", paste0(to_add_version, collapse = ",\n    "))
  # add newly created package string to last line of Imports
  tmp[i_end] <- paste0(tmp[i_end], ",", to_add_final)
  # write result back into DESCRIPTION file
  writeLines(text = tmp, con = description_file)
}
