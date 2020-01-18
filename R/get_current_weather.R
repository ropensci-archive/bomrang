
#' Get current weather observations of a BOM station
#'
#' @param station_name The name of the weather station. Fuzzy string matching
#' via \code{\link[base]{agrep}} is done.
#' @param strict (logical) If \code{TRUE}, \var{station_name} must match the
#' station name exactly, except that \var{station_name} need not be upper case.
#' Note this may be different to \code{full_name} in the response. See
#' \strong{Details}.
#' @param latlon A length-2 numeric vector giving the decimal degree
#' latitude and longitude (in that order), \emph{e.g.}, \code{latlon =
#' c(-34, 151)} for Sydney. When given instead of \code{station_name}, the
#' nearest station (in this package) is used, with a message indicating the
#' nearest such station. (See also \code{\link{sweep_for_stations}}.) Ignored if
#' used in combination with \var{station_name}, with a warning.
#' @param emit_latlon_msg Logical. If \code{TRUE} (the default), and
#' \code{latlon} is selected, a message is emitted before the table is returned
#' indicating which station was actually used (\emph{i.e.}, which station was
#' found to be nearest to the given coordinate).
#'
#' @details
#' Station names are not consistently named within the Bureau, so
#' the response may contain a different \code{full_name} to the one
#' matched, even if \var{strict = TRUE}. For example, \cr
#' \code{get_current_weather("CASTLEMAINE PRISON")[["full_name"]][1]} \cr
#' is \code{Castlemaine}, not \code{Castlemaine Prison}.
#'
#' Note that the column \code{local_date_time_full} is set to a
#' \code{POSIXct} object in the local time of the \strong{user}.
#' For more details see "Appendix 1 - Output from get_current_weather()" in
#' the \pkg{bomrang} vignette \cr
#' \code{vignette("bomrang", package = "bomrang")}\cr
#' for a complete list of fields and units.
#'
#' @return A \code{bomrang_tbl} object (extension of a
#' \code{\link[base]{data.frame}})  of requested BOM station's current and prior
#'  72hr data. For full details of fields and units returned, see Appendix 1
#'  in the \pkg{bomrang} vignette, use \cr
#' \code{vignette("bomrang", package = "bomrang")} to view.
#' @examples
#' \donttest{
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
#' Australian Bureau of Meteorology (\acronym{BOM}) Weather Data Services,
#' Observations - individual stations:
#' \url{http://www.bom.gov.au/catalogue/data-feeds.shtml}
#'
#' Station location and other metadata are sourced from the Australian Bureau of
#' Meteorology (\acronym{BOM}) webpage, Bureau of Meteorology Site Numbers:
#' \url{http://www.bom.gov.au/climate/cdo/about/site-num.shtml}
#'
#' @author Hugh Parsonage, \email{hugh.parsonage@@gmail.com}
#' @importFrom magrittr use_series
#' @importFrom magrittr %$%
#' @importFrom data.table :=
#' @importFrom data.table %chin%
#' @importFrom data.table setnames
#' @rdname get_current_weather
#' @export get_current_weather

get_current_weather <-
  function(station_name,
           strict = FALSE,
           latlon = NULL,
           emit_latlon_msg = TRUE) {
    # CRAN NOTE avoidance
    JSONurl_site_list <- end <- name <- NULL # nocov
    
    # Load JSON URL list
    load(system.file("extdata", "JSONurl_site_list.rda",  # nocov start
                     package = "bomrang"))  # nocov end
    
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
      
      station_name <- toupper(station_name)
      
      # If there's an exact match, use it; else, attempt partial match.
      if (station_name %in% JSONurl_site_list[["name"]]) {
        the_station_name <- station_name
      } else {
        likely_stations <-
          # Present those with common prefixes first
          c(
            grep(
              pattern = paste0("^", station_name),
              x = JSONurl_site_list[["name"]],
              ignore.case = TRUE,
              value = TRUE
            ),
            agrep(
              pattern = station_name,
              x = JSONurl_site_list[["name"]],
              value = TRUE
            )
          ) %>%
          unique
        
        if (length(likely_stations) == 0) {
          stop("No station found.")
        }
        
        the_station_name <- likely_stations[1]
        if (length(likely_stations) > 1) {
          # Likely common use case
          # (otherwise defaults to KURNELL RADAR,
          # which does not provide observations)
          if (toupper(station_name) == "SYDNEY" &&
              "SYDNEY (OBSERVATORY HILL)" %in% likely_stations) {
            likely_stations <- c(
              "SYDNEY (OBSERVATORY HILL)",
              setdiff(likely_stations,
                      "SYDNEY (OBSERVATORY HILL)")
            )
            the_station_name <- "SYDNEY (OBSERVATORY HILL)"
          }
          
          # If not strict, warn; otherwise, later code will error on its own.
          if (!strict) {
            warning(
              "Multiple stations match station_name. ",
              "Using\n\tstation_name = '",
              the_station_name,
              "'\nDid you mean any of the following?\n",
              paste0(
                "\tstation_name = '",
                likely_stations[-1],
                "'",
                collapse = "\n"
              )
            )
          }
        }
        
        if (strict) {
          if (length(likely_stations) == 1) {
            stop(
              "strict = TRUE but station name not exactly matched.",
              "\nDid you mean the following?\n\t",
              "station_name = '",
              the_station_name,
              "'"
            )
          } else {
            stop(
              "strict = TRUE but station name not exactly matched.\n",
              "Multiple stations match station_name. ",
              "\n\nDid you mean any of the following?\n",
              paste0("\tstation_name = '",
                     likely_stations,
                     "'",
                     collapse = "\n")
            )
          }
          
        }
      }
      
      json_url <-
        JSONurl_site_list[name == the_station_name][["url"]]
      full_lat <-
        JSONurl_site_list[name == the_station_name][["lat"]]
      full_lon <-
        JSONurl_site_list[name == the_station_name][["lon"]]
      
    } else {
      # We have established latlon is not NULL
      if (length(latlon) != 2 || !is.numeric(latlon)) {
        stop("latlon must be a length-2 numeric vector.")
      }
      
      Lat <- latlon[1]
      Lon <- latlon[2]
      
      # CRAN NOTE avoidance: names of JSONurl_site_list
      lat <- lon <- NULL # nocov
      
      station_nrst_latlon <-
        JSONurl_site_list %>%
        # Lat Lon are in JSON
        .[which.min(.haversine_distance(Lat, Lon, lat, lon))]
      
      if (emit_latlon_msg) {
        distance <-
          station_nrst_latlon %$%
          .haversine_distance(Lat, Lon, lat, lon) %>%
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
      full_lat <- station_nrst_latlon[["lat"]]
      full_lon <- station_nrst_latlon[["lon"]]
      
    }
    
    observations.json <- .get_url(remote_file = json_url)
    if (is.null(observations.json)) {
      return(invisible(NULL))
    }
    
    if ("observations" %notin% names(observations.json) ||
        "data" %notin% names(observations.json$observations)) {
      stop(
        "\nA station was matched. ",
        "However, the JSON returned by bom.gov.au was not in expected form.\n"
      )
    }
    
    out <-
      observations.json %>%
      use_series("observations") %>%
      use_series("data")
    
    data.table::setDT(out)
    # replaced rounded values from .json with full values from internal db
    data.table::set(out, j = "lat", value = full_lat)
    data.table::set(out, j = "lon", value = full_lon)
    
    # BOM raw JSON uses `name`, which is ambiguous (see #27)
    if ("name" %in% names(out)) {
      setnames(out, "name", "full_name")
    }
    
    # CRAN NOTE avoidance
    out[, "local_date_time_full" := lapply(.SD, function(x)
      as.POSIXct(x,
                 origin = "1970-1-1",
                 format = "%Y%m%d%H%M%OS")),
      .SDcols = "local_date_time_full"]
    
    out[, "aifstime_utc" := lapply(.SD, function(x)
      as.POSIXct(
        x,
        origin = "1970-1-1",
        format = "%Y%m%d%H%M%OS",
        tz = "GMT"
      )),
      .SDcols = "aifstime_utc"]
    
    out[, "rel_hum" := suppressWarnings(as.integer("rel_hum"))]
    
    # Columns which are meant to be numeric
    double_cols <-
      c("lat",
        "lon",
        "apparent_t",
        "cloud_base_m",
        "cloud_oktas",
        "rain_trace")
    
    for (j in which(names(out) %chin% double_cols)) {
      data.table::set(out, j = j, value = .force_double(out[[j]]))
    }
    
    station_meta <- subset(JSONurl_site_list, url %in% json_url)
    
    return(
      structure(
        out,
        class = union("bomrang_tbl", class(out)),
        station = station_meta$site,
        type = "All",
        origin = "Current",
        location = station_meta$name,
        lat = station_meta$lat,
        lon = station_meta$lon,
        start = station_meta$start,
        end = station_meta$end,
        count = station_meta$end - station_meta$start,
        units = "years",
        ncc_list = station_meta
      )
    )
  }
