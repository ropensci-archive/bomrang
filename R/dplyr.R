## Preserve attributes through dplyr operations

#' @export
dplyr::filter

#' @importFrom dplyr filter
#' @export
filter.bomrang_tbl <- function(.data, ...) {
  attribs <- attributes(.data)[.bomrang_attribs]
  .data <- NextMethod()
  attributes(.data) <- utils::modifyList(attributes(.data), attribs)
  .data
}

#' @export
dplyr::select

#' @importFrom dplyr select
#' @export
select.bomrang_tbl <- function(.data, ...) {
  attribs <- attributes(.data)[.bomrang_attribs]
  .data <- NextMethod(.data)
  attributes(.data) <- utils::modifyList(attributes(.data), attribs)
  .data
}

#' @export
dplyr::mutate

#' @inheritParams dplyr mutate
#' @export
mutate.bomrang_tbl <- function(.data, ...) {
  attribs <- attributes(.data)[.bomrang_attribs]
  .data <- NextMethod(.data)
  attributes(.data) <- utils::modifyList(attributes(.data), attribs)
  .data
}

#' @export
dplyr::rename

#' @inheritParams dplyr rename
#' @export
rename.bomrang_tbl <- function(.data, ...) {
  attribs <- attributes(.data)[.bomrang_attribs]
  .data <- NextMethod(.data)
  attributes(.data) <- utils::modifyList(attributes(.data), attribs)
  .data
}

#' @export
dplyr::arrange

#' @inheritParams dplyr arrange
#' @export
arrange.bomrang_tbl <- function(.data, ...) {
  attribs <- attributes(.data)[.bomrang_attribs]
  .data <- NextMethod(.data)
  attributes(.data) <- utils::modifyList(attributes(.data), attribs)
  .data
}

#' @export
dplyr::group_by

#' @inheritParams dplyr group_by
#' @export
group_by.bomrang_tbl <- function(.data, ...) {
  attribs <- attributes(.data)[.bomrang_attribs]
  .data <- NextMethod(.data)
  attributes(.data) <- utils::modifyList(attributes(.data), attribs)
  .data
}

#' @export
dplyr::slice

#' @inheritParams dplyr slice
#' @export
slice.bomrang_tbl <- function(.data, ...) {
  attribs <- attributes(.data)[.bomrang_attribs]
  .data <- NextMethod(.data)
  attributes(.data) <- utils::modifyList(attributes(.data), attribs)
  .data
}
