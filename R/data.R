
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
