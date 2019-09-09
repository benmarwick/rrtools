use_template <- function(template, save_as = template, data = list(),
                         ignore = FALSE, open = FALSE, pkg = ".",
                         out_path, ask = TRUE) {
  pkg <- as.package(pkg)

  path <- file.path(pkg$path, out_path, save_as)
  if (!can_overwrite(path, ask = ask)) {
    stop("`", save_as, "` already exists.", call. = FALSE)
  }

  template_path <- template_path_fn(template)

  template_out <- whisker::whisker.render(readLines(template_path), data)

  usethis::ui_done("Creating {usethis::ui_value(save_as)} from template.")
  writeLines(template_out, path)

  if (ignore) {
    usethis::ui_done("Adding {usethis::ui_value(save_as)} to `.Rbuildignore`.")
    use_build_ignore(save_as, pkg = pkg)
  }

  if (open) {
    usethis::ui_todo("Modify {usethis::ui_value(save_as)}")
    open_in_rstudio(path)
  }

  invisible(TRUE)
}

template_path_fn <- function(template){
  system.file("templates",
               template,
               package = "rrtools",
               mustWork = TRUE)
}

# from https://github.com/r-lib/devtools/blob/master/R/utils.R
render_template <- function(name, data = list()) {
  path <- system.file("templates", name, package = "devtools")
  template <- readLines(path)
  whisker::whisker.render(template, data)
}

# from https://github.com/r-lib/devtools/blob/master/R/utils.R
read_dcf <- function(path) {
  fields <- colnames(read.dcf(path))
  as.list(read.dcf(path, keep.white = fields)[1, ])
}

# from https://github.com/r-lib/devtools/blob/master/R/utils.R
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
