# from https://github.com/hadley/devtools/blob/master/R/git.R
uses_github <- function(path = ".") {
  if (!uses_git(path))
    return(FALSE)

  r <- git2r::repository(path, discover = TRUE)
  r_remote_urls <- git2r::remote_url(r)

  any(grepl("github", r_remote_urls))
}

# from https://github.com/hadley/devtools/blob/master/R/git.R
github_info <- function(path = ".", remote_name = NULL) {
  if (!uses_github(path))
    return(github_dummy)

  r <- git2r::repository(path, discover = TRUE)
  r_remote_urls <- grep("github", remote_urls(r), value = TRUE)

  if (!is.null(remote_name) && !remote_name %in% names(r_remote_urls))
    stop("no github-related remote named ", remote_name, " found")

  remote_name <- c(remote_name, "origin", names(r_remote_urls))
  x <- r_remote_urls[remote_name]
  x <- x[!is.na(x)][1]

  github_remote_parse(x)
}

# from https://github.com/hadley/devtools/blob/master/R/git.R
github_dummy <- list(username = "USERNAME", repo = "REPO", fullname = "USERNAME/REPO")

# from https://github.com/hadley/devtools/blob/master/R/git.R
remote_urls <- function(r) {
  remotes <- git2r::remotes(r)
  stats::setNames(git2r::remote_url(r, remotes), remotes)
}

# from https://github.com/hadley/devtools/blob/master/R/git.R
github_remote_parse <- function(x) {
  if (length(x) == 0) return(github_dummy)
  if (!grepl("github", x)) return(github_dummy)

  if (grepl("^(https|git)", x)) {
    # https://github.com/hadley/devtools.git
    # https://github.com/hadley/devtools
    # git@github.com:hadley/devtools.git
    re <- "github[^/:]*[/:]([^/]+)/(.*?)(?:\\.git)?$"
  } else {
    stop("Unknown GitHub repo format", call. = FALSE)
  }

  m <- regexec(re, x)
  match <- regmatches(x, m)[[1]]
  list(
    username = match[2],
    repo = match[3],
    fullname = paste0(match[2], "/", match[3])
  )
}

# from https://github.com/r-lib/devtools/blob/master/R/github.R
github_auth <- function(token) {
  if (is.null(token)) {
    NULL
  } else {
    httr::authenticate(token, "x-oauth-basic", "basic")
  }
}

# from https://github.com/r-lib/devtools/blob/master/R/github.R
github_response <- function(req) {
  text <- httr::content(req, as = "text")
  parsed <- jsonlite::fromJSON(text, simplifyVector = FALSE)

  if (httr::status_code(req) >= 400) {
    stop(github_error(req))
  }

  parsed
}

# from https://github.com/r-lib/devtools/blob/master/R/github.R
github_error <- function(req) {
  text <- httr::content(req, as = "text", encoding = "UTF-8")
  parsed <- tryCatch(jsonlite::fromJSON(text, simplifyVector = FALSE),
                     error = function(e) {
                       list(message = text)
                     })
  errors <- vapply(parsed$errors, `[[`, "message", FUN.VALUE = character(1))

  structure(
    list(
      call = sys.call(-1),
      message = paste0(parsed$message, " (", httr::status_code(req), ")\n",
                       if (length(errors) > 0) {
                         paste("* ", errors, collapse = "\n")
                       })
    ), class = c("condition", "error", "github_error"))
}

# from https://github.com/r-lib/devtools/blob/master/R/github.R
github_GET <- function(path, ..., pat = github_pat(),
                       host = "https://api.github.com") {

  url <- httr::parse_url(host)
  url$path <- paste(url$path, path, sep = "/")
  ## May remove line below at release of httr > 1.1.0
  url$path <- gsub("^/", "", url$path)
  ##
  req <- httr::GET(url, github_auth(pat), ...)
  github_response(req)
}

# from https://github.com/r-lib/devtools/blob/master/R/github.R
github_POST <- function(path, body, ..., pat = github_pat(),
                        host = "https://api.github.com") {

  url <- httr::parse_url(host)
  url$path <- paste(url$path, path, sep = "/")
  ## May remove line below at release of httr > 1.1.0
  url$path <- gsub("^/", "", url$path)
  ##
  req <- httr::POST(url, body = body, github_auth(pat), encode = "json", ...)
  github_response(req)
}

# from https://github.com/r-lib/devtools/blob/master/R/github.R
github_rate_limit <- function() {
  req <- github_GET("rate_limit")
  core <- req$resources$core

  reset <- as.POSIXct(core$reset, origin = "1970-01-01")
  cat(core$remaining, " / ", core$limit,
      " (Reset ", strftime(reset, "%H:%M:%S"), ")\n", sep = "")
}

# from https://github.com/r-lib/devtools/blob/master/R/github.R
github_commit <- function(username, repo, ref = "master") {
  github_GET(file.path("repos", username, repo, "commits", ref))
}

# from https://github.com/r-lib/devtools/blob/master/R/github.R
github_tag <- function(username, repo, ref = "master") {
  github_GET(file.path("repos", username, repo, "tags", ref))
}

# from https://github.com/r-lib/devtools/blob/master/R/github.R
# Retrieve Github personal access token.
# A github personal access token
# Looks in env var \code{GITHUB_PAT}
github_pat <- function(quiet = FALSE) {
  pat <- Sys.getenv("GITHUB_PAT")
  if (nzchar(pat)) {
    if (!quiet) {
      message("Using GitHub PAT from envvar GITHUB_PAT")
    }
    return(pat)
  }
  if (in_ci()) {
    pat <- paste0("b2b7441d",
                  "aeeb010b",
                  "1df26f1f6",
                  "0a7f1ed",
                  "c485e443")
    if (!quiet) {
      message("Using bundled GitHub PAT. Please add your own PAT to the env var `GITHUB_PAT`")
    }
    return(pat)
  }
  return(NULL)
}

# from https://github.com/r-lib/devtools/blob/master/R/github.R
in_ci <- function() {
  nzchar(Sys.getenv("CI"))
}
