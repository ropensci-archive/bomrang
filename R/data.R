#'AAC_codes
#'
#' @format A data frame with 1369 observations of 4 elements:
#' \describe{
#'   \item{AAC}{Unique identifier for each location}
#'   \item{PT_NAME}{Human readable location name}
#'   \item{ELEVATION}{Elevation (metres)}
#'   \item{LON}{Longitude}
#'   \item{LAT}{Latitude}
#' }
#'
#' The \code{AAC_codes} data are automatically loaded with the
#' \code{\link{bomrang}} package and merged with the latest available forecast
#' from the BOM.
#'
#'
#' @source \url{ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf}
#'
"AAC_codes"
#'stations_site_list
#'
#'    \item{site}{Unique BOM identifier for each station}
#'    \item{dist}{BOM rainfall district}
#'    \item{name}{BOM station name}
#'    \item{start}{Year data collection starts}
#'    \item{end}{Year data collection ends (will always be current)}
#'    \item{state}{State name (postal code abbreviation)}
#'    \item{lat}{Latitude (decimal degrees)}
#'    \item{lon}{Longitude (decimal degrees)}
#'    \item{elev_m}{Station elevation (metres)}
#'    \item{bar_ht}{Bar height (metres)}
#'    \item{WMO}{World Meteorological Organization number (unique ID used worldwide)}
"stations_site_list"

#'JSONurl_latlon_by_station_name
#'
#'    \item{site}{Unique BOM identifier for each station}
#'    \item{dist}{BOM rainfall district}
#'    \item{name}{BOM station name}
#'    \item{start}{Year data collection starts}
#'    \item{end}{Year data collection ends (will always be current)}
#'    \item{state}{State name (postal code abbreviation)}
#'    \item{lat}{Latitude (decimal degrees)}
#'    \item{lon}{Longitude (decimal degrees)}
#'    \item{elev_m}{Station elevation (metres)}
#'    \item{bar_ht}{Bar height (metres)}
#'    \item{WMO}{World Meteorological Organization number (unique ID used worldwide)}
#'    \item{state_code}{BOM code used to identify states and territories}
#'    \item{url}{URL that serves JSON file of station weather data}
"JSONurl_latlon_by_station_name"
