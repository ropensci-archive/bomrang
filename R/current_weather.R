#' Current weather observations of a station
#'
#' @param station_name The name of the weather station. Fuzzy string matching via
#' \code{base::agrep} is done.
#' @param raw Do not convert the columns \code{data.table} to the appropriate classes. (\code{FALSE} by default.)
#' @details Note that the column \code{local_date_time_full} is set to a \code{POSIXct} object
#' in the local time of the \strong{user}.
#' @examples
#' \dontrun{
#'   # warning
#'   Melbourne_forecast <- current_weather("Melbourne")
#'
#'   # no warning
#'   Melbourne_forecast <- current_weather("Melbourne (Olympic Park)")
#' }
#' @import data.table
#' @importFrom lubridate ymd_hms
#' @importFrom magrittr use_series
#' @export current_weather

current_weather <- function(station_name, raw = FALSE) {
  stopifnot(is.character(station_name),
            length(station_name) == 1)

  likely_stations <- agrep(pattern = station_name,
                           x = station_name_by_url[["station_name"]],
                           value = TRUE)

  if (length(likely_stations) == 0) {
    stop("No station found.")
  }

  the_station_name <- likely_stations[1]
  if (length(likely_stations) > 1) {
    warning("Multiple stations match station_name. Using\n\tstation_name = '", the_station_name,
            "'\ndid you mean:\n\tstation_name = '", likely_stations[-1], "'?")
  }



  json_url <- station_name_by_url[station_name == the_station_name][["url"]]

  observations.json <-
    rjson::fromJSON(file = json_url)

  if ("observations" %notin% names(observations.json) ||
      "data" %notin% names(observations.json$observations)) {
    stop("A station was matched by the JSON returned by bom.gov.au was not in expected form")
  }


  # Columns which are meant to be numeric
  double_cols <-
    c("lat", "lon", "apparent_t", "cloud_base_m", "cloud_oktas", "rain_trace")
  # (i.e. not raw)
  cook <- function(DT) {
    DTnoms <- names(DT)

    # CRAN NOTE avoidance
    local_date_time_full <- NULL
    if ("local_date_time_full" %chin% DTnoms) {
      DT[, local_date_time_full := ymd_hms(local_date_time_full, tz = "")]
    }

    aifstime_utc <- NULL
    if ("aifstime_utc" %chin% DTnoms) {
      DT[, aifstime_utc := ymd_hms(aifstime_utc)]
    }

    for (j in which(DTnoms %chin% double_cols)) {
      set(DT, j = j, value = force_double(DT[[j]]))
    }
    DT[]
  }

  out <-
    observations.json %>%
    use_series("observations") %>%
    use_series("data") %>%
    lapply(as.data.table) %>%
    rbindlist(use.names = TRUE, fill = TRUE)

  if (raw) {
    return(out)
  } else {
    return(cook(out))
  }
}
