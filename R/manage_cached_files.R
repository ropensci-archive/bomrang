


#' @title Manage locally cached bomrang files
#'
#' @description The user is given an option when downloading the bomrang
#' data to cache or not to cache the data for later use.  If
#' \code{cache == TRUE}, then the bomrang data files are saved in a
#' directory in the users' home file space.  These functions provide facilities
#' for interacting and managing these files.
#'
#' @export
#' @name manage_bomrang_cache
#' @param files Character.  One or more complete file names with no file path
#' @param force Logical.  Should files be force deleted? Defaults to :
#' \code{TRUE}
#'
#' @details \code{bomrang_cache_delete} only accepts one file name, while
#' \code{bomrang_cache_delete_all} does not accept any names, but deletes all
#' files.  For deleting many specific files, use \code{cache_delete} in a
#' \code{\link{lapply}} type call.
#'
#' We files cache using \code{\link[rappdirs]{user_cache_dir}}, find your
#' cache folder by executing \code{rappdirs::user_cache_dir("bomrang")}
#'
#' @section Functions:
#' \itemize{
#'  \item \code{bomrang_cache_list()} returns a character vector of full path
#'  file names
#'  \item \code{bomrang_cache_delete()} deletes one or more files, returns
#'  nothing
#'  \item \code{bomrang_cache_delete_all()} delete all files, returns nothing
#'  \item \code{bomrang_cache_details()} prints file name and file size for each
#'  file, supply with one or more files, or no files (and get details for
#'  all available)
#' }
#'
#' @examples \dontrun{
#' # List files in cache
#' bomrang_cache_list()
#'
#' # List info for single files
#' bomrang_cache_details(files = bomrang_cache_list()[1])
#' bomrang_cache_details(files = bomrang_cache_list()[2])
#'
#' # List info for all files
#' bomrang_cache_details()
#'
#' # Delete files by name in cache
#' bomrang_cache_delete(files = bomrang_cache_list()[1])
#'
#' # Delete all files in cache
#' bomrang_cache_delete_all()
#' }
#'
#' @author Original: Scott Chamberlain, \email{scott@ropensci.org}, adapted for
#' use in this package by Adam H Sparks, \email{adamhsparks@gmail.com}
#'
#' @note
#' These functions were adapted from rOpenSci's \code{\link[ccafs]{cc_cache}}.
#'
#' @export
#' @rdname manage_bomrang_cache
bomrang_cache_list <- function() {
  cache_dir <- rappdirs::user_cache_dir("bomrang")
  list.files(
    cache_dir,
    ignore.case = TRUE,
    include.dirs = TRUE,
    recursive = TRUE,
    full.names = TRUE
  )
}

#' @export
#' @rdname manage_bomrang_cache
bomrang_cache_delete <- function(files, force = TRUE) {
  files <- file.path(rappdirs::user_cache_dir("bomrang"), files)
  if (!all(file.exists(files))) {
    stop(
      "These files don't exist or can't be found: \n",
      strwrap(file.path(files)[!file.exists(files)], indent = 5),
      call. = FALSE
    )
  }
  unlink(files, force = force, recursive = TRUE)
}

#' @export
#' @rdname manage_bomrang_cache
bomrang_cache_delete_all <- function(force = TRUE) {
  cache_dir <- rappdirs::user_cache_dir("bomrang")
  files <-
    list.files(
      cache_dir,
      ignore.case = TRUE,
      include.dirs = TRUE,
      full.names = TRUE,
      recursive = TRUE
    )
  unlink(files, force = force, recursive = TRUE)
}

#' @export
#' @rdname manage_bomrang_cache
bomrang_cache_details <- function(files = NULL) {
  cache_dir <- rappdirs::user_cache_dir("bomrang")
  if (is.null(files)) {
    files <-
      list.files(
        cache_dir,
        ignore.case = TRUE,
        include.dirs = TRUE,
        full.names = TRUE,
        recursive = TRUE
      )
    structure(lapply(files, file_info_), class = "bomrang_cache_info")
  } else {
    structure(lapply(files, file_info_), class = "bomrang_cache_info")
  }
}

file_info_ <- function(x) {
  if (file.exists(x)) {
    fs <- file.size(x)
  } else {
    fs <- type <- NA
    x <- paste0(x, " - does not exist")
  }
  list(file = x,
       type = "gz",
       size = if (!is.na(fs))
         getsize(fs)
       else
         NA)
}

getsize <- function(x) {
  round(x / 10 ^ 6, 3)
}

#' @export
print.bomrang_cache_info <- function(x, ...) {
  cache_dir <- rappdirs::user_cache_dir("bomrang")
  cat("<bomrang cached files>", sep = "\n")
  cat(sprintf("  directory: %s\n", cache_dir), sep = "\n")
  for (i in seq_along(x)) {
    cat(paste0("  file: ", sub(cache_dir, "", x[[i]]$file)), sep = "\n")
    cat(paste0("  size: ", x[[i]]$size, if (is.na(x[[i]]$size))
      ""
      else
        " mb"),
      sep = "\n")
    cat("\n")
  }
}
