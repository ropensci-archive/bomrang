#'AAC_codes
#'
#'@description
#'BoM Précis Forecast Town Names and Longitude and Latitude
#'
#'@details
#' \describe{
#'   \item{AAC}{Unique identifier for each town}
#'   \item{PT_NAME}{Human readable town name}
#'   \item{ELEVATION}{Elevation (metres)}
#'   \item{LON}{Longitude}
#'   \item{LAT}{Latitude}
#' }
#'
#' The \code{AAC_codes} data are automatically loaded with the
#' \code{\link{bomrang}} package and merged with the latest available forecast
#' from the BoM.
#'
#' @source \url{ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf}
#'
"AAC_codes"

#'stations_site_list
#'
#'@description
#'A database of station names, locations and other metadata used for the ag
#'bulletin
#'
#'@details
#'\describe{
#'    \item{site}{Unique BoM identifier for each station}
#'    \item{dist}{BoM rainfall district}
#'    \item{name}{BoM station name}
#'    \item{start}{Year data collection starts}
#'    \item{end}{Year data collection ends (will always be current)}
#'    \item{state}{State name (postal code abbreviation)}
#'    \item{lat}{Latitude (decimal degrees)}
#'    \item{lon}{Longitude (decimal degrees)}
#'    \item{elev_m}{Station elevation (metres)}
#'    \item{bar_ht}{Bar height (metres)}
#'    \item{WMO}{World Meteorological Organization number (unique ID used worldwide)}
#'    }
#'
#'@source \url{ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/sitelists/stations.zip}
#'
"stations_site_list"

#'JSONurl_latlon_by_station_name
#'
#'@description
#'A database of URLs that provide a JSON file of current weather conditions
#'for BoM weather stations.
#'
#'@details
#'\describe{
#'    \item{site}{Unique BoM identifier for each station}
#'    \item{dist}{BoM rainfall district}
#'    \item{name}{BoM station name}
#'    \item{start}{Year data collection starts}
#'    \item{end}{Year data collection ends (will always be current)}
#'    \item{state}{State name (postal code abbreviation)}
#'    \item{lat}{Latitude (decimal degrees)}
#'    \item{lon}{Longitude (decimal degrees)}
#'    \item{elev_m}{Station elevation (metres)}
#'    \item{bar_ht}{Bar height (metres)}
#'    \item{WMO}{World Meteorological Organization number (unique ID used worldwide)}
#'    \item{state_code}{BoM code used to identify states and territories}
#'    \item{url}{URL that serves JSON file of station weather data}
#'    }
#'@source \url{ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/sitelists/stations.zip}
#'
"JSONurl_latlon_by_station_name"
