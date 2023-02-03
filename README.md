# rrtools: Tools for Writing Reproducible Research in R

  <!-- badges: start -->
[![R-CMD-check](https://github.com/benmarwick/rrtools/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/benmarwick/rrtools/actions/workflows/R-CMD-check.yaml)
[![Launch Rstudio Binder](http://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/benmarwick/rrtools/master?urlpath=rstudio)
  <!-- badges: end -->

## Motivation

The goal of **rrtools** is to provide instructions, templates, and functions for making a basic compendium suitable for writing a reproducible journal article or report with [R](https://www.r-project.org). This package documents the key steps and provides convenient functions for quickly creating a new research compendium. The approach is based on [Marwick (2017)](https://doi.org/10.1007/s10816-015-9272-9), [Marwick et al. (2018)](https://doi.org/10.7287/peerj.preprints.3192v1), and [Wickham’s (2017)](https://docs.google.com/document/d/1LzZKS44y4OEJa4Azg5reGToNAZL0e0HSUwxamNY7E-Y/edit#) work using the R package structure as the basis for a research compendium.

rrtools provides a template for doing scholarly writing in a literate programming environment using [Quarto](https://quarto.org/), an open-source scientific and technical publishing system. It also allows for isolation of your computational environment using [Docker](https://www.docker.com/what-docker), package versioning using [renv](https://rstudio.github.io/renv/index.html), and continuous integration using [GitHub Actions](https://github.com/features/actions). It makes a convenient starting point for writing a journal article or report. 

The functions in rrtools allow you to use R to easily follow the best practices outlined in several major scholarly publications on reproducible research. In addition to those cited above, [Wilson et al. (2017)](https://doi.org/10.1371/journal.pcbi.1005510), [Piccolo & Frampton (2016)](https://gigascience.biomedcentral.com/articles/10.1186/s13742-016-0135-4), [Stodden & Miguez (2014)](http://doi.org/10.5334/jors.ay) and [rOpenSci (2017](https://github.com/ropensci/rrrpkg)) are important sources that have influenced our approach to this package.

## Installation

To explore and test rrtools without installing anything, click the [Binder](https://mybinder.org/v2/gh/benmarwick/rrtools/master?urlpath=rstudio) badge above to start RStudio in a browser tab that includes the contents of this GitHub repository. In that environment you can browse the files, install rrtools, and make a test compendium without altering anything on your computer.

You can install rrtools from GitHub with these lines of R code (Windows users are recommended to install a separate program, [Rtools](https://cran.r-project.org/bin/windows/Rtools/), before proceeding with this step):

``` r
if (!require("devtools")) install.packages("devtools")
devtools::install_github("benmarwick/rrtools")
```

## How to use

To create a reproducible research compendium step-by-step using the rrtools approach, follow these detailed instructions. We use [RStudio](https://posit.co/products/open-source/rstudio/#Desktop), and recommend it, but is not required for these steps to work. We recommend copy-pasting these directly into your console, and editing the options before running. We don’t recommend saving these lines in a script in your project: they are meant to be once-off setup functions.

#### 0\. Create a Git-managed directory linked to an online repository

  - It is possible to use rrtools without Git, but usually we want our research compendium to be managed by the version control software [Git](https://git-scm.com/). The free online book [Happy Git With R](http://happygitwithr.com) has details on how to do this. In brief, there are two methods to get started:
      + [New project on GitHub first, then download to RStudio](https://happygitwithr.com/new-github-first.html): Start on Github, Gitlab, or a similar web service, and create an empty repository called `pkgname` (you should use a different name, please follow the rules below) on that service. Then [clone](https://happygitwithr.com/new-github-first.html) that repository to have a local empty directory on your computer, called `pkgname`, that is linked to this remote repository. Please see our [wiki](https://github.com/benmarwick/rrtools/wiki/Create-a-new,-empty-research-compendium,-starting-with-an-empty-GitHub-repository) for a step-by-step walk-though of this method, illustrated with screenshots. 
      + [New project in RStudio first, then connect to GitHub/GitLab](https://happygitwithr.com/existing-github-last.html): An alternative approach is to create a local, empty, directory called `pkgname` on your computer, and initialize it with Git (`git init`), then create a GitHub/GitLab repository and connect your local project to the remote repository.
  - Whichever of those two methods that you choose, you continue by [staging, commiting and pushing](https://happygitwithr.com/git-basics.html) every future change in the repository with Git.
  - Your `pkgname` must follow some rules for everything to work, it must: 
    + … contain only ASCII letters, numbers, and ‘.’
    + … have at least two characters
    + … start with a letter (not a number)
    + … not end with ‘.’

#### 1\. `rrtools::use_compendium("pkgname")`

  - this uses `usethis::create_package()` to create a basic R package in the `pkgname` directory, and then, if you’re using RStudio, opens the project. If you’re not using RStudio, it sets the working directory to the `pkgname` directory. 
  - we need to:
      - run `rrtools::use_compendium("path/to/pkgname")` (you use the path to `pkgname` in your system)
      - edit the `DESCRIPTION` file (located in your `pkgname` directory) to include accurate metadata, e.g. your [ORCID](https://orcid.org/)
      - periodically update the `Imports:` section of the `DESCRIPTION` file with the names of packages used in the code we write in the qmd document(s) by running `rrtools::add_dependencies_to_description()`

#### 2\. `usethis::use_mit_license(copyright_holder = "My Name")`

  - this adds a reference to the MIT license in the [DESCRIPTION](DESCRIPTION) file and generates a [LICENSE](LICENSE) file listing the name provided as the copyright holder
  - to use a different license, replace this line with any of the licenses mentioned here: `?usethis::use_mit_license()`

#### 3\. `rrtools::use_readme_rmd()`

  - this generates [README.Rmd](README.Rmd) and renders it to [README.md](README.md), ready to display on GitHub. It contains: 
      - a template citation to show others how to cite your project. Edit this to include the correct title and [DOI](https://doi.org).
      - license information for the text, figures, code and data in your compendium
  - this also adds two other markdown files: a code of conduct for users [CONDUCT.md](CONDUCT.md), and basic instructions for people who want to contribute to your project [CONTRIBUTING.md](CONTRIBUTING.md), including for first-timers to git and GitHub. 
  - this adds a `.binder/Dockerfile` that makes [Binder](https://mybinder.org/) work, if your compendium is hosted online. Currently configured for GitHub, but easily adapted for elsewhere (e.g. Zenodo, Figshare, Dataverse, etc.)
  - render this document after each change to refresh [README.md](README.md), which is the file that GitHub displays on the repository home page

#### 4\. `rrtools::use_analysis()`

  - this function has three `location =` options: `top_level` to create a top-level `analysis/` directory, `inst` to create an `inst/` directory (so that all the sub-directories are available after the package is installed), and `vignettes` to create a `vignettes/` directory (and automatically update the `DESCRIPTION`). The default is a top-level `analysis/`.
  - for each option, the contents of the sub-directories are the same, with the following (using the default `analysis/` for example):

<!-- end list -->

    analysis/
    |
    ├── paper/
    │   ├── paper.qmd       # this is the main document to edit
    │   └── references.bib  # this contains the reference list information
    
    ├── figures/            # location of the figures produced by the qmd
    |
    ├── data/
    │   ├── raw_data/       # data obtained from elsewhere
    │   └── derived_data/   # data generated during the analysis
    |
    └── templates
        ├── journal-of-archaeological-science.csl
        |                   # this sets the style of citations & reference list
        ├── template.docx   # used to style the output of the paper.qmd
        └── template.Rmd

  - the `paper.qmd` is ready to write in and render with Quarto. It includes:
      - a YAML header that identifies the `references.bib` file and the supplied `csl` file (to style the reference list)
      - a colophon that adds some git commit details to the end of the document. This means that the output file (HTML/PDF/Word) is always traceable to a specific state of the code.
  - the `references.bib` file has just one item to demonstrate the format. It is ready to insert more reference details.
  - you can replace the supplied `csl` file with a different citation style from <https://github.com/citation-style-language/>
  - we recommend using the [RStudio 2022.07](https://www.rstudio.com/products/rstudio/download/preview/) or higher to efficiently insert citations from your [Zotero](https://www.zotero.org/) library while writing in an qmd file (see [here](https://blog.rstudio.com/2020/11/09/rstudio-1-4-preview-citations/) for detailed setup and use information to connect your RStudio to your Zotero)
  - remember that the `Imports:` field in the `DESCRIPTION` file must include the names of all packages used in analysis documents (e.g. `paper.qmd`). We have a helper function
    `rrtools::add_dependencies_to_description()` that will scan the qmd file, identify libraries used in there, and add them to the `DESCRIPTION` file.
  - this function has an `data_in_git =` argument, which is `TRUE` by default. If set to `FALSE` you will exclude files in the `data/` directory from being tracked by git and prevent them from appearing on GitHub. You should set `data_in_git = FALSE` if your data files are large (\>100 mb is the limit for GitHub) or you do not want to make the data files publicly accessible on GitHub.
      - To load your custom code in the `paper.qmd`, you have a few options. You can write all your R code in chunks in the qmd, that’s the simplest method. Or you can write R code in script files in `/R`, and include `devtools::load_all(".")` at the top of your `paper.qmd`. Or you can write functions in `/R` and use `library(pkgname)` at the top of your `paper.qmd`, or omit `library` and preface each function call with `pkgname::`. Up to you to choose whatever seems most natural to you.

#### 5\. `rrtools::use_dockerfile()`

  - this creates a basic Dockerfile using [`rocker/verse`](https://github.com/rocker-org/rocker) as the base image
  - this also creates creates a minimal `.yml` configuration file to activate continuous integration using GitHub Actions. This will attempt to render your qmd document, in a Docker container specified by your Dockerfile, each time you push to GitHub. You can view the results of each attempt at the 'actions' page for your compendium on github.com, e.g. https://github.com/benmarwick/rrtools/actions 
  - the version of R in your rocker container will match the version used when you run this function (e.g., `rocker/verse:3.5.0`)
  - [`rocker/verse`](https://github.com/rocker-org/rocker) includes R, the [tidyverse](http://tidyverse.org/), RStudio, pandoc and LaTeX, so compendium build times are very fast 
  - we need to:
      - edit the Dockerfile to add linux dependencies (for R packages that require additional libraries outside of R). You can find out what these are by browsing the [DESCRIPTION](DESCRIPTION) files of the other packages you’re using, and looking in the SystemRequirements field for each package. If you are getting build errors on GitHub Actions, check the logs. Often, the error messages will include the names of missing libraries.
      - modify which qmd files are rendered when the container is made
      - have a public GitHub repo to use the Dockerfile that this function generates. It is possible to keep the repository private and run a local Docker container with minor modifications to the Dockerfile that this function generates. 
      
#### 6\. `renv::init()`

  - this initates tracking of the packages you use in your project using [renv](https://github.com/rstudio/renv). renv will discover the R packages used in your project, and install those packages into a private project library
  - We can use `renv::snapshot()` to save the state of our project library from time to time, or at the end when we are ready to share. The project state will be saved into a file called renv.lock.
  - Our collaborators can run `renv::restore()` to install exactly those packages into their own library.
  - Don't skip this step because our Binder and Dockerfile use the renv.lock file to install the packages they need to run your code. So renv is an important component of making a compendium reproducible.
 

You should be able to follow these steps to get a new research compendium repository ready to write in just a few minutes.

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
