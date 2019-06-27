FROM rocker/binder:latest
LABEL maintainer="bmarwick"
USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}
## Become normal user again
USER ${NB_USER}
RUN wget https://github.com/benmarwick/rrtools/raw/master/DESCRIPTION && R -e "devtools::install_deps()"
