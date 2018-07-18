context("add_dependencies_to_description()")

#### preparations ####

# create artificial files with some dependencies
testfile_1 <- file.path(package_path, "/R/testfile_1.R")
writeLines(
  c("library(knitr)", "require(glue)", "rmarkdown::draft()"),
  con = testfile_1
)

if (!dir.exists(file.path(package_path, "/playground"))) {
  dir.create(file.path(package_path, "/playground"))
}
testfile_2 <- file.path(package_path, "/playground/testfile_2.R")
writeLines(
  c("library(bookdown)", "require(git2r)", "usethis::use_template()"),
  con = testfile_2
)

description_path <- paste0(package_path, "/DESCRIPTION")
description_unchanged <- readLines(description_path)

#### run function to change description ####

rrtools::add_dependencies_to_description(
  package_path,
  description_path,
  just_packages = FALSE
)

#### check results ####

description_changed <- readLines(description_path)

test_that("the DESCRIPTION file has changed exactly as expected", {
  expect_equal(
    all.equal(
      description_unchanged, description_changed
    ),
    "Lengths (8, 15) differ (string compare on first 8)"
  )
})

test_that("the DESCRIPTION file now actually contains the package dependencies", {
  expect_equal(
    grep("bookdown | git2r | glue | knitr | rmarkdown | usethis", description_changed),
    c(10:15)
  )
})

#### check functions ability to provide packages vector ####

test_that("add_dependencies_to_description provides correct packages vector if just_packages = TRUE", {
  expect_equal(
    rrtools::add_dependencies_to_description(
      package_path,
      description_path,
      just_packages = TRUE
    ),
    c("bookdown", "git2r", "glue", "knitr", "rmarkdown", "usethis")
  )
})
