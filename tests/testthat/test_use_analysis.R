context("use_analysis()")

#### run function default (analysis/) ####

suppressMessages(
  rrtools::use_analysis(pkg = package_path)
)

#### check results ####

test_that("use_analysis generates the template directories and files", {

  expect_equal(list.files(file.path(package_path, 'analysis')),
               c("data", "figures",  "paper", "templates"))

  expect_equal(list.files(file.path(package_path, 'analysis', 'paper')),
               c("paper.Rmd", "references.bib"))

})



#### run function inst/ ####

suppressMessages(
  rrtools::use_analysis(pkg = package_path, location = "inst")
)

#### check results ####

test_that("use_analysis(location = 'inst') generates the template directories and files", {

  expect_equal(list.files(file.path(package_path, 'inst')),
               c("data", "figures",  "paper", "templates"))

  expect_equal(list.files(file.path(package_path, 'inst', 'paper')),
               c("paper.Rmd", "references.bib"))

})



#### run function vignettes/ ####

suppressMessages(
  rrtools::use_analysis(pkg = package_path, location = "vignettes")
)

#### check results ####

test_that("use_analysis(location = 'vignettes') generates the template directories and files", {

  expect_equal(list.files(file.path(package_path, 'vignettes')),
               c("data", "figures",  "paper", "templates"))

  expect_equal(list.files(file.path(package_path, 'vignettes', 'paper')),
               c("paper.Rmd", "references.bib"))

})
