context("use_dockerfile()")



# Makeshift test of `use_dockerfile(package_manager = TRUE)`
# `rrtools::create_compendium("newpackage")`
#
# In `newpackage`,
#
# ```
# rrtools::use_dockerfile()
# install.packages("tatoo") # `tatoo` imports `data.table` which is not in `rocker/verse:3.5.3`
# ```
#
# Then add to `demo-inline-code` chunk of `paper.Rmd`,
#
# ```
# library(tatoo)
# library(data.table)
#
# # test direct install ("tatoo")
# tag_table(head(cars), tt_meta(table_id = "t1", title = "Data about cars"))
#
# # test import ("data.table" from "tatoo")
# DT = data.table(a = LETTERS[c(3L,1:3)], b = 4:7)
# ```
#
# After a minute, `packrat` performs an automatic snapshot. Then open a terminal, `cd newpackage` and
#
# `docker build --rm -t knitmynewpackagepaper .`
#
# Success: `Output created: paper.html`
