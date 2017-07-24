
<!-- README.md is generated from README.Rmd. Please edit that file -->
rrtools: Tools for Writing Reproducible Research in R
=====================================================

[![Travis-CI Build Status](https://travis-ci.org/benmarwick/rrtools.svg?branch=master)](https://travis-ci.org/benmarwick/rrtools)

The goal of rrtools is to provide instructions, templates, and functions for making a basic compendium suitable for doing reproducible research with [R](https://www.r-project.org). This package documents the key steps and provides convenient functions for quickly creating a new research compendium. The approach is based generally on Kitzes et al. (2017), and more specifically on Marwick (2017) and Wickham's (2017) work using the R package structure as the basis for a research compendium.

rrtools gives you a template for doing scholarly writing in a literate programming environment using [R Markdown](http://rmarkdown.rstudio.com) and [bookdown](https://bookdown.org/home/about.html). It also provides isolation of your computational environment using [Docker](https://www.docker.com/what-docker), package versioning using [MRAN](https://mran.microsoft.com/documents/rro/reproducibility/), and continuous integration using [Travis](https://docs.travis-ci.com/user/for-beginners). It makes a convenient starting point for writing a journal article, report or thesis.

This project was developed during the 2017 Summer School on Reproducible Research in Landscape Archaeology at the Freie Universität Berlin (17-21 July), funded and jointly organized by [Exc264 Topoi](https://www.topoi.org/), [CRC1266](http://www.sfb1266.uni-kiel.de/en), and [ISAAKiel](https://isaakiel.github.io/). Special thanks to [Sophie C. Schmidt](https://github.com/SCSchmidt) for help. The convenience functions in this package are derived from similar functions in Hadley Wickham's [`devtools`](https://github.com/hadley/devtools) package.

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

#### 0. `setwd("base directory of your working environment")`

-   this ensures that your new package will be created in the correct directory

#### 1. `rrtools::use_compendium("pkgname")`

-   this uses `devtools::create()` to create a basic R package with the name `pkgname` (you should use a different one), and then, if you're using RStudio, opens the project. If you're not using RStudio, it sets the working directory to the `pkgname` directory.
-   we need to edit the DESCRIPTION file to include accurate metadata
-   we need to periodically update the `Imports:` section with the names of packages used in the code we write in the Rmd document(s) (e.g., `devtools::use_package("dplyr", "imports")`)

#### 2. `devtools::use_mit_license(copyright_holder = "My Name")`

-   this references the MIT license in the DESCRIPTION file and adds a LICENSE file with the given name
-   you may wish to use a different license for your code, if so, replace this line with `devtools::use_gpl3_license(copyright_holder = "My Name")`, or follow the instructions for other licenses.

#### 3. `devtools::use_github(".", auth_token = "xxxx", protocol = "https", private = FALSE)`

-   if you are connected to the internet, this initializes a local git repository, connects to [github.com](https://github.com), and creates a remote repository
-   if you are not connected to the internet, use `devtools::use_git(".")` to initialise a git repository with your project. Reopen your project in RStudio to see the git buttons on the toolbar.
-   we need to get a token from <https://github.com/settings/tokens>, and replace "xxxx" with that token. Give the token at least the access right to your public repositories (public\_repo), if the resulting compendium will be public. Otherwise you need to grant repo scope to give it full access also to private repositories.
-   we found that this function can be a little unreliable in RStudio, sometimes giving and errors and not fully enabling git in RStudio, so, to work around this:
-   in the shell, we need to `git remote set-url origin https://github.com/username/pkgname.git` (it does seem to work again in RStudio after completing one commit-push cycle from the shell and restarting RStudio)
-   then we can commit, push, pull etc. as usual

#### 4. `rrtools::use_readme_rmd()`

-   this generates README.Rmd and renders it to README.md, ready to display on GitHub
-   the Rmd contains:
    -   a template citation to show others how to cite your project, we need to edit this to include the correct title and [DOI](https://doi.org)
    -   badges to automatically show the last edit date, the R version used, and the status of the last build on travis
    -   text giving license information for the text, figures, code and data in your compendium
-   this also adds two other markdown files: a code of conduct for users, and basic instructions for people who want to contribute to your project, including for first-timers to git and GitHub
-   we need to render this document after each change to refresh README.md, which is the file that GitHub displays on the home page of our repository

#### 5. `rrtools::use_analysis()`

-   this has three options: create a top-level `analysis/` directory, or create an `inst/` directory (so that all the sub-directories are available after the package is installed), or create a `vingettes/` directory (and automatically update the `DESCRIPTION`). The default is a top-level `analysis/`
-   For each option the contents of the sub-directories are the same, with the following (suing the default `analysis/` for example):

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

-   the `paper.Rmd` in `analysis/paper/` is ready to write in and render with bookdown
-   the `references.bib` file is empty, ready to insert reference details
-   you can replace the supplied `csl` file with one from <https://github.com/citation-style-language/>
-   we recommend using the [citr addin](https://github.com/crsh/citr) and [Zotero](https://www.zotero.org/) for highly efficient citation insertion while writing in an Rmd file.
-   remember that `Imports:` field in the `DESCRIPTION` file must include the names of all packages used in analysis documents (e.g. `paper.Rmd`)

#### 6. `rrtools::use_dockerfile()`

-   this creates a basic Dockerfile using [`rocker/verse`](https://github.com/rocker-org/rocker) as the base image.
-   the version of R in your rocker container will match the version used when you run this function, for example `rocker/verse:3.4.0`
-   [`rocker/verse`](https://github.com/rocker-org/rocker) includes R, the [tidyverse](http://tidyverse.org/), RStudio, pandoc and LaTeX, so compendium build times are very fast, both locally and on travis.
-   we need to edit Dockerfile to add linux dependencies (many R packages require additional libraries outside of R).
-   we need to modify which Rmd files are rendered when the container is made.
-   we do not need to be online or using a public repo to make a Dockerfile. If we want to make the docker container then we need to be online, but we can make the container locally and keep it private until we are ready.
-   If we have a public GitHub repo and want to use Travis on our project, we need to make an account at <https://hub.docker.com/> to host our Docker container

#### 7. `rrtools::use_travis()`

-   this creates a minimal .travis.yml for us, by default it configures travis to build our Docker container from our Dockerfile, and build, install and run our custom package in this container. By specifying `docker = FALSE` in this function the travis file will not use Docker in travis, but run R directly on the travis infrastructure. Using Docker is recommended because it gives greater computational isolation and saves a substantial amount of time during the travis build because the base image contains many pre-compiled packages.
-   we need to run this function only when we are ready for our repository to be public. The free travis service we're using here requires your GitHub repository to be public. It will not work on private repositories. You can skip this step if you want to keep your repo private until after publication.
-   we need to go to <https://travis-ci.org/> to connect to our repo
-   we need to add environment variables to enable push of the Docker container to the Docker Hub
-   we need to make an account at <https://hub.docker.com/> to host our Docker container

#### 8. `devtools::use_testthat()`

-   in case we have functions in R/, we need to include tests to ensure they do what we want
-   create tests.R in tests/testhat/ and check <http://r-pkgs.had.co.nz/tests.html> for template

You should be able to follow these steps to get a new research compendium repository connected to travis and ready to write in just a few minutes.

Future directions
-----------------

-   updating Imports: with `library()`, `require()` and `::` calls in the Rmd when `render()`ing

References
----------

Kitzes, J., Turek, D., & Deniz, F. (Eds.). (2017). *The Practice of Reproducible Research: Case Studies and Lessons from the Data-Intensive Sciences*. Oakland, CA: University of California Press. <https://www.practicereproducibleresearch.org>

Marwick, B. (2017). Computational reproducibility in archaeological research: Basic principles and a case study of their implementation. *Journal of Archaeological Method and Theory*, 24(2), 424-450. <https:doi.org/10.1007/s10816-015-9272-9>

Wickham, H. (2017) *Research compendia*. Note prepared for the 2017 rOpenSci Unconf. <https://docs.google.com/document/d/1LzZKS44y4OEJa4Azg5reGToNAZL0e0HSUwxamNY7E-Y/edit#>

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
