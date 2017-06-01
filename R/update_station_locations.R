#' Update Internal Database With Latest BOM Station Locations and Metadata
#'
#' Download the latest station locations and metadata and update bomrang's
#' internal databases that support the use of \code{link{get_current_weather}}
#' and \code{\link{get_ag_bulletin}}.  There is no need to use this unless you
#' know that a station exists in BOM's database that is not available in the
#' databases distributed with \code{\link{bomrang}}.
#'
#' @examples
#' \dontrun{
#' update_station_locations()
#' }
#' @return Updated internal databases of BOM station locations and JSON URLs
#'
#' @references
#' Australian Bureau of Meteorology (BOM) Site Numbers
#' \url{http://www.bom.gov.au/climate/cdo/about/site-num.shtml}
#'
#'
#' @author Adam H Sparks, \email{adamhsparks@gmail.com}
#' @export
#'
update_station_locations <- function() {
  # CRAN NOTE avoidance
  name <- site <- NULL
  tryCatch({
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
    bom_stations_raw <- bom_stations_raw[1:nrows,]

    # recode the states to match product codes
    # IDD - NT,
    # IDN - NSW/ACT,
    # IDQ - Qld,
    # IDS - SA,
    # IDT - Tas/Antarctica,
    # IDV - Vic,
    # IDW - WA

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
      stations_site_list[stations_site_list$state != "null",]

    # return only current stations listing
    stations_site_list <-
      stations_site_list[is.na(stations_site_list$end),]
    stations_site_list$end <- format(Sys.Date(), "%Y")

    JSONurl_latlon_by_station_name <-
      bom_stations_raw[!is.na(stations_site_list$url),]
    pkg <- system.file(package = "bomrang")
    path <-
      file.path(file.path(pkg, "data"),
                paste0("JSONurl_latlon_by_station_name.rda"))
    save(JSONurl_latlon_by_station_name,
         file = path,
         compress = "bzip2")

    stations_site_list <-
      stations_site_list %>%
      dplyr::rename(lat = Lat,
                    lon = Lon) %>%
      dplyr::select(-state_code, -source, -url)
    stations_site_list$site <-
      gsub("^0{1,2}", "", stations_site_list$site)

    path <-
      file.path(file.path(pkg, "data"), paste0("stations_site_list.rda"))
    save(stations_site_list, file = path, compress = "bzip2")

  },
  error = function(x)
    stop(
      "\nThe server with the location information is not responding. Please retry again later.\n"
    ))
}
