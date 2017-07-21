
<!-- README.md is generated from README.Rmd. Please edit that file -->
timetest
========

[![Travis-CI Build Status](https://travis-ci.org/benmarwick/timetest.svg?branch=master)](https://travis-ci.org/benmarwick/timetest) [![Circle CI](https://circleci.com/gh/benmarwick/timetest.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/benmarwick/timetest)

The goal of timetest is to see how long it would take to set up a basic research compendium, with continous integration, and ready to write a journal article, report or thesis. The goal was also to document the key steps of creating a new research compendium in an efficient order suitable for reuse in new projects.

This was a project developed during the 2017 [ISAA Kiel](https://isaakiel.github.io/) Summer School on Reproducible Research in Landscape Archaeology at the Freie Universität Berlin (17-21 July). Thanks to [Sophie C. Schmidt](https://github.com/SCSchmidt) for help.

We did the following steps (in RStudio, but that's not important):

#### 1. `devtools::create("pkgname")`

-   this creates a basic R package with the name pkgname
-   we must find the new project folder, and open the new .Rproj file to go into the new project
-   we must edit the DESCRIPTION to give correct metadata
-   then we continuinously update Imports: with pkgs used in Rmd, as we write the Rmd

#### 2. `devtools::use_mit_license(copyright_holder = "My Name")`

-   this gives MIT licence in DESCRIPTION, adds LICENSE file with our name in it

#### 3. `devtools::use_github(".", auth_token = "xxxx")`

-   connect to github.com, get token from <https://github.com/settings/tokens>
-   commit, push... maybe not, this is a bit flaky...

#### 4. `devtools::use_readme_rmd(); evtools::use_code_of_conduct()`

-   ready for to add markdon code to show travis and circle badges
-   paste in test from CoC from fn, ready for public contributions

#### 5. `devtools::use_travis()`

-   this creates a minimal .travis.yml for us
-   we need to go to the <https://travis-ci.org/> to connect,
-   in .travis.yml we need to change: -- MRAN
    -   linux dependencies, see previous .travis.yml
    -   `devtools::install()` to install custom fns
    -   `rmarkdown::render(...)` to knit Rmd file to Word/HTML/PDF
    -   `warnings_are_error: false`
-   wee need edit DESCRIPTION add to Imports: rmarkdown, knitr, bookdown so Travis has these available to knit the Rmd (Docker doesn't need them because they're in the rocker/verse base iamge)

#### 6. create analysis/ dir, and paper.Rmd and data/ dir

-   in metadata yml block
    -   output: bookdown::word\_document2 or html\_ or pdf\_
    -   bibliography: \[file name of bib file\] use the citr Addin and Zotero for high efficiency
    -   csl: \[file name of csl, downloaded from <https://github.com/citation-style-language>\]
-   we need to update travis.yml with exact path/name of Rmd
-   while working in the Rmd writing code, update DESCTIPTION Imports: with pkg names

#### 7. paste in Dockerfile

-   we need to get dockerfile from most recent good project
-   then edit dockerfile:
    -   set rocker/verse R version
    -   add linux dependencies
    -   update repo/pkg name
    -   update Rmd path/name

#### 8. paste in circle.yml

-   need to get circle.yml from most recent project
-   we must change pkg name in 3 places in the circle.yml file
-   we need to go to <https://circleci.com> & add env vars
-   we must add badge to readme.Rmd, then knit to md for display on GitHub

#### 9. `devtools::use_testthat()`

-   in case we have functions in R/, we need to have some tests to ensure they do what we want
-   Create tests.R in tests/testhat/ and check <http://r-pkgs.had.co.nz/tests.html> for template

First timed attempt of this workflow, from nothing to green badges, took **1 hour**, including builds with tidyverse and a little bit of code in the Rmd.

Future directions
-----------------

We see scope for automation in these area:

-   updating Imports: with `library()`, `require()` and :: calls in the Rmd
-   write Dockerfile (containerit did not work for us)
-   write circle.yml
-   write custom lines to .travis.yml for install and render

Installation
------------

You can install timetest from github with:

``` r
# install.packages("devtools")
devtools::install_github("benmarwick/timetest")
```

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
