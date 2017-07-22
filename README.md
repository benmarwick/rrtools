
<!-- README.md is generated from README.Rmd. Please edit that file -->
rrtools: Tools for Writing Reproducible Reseach in R
====================================================

[![Travis-CI Build Status](https://travis-ci.org/benmarwick/rrtools.svg?branch=master)](https://travis-ci.org/benmarwick/rrtools)

The goal of rrtools is to provide instructions, templates and functions for making a basic compendium suitable for doing reproducible research with R. This package documents the key steps and provides convenient functions for quickly creating a new research compendium.

rrtools gives you a template for doing scholarly writing in literate programming enviroment using R Markdown and bookdown. It also provides isolation of your computational enviroment using Docker, package versioning using MRAN, and continuous integration using Travis. It makes a convenient starting point for writing a journal article, report or thesis.

This project was developed during the 2017 [ISAA Kiel](https://isaakiel.github.io/) Summer School on Reproducible Research in Landscape Archaeology at the Freie Universität Berlin (17-21 July). Special thanks to [Sophie C. Schmidt](https://github.com/SCSchmidt) for help.

Installation
------------

You can install rrtools from github with:

``` r
# install.packages("devtools")
devtools::install_github("benmarwick/timetest")
```

How to use
----------

To create a reproducible research compendium using the rrtools approach, follow these steps (in RStudio, which we recommend):

#### 1. `devtools::create("pkgname")`

-   this creates a basic R package with the name pkgname
-   we need to double-click the `pkgname.Rproj` just created to open the new package project
-   edit the DESCRIPTION to give correct metadata
-   then we continuinously update `Imports:` with names of pkgs used in Rmd, as we write the Rmd, this can be done with, for example, `devtools::use_package("dplyr", "imports")`

#### 2. `devtools::use_mit_license(copyright_holder = "My Name")`

-   this gives MIT licence in DESCRIPTION, adds LICENSE file with our name in it

#### 3. `devtools::use_github(".", auth_token = "xxxx")`

-   connect to github.com, get token from <https://github.com/settings/tokens>
-   commit, push... maybe not, this is a bit flaky...

#### 4. `devtools::use_readme_rmd(); devtools::use_code_of_conduct()`

-   this makes readme.Rmd, ready for to add markdown code to show travis badge
-   we need to paste in test from CoC from fn output in console, ready for public contributions

#### 5. `rrtools::use_travis()`

-   this creates a minimal .travis.yml for us
-   we need to go to the <https://travis-ci.org/> to connect to our repo
-   we need to add environment variables to enable push of the Docker container to the Docker Hub

#### 6. `rrtools::use_analysis()`

-   this creates an `analysis/` directory and some sub-directories to hold files for a `paper/` (or thesis or report), `data/` and `figures/`
-   also creates a `paper.Rmd` in `paper/` ready to render with bookdown
-   also creates an empty `references.bib` file, ready to insert reference details
-   also adds a `csl` file, you can replace it with one from <https://github.com/citation-style-language/>
-   we recommend using the citr Addin and Zotero for high efficiency
-   we need to remember that when working in the Rmd writing code, we much update DESCTIPTION Imports: with pkg names used in the Rmd

#### 7. `rrtools::use_dockerfile()`

-   this will create a basic Dockerfile using `rocker/verse` as the base image
-   the version of R in your rocker container will match the version used when you run this function, for example `rocker/verse:3.4.0`
-   `rocker/verse` includes R, the tidyverse, RStudio, pandoc and LaTeX, so build times are very fast
-   we need to edit dockerfile to add linux dependencies (if any) & modify which Rmd files are rendered when the container is made.

#### 8. `devtools::use_testthat()`

-   in case we have functions in R/, we need to have some tests to ensure they do what we want
-   Create tests.R in tests/testhat/ and check <http://r-pkgs.had.co.nz/tests.html> for template

You should be able to follow these steps get a new research compendium repository connected to travis and ready to write in just a few minutes.

Future directions
-----------------

We see scope for automation in these area:

-   updating Imports: with `library()`, `require()` and :: calls in the Rmd

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
