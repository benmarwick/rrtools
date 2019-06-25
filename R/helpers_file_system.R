use_directory <- function(path, ignore = FALSE, pkg = ".") {
  pkg <- as.package(pkg)
  pkg_path <- file.path(pkg$path, path)

  if (file.exists(pkg_path)) {
    if (!is_dir(pkg_path)) {
      stop("`", path, "` exists but is not a directory.", call. = FALSE)
    }
  } else {
    usethis::ui_done("Creating {usethis::ui_value(path)}")
    dir.create(pkg_path, showWarnings = FALSE, recursive = TRUE,  mode = "0777")
  }

  if (ignore) {
    usethis::ui_done("Adding {usethis::ui_value(path)} to `.Rbuildignore`")
    use_build_ignore(path, pkg = pkg)
  }

  invisible(TRUE)
}

# from https://github.com/r-lib/devtools/blob/master/R/utils.R
# Given the name or vector of names, returns a named vector reporting
# whether each exists and is a directory.
dir.exists <- function(x) {
  res <- file.exists(x) & file.info(x)$isdir
  stats::setNames(res, x)
}
