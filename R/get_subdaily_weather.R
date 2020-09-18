

#' Obtain historical BOM data in sub-daily time scales
#'
#' Retrieves hourly or smaller, if available, weather observations for a given
#'   station.
#'
#' @param stationid \acronym{BOM} station \sQuote{ID}. See Details.
#' @param name Official \acronym{BOM} station name. See Details.
#' @param years Year(s) of weather data to download. Entered as integers,
#'   \emph{e.g.} \code{2001:2002}. Defaults to all available years for the
#'   specified station if left unspecified.
#' @param hourly If \code{TRUE} this forces the values to start on
#'   the hour and returns hourly values for the entire period requested rather
#'   than sub-hourly values if available for the selected station. Defaults to
#'   \code{TRUE}.
#' @param ... Other parameters as passed along to
#'  \code{\link[stationaRy]{get_met_data}}.
#' @return A \code{\link[tibble]{tibble}} object of historical sub-daily (hourly
#'   or less)time-scale observations for the selected station. While times are
#'   recorded using the Universal Time Code (UTC) in the source data, they are
#'   adjusted here to local standard time for the station's locale.
#' \describe{
#' \item{id}{A character string identifying the fixed weather station
#' from the USAF Master Station Catalog identifier and the WBAN identifier.}
#' \item{time}{A datetime value representing the observation time.}
#' \item{temp}{Air temperature measured in degrees Celsius.}
#' \item{wd}{The angle of wind direction, measured in a clockwise direction,
#' between true north and the direction from which the wind is blowing. For
#' example, `wd = 90` indicates the wind is blowing from due east. `wd = 225`
#' indicates the wind is blowing from the south west. The minimum value is `1`,
#' and the maximum value is `360`.}
#' \item{ws}{Wind speed in meters per second.}
#' \item{atmos_pres}{The air pressure in hectopascals relative to Mean Sea Level
#' (MSL).}
#' \item{dew_point}{The temperature in degrees Celsius to which a given parcel
#' of air must be cooled at constant pressure and water vapor content in order
#' for saturation to occur.}
#' \item{rh}{Relative humidity, measured as a percentage, as calculated using
#' the August-Roche-Magnus approximation.}
#' \item{ceil_hgt}{The height above ground level of the lowest cloud cover or
#' other obscuring phenomena amounting to at least 5/8 sky coverage. Measured in
#' meters. Unlimited height (no obstruction) is denoted by the value `22000`.}
#' \item{visibility}{The horizontal distance at which an object can be seen and
#' identified. Measured in meters. Values greater than `16000` are entered as
#'  `16000` (which constitutes 10 mile visibility).}
#' }
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
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com} and Richard Iannone,
#' \email{riannone@@me.com}
#'
#' @rdname get_subdaily_weather
#' @export get_subdaily_weather

get_subdaily_weather <- function(stationid = NULL,
                                 name = NULL,
                                 years = NULL,
                                 hourly = TRUE,
                                 ...) {
  # CRAN Note avoidance
  JSONurl_site_list <- site <- id <- NULL
  
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
  
  # fetch station name when `stationid` is provided
  if (is.null(name)) {
    if (stationid %notin% JSONurl_site_list$site) {
      stop(call. = FALSE,
           "You have requested a station that is not present in the BOM network.")
    }
    station_name <- JSONurl_site_list %>%
      dplyr::filter(stationid == site) %>%
      dplyr::pull(name)
  } else {
    # validate station name when `name` is provided
    station_name <- toupper(name)
    if (any(station_name  %notin% stationaRy_meta$name)) {
      stop(call. = FALSE,
           "You have requested a station that is not present in the BOM network.")
    }
  }
  
  station_name <- stationaRy_meta %>%
    dplyr::filter(name == station_name) %>%
    dplyr::pull(id)
  
  # fetch data and return
  met_data <- stationaRy::get_met_data(station_id = station_name,
                                       years = years,
                                       make_hourly = hourly)
  
  if (nrow(met_data) >= 1) {
    return(met_data)
  } else
    message("No records were found for this station and year combination.",
            call. = FALSE)
}
