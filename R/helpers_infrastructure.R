warning_bullet <- function() crayon::yellow(clisymbols::symbol$warning)
red_cross <- function() crayon::red(clisymbols::symbol$cross)
green_tick  <- function() crayon::green(clisymbols::symbol$tick)

# from http://r.789695.n4.nabble.com/Suppressing-output-e-g-from-cat-tp859876p859882.html
# capture the cat & message output
quietly <- function(x) {
  sink(tempfile())
  on.exit(sink())
  invisible(force(suppressMessages(x)))
}

# from https://github.com/poissonconsulting/yesno/blob/master/R/yesno.R
yesno <- function(...) {
  yeses <- c("Yes", "Definitely", "For sure", "Yup", "Yeah", "I agree", "Absolutely")
  nos <- c("No way", "Not yet", "I forget", "No", "Nope", "Uhhhh... Maybe?")

  cat(paste0(..., collapse = ""))
  qs <- c(sample(yeses, 1), sample(nos, 2))
  rand <- sample(length(qs))

  menu(qs[rand]) != which(rand == 1)
}

# from https://github.com/r-lib/devtools/blob/master/R/infrastructure.R
open_in_rstudio <- function(path) {
  if (!rstudioapi::isAvailable())
    return()

  if (!rstudioapi::hasFun("navigateToFile"))
    return()

  rstudioapi::navigateToFile(path)

}

# from https://github.com/r-lib/devtools/blob/master/R/utils.R
dots <- function(...) {
  eval(substitute(alist(...)))
}
