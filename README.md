
<!-- README.md is generated from README.Rmd. Please edit that file -->
rrtools: Tools for Writing Reproducible Research in R
=====================================================

[![Travis-CI Build Status](https://travis-ci.org/benmarwick/rrtools.svg?branch=master)](https://travis-ci.org/benmarwick/rrtools)

The goal of rrtools is to provide instructions, templates, and functions for making a basic compendium suitable for doing reproducible research with [R](https://www.r-project.org). This package documents the key steps and provides convenient functions for quickly creating a new research compendium. The approach is based generally on Kitzes et al. (2017), and more specifically on Marwick (2017) and Wickham's (2017) work using the R package structure as the basis for a research compendium.

rrtools gives you a template for doing scholarly writing in a literate programming environment using [R Markdown](http://rmarkdown.rstudio.com) and [bookdown](https://bookdown.org/home/about.html). It also provides isolation of your computational environment using [Docker](https://www.docker.com/what-docker), package versioning using [MRAN](https://mran.microsoft.com/documents/rro/reproducibility/), and continuous integration using [Travis](https://docs.travis-ci.com/user/for-beginners). It makes a convenient starting point for writing a journal article, report or thesis.

This project was developed during the 2017 [ISAA Kiel](https://isaakiel.github.io/) Summer School on Reproducible Research in Landscape Archaeology at the Freie Universität Berlin (17-21 July). Special thanks to [Sophie C. Schmidt](https://github.com/SCSchmidt) for help. The convenience functions in this package are derived from similar functions in Hadley Wickham's [`devtools`](https://github.com/hadley/devtools) package.

Installation
------------

You can install rrtools from github with:

``` r
# install.packages("devtools")
devtools::install_github("benmarwick/rrtools")
```

How to use
----------

To create a reproducible research compendium using the rrtools approach, follow these steps (in [RStudio](https://www.rstudio.com/products/rstudio/#Desktop), which we recommend, but is not required):

#### 1. `rrtools::use_compendium("pkgname")`

-   this uses `devtools::create()` to create a basic R package with the name pkgname, and then opens the project (if using RStudio, if not, it sets the working directory to the pkgname directory)
-   we need to edit the DESCRIPTION file to include accurate metadata
-   we need to periodically update the `Imports:` section with the names of packages used (e.g., `devtools::use_package("dplyr", "imports")`)

#### 2. `devtools::use_mit_license(copyright_holder = "My Name")`

-   this references the MIT licence in the DESCRIPTION file and adds a LICENSE file with the given name

#### 3. `devtools::use_github(".", auth_token = "xxxx", protocol = "https", private = FALSE)`

-   this initializes a local git repository, connects to [github.com](https://github.com), and creates a remote repository
-   we need to get a token from <https://github.com/settings/tokens>, and replace "xxxx" with that token
-   we found that this gives an error in RStudio and doesn't fully enable git in RStudio, so:
-   in the shell, we need to run `git remote set-url origin https://github.com/username/pkgname.git`, complete one commit-push cycle from the shell, and restart RStudio
-   then we can commit, push, etc. as usual, from the shell or RStudio

#### 4. `rrtools::use_readme_rmd(); devtools::use_code_of_conduct()`

-   this generates README.Rmd, ready to add markdown code to show travis badge
-   we need to paste in the text from CoC from fn output in console, ready for public contributions
-   we need to render this document after each change to refresh README.md, which is the file that GitHub displays on the home page of our repository

#### 5. `rrtools::use_travis()`

-   this creates a minimal .travis.yml for us
-   we need to go to <https://travis-ci.org/> to connect to our repo
-   we need to add environment variables to enable push of the Docker container to the Docker Hub
-   we need to make an account at <https://hub.docker.com/> to host our Docker container

#### 6. `rrtools::use_analysis()`

-   this creates a top-level `analysis/` directory with the following contents:

<!-- -->

    analysis/
    |
    ├── paper/
    │   ├── paper.Rmd         # this is the main document to edit, could be multiple
    │   ├── references.bib    # this contains the reference list information
    │   └── journal-of-archaeological-science.csl
    |                         # this sets the style of citations & reference list
    ├── figures/
    |
    ├── data/
    │   ├── raw_data/       # data obtained from elswhere
    │   └── derived_data/   # data generated during the analysis
    |
    └──  templates
        ├── template.docx  # used to style the output of the paper.Rmd
        └── template.Rmd

-   the `paper.Rmd` in `analysis/paper/` is ready to render with bookdown
-   the `references.bib` file is empty, ready to insert reference details
-   you can replace the supplied `csl` file with one from <https://github.com/citation-style-language/>
-   we recommend using the [citr addin](https://github.com/crsh/citr) and [Zotero](https://www.zotero.org/) for high efficiency
-   remember that DESCRIPTION Imports: must include the names of all packages used in analysis

#### 7. `rrtools::use_dockerfile()`

-   this creates a basic Dockerfile using [`rocker/verse`](https://github.com/rocker-org/rocker) as the base image
-   the version of R in your rocker container will match the version used when you run this function, for example `rocker/verse:3.4.0`
-   [`rocker/verse`](https://github.com/rocker-org/rocker) includes R, the [tidyverse](http://tidyverse.org/), RStudio, pandoc and LaTeX, so build times are very fast
-   we need to edit dockerfile to add linux dependencies (if any) & modify which Rmd files are rendered when the container is made
-   we need to make an account at <https://hub.docker.com/> to host our Docker container

#### 8. `devtools::use_testthat()`

-   in case we have functions in R/, we need to include tests to ensure they do what we want
-   create tests.R in tests/testhat/ and check <http://r-pkgs.had.co.nz/tests.html> for template

You should be able to follow these steps to get a new research compendium repository connected to travis and ready to write in just a few minutes.

Future directions
-----------------

-   updating Imports: with `library()`, `require()` and :: calls in the Rmd when `render()`ing

References
----------

Kitzes, J., Turek, D., & Deniz, F. (Eds.). (2017). *The Practice of Reproducible Research: Case Studies and Lessons from the Data-Intensive Sciences*. Oakland, CA: University of California Press. <https://www.practicereproducibleresearch.org>

Marwick, B. (2017). Computational reproducibility in archaeological research: Basic principles and a case study of their implementation. *Journal of Archaeological Method and Theory*, 24(2), 424-450. <https:doi.org/10.1007/s10816-015-9272-9>

Wickham, H. (2017) *Research compendia*. Note prepared for the 2017 rOpenSci Unconf. <https://docs.google.com/document/d/1LzZKS44y4OEJa4Azg5reGToNAZL0e0HSUwxamNY7E-Y/edit#>

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
