# create temporary directory in file system
playground_path <- paste0(tempdir(), "/testpackages")
dir.create(playground_path, showWarnings = FALSE)

# create test package
package_path <- paste0(
  playground_path,
  tempfile(pattern = "testpackage.", tmpdir = "", fileext = "")
)

devtools::create(
  path = package_path,
  check = FALSE,
  rstudio = FALSE,
  quiet = TRUE
)

