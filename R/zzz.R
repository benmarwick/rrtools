
.onAttach <- function(...){

# check to see if git is installed using 'which git'
which_git <-
  switch(Sys.info()[['sysname']],
         Windows= {system("where git", intern = TRUE)},
         Linux  = {system("which git", intern = TRUE)},
         Darwin = {system("which git", intern = TRUE)})

if(!grepl("git", which_git[1])) { packageStartupMessage(red_cross(), " Git is not installed on this computer. Go to ", crayon::bgBlue("https://git-scm.com/downloads"), " to download Git for your computer. For more information on installing and using Git, see ", crayon::bgBlue("http://happygitwithr.com/"))

} else {

  # check to see if git is configured with the user's name and email
  git_config <- git2r::config()
  git_user_name <- git_config$global$user.name
  git_user_email <- git_config$global$user.email

  if(!is.null(git_user_name)){
  packageStartupMessage(green_tick(), " Git is installed on this computer, your username is ",
                 usethis::ui_field(git_user_name))
  } else {
    packageStartupMessage(red_cross(), " Git is installed on this computer, but not configured for use. For more information on configuring and using Git, see ", crayon::bgBlue("http://happygitwithr.com/"))
  }
}
}


