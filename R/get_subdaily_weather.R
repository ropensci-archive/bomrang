
#' Obtain historical BOM data in sub-daily time scales
#'
#' Retrieves hourly or smaller, if available, weather observations for a given
#'   station.
#'
#' @param stationid \acronym{BOM} station \sQuote{ID}. See Details.
#' @param station_name Official \acronym{BOM} station name. See Details.
#' @param years Year(s) of weather data to download. Entered as integers,
#'   \emph{e.g.} \code{2001:2002}. Defaults to all available years for the
#'   specified station if left unspecified.
#' @param hourly If \code{TRUE} this forces the values to start on
#'   the hour and returns hourly values for the entire period requested rather
#'   than sub-hourly values if available for the selected station. Defaults to
#'   \code{TRUE}.
#' @param ... Other parameters as passed along to
#'  \code{\link[stationaRy]{get_met_data}}.
#' @return A \code{bomrang_tbl} object (extension of a
#'   \code{\link[base]{data.frame}}) of historical sub-daily (hourly or
#'   less)time-scale observations for the selected station.
#'
#' @details A value for \var{stationid} or \var{name} must be provided. If
#'   you are uncertain, you may use \code{\link{sweep_for_stations}} to identify
#'   possible candidate stations to query. See
#'   \code{vignette("bomrang", package = "bomrang")} for an example of this use.
#'
#'   Only stations falling within BOM's network are returned. If you require
#'   stations that are outside of BOM's network, please use
#'   \CRANpkg{stationaRy} directly.
#'
#' @examples
#' \donttest{
#' # `stationid` and `name` refer to the same station, CHARLTON, in Victoria
#' # Get hourly weather data
#' get_subdaily_weather(stationid = "080128", years = 2018:2019, hourly = TRUE)
#' 
#' # Get sub-hourly weather data
#' get_subdaily_weather(name = "CHARLTON", years = 2018:2019, hourly = FALSE)
#' }
#'
#' @seealso \link{get_current_weather} \link{get_historical_weather}
#'
#' @rdname get_subdaily_weather
#' @export get_subdaily_weather

get_subdaily_weather <- function(stationid = NULL,
                                 name = NULL,
                                 years = NULL,
                                 hourly = TRUE,
                                 ...) {

  load(system.file("extdata",
                   "JSONurl_site_list.rda",
                   package = "bomrang"))

  stationaRy_meta <- stationaRy::get_station_metadata()
  
  if (is.null(name) & is.null(stationid)) {
    stop(call. = FALSE,
         "You must provide either a `stationid` or `name`.")
  }
  
  if (!is.null(name) & !is.null(stationid)) {
    warning(call. = FALSE,
         "You have provided both a `stationid` and `name`, using `name`.")
    stationid <- NULL
  }
  
  # fetch station name if stationid is provided
  if (is.null(name)) {
    station_name <- JSONurl_site_list %>%
      dplyr::filter(stationid == site) %>%
      dplyr::pull(name)
  }
  
  # validate that exists in BOM network
  station_name <- toupper(name)
  if (any(station_name %notin% stationaRy_meta$name)) {
    stop(call. = FALSE,
         "You have requested a station that is not present in the BOM network.")
  } else {
    station_id <- stationaRy_meta %>%
      dplyr::filter(name == station_name) %>%
      dplyr::pull(id)
  }
  
  # fetch data and return
  met_data <- stationaRy::get_met_data(station_id = station_id,
                                  years = years,
                                  make_hourly = hourly)
  
  if (nrow(met_data) >= 1) {
    return(met_data)
  } else
    message("No records were found for this station and year combination.",
            call. = FALSE)
}
