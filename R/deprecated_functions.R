
#' Deprecated function(s) in the bomrang package
#'
#' These functions are now deprecated in \pkg{bomrang}.
#'
#' @docType package
#' @section Details:
#' \tabular{rl}{
#'   \code{bomrang_cache_list} \tab now superceded by \code{manage_cache$list}\cr
#'   \code{bomrang_cache_details} \tab now superceded by \code{manage_cache$details}\cr
#'   \code{bomrang_cache_delete} \tab now superceded by \code{manage_cache$delete}\cr
#'   \code{bomrang_cache_delete_all} \tab now superceded by \code{manage_cache$delete_all}\cr
#' }
#'
#' @rdname bomrang-deprecated
#' @name bomrang-deprecated
#' @export
bomrang_cache_list <- function() {
  .Deprecated("manage_cache$list", package = "bomrang")
}

#' @rdname bomrang-deprecated
#' @name bomrang-deprecated
#' @export
bomrang_cache_details <- function() {
  .Deprecated("manage_cache$details", package = "bomrang")
}

#' @rdname bomrang-deprecated
#' @name bomrang-deprecated
#' @export
bomrang_cache_delete <- function() {
  .Deprecated("manage_cache$delete", package = "bomrang")
}

#' @rdname bomrang-deprecated
#' @name bomrang-deprecated
#' @export
bomrang_cache_delete_all <- function() {
  .Deprecated("manage_cache$delete_all", package = "bomrang")
}

NULL
