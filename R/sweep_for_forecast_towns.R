
#' Find Nearest BOM Forecast Towns
#'
#' @param latlon A length-2 numeric vector. By default, Canberra
#' (approximately).
#' @return A data frame of all forecast towns (in this package) sorted
#' by distance from \var{latlon}, ascending.
#' @author Hugh Parsonage, \email{hugh.parsonage@@gmail.com}
#' @importFrom data.table copy setorderv
#' @export sweep_for_forecast_towns

sweep_for_forecast_towns <- function(latlon = c(-35.3, 149.2)) {
  Lat <- latlon[1]
  Lon <- latlon[2]

  # CRAN NOTE avoidance:
  JSONurl_site_list <- lat <- lon <- NULL # nocov

  # Load JSON URL list
  load(system.file("extdata",
                   "AAC_codes.rda",
                   package = "bomrang"))

  AAC_codes %>%
    copy %>%
    # Lat Lon are in JSON
    .[, "distance" := .haversine_distance(Lat, Lon, lat, lon)] %>%
    setorderv("distance") %>%
    .[] %>%
    as.data.frame
}

