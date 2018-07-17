
.onAttach <- function(...){
  git_config <- git2r::config()
  git_user_name <- git_config$global$user.name
  git_user_email <- git_config$global$user.email

  if(!is.null(git_user_name)){
  packageStartupMessage(green_tick(), " Git is installed on this computer, your username is ",
                 usethis:::field(git_user_name))
  } else {
    packageStartupMessage(red_cross(), " Git is not installed on this computer. Go to ", crayon::bgBlue("https://git-scm.com/downloads"), " to download Git for your computer. For more information on installing and using Git, see ", crayon::bgBlue("http://happygitwithr.com/"))
  }
}


