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

