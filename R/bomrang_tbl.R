#' @export
#' @noRd
print.bomrang_tbl <- function(x, ...) {
  .bomrang_header(x)
  print(data.table::as.data.table(x), ...)
}

.bomrang_header <- function(x) {
  location <- attr(x, "location") %||% "UNKNOWN"
  station  <- attr(x, "station") %||% "UNKNOWN"
  lat      <- attr(x, "lat") %||% "UNKNOWN"
  lon      <- attr(x, "lon") %||% "UNKNOWN"
  type     <- tools::toTitleCase(attr(x, "type")) %||% "UNKNOWN"
  origin   <- tools::toTitleCase(attr(x, "origin")) %||% "UNKNOWN"
  start    <- attr(x, "start") %||% "UNKNOWN"
  end      <- attr(x, "end") %||% "UNKNOWN"
  count    <- attr(x, "count") %||% "UNKNOWN"
  units    <- attr(x, "units") %||% NULL
  vars     <- attr(x, "vars") %||% "UNKNOWN"
  indices  <- attr(x, "indices") %||% "UNKNOWN"
  
  .stylecat("  --- Australian Bureau of Meteorology (BOM) Data Resource ---\n")
  .stylecat("  (Original Request Parameters)\n")
  .stylecat("  Station:\t\t", location, " [", station, "] \n")
  .stylecat("  Location:\t\t", "lat: ", lat, ", lon: ", lon, "\n")
  .stylecat("  Measurement / Origin:\t", type, " / ", origin, "\n")
  .stylecat("  Timespan:\t\t",
            start,
            " -- ",
            end,
            " [",
            count,
            " ",
            units,
            "]",
            "\n")
  # dplyr groupings
  if (!is.null(attr(x, "vars"))) {
    .stylecat("  Groups:\t\t", vars, paste0(" [", length(indices), "]\n"))
  }
  if (!is.null(attr(x, "groups"))) {
    vars <- setdiff(names(attr(x, "groups")), ".rows")
    indices <- nrow(attr(x, "groups"))
    .stylecat("  Groups:\t\t", vars, paste0(" [", indices, "]\n"))
  }
  .stylecat("  ", strrep("-", 63), "  \n")
  
}

.stylecat <- function(...) {
  cat(crayon::cyan(crayon::italic(paste0(...))))
}
