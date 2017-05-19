#' Find nearest weather stations
#' @param latlon A length-2 numeric vector. By default, Canberra (approximately).
#' @return A \code{data.table} of all weather stations (in this package) sorted by
#' distance from \code{latlon}, ascending.
#' @export

sweep_for_stations <- function(latlon = c(-35.3, 149.2)) {
  lat <- latlon[1]
  lon <- latlon[2]

  JSONurl_latlon_by_station_name %>%
    copy %>%
    # distracting for this purpose
    .[, c("NAME", "url") := NULL] %>%
    .[complete.cases(.)] %>%
    # Lat Lon are in JSON
    .[, "distance" := haversine_distance(lat, lon, Lat, Lon)] %>%
    setorderv("distance") %>%
    .[]
}



