# rrtools: Tools for Writing Reproducible Research in R

[![Travis-CI Build Status](https://travis-ci.org/benmarwick/rrtools.svg?branch=master)](https://travis-ci.org/benmarwick/rrtools) [![Circle-CI Build Status](https://circleci.com/gh/benmarwick/rrtools.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/benmarwick/rrtools) [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/benmarwick/rrtools/master?urlpath=rstudio)

## Motivation

The goal of **rrtools** is to provide instructions, templates, and functions for making a basic compendium suitable for writing a reproducible journal article or report with [R](https://www.r-project.org). This package documents the key steps and provides convenient functions for quickly creating a new research compendium. The approach is based generally on [Kitzes et al. (2017)](https://www.practicereproducibleresearch.org), and more specifically on [Marwick (2017)](https://doi.org/10.1007/s10816-015-9272-9), [Marwick et al. (2018)](https://doi.org/10.7287/peerj.preprints.3192v1), and [Wickham’s (2017)](https://docs.google.com/document/d/1LzZKS44y4OEJa4Azg5reGToNAZL0e0HSUwxamNY7E-Y/edit#) work using the R package structure as the basis for a research compendium.

rrtools provides a template for doing scholarly writing in a literate programming environment using [R Markdown](http://rmarkdown.rstudio.com) and [bookdown](https://bookdown.org/home/about.html). It also allows for isolation of your computational environment using [Docker](https://www.docker.com/what-docker), package versioning using [MRAN](https://mran.microsoft.com/documents/rro/reproducibility/), and continuous integration using [Travis](https://docs.travis-ci.com/user/for-beginners). It makes a convenient starting point for writing a journal article or report. If you’re writing a PhD thesis, or a similar type of multi-chapter document, a better choice might the [huskydown package](https://github.com/benmarwick/huskydown) or other bookdown variants.

The functions in rrtools allow you to use R to easily follow the best practices outlined in several major scholarly publications on reproducible research. In addition to those cited above, [Wilson et al. (2017)](https://doi.org/10.1371/journal.pcbi.1005510), [Piccolo & Frampton (2016)](https://gigascience.biomedcentral.com/articles/10.1186/s13742-016-0135-4), [Stodden & Miguez (2014)](http://doi.org/10.5334/jors.ay) and rOpenSci (2017[a](http://ropensci.github.io/reproducibility-guide/), [b](https://github.com/ropensci/rrrpkg)) are important sources that have influenced our approach to this package.

## Installation

To explore and test rrtools without installing anything, click the [Binder](https://mybinder.org/v2/gh/benmarwick/rrtools/master?urlpath=rstudio) badge above to start RStudio in a browser tab that includes the contents of this GitHub repository. In that environment you can browse the files, install rrtools, and make a test compendium without altering anything on your computer.

You can install rrtools from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("benmarwick/rrtools")
```

## How to use

To create a reproducible research compendium step-by-step using the rrtools approach, follow these detailed instructions. We use [RStudio](https://www.rstudio.com/products/rstudio/#Desktop), and recommend it, but is not required for these steps to work. We recommend copy-pasting these directly into your console, and editing the options before running. We don’t recommend saving these lines in a script in your project: they are meant to be once-off setup functions.

#### 0\. Create a Git managed directory linked to an online repository

  - Usually we want our research compendium to be managed by the version control software [Git](https://git-scm.com/). The free online book [Happy Git With R](http://happygitwithr.com) has details on how to do this. In brief, there are two methods to get started:
      + [New project on GitHub first, then download to RStudio](https://happygitwithr.com/new-github-first.html): Start on Github, Gitlab, or a similar web service, and create an empty repository called `pkgname` (you should use a different name, please follow the rules below) on that service. Then [clone](https://happygitwithr.com/new-github-first.html) that repository to have a local empty directory on your computer, called `pkgname`, that is linked to this remote repository. 
      + [New project in RStudio first, then connect to GitHub/GitLab](https://happygitwithr.com/existing-github-first.html): An alternative approach is to create a local, empty, directory called `pkgname` on your computer, and initialize it with Git (`git init`), then create a GitHub/GitLab repository and connect your local project to the remote repository.
  - Whichever of those two methods that you choose, you continue by [staging, commiting an pushing](https://happygitwithr.com/git-basics.html) every future change in the repository with Git.
  - Your `pkgname` must follow some rules for everything to work, it must: 
    + … contain only ASCII letters, numbers, and ‘.’
    + … have at least two characters
    + … start with a letter (not a number)
    + … not end with ‘.’

#### 1\. `rrtools::use_compendium("pkgname")`

  - this uses `usethis::create_package()` to create a basic R package in the `pkgname` directory, and then, if you’re using RStudio, opens the project. If you’re not using RStudio, it sets the working directory to the `pkgname` directory. 
  - we need to:
      - run `rrtools::use_compendium("path/to/pkgname")` (you use the path to `pkgname` in your system)
      - edit the `DESCRIPTION` file (located in your `pkgname` directory) to include accurate metadata
      - periodically update the `Imports:` section of the `DESCRIPTION` file with the names of packages used in the code we write in the         Rmd document(s) (e.g., `usethis::use_package("dplyr", "imports")`)

#### 2\. `usethis::use_mit_license(name = "My Name")`

  - this adds a reference to the MIT license in the [DESCRIPTION](DESCRIPTION) file and generates a [LICENSE](LICENSE) file listing the name provided as the copyright holder
  - to use a different license, replace this line with `usethis::use_gpl3_license(name = "My Name")`, or follow the instructions for other licenses

#### 3\. `rrtools::use_readme_rmd()`

  - this generates [README.Rmd](README.Rmd) and renders it to [README.md](README.md), ready to display on GitHub. It contains: 
      - a template citation to show others how to cite your project. Edit this to include the correct title and [DOI](https://doi.org).
      - license information for the text, figures, code and data in your compendium
  - this also adds two other markdown files: a code of conduct for users [CONDUCT.md](CONDUCT.md), and basic instructions for people who want to contribute to your project [CONTRIBUTING.md](CONTRIBUTING.md), including for first-timers to git and GitHub. 
  - render this document after each change to refresh [README.md](README.md), which is the file that GitHub displays on the repository home page

#### 4\. `rrtools::use_analysis()`

  - this function has three `location =` options: `top_level` to create a top-level `analysis/` directory, `inst` to create an `inst/` directory (so that all the sub-directories are available after the package is installed), and `vignettes` to create a `vignettes/` directory (and automatically update the `DESCRIPTION`). The default is a top-level `analysis/`.
  - for each option, the contents of the sub-directories are the same, with the following (using the default `analysis/` for example):

<!-- end list -->

    analysis/
    |
    ├── paper/
    │   ├── paper.Rmd       # this is the main document to edit
    │   └── references.bib  # this contains the reference list information
    
    ├── figures/            # location of the figures produced by the Rmd
    |
    ├── data/
    │   ├── raw_data/       # data obtained from elsewhere
    │   └── derived_data/   # data generated during the analysis
    |
    └── templates
        ├── journal-of-archaeological-science.csl
        |                   # this sets the style of citations & reference list
        ├── template.docx   # used to style the output of the paper.Rmd
        └── template.Rmd

  - the `paper.Rmd` is ready to write in and render with bookdown. It includes:
      - a YAML header that identifies the `references.bib` file and the supplied `csl` file (to style the reference list)
      - a colophon that adds some git commit details to the end of the document. This means that the output file (HTML/PDF/Word) is always traceable to a specific state of the code.
  - the `references.bib` file has just one item to demonstrate the format. It is ready to insert more reference details.
  - you can replace the supplied `csl` file with a different citation style from <https://github.com/citation-style-language/>
  - we recommend using the [citr addin](https://github.com/crsh/citr) and [Zotero](https://www.zotero.org/) to efficiently insert citations while writing in an Rmd file
  - remember that the `Imports:` field in the `DESCRIPTION` file must include the names of all packages used in analysis documents (e.g. `paper.Rmd`). We have a helper function
    `rrtools::add_dependencies_to_description()` that will scan the Rmd file, identify libraries used in there, and add them to the `DESCRIPTION` file.
  - this function has an `data_in_git =` argument, which is `TRUE` by default. If set to `FALSE` you will exclude files in the `data/` directory from being tracked by git and prevent them from appearing on GitHub. You should set `data_in_git = FALSE` if your data files are large (\>100 mb is the limit for GitHub) or you do not want to make the data files publicly accessible on GitHub.
      - To load your custom code in the `paper.Rmd`, you have a few options. You can write all your R code in chunks in the Rmd, that’s the simplest method. Or you can write R code in script files in `/R`, and include `devtools::load_all(".")` at the top of your `paper.Rmd`. Or you can write functions in `/R` and use `library(pkgname)` at the top of your `paper.Rmd`, or omit `library` and preface each function call with `pkgname::`. Up to you to choose whatever seems most natural to you.

#### 5\. `rrtools::use_dockerfile()`

  - this creates a basic Dockerfile using [`rocker/verse`](https://github.com/rocker-org/rocker) as the base  image
  - the version of R in your rocker container will match the version used when you run this function (e.g., `rocker/verse:3.5.0`)
  - [`rocker/verse`](https://github.com/rocker-org/rocker) includes R, the [tidyverse](http://tidyverse.org/), RStudio, pandoc and LaTeX, so compendium build times are very fast on travis
  - we need to:
      - edit the Dockerfile to add linux dependencies (for R packages that require additional libraries outside of R). You can find out what these are by browsing the [DESCRIPTION](DESCRIPTION) files of the other packages you’re using, and looking in the SystemRequirements field for each package. If you are getting build errors on travis, check the logs. Often, the error messages will include the names of missing libraries.
      - modify which Rmd files are rendered when the container is made
      - have a public GitHub repo to use the Dockerfile that this function generates. It is possible to keep the repository private and run a local Docker container with minor modifications to the Dockerfile that this function generates. Or we can use `rrtools::use_circleci()` to build our Docker container privately at <https://circleci.com>, from a private GitHub repo.
  - If we want to use Travis on our project, we need to make an account at <https://hub.docker.com/> to receive our Docker container after a successful build on travis

#### 6\. `rrtools::use_travis()`

  - this creates a minimal `.travis.yml` file. By default it configures travis to build our Docker container from our Dockerfile, and build, install and run our custom package in this container. By specifying `docker = FALSE` in this function, the travis file will not use Docker in travis, but run R directly on the travis infrastructure. We recommend using Docker because it offers greater computational isolation and saves a substantial amount of time during the travis build because the base image contains many pre-compiled packages.
  - we need to:
      - go to <https://travis-ci.org/> to connect to our repo
      - add environment variables to enable push of the Docker container to the Docker Hub
      - make an account at <https://hub.docker.com/> to host our Docker container
  - Note that you should run this function only when we are ready for our GitHub repository to be public. The free travis service we’re using here requires your GitHub repository to be public. It will not work on private repositories. If you want to keep your GitHub repo private until after publication, you can use `rrtools::use_circleci()` for running free private continuous integration tests at <https://circleci.com>, instead of travis. With `rrtools::use_circleci(docker_hub = FALSE)` we can stop our Docker container from appearing on Docker Hub, so our Docker container stays completely private.

#### 7\. `usethis::use_testthat()`

  - if you add functions in `R/`, include tests to ensure they function as intended
  - create tests.R in `tests/testthat/` and check <http://r-pkgs.had.co.nz/tests.html> for template

You should be able to follow these steps to get a new research compendium repository connected to travis and ready to write in just a few minutes.

## References and related reading

Kitzes, J., Turek, D., & Deniz, F. (Eds.). (2017). *The Practice of
Reproducible Research: Case Studies and Lessons from the Data-Intensive
Sciences*. Oakland, CA: University of California Press.
<https://www.practicereproducibleresearch.org>

Marwick, B. (2017). Computational reproducibility in archaeological
research: Basic principles and a case study of their implementation.
*Journal of Archaeological Method and Theory*, 24(2), 424-450.
<https://doi.org/10.1007/s10816-015-9272-9>

Marwick, B., Boettiger, C., & Mullen, L. (2018). Packaging data 
analytical work reproducibly using R (and friends). 
*The American Statistician* 72(1), 80-88. <https://doi.org/10.1080/00031305.2017.1375986>

Piccolo, S. R. and M. B. Frampton (2016). “Tools and techniques for
computational reproducibility.” GigaScience 5(1): 30.
<https://gigascience.biomedcentral.com/articles/10.1186/s13742-016-0135-4>

rOpenSci community (2017a). Reproducibility in Science A Guide to
enhancing reproducibility in scientific results and writing. Online at
<http://ropensci.github.io/reproducibility-guide/>

rOpenSci community (2017b). rrrpkg: Use of an R package to facilitate
reproducible research. Online at <https://github.com/ropensci/rrrpkg>

Schmidt, S.C. and Marwick, B., 2020. Tool-Driven Revolutions in Archaeological Science. *Journal of Computer Applications in Archaeology*, 3(1), pp.18–32. DOI: <http://doi.org/10.5334/jcaa.29>

Stodden, V. & Miguez, S., (2014). Best Practices for Computational
Science: Software Infrastructure and Environments for Reproducible and
Extensible Research. Journal of Open Research Software. 2(1), p.e21.
DOI: <http://doi.org/10.5334/jors.ay>

Wickham, H. (2017) *Research compendia*. Note prepared for the 2017
rOpenSci Unconf.
<https://docs.google.com/document/d/1LzZKS44y4OEJa4Azg5reGToNAZL0e0HSUwxamNY7E-Y/edit#>

Wilson G, Bryan J, Cranston K, Kitzes J, Nederbragt L, et al. (2017).
Good enough practices in scientific computing. *PLOS Computational
Biology* 13(6): e1005510. <https://doi.org/10.1371/journal.pcbi.1005510>

## Contributing

If you would like to contribute to this project, please start by reading uur [Guide to Contributing](CONTRIBUTING.md). Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

## Acknowledgements

This project was developed during the 2017 Summer School on Reproducible Research in Landscape Archaeology at the Freie Universität Berlin (17-21 July), funded and jointly organized by [Exc264 Topoi](https://www.topoi.org/), [CRC1266](http://www.sfb1266.uni-kiel.de/en), and [ISAAKiel](https://isaakiel.github.io/). Special thanks to [Sophie C. Schmidt](https://github.com/SCSchmidt) for help. The convenience functions in this package are inspired by similar functions in the [`usethis`](https://github.com/r-lib/usethis) package.
