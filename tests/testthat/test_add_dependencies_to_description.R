context("add_dependencies_to_description()")

#### preparations ####

# create artificial files
testfile_1 <- paste0(package_path, "/R/testfile_1.R")

writeLines(
  c("library(devtools)", "require(git2r)", "rmarkdown::draft()"),
  con = testfile_1
)

description_path <- paste0(package_path, "/DESCRIPTION")

#### run function ####

add_dependencies_to_description(
  package_path,
  description_path,
  just_packages = F
)

#### check results ####

test_that("the DESCRIPTION file contains the package dependencies", {
  expect_equal(grep("devtools | git2r | rmarkdown", readLines(description_path)), c(11, 12, 13))
})
