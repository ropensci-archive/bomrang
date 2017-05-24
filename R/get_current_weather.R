#' Current weather observations of a station
#'
#' @param station_name The name of the weather station. Fuzzy string matching
#' via \code{base::agrep} is done.
#' @param latlon A length-2 numeric vector. When given instead of
#' \code{station_name}, the nearest station
#' (in this package) is used, with a message indicating the nearest such
#' station. (See also \code{\link{sweep_for_stations}}.) Ignored if used in
#' combination with \code{station_name}, with a warning.
#' @param raw Do not convert the columns \code{data.table} to the appropriate
#' classes. (\code{FALSE} by default.)
#' @param emit_latlon_msg Logical. If \code{TRUE} (the default), and
#' \code{latlon} is selected
#' @details Note that the column \code{local_date_time_full} is set to a
#' \code{POSIXct} object in the local time of the \strong{user}.
#' @examples
#' \dontrun{
#'   # warning
#'   Melbourne_forecast <- get_current_weather("Melbourne")
#'
#'   # no warning
#'   Melbourne_forecast <- get_current_weather("Melbourne (Olympic Park)")
#'
#'   # Get weather by latitude and longitude:
#'   get_current_weather(latlon = c(-34, 151))
#' }
#' @import data.table
#' @importFrom lubridate ymd_hms
#' @importFrom magrittr use_series
#' @export get_current_weather

get_current_weather <-
  function(station_name,
           latlon = NULL,
           raw = FALSE,
           emit_latlon_msg = TRUE) {
    if (missing(station_name) && is.null(latlon)) {
      stop("One of 'station_name' or 'latlon' must be provided.")
    }

    if (!missing(station_name)) {
      if (!is.null(latlon)) {
        latlon <- NULL
        warning("Both station_name and latlon provided. Ignoring latlon.")
      }
      stopifnot(is.character(station_name),
                length(station_name) == 1)

      # CRAN NOTE avoidance
      name <- NULL

      # If there's an exact match, use it; else, attempt partial match.
      if (station_name %in% JSONurl_latlon_by_station_name[["name"]]) {
        the_station_name <- station_name
      } else {
        likely_stations <- agrep(pattern = station_name,
                                 x = JSONurl_latlon_by_station_name[["name"]],
                                 value = TRUE)

        if (length(likely_stations) == 0) {
          stop("No station found.")
        }

        the_station_name <- likely_stations[1]
        if (length(likely_stations) > 1) {
          warning(
            "Multiple stations match station_name. Using\n\tstation_name = '",
            the_station_name,
            "'\ndid you mean:\n\tstation_name = '",
            likely_stations[-1],
            "'?"
          )
        }
      }

      json_url <-
        JSONurl_latlon_by_station_name[name == the_station_name][["url"]]

    } else {
      # We have established latlon is not NULL
      if (length(latlon) != 2 || !is.numeric(latlon)) {
        stop("latlon must be a length-2 numeric vector.")
      }

      lat <- latlon[1]
      lon <- latlon[2]

      if (lat > 0 || lon < 90) {
        warning("lat > 0 or lon < 90, which are unlikely value for Australian stations.")
      }

      # CRAN NOTE avoidance: names of JSONurl_latlon_by_station_name
      Lat <- Lon <- NULL

      station_nrst_latlon <-
        JSONurl_latlon_by_station_name %>%
        # Lat Lon are in JSON
        .[which.min(haversine_distance(lat, lon, Lat, Lon))]

      on.exit(
        message(
          "Using station_name = '",
          station_nrst_latlon$name,
          "', at latitude = ",
          station_nrst_latlon$Lat,
          ", ",
          "longitude = ",
          station_nrst_latlon$Lon
        )
      )

      json_url <- station_nrst_latlon[["url"]]
    }

    observations.json <-
      rjson::fromJSON(file = json_url)

    if ("observations" %notin% names(observations.json) ||
        "data" %notin% names(observations.json$observations)) {
      stop("A station was matched but the JSON returned by bom.gov.au was not in expected form.")
    }


    # Columns which are meant to be numeric
    double_cols <-
      c("lat",
        "lon",
        "apparent_t",
        "cloud_base_m",
        "cloud_oktas",
        "rain_trace")
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

