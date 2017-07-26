
<!-- README.md is generated from README.Rmd. Please edit that file -->
rrtools: Tools for Writing Reproducible Research in R
=====================================================

[![Travis-CI Build Status](https://travis-ci.org/benmarwick/rrtools.svg?branch=master)](https://travis-ci.org/benmarwick/rrtools)

The goal of rrtools is to provide instructions, templates, and functions for making a basic compendium suitable for doing reproducible research with [R](https://www.r-project.org). This package documents the key steps and provides convenient functions for quickly creating a new research compendium. The approach is based generally on Kitzes et al. (2017), and more specifically on Marwick (2017) and Wickham's (2017) work using the R package structure as the basis for a research compendium.

rrtools gives you a template for doing scholarly writing in a literate programming environment using [R Markdown](http://rmarkdown.rstudio.com) and [bookdown](https://bookdown.org/home/about.html). It also provides isolation of your computational environment using [Docker](https://www.docker.com/what-docker), package versioning using [MRAN](https://mran.microsoft.com/documents/rro/reproducibility/), and continuous integration using [Travis](https://docs.travis-ci.com/user/for-beginners). It makes a convenient starting point for writing a journal article, report or thesis.

The functions in rrtools allow you to use R to easily follow the best practices outlined in several major scholarly publications on reproducible research. In addition to those cited above, Wilson et al. (2017), Piccolo & Frampton (2016), Stodden & Miguez (2014) and rOpenSci (2017a, b) are important sources that have influenced our approach to this package. Please read those before using this package.

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

To create a reproducible research compendium using the rrtools approach, follow these steps. We use [RStudio](https://www.rstudio.com/products/rstudio/#Desktop), and recommend it, but is not required for these steps to work. We recommend copy-pasting these directly into your console, and editing the options before running. We don't recommend saving these lines in a script in your project: they are meant to be once-off setup functions.

#### 1. `rrtools::use_compendium("pkgname")`

-   this uses `devtools::create()` to create a basic R package with the name `pkgname` (you should use a different one), and then, if you're using RStudio, opens the project. If you're not using RStudio, it sets the working directory to the `pkgname` directory.
-   we need to:
    -   choose where we want our compendium package to be located on our computer. We recommend two ways you can do this. First, you can specify a full path to this function, for example, `rrtools::use_compendium("C:/Users/bmarwick/Desktop/pkgname")`. Second, you can set the working directory by means of the setwd command, for example, `setwd("C:/Users/bmarwick/Desktop/pkgname")` or using the drop-down menu in RStudio: `Session` -&gt; `Set Working Directory` and then run `rrtools::use_compendium("pkgname")`.
    -   edit the `DESCRIPTION` file (located in your `pkgname` directory) to include accurate metadata
    -   periodically update the `Imports:` section with the names of packages used in the code we write in the Rmd document(s) (e.g., `devtools::use_package("dplyr", "imports")`)

#### 2. `devtools::use_mit_license(copyright_holder = "My Name")`

-   this references the MIT license in the DESCRIPTION file and adds a LICENSE file with the given name
-   you may wish to use a different license for your code, if so, replace this line with `devtools::use_gpl3_license(copyright_holder = "My Name")`, or follow the instructions for other licenses.

#### 3. `devtools::use_github(".", auth_token = "xxxx", protocol = "https", private = FALSE)`

-   if you are connected to the internet, this initializes a local git repository, connects to [github.com](https://github.com), and creates a remote repository
-   if you are not connected to the internet, use `devtools::use_git(".")` to initialise a git repository with your project. Reopen your project in RStudio to see the git buttons on the toolbar.
-   we need to:
    -   install and configure git on our system *before* running this line. See <http://happygitwithr.com> for easy steps to do this.
    -   get a token from <https://github.com/settings/tokens>, and replace "xxxx" with that token
-   we found that this function can be a little unreliable in RStudio:
    -   sometimes giving and errors
    -   not fully enabling git in RStudio,
-   to work around this unreliability:
    -   in the shell, we need to `git remote set-url origin https://github.com/username/pkgname.git`
    -   restart RStudio, then we can commit, push, pull etc. as usual

#### 4. `rrtools::use_readme_rmd()`

-   this generates README.Rmd and renders it to README.md, ready to display on GitHub
-   the Rmd contains:
    -   a template citation to show others how to cite your project, we need to edit this to include the correct title and [DOI](https://doi.org)
    -   text giving license information for the text, figures, code and data in your compendium
-   this also adds two other markdown files: a code of conduct for users (CONDUCT.md), and basic instructions for people who want to contribute to your project (CONTRIBUTING.md), including for first-timers to git and GitHub
-   we need to render this document after each change to refresh README.md, which is the file that GitHub displays on the home page of our repository

#### 5. `rrtools::use_analysis()`

-   this has three `location` options: create a top-level `analysis/` directory, or create an `inst/` directory (so that all the sub-directories are available after the package is installed), or create a `vingettes/` directory (and automatically update the `DESCRIPTION`). The default is a top-level `analysis/`
-   For each option the contents of the sub-directories are the same, with the following (using the default `analysis/` for example):

<!-- -->

    analysis/
    |
    ├── paper/
    │   ├── paper.Rmd         # this is the main document to edit
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

-   the `paper.Rmd` is ready to write in and render with bookdown:
    -   it has a reference to the `references.bib` file
    -   it has a reference to the supplied `csl` file to style the reference list
    -   it has a colophon that adds some git commit details to the end of the document. This means that the output file (HTML/PDF/Word) is always tracable to a specific state of the code.
-   the `references.bib` file is has just one item to demonstrate the format, its ready to insert more reference details
-   you can replace the supplied `csl` file with one from <https://github.com/citation-style-language/>
-   we recommend using the [citr addin](https://github.com/crsh/citr) and [Zotero](https://www.zotero.org/) for highly efficient citation insertion while writing in an Rmd file.
-   remember that `Imports:` field in the `DESCRIPTION` file must include the names of all packages used in analysis documents (e.g. `paper.Rmd`)

#### 6. `rrtools::use_dockerfile()`

-   this creates a basic Dockerfile using [`rocker/verse`](https://github.com/rocker-org/rocker) as the base image.
-   the version of R in your rocker container will match the version used when you run this function, for example `rocker/verse:3.4.0`
-   [`rocker/verse`](https://github.com/rocker-org/rocker) includes R, the [tidyverse](http://tidyverse.org/), RStudio, pandoc and LaTeX, so compendium build times are very fast on travis.
-   we need to:
    -   edit Dockerfile to add linux dependencies (some R packages require additional libraries outside of R). You can find out what these are by browsing the DESCRIPTION files of the other packages you're using, and looking in the SystemRequirements field for each package. Often the logs on travis give error messages that include the names of missing libraries, so they are a useful source of information also.
    -   modify which Rmd files are rendered when the container is made.
    -   have a public GitHub repo to use the Dockerfile that this function generates. It is possible to keep the repository private and run a local Docker container with minor modifications to the Dockerfile that this funciton generates.
-   If we want to use Travis on our project, we need to make an account at <https://hub.docker.com/> to receive our Docker container after a successful build on travis

#### 7. `rrtools::use_travis()`

-   this creates a minimal `.travis.yml` file for us, by default it configures travis to build our Docker container from our Dockerfile, and build, install and run our custom package in this container. By specifying `docker = FALSE` in this function the travis file will not use Docker in travis, but run R directly on the travis infrastructure. Using Docker is recommended because it gives greater computational isolation and saves a substantial amount of time during the travis build because the base image contains many pre-compiled packages.
-   we need to:
    -   run this function only when we are ready for our repository to be public. The free travis service we're using here requires your GitHub repository to be public. It will not work on private repositories. You can skip this step if you want to keep your repo private until after publication.
    -   go to <https://travis-ci.org/> to connect to our repo
    -   add environment variables to enable push of the Docker container to the Docker Hub
    -   make an account at <https://hub.docker.com/> to host our Docker container

#### 8. `devtools::use_testthat()`

-   in case we have functions in `R/`, we need to include tests to ensure they do what we want
-   create tests.R in `tests/testhat/` and check <http://r-pkgs.had.co.nz/tests.html> for template

You should be able to follow these steps to get a new research compendium repository connected to travis and ready to write in just a few minutes.

References
----------

Kitzes, J., Turek, D., & Deniz, F. (Eds.). (2017). *The Practice of Reproducible Research: Case Studies and Lessons from the Data-Intensive Sciences*. Oakland, CA: University of California Press. <https://www.practicereproducibleresearch.org>

Marwick, B. (2017). Computational reproducibility in archaeological research: Basic principles and a case study of their implementation. *Journal of Archaeological Method and Theory*, 24(2), 424-450. <https:doi.org/10.1007/s10816-015-9272-9>

Piccolo, S. R. and M. B. Frampton (2016). "Tools and techniques for computational reproducibility." GigaScience 5(1): 30. <https://gigascience.biomedcentral.com/articles/10.1186/s13742-016-0135-4>

rOpenSci community (2017a). Reproducibility in Science A Guide to enhancing reproducibility in scientific results and writing. Online at <http://ropensci.github.io/reproducibility-guide/>

rOpenSci community (2017b). rrrpkg: Use of an R package to facilitate reproducible research. Online at <https://github.com/ropensci/rrrpkg>

Stodden, V. & Miguez, S., (2014). Best Practices for Computational Science: Software Infrastructure and Environments for Reproducible and Extensible Research. Journal of Open Research Software. 2(1), p.e21. DOI: <http://doi.org/10.5334/jors.ay>

Wickham, H. (2017) *Research compendia*. Note prepared for the 2017 rOpenSci Unconf. <https://docs.google.com/document/d/1LzZKS44y4OEJa4Azg5reGToNAZL0e0HSUwxamNY7E-Y/edit#>

Wilson G, Bryan J, Cranston K, Kitzes J, Nederbragt L, et al. (2017). Good enough practices in scientific computing. *PLOS Computational Biology* 13(6): e1005510. <https://doi.org/10.1371/journal.pcbi.1005510>

Contributing
------------

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
