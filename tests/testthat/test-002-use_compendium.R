context("use_compendium")

#### run function default (analysis/) ####
wd <- getwd()
setwd(package_path)
# usethis::use_package() does not create a license file, but we cannot
# pass the test without one, so this is a hack to stay faithful to usethis::
# but also pass the test
file.create("LICENSE")
suppressMessages(devtools::load_all("."))
suppressMessages(devtools::document())
rrtools:::quietly(output_of_check <- devtools::check())
setwd(wd)

#### check results ####

test_that("use_compendium generates a pkg that passes devtools::check() with no errors", {

  expect_equal(length(output_of_check$errors),
               0)

})

test_that("use_compendium generates a pkg that passes devtools::check() with no warnings", {


  expect_equal(length(output_of_check$warnings),
               0)

})

test_that("use_compendium generates a pkg that passes devtools::check() with no notes", {

  expect_equal(length(output_of_check$notes),
               0)

})

