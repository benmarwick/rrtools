context("use_analysis()")

#### run function default (analysis/) ####

suppressMessages(
  rrtools::use_analysis(pkg = package_path)
)

#### check results ####

test_that("use_analysis generates the template directories and files", {

  expect_equal(list.files(file.path(package_path, 'analysis')),
               c("data", "figures",  "paper", "supplementary-materials", "templates"))

  expect_equal(list.files(file.path(package_path, 'analysis', 'paper')),
               c("paper.qmd", "references.bib"))

})

#### check that the new paper.qmd can render ok ####

test_that("the new paper.qmd can render to docx ok", {

 quarto::quarto_render(input = file.path(package_path, 'analysis', 'paper', "paper.qmd"),
                       quiet = TRUE)

 expect_equal(list.files(file.path(package_path, 'analysis', 'paper')),
             c( "paper.docx" , "paper.qmd", "references.bib"))
})

#### DESCRIPTION updated correctly ####

test_that("use_analysis updates DESCRIPTION correctly", {

  pkg <- as.package(package_path)

  # check there's only a single suggests field
  expect_equal(sum(grepl("suggests", names(pkg))), 1)

  # check there's only a single imports field
  expect_equal(sum(grepl("imports", names(pkg))), 1)
  expect_equal(pkg$suggests , "devtools,\ngit2r")

})

#### run function inst/ ####

suppressMessages(
  rrtools::use_analysis(pkg = package_path, location = "inst")
)

#### check results ####

test_that("use_analysis(location = 'inst') generates the template directories and files", {

  expect_equal(list.files(file.path(package_path, 'inst')),
               c("data", "figures",  "paper", "supplementary-materials", "templates"))

  expect_equal(list.files(file.path(package_path, 'inst', 'paper')),
               c("paper.qmd", "references.bib"))

})



#### run function vignettes/ ####

suppressMessages(
  rrtools::use_analysis(pkg = package_path, location = "vignettes")
)

# clean up from readme test
unlink(file.path(package_path, "runtime.txt"))


#### check results ####

test_that("use_analysis(location = 'vignettes') generates the template directories and files", {

  expect_equal(list.files(file.path(package_path, 'vignettes')),
               c("data", "figures",  "paper", "supplementary-materials", "templates"))

  expect_equal(list.files(file.path(package_path, 'vignettes', 'paper')),
               c("paper.qmd", "references.bib"))

})
