#' @noRd
.validate_state <-
  function(state) {
    if (!is.null(state)) {
      state <- toupper(trimws(state))
    } else
      stop("\nPlease provide a valid 2 or 3 letter state or territory postal code abbreviation")
  }

`%notin%` <- Negate("%in%")

force_double <- function(v) {
  suppressWarnings(as.double(v))
}

# Distance over a great circle. Reasonable approximation.
haversine_distance <- function(lat1, lon1, lat2, lon2) {
  # to radians
  lat1 <- lat1 * pi / 180
  lat2 <- lat2 * pi / 180
  lon1 <- lon1 * pi / 180
  lon2 <- lon2 * pi / 180

  delta_lat <- abs(lat1 - lat2)
  delta_lon <- abs(lon1 - lon2)

  # radius of earth
  6371 * 2 * asin(sqrt(`+`((sin(delta_lat / 2)) ^ 2,
                           cos(lat1) * cos(lat2) * (sin(delta_lon / 2)) ^ 2
  )))
}

#' @importFrom magrittr %>%
#' @noRd
.get_station_metadata <- function() {

  # CRAN NOTE avoidance
  name <- site <- NULL

  curl::curl_download(url = "ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/sitelists/stations.zip",
                      destfile = paste0(tempdir(), "stations.zip"))

  bom_stations_raw <-
    readr::read_table(
      paste0(tempdir(), "stations.zip"),
      skip = 5,
      guess_max = 20000,
      col_names = c(
        "site",
        "dist",
        "name",
        "start",
        "end",
        "Lat",
        "Lon",
        "source",
        "state",
        "elev",
        "bar_ht",
        "WMO"
      ),
      col_types = readr::cols(
        site = readr::col_character(),
        dist = readr::col_character(),
        name = readr::col_character(),
        start = readr::col_integer(),
        end = readr::col_integer(),
        Lat = readr::col_double(),
        Lon = readr::col_double(),
        source = readr::col_character(),
        state = readr::col_character(),
        elev = readr::col_double(),
        bar_ht = readr::col_double(),
        WMO = readr::col_integer()
      ),
      na = c("..")
    )

  # trim the end of the rows off that have extra info that's not in columns
  nrows <- nrow(bom_stations_raw) - 5
  bom_stations_raw <- bom_stations_raw[1:nrows, ]

  # recode the states to match product codes
  # IDD - NT, IDN - NSW/ACT, IDQ - Qld, IDS - SA, IDT - Tas/Antarctica, IDV - Vic, IDW - WA

  bom_stations_raw$state_code <- NA
  bom_stations_raw$state_code[bom_stations_raw$state == "WA"] <-
    "W"
  bom_stations_raw$state_code[bom_stations_raw$state == "QLD"] <-
    "Q"
  bom_stations_raw$state_code[bom_stations_raw$state == "VIC"] <-
    "V"
  bom_stations_raw$state_code[bom_stations_raw$state == "NT"] <-
    "D"
  bom_stations_raw$state_code[bom_stations_raw$state == "TAS" |
                                bom_stations_raw$state == "ANT"] <-
    "T"
  bom_stations_raw$state_code[bom_stations_raw$state == "NSW"] <-
    "N"
  bom_stations_raw$state_code[bom_stations_raw$state == "SA"] <-
    "S"

  stations_site_list <-
    bom_stations_raw %>%
    dplyr::select(site:name, dplyr::everything()) %>%
    dplyr::mutate(
      url = dplyr::case_when(
        .$state != "ANT" & !is.na(.$WMO) ~
          paste0(
            "http://www.bom.gov.au/fwo/ID",
            .$state_code,
            "60801",
            "/",
            "ID",
            .$state_code,
            "60801",
            ".",
            .$WMO,
            ".json"
          ),
        .$state == "ANT" & !is.na(.$WMO) ~
          paste0(
            "http://www.bom.gov.au/fwo/ID",
            .$state_code,
            "60803",
            "/",
            "ID",
            .$state_code,
            "60803",
            ".",
            .$WMO,
            ".json"
          )
      )
    )

  # There are weather stations that do have a WMO but don't report online,
  # most of these don't have a "state" value, e.g., KIRIBATI NTC AWS or
  # MARSHALL ISLANDS NTC AWS, remove these from the list

  stations_site_list <-
    stations_site_list[stations_site_list$state != "null", ]

  # return only current stations listing
  stations_site_list <-
    stations_site_list[is.na(stations_site_list$end), ]
  stations_site_list$end <- format(Sys.Date(), "%Y")

  return(stations_site_list)
}
