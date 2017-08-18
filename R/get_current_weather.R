
#' Current Weather Observations of a BoM Station
#'
#' @param station_name The name of the weather station. Fuzzy string matching
#' via \code{base::agrep} is done.
#' @param strict (logical) If \code{TRUE}, \code{station_name} must match the station name exactly,
#' except that \code{station_name} need not be uppercase. Note this may be different to
#' \code{full_name} in the response. See \strong{Details}.
#' @param latlon A length-2 numeric vector giving the decimal
#' latitude and longitude (in that order), \emph{e.g.} \code{latlon = c(-34, 151)} for Sydney.
#' When given instead of \code{station_name}, the nearest station (in this package) is used, with a
#' message indicating the nearest such station. (See also
#'  \code{\link{sweep_for_stations}}.) Ignored if used in combination with
#' \code{station_name}, with a warning.
#' @param raw Logical. Do not convert the columns \code{data.table} to the
#' appropriate classes. (\code{FALSE} by default.)
#' @param emit_latlon_msg Logical. If \code{TRUE} (the default), and
#' \code{latlon} is selected, a message is emitted before the table is returned
#' indicating which station was actually used (i.e. which station was found to
#' be nearest to the given coordinate).
#' @param as.data.table Return result as a \code{data.table}.
#' @details
#' Station names are not consistently named within the Bureau, so
#' the response may contain a different \code{full_name} to the one
#' matched, even if \code{strict = TRUE}. For example,
#' \code{get_current_weather("CASTLEMAINE PRISON")[["full_name"]][1]}
#' is \code{Castlemaine}, not \code{Castlemaine Prison}.
#'
#' Note that the column \code{local_date_time_full} is set to a
#' \code{POSIXct} object in the local time of the \strong{user}.
#' For more details see the vignette "Current Weather Fields":
#' \code{vignette("Current Weather Fields", package = "bomrang")}
#' for a complete list of fields and units.
#' @return
# Tidy data frame of requested BoM station's current and prior 72hr data.  For
#' full details of fields and units returned, see Appendix 1 in the
#' \emph{bomrang} vignette, use \code{vignette("bomrang", package = "bomrang")}
#' to view.
#' @examples
#' \dontrun{
#'   # warning
#'   Melbourne_weather <- get_current_weather("Melbourne")
#'
#'   # no warning
#'   Melbourne_weather <- get_current_weather("Melbourne (Olympic Park)")
#'
#'   # Get weather by latitude and longitude:
#'   get_current_weather(latlon = c(-34, 151))
#' }
#' @references
#' Weather data observations are retrieved from:
#' Australian Bureau of Meteorology (BoM) Weather Data Services,
#' Observations - individual stations:
#' \url{http://www.bom.gov.au/catalogue/data-feeds.shtml}
#'
#' Station location and other metadata are sourced from the Australian Bureau of
#' Meteorology (BoM) webpage, Bureau of Meteorology Site Numbers:
#' \url{http://www.bom.gov.au/climate/cdo/about/site-num.shtml}
#'
#' @author Hugh Parsonage, \email{hugh.parsonage@gmail.com}
#' @importFrom magrittr use_series
#' @importFrom magrittr %$%
#' @importFrom data.table :=
#' @importFrom data.table %chin%
#' @importFrom data.table setnames
#' @export get_current_weather

get_current_weather <-
  function(station_name,
           strict = FALSE,
           latlon = NULL,
           raw = FALSE,
           emit_latlon_msg = TRUE,
           as.data.table = FALSE) {

    # CRAN NOTE avoidance
    JSONurl_latlon_by_station_name <- NULL

    # Load JSON URL list
    load(system.file("extdata", "JSONurl_latlon_by_station_name.rda",
                     package = "bomrang"))

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

      station_name <- toupper(station_name)

      # If there's an exact match, use it; else, attempt partial match.
      if (station_name %in% JSONurl_latlon_by_station_name[["name"]]) {
        the_station_name <- station_name
      } else {
        likely_stations <-
          # Present those with common prefixes first
          c(grep(pattern = paste0("^", station_name),
                 x = JSONurl_latlon_by_station_name[["name"]],
                 ignore.case = TRUE,
                 value = TRUE),
            agrep(pattern = station_name,
                  x = JSONurl_latlon_by_station_name[["name"]],
                  value = TRUE)) %>%
          unique

        if (length(likely_stations) == 0) {
          stop("No station found.")
        }

        the_station_name <- likely_stations[1]
        if (length(likely_stations) > 1) {
          # Likely common use case
          # (otherwise defaults to KURNELL RADAR which does not provide observations)
          if (toupper(station_name) == "SYDNEY" && 'SYDNEY (OBSERVATORY HILL)' %in% likely_stations) {
            likely_stations <- c('SYDNEY (OBSERVATORY HILL)',
                                 setdiff(likely_stations,
                                         'SYDNEY (OBSERVATORY HILL)'))
            the_station_name <- 'SYDNEY (OBSERVATORY HILL)'
          }

          # If not strict, warn; otherwise, later code will error on its own.
          if (!strict) {
            warning("Multiple stations match station_name. ",
                    "Using\n\tstation_name = '",
                    the_station_name,
                    "'\n\nDid you mean any of the following?\n",
                    paste0("\tstation_name = '",
                           likely_stations[-1],
                           "'",
                           collapse = "\n"))
          }
        }

        if (strict) {
          if (length(likely_stations) == 1) {
            stop("strict = TRUE but station name not exactly matched.\nDid you mean the following?\n\t",
                 "station_name = '",
                 the_station_name, "'")
          } else {
            stop("strict = TRUE but station name not exactly matched.\n",
                 "Multiple stations match station_name. ",
                 "\n\nDid you mean any of the following?\n",
                 paste0("\tstation_name = '",
                        likely_stations,
                        "'",
                        collapse = "\n"))
          }

        }
      }

      json_url <-
        JSONurl_latlon_by_station_name[name == the_station_name][["url"]]

    } else {
      # We have established latlon is not NULL
      if (length(latlon) != 2 || !is.numeric(latlon)) {
        stop("latlon must be a length-2 numeric vector.")
      }

      Lat <- latlon[1]
      Lon <- latlon[2]

      # CRAN NOTE avoidance: names of JSONurl_latlon_by_station_name
      lat <- lon <- NULL

      station_nrst_latlon <-
        JSONurl_latlon_by_station_name %>%
        # Lat Lon are in JSON
        .[which.min(haversine_distance(Lat, Lon, lat, lon))]

      if (emit_latlon_msg) {
        distance <-
          station_nrst_latlon %$%
          haversine_distance(Lat, Lon, lat, lon) %>%
          signif(digits = 3)

        on.exit(
          message(
            "Using station_name = '",
            station_nrst_latlon$name,
            "', at latitude = ",
            station_nrst_latlon$lat,
            ", ",
            "longitude = ",
            station_nrst_latlon$lon,
            " (",
            distance,
            " km away)."
          )
        )
      }

      json_url <- station_nrst_latlon[["url"]]
    }

    tryCatch({
      observations.json <-
        jsonlite::fromJSON(txt = json_url)
    },
    error = function(e) {
      e$message <-
        paste("\nA station was matched.",
              "However a corresponding JSON file was not found at bom.gov.au.\n")
      # Otherwise refers to open.connection
      e$call <- NULL
      stop(e)
    })

    if ("observations" %notin% names(observations.json) ||
        "data" %notin% names(observations.json$observations)) {
      stop("\nA station was matched",
           "but the JSON returned by bom.gov.au was not in expected form.\n")
    }

    # Columns which are meant to be numeric
    double_cols <-
      c("lat",
        "lon",
        "apparent_t",
        "cloud_base_m",
        "cloud_oktas",
        "rain_trace")
    out <-
      observations.json %>%
      use_series("observations") %>%
      use_series("data")

    if (as.data.table) {
      data.table::setDT(out)
    }

    # BoM raw JSON uses `name`, which is ambiguous (see #27)
    if ("name" %in% names(out)) {
      setnames(out, "name", "full_name")
    }

    if (raw) {
      return(out)
    } else {
      return(cook(out, as.DT = as.data.table, double_cols = double_cols))
    }
  }

# (i.e. not raw)
cook <- function(DT, as.DT, double_cols) {
  if (!data.table::is.data.table(DT)) {
    data.table::setDT(DT)
  }

  DTnoms <- names(DT)

  # CRAN NOTE avoidance
  local_date_time_full <- NULL
  if ("local_date_time_full" %chin% DTnoms) {
    DT[, local_date_time_full := as.POSIXct(
      local_date_time_full,
      origin = "1970-1-1",
      format = "%Y%m%d%H%M%OS",
      tz = ""
    )]
  }

  aifstime_utc <- NULL
  if ("aifstime_utc" %chin% DTnoms) {
    DT[, aifstime_utc := as.POSIXct(aifstime_utc,
                                    origin = "1970-1-1",
                                    format = "%Y%m%d%H%M%OS",
                                    tz = "GMT")]
  }

  for (j in which(DTnoms %chin% double_cols)) {
    data.table::set(DT, j = j, value = force_double(DT[[j]]))
  }

  if (!as.DT) {
    DT <- as.data.frame(DT)
  }

  DT[]
}