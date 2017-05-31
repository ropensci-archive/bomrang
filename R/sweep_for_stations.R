#' Find nearest weather stations
#' @param latlon A length-2 numeric vector. By default, Canberra
#' (approximately).
#' @return A data frame of all weather stations (in this package) sorted
#' by distance from \code{latlon}, ascending.
#' @importFrom stats complete.cases
#' @author Hugh Parsonage, \email{hugh.parsonage@gmail.com}
#' @export

sweep_for_stations <- function(latlon = c(-35.3, 149.2)) {
  lat <- latlon[1]
  lon <- latlon[2]

  # see internal_functions.R for the .get_station_metadata() function
  JSONurl_latlon_by_station_name <- data.table(.get_station_metadata())

  # select only stations with a JSON url from the list
  JSONurl_latlon_by_station_name <-
    JSONurl_latlon_by_station_name[!is.na(JSONurl_latlon_by_station_name$url), ]

  # CRAN NOTE avoidance:
  Lat <- Lon <- NULL

  JSONurl_latlon_by_station_name %>%
    copy %>%
    # Lat Lon are in JSON
    .[, "distance" := haversine_distance(lat, lon, Lat, Lon)] %>%
    setorderv("distance") %>%
    .[] %>%
    as.data.frame
}
