# Initialise a git repository without asking questions
#
# From usethis, modified to be non-interactive.
# `use_git_quietly()` initialises a Git repository and adds important files to
# `.gitignore`. If user consents, it also makes an initial commit.
#
# @param message Message to use for first commit.
use_git_quietly <- function(message = "Initial commit") {
  if (uses_git()) {
    return(invisible())
  }

  usethis::ui_done("Initialising Git repo")
  r <- git2r::init(usethis::proj_get())

  usethis::use_git_ignore(c(".Rhistory", ".RData", ".Rproj.user"))

  # if there is something uncommitted, then commit it
  if ( git_uncommitted()) {
    paths <- unlist(git2r::status(r))
    usethis::ui_done("Adding files and committing")
      git2r::add(r, paths)
      git2r::commit(r, message)

  }

	usethis::ui_todo(
    "A restart of RStudio is required to activate the Git pane"
  )
  invisible(TRUE)
}

# from https://github.com/hadley/devtools/blob/master/R/git.R
uses_git <- function(path = ".") {
  !is.null(git2r::discover_repository(path, ceiling = 0))
}

# from https://github.com/hadley/devtools/blob/master/R/git.R
# sha of most recent commit
git_repo_sha1 <- function(r) {
  rev <- git2r::head(r)
  if (is.null(rev)) {
    return(NULL)
  }

  if (git2r::is_commit(rev)) {
    rev@sha
  } else {
    git2r::branch_target(rev)
  }
}

# from https://github.com/hadley/devtools/blob/master/R/git.R
git_sha1 <- function(n = 10, path = ".") {
  r <- git2r::repository(path, discover = TRUE)
  sha <- git_repo_sha1(r)
  substr(sha, 1, n)
}

# from https://github.com/hadley/devtools/blob/master/R/git.R
git_uncommitted <- function(path = ".") {
  r <- git2r::repository(path, discover = TRUE)
  st <- vapply(git2r::status(r), length, integer(1))
  any(st != 0)
}

# from https://github.com/hadley/devtools/blob/master/R/git.R
git_sync_status <- function(path = ".", check_ahead = TRUE, check_behind = TRUE) {
  r <- git2r::repository(path, discover = TRUE)

  r_head <- git2r::head(r)
  if (!methods::is(r_head, "git_branch")) {
    stop("HEAD is not a branch", call. = FALSE)
  }

  upstream <- git2r::branch_get_upstream(r_head)
  if (is.null(upstream)) {
    stop("No upstream branch", call. = FALSE)
  }

  git2r::fetch(r, git2r::branch_remote_name(upstream))

  c1 <- git2r::lookup(r, git2r::branch_target(r_head))
  c2 <- git2r::lookup(r, git2r::branch_target(upstream))
  ab <- git2r::ahead_behind(c1, c2)

  is_ahead <- ab[[1]] != 0
  is_behind <- ab[[2]] != 0
  check <- (check_ahead && is_ahead) || (check_behind && is_behind)
  check
}

# from https://github.com/hadley/devtools/blob/master/R/git.R
# Retrieve the current running path of the git binary.
# @param git_binary_name The name of the binary depending on the OS.
git_path <- function(git_binary_name = NULL) {
  # Use user supplied path
  if (!is.null(git_binary_name)) {
    if (!file.exists(git_binary_name)) {
      stop("Path ", git_binary_name, " does not exist", .call = FALSE)
    }
    return(git_binary_name)
  }

  # Look on path
  git_path <- Sys.which("git")[[1]]
  if (git_path != "") return(git_path)

  # On Windows, look in common locations
  if (.Platform$OS.type == "windows") {
    look_in <- c(
      "C:/Program Files/Git/bin/git.exe",
      "C:/Program Files (x86)/Git/bin/git.exe"
    )
    found <- file.exists(look_in)
    if (any(found)) return(look_in[found][1])
  }

  stop("Git does not seem to be installed on your system.", call. = FALSE)
}

# from https://github.com/hadley/devtools/blob/master/R/git.R
git_branch <- function(path = ".") {
  r <- git2r::repository(path, discover = TRUE)

  if (git2r::is_detached(r)) {
    return(NULL)
  }

  git2r::head(r)@name
}

# from https://github.com/hadley/devtools/blob/master/R/git.R
# Extract the commit hash from a git archive. Git archives include the SHA1
# hash as the comment field of the zip central directory record
# (see https://www.kernel.org/pub/software/scm/git/docs/git-archive.html)
# Since we know it's 40 characters long we seek that many bytes minus 2
# (to confirm the comment is exactly 40 bytes long)
git_extract_sha1 <- function(bundle) {

  # open the bundle for reading
  conn <- file(bundle, open = "rb", raw = TRUE)
  on.exit(close(conn))

  # seek to where the comment length field should be recorded
  seek(conn, where = -0x2a, origin = "end")

  # verify the comment is length 0x28
  len <- readBin(conn, "raw", n = 2)
  if (len[1] == 0x28 && len[2] == 0x00) {
    # read and return the SHA1
    rawToChar(readBin(conn, "raw", n = 0x28))
  } else {
    NULL
  }
}

# from https://github.com/r-lib/devtools/blob/master/R/infrastructure-git.R
# Add a git hook.
# @param hook Hook name. One of "pre-commit", "prepare-commit-msg",
#   "commit-msg", "post-commit", "applypatch-msg", "pre-applypatch",
#   "post-applypatch", "pre-rebase", "post-rewrite", "post-checkout",
#   "post-merge", "pre-push", "pre-auto-gc".
# @param script Text of script to run
use_git_hook <- function(hook, script, pkg = ".") {
  pkg <- as.package(pkg)

  git_dir <- file.path(pkg$path, ".git")
  if (!file.exists(git_dir)) {
    stop("This project doesn't use git", call. = FALSE)
  }

  hook_dir <- file.path(git_dir, "hooks")
  if (!file.exists(hook_dir)) {
    dir.create(hook_dir)
  }

  hook_path <- file.path(hook_dir, hook)
  writeLines(script, hook_path)
  Sys.chmod(hook_path, "0744")
}

# from https://github.com/r-lib/devtools/blob/master/R/infrastructure-git.R
use_git_ignore <- function(ignores, directory = ".", pkg = ".", quiet = FALSE) {
  pkg <- as.package(pkg)

  paths <- paste0("`", ignores, "`", collapse = ", ")
  if (!quiet) {
    usethis::ui_done("Adding ", paths, " to ", file.path(directory, ".gitignore"))
  }

  path <- file.path(pkg$path, directory, ".gitignore")
  union_write(path, ignores)

  invisible(TRUE)
}
