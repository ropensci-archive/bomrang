
#' Obtain historical BOM data in sub-daily time scales
#'
#' Retrieves ten minute or hourly weather observations for a given station.
#'
#' @param stationid \acronym{BOM} station \sQuote{ID}. See Details.
#' @param years Year(s) of weather data to download. Entered as integers,
#'   \emph{e.g.} \code{2001:2002}. Defaults to all available years for the
#'   specified station if left unspecified.
#' @param hourly If \code{TRUE} this forces the values to start on
#'   the hour and returns hourly values for the entire period requested rather
#'   than sub-hourly values. Defaults to \code{TRUE}.
#' @param ... Other parameters as passed along to
#'  \code{\link[stationaRy]{get_met_data}}.
#' @return A \code{bomrang_tbl} object (extension of a
#'   \code{\link[base]{data.frame}}) of historical sub-daily (hourly or
#'   ten-minute)time-scale observations for the selected station.
#'
#' @details A value for \code{stationid} or \code{latlon} must be provided. If
#'   you are uncertain, you may use \code{\link{sweep_for_stations}} to identify
#'   possible candidate stations to query.
#'
#'   Only stations falling within BOM's network are returned. If you require
#'   stations that are outside of BOM's network, please use
#'   \CRANpkg{stationaRy} directly.
#'
#' @examples
#' \donttest{
#' # Get hourly weather data for CHARLTON station in Victoria
#' get_subdaily_weather(stationid = "080128")
#' }
#'
#' @seealso \link{get_current_weather} \link{get_historical_weather}
#'
#' @rdname get_subdaily_weather
#' @export get_subdaily_weather

get_subdaily_weather <- function(stationid = NULL,
                                 years = NULL,
                                 hourly = TRUE,
                                 ...) {
  # Load JSON URL list and metadata for BOM
  load(system.file("extdata",
                   "JSONurl_site_list.rda",
                   package = "bomrang"))
  
  # Load stationAry metadata
  stationaRy_meta <- stationaRy::get_station_metadata()
  
  station_name <- JSONurl_site_list %>%
    dplyr::filter(stationid == site) %>% 
    dplyr::pull(name)

  # validate that exists in BOM network
  if (any(station_name %notin% stationaRy_meta$name)) {
    stop(call. = FALSE,
         "You have requested a station that is not present in the BOM network.")
  } else {
    station_id <- stationaRy_meta %>%
      dplyr::filter(name == station_name) %>%
      dplyr::pull(id)
  }
  
  dat <- stationaRy::get_met_data(station_id = station_id,
                                  years = years,
                                  make_hourly = hourly)
  
  
  if (nrow(dat) >= 1) {
    return(dat)
  } else
    message("No records were found for this station and year combination.",
            call. = FALSE)
}
