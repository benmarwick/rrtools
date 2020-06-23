context("use_readme_rmd()")

#### run function ####

suppressMessages(
  rrtools::use_readme_rmd(
    package_path,
    render_readme = FALSE
  )
)

#### check results ####

# general
test_that("use_readme_rmd generates the correct files", {
  expect_true(
    all(
      c("CONDUCT.md", "CONTRIBUTING.md",  "README.Rmd") %in%
      list.files(package_path)
    )
  )
})

# CONDUCT.md
test_that("CONDUCT.md is a text file, has the correct heading and some text", {
  conduct <- readLines(file.path(package_path, "CONDUCT.md"))
  expect_gt(
    length(conduct),
    1
  )
  expect_equal(
    conduct[1],
    "# Contributor Code of Conduct"
  )
})

test_that("CONDUCT.md could be rendered to html", {
  expect_silent(
    rmarkdown::render(
      input = file.path(package_path, "CONDUCT.md"),
      output_format = "html_document",
      output_file = file.path(package_path, "CONDUCT.html"),
      quiet = TRUE,
      output_options = list(
        pandoc_args = c("--metadata=title:\"CONDUCT\"")
      )
    )
  )
})

# CONTRIBUTING.md
test_that("CONTRIBUTING.md is a text file and has the correct headings", {
  contributing <- readLines(file.path(package_path, "CONTRIBUTING.md"))
  expect_gt(
    length(contributing),
    1
  )

  expect_true(
    all(
      c(
        "# Contributing",
        "## Getting Started",
        "## Making changes",
        "## Submitting your changes"
      ) %in%
        contributing
    )
  )
})

test_that("CONTRIBUTING.md could be rendered to html", {
  expect_silent(
    rmarkdown::render(
      input = file.path(package_path, "CONTRIBUTING.md"),
      output_format = "html_document",
      output_file = file.path(package_path, "CONTRIBUTING.md"),
      quiet = TRUE,
      output_options = list(
        pandoc_args = c("--metadata=title:\"CONTRIBUTING\"")
      )
    )
  )
})

# README.Rmd
test_that("README.Rmd is a text file and has the correct heading", {
  readme <- readLines(file.path(package_path, "README.Rmd"))
  expect_gt(
    length(readme),
    1
  )
  expect_true(
    paste("#", basename(package_path)) %in% readme
  )
})

test_that("README.Rmd could be rendered to github markdown and then html", {
  expect_silent(
    rmarkdown::render(
      input = file.path(package_path, "README.Rmd"),
      output_format = "github_document",
      output_file = file.path(package_path, "README.md"),
      quiet = TRUE
    )
  )
  expect_silent(
    rmarkdown::render(
      input = file.path(package_path, "README.md"),
      output_format = "html_document",
      output_file = file.path(package_path, "README.html"),
      quiet = TRUE,
      output_options = list(
        pandoc_args = c("--metadata=title:\"README\"")
      )
    )
  )
})

