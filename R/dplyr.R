## Preserve attributes through dplyr operations

## attributes set by bomrang which should be preserved
# nocov start
.bomrang_attribs <- c("class", "station", "type", "origin", 
                      "location", "lat", "lon", "start", 
                      "end", "count", "units", "years", 
                      "ncc_list", "vars", "indices", "groups")

#' @name filter
#' @rdname filter
#' @export
dplyr::filter

#' @name filter
#' @rdname filter
#' @keywords internal
#' @importFrom dplyr filter
#' @export
filter.bomrang_tbl <- function(.data, ...) {
  attribs <- attributes(.data)[.bomrang_attribs]
  .data <- NextMethod()
  attributes(.data) <- utils::modifyList(attributes(.data), attribs)
  .data
}

#' @name select
#' @rdname select
#' @export
dplyr::select

#' @name select
#' @rdname select
#' @keywords internal
#' @importFrom dplyr select
#' @export
select.bomrang_tbl <- function(.data, ...) {
  attribs <- attributes(.data)[.bomrang_attribs]
  .data <- NextMethod(.data)
  attributes(.data) <- utils::modifyList(attributes(.data), attribs)
  .data
}

#' @name mutate
#' @rdname mutate
#' @export
dplyr::mutate

#' @name mutate
#' @rdname mutate
#' @keywords internal
#' @importFrom dplyr mutate
#' @export
mutate.bomrang_tbl <- function(.data, ...) {
  attribs <- attributes(.data)[.bomrang_attribs]
  .data <- NextMethod(.data)
  attributes(.data) <- utils::modifyList(attributes(.data), attribs)
  .data
}

#' @name rename
#' @rdname rename
#' @export
dplyr::rename

#' @name rename
#' @rdname rename
#' @keywords internal
#' @importFrom dplyr rename
#' @export
rename.bomrang_tbl <- function(.data, ...) {
  attribs <- attributes(.data)[.bomrang_attribs]
  .data <- NextMethod(.data)
  attributes(.data) <- utils::modifyList(attributes(.data), attribs)
  .data
}

#' @name arrange
#' @rdname arrange
#' @export
dplyr::arrange

#' @name arrange
#' @rdname arrange
#' @keywords internal
#' @importFrom dplyr arrange
#' @export
arrange.bomrang_tbl <- function(.data, ...) {
  attribs <- attributes(.data)[.bomrang_attribs]
  .data <- NextMethod(.data)
  attributes(.data) <- utils::modifyList(attributes(.data), attribs)
  .data
}

#' @name group_by
#' @rdname group_by
#' @export
dplyr::group_by

#' @name group_by
#' @rdname group_by
#' @keywords internal
#' @importFrom dplyr group_by
#' @export
group_by.bomrang_tbl <- function(.data, ...) {
  attribs <- attributes(.data)[setdiff(.bomrang_attribs, "class")]
  .data <- NextMethod(.data)
  attributes(.data) <- utils::modifyList(attributes(.data), attribs)
  attr(.data, "class") <- union(c("bomrang_tbl", "data.table", "grouped_df"),
                                attr(.data, "class"))
  .data
}

#' @name slice
#' @rdname slice
#' @export
dplyr::slice

#' @name slice
#' @rdname slice
#' @keywords internal
#' @importFrom dplyr slice
#' @export
slice.bomrang_tbl <- function(.data, ...) {
  attribs <- attributes(.data)[.bomrang_attribs]
  .data <- NextMethod(.data)
  attributes(.data) <- utils::modifyList(attributes(.data), attribs)
  .data
}

# nocov end
