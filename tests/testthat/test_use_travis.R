context("use_travis()")

# Idea for the future: The validity of travis.yml files can be checked automatically:
# https://docs.travis-ci.com/user/travis-lint

#### run function without docker = TRUE ####

suppressMessages(
  rrtools::use_travis(
    package_path,
    browse = FALSE,
    docker = FALSE,
    ask = FALSE
  )
)

#### check results without docker = TRUE ####

test_that("use_travis() generates .travis.yml", {
  expect_true(
      ".travis.yml" %in% list.files(package_path, all.files = TRUE)
  )
})

test_that(".travis.yml is a text file, has some text and an essential line", {
  travis <- readLines(file.path(package_path, ".travis.yml"))
  expect_gt(
    length(travis),
    1
  )
  expect_true(
    "language: R" %in% travis
  )
})

#### cleanup after test without docker ####

file.remove(
  file.path(package_path, ".travis.yml")
)

#### run function with docker = TRUE ####

suppressMessages(
  rrtools::use_travis(
    package_path,
    browse = FALSE,
    docker = TRUE,
    ask = FALSE
  )
)

#### check results with docker = TRUE ####

test_that("use_travis() generates .travis.yml", {
  expect_true(
    ".travis.yml" %in% list.files(package_path, all.files = TRUE)
  )
})

test_that(".travis.yml is a text file, has some text and an essential line", {
  travis <- readLines(file.path(package_path, ".travis.yml"))
  expect_gt(
    length(travis),
    1
  )
  expect_true(
    "language: generic" %in% travis
  )
})
