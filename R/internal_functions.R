#' @noRd
.validate_state <-
  function(state) {
    if (!is.null(state)) {
      state <- toupper(trimws(state))
    } else
      stop("\nPlease provide a valid 2 or 3 letter state or territory postal code abbreviation")
  }

`%notin%` <- Negate("%in%")

force_double <- function(v) {
  suppressWarnings(as.double(v))
}
