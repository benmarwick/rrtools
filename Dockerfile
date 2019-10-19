# get the base image, the rocker/verse has R, RStudio and pandoc
FROM rocker/verse:3.6.0

# required
MAINTAINER Ben Marwick <benmarwick@gmail.com>

COPY . /rrtools

# go into the repo directory
RUN . /etc/environment \

  # Install linux depedendencies here
  # e.g. need this for ggforce::geom_sina
  && sudo apt-get update \
  && sudo apt-get install libudunits2-dev -y \

  # build this compendium package
  && sudo R -e "devtools::install('/rrtools', dep=TRUE)" \
  
  # make project directory writable to save images and other output
  && sudo chmod a+rwx -R rrtools \

 # render the manuscript into a html output
  && sudo R -e "setwd('/rrtools/analysis/paper'); rmarkdown::render('paper.Rmd')"
