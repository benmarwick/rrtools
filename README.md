
<!-- README.md is generated from README.Rmd. Please edit that file -->
timetest
========

[![Travis-CI Build Status](https://travis-ci.org/benmarwick/timetest.svg?branch=master)](https://travis-ci.org/benmarwick/timetest) [![Circle CI](https://circleci.com/gh/benmarwick/timetest.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/benmarwick/timetest)

The goal of timetest is to see how long it takes to set up a basic research compendium, with continous integration, and ready to write a journal article, report or thesis.

This was a project developed during the 2017 [ISAA Kiel](https://isaakiel.github.io/) Summer School on Reproducible Research in Landscape Archaeology at the Freie Universität Berlin (17-21 July). Thanks to [Sophie C. Schmidt](https://github.com/SCSchmidt) for help!

We did the following steps:

#### 1. devtools::create("pkgname")

-   edit the DESCRIPTION
-   continuinously update Imports: with pkgs used in Rmd

#### 2. devtools::use\_mit\_license()

-   gives MIT licence in DESCRIPTION, edit LICENSE file to add name

#### 3. devtools::use\_github(".", auth\_token = "xxxx")

-   connect to github.com, get token from <https://github.com/settings/tokens>
-   commit, push... maybe not, this is a bit flaky...

#### 4. devtools::use\_readme\_rmd()

-   ready for to add markdon code to show travis and circle badges

#### 5. devtools::use\_travis()

-   go to the <https://travis-ci.org/> to connect,
-   change: MRAN
    -- linux dependencies, see previous .travis.yml
    -- devtools::install() to install custom fns
    -- render Rmd command
    -- warnings\_are\_error: false

#### 6. create analysis dir, and paper.Rmd and data/ dir

-   in metadata yml block
    -- output: bookdown::word\_document2
    -- bibliography:
    -- csl:
-   update travis.yml with path/name of Rmd

#### 7. paste in circle.yml

-   get circle.yml from most recent project
-   change pkg name in 3 places
-   go to <https://circleci.com> & add env vars
-   add badge to readme.Rmd, knit to md

#### 8. paste in Dockerfile

-   get dockerfile from most recent project
-   edit dockerfile:
    -- set rocker/verse R version
    -- add linux dependencies
    -- update repo/pkg name
    -- update Rmd path/name

First timed attempt from nothing to green badges took **1 hour**, including builds with tidyverse.

Installation
------------

You can install timetest from github with:

``` r
# install.packages("devtools")
devtools::install_github("benmarwick/timetest")
```

Example
-------

This is a basic example which shows you how to solve a common problem:

``` r
## basic example code
```
