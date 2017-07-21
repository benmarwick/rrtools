
<!-- README.md is generated from README.Rmd. Please edit that file -->
timetest
========

[![Travis-CI Build Status](https://travis-ci.org/benmarwick/timetest.svg?branch=master)](https://travis-ci.org/benmarwick/timetest) [![Circle CI](https://circleci.com/gh/benmarwick/timetest.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/benmarwick/timetest)

The goal of timetest is to see how long it takes to set up a basic researh compendium. We did the following steps:

1.  devtools::create("pkgname") \# edit the desc, continuinous update Imports with pkg 1a. se\_mit\_license() \# license
2.  devtools::use\_github(".", auth\_token = "xxxx") \# connect to github.com, get token from <https://github.com/settings/tokens>, commit, push... maybe not, this is a bit flaky...
3.  devtools::use\_readme\_rmd() \# ready for the badges
4.  devtools::use\_travis() \# go to the <https://travis-ci.org/> to connect, change: MRAN,linux dependencies, devtools::install() to install custom fns, render, warnings\_are\_error: false %. create analysis dir, paper.Rmd, output: bookdown::word\_document2 bibliography: csl: update travis.yml
5.  paste in circle.yml \# change pkg name in 3 places, go to <https://circleci.com> & add env var, addd badge to readme.Rmd, knit to md
6.  paster in Dockerfile \# edit dockerfile: set rocker/verse R version, linux dependencies, pkg name, Rmd path/name, use <https://github.com/ropensci/dependencies> to get system libraries 7

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
