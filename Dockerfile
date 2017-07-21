# get the base image, this one has R, RStudio and pandoc
# also we get pkgs from MRAN, not CRAN
FROM rocker/verse:3.3.2 # https://github.com/rocker-org/rocker-versioned

# required
MAINTAINER Ben Marwick <benmarwick@gmail.com>

COPY . /timetest
 # go into the repo directory
RUN . /etc/environment \

# install linux dependencies for spatial pkgs
  && apt-get update -y \
  && apt-get install -y libudunits2-dev  \

# build this compendium package, get deps from MRAN
# set date here manually
  && R -e "devtools::install('/timetest', dep=TRUE)" \

 # render the manuscript into a docx
  && R -e "rmarkdown::render('/timetest/analysis/paper.Rmd')"
