context("license")

#### run function default (analysis/) ####

wd <- getwd()
setwd(package_path)
suppressMessages(
usethis::use_mit_license(name = usethis:::git_config_get("user.name", global = TRUE))
)
setwd(wd)

#### check results ####

test_that("license file has a username", {

  license_file_text <-
  readLines(file.path(package_path, "LICENSE.md"))

  # number of characters in line 3 if there is no name
  num_char <- 18

  # so if there is a name, we will have more than 18 chr there

  expect_gt(nchar(license_file_text[3]),
               num_char)


})