FROM rocker/binder:4.1.2
LABEL maintainer='Ben Marwick <benmarwick@gmail.com>'
USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}
USER ${NB_USER}

RUN wget https://github.com/benmarwick/rrtools/raw/master/DESCRIPTION && R --vanilla -s -e "options(repos = list(CRAN = 'http://cran.rstudio.com'));  devtools::install_deps()"

RUN rm DESCRIPTION.1; exit 0
