context("use_analysis()")

#### run function ####

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
