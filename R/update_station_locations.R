
#' Update Internal Databases With Latest BoM Station Locations and Metadata
#'
#' Download the latest station locations and metadata and update bomrang's
#' internal databases that support the use of \code{\link{get_current_weather}}
#' and \code{\link{get_ag_bulletin}}.  There is no need to use this unless you
#' know that a station exists in BoM's database that is not available in the
#' databases distributed with \code{\link{bomrang}}.
#'
#' @examples
#' \dontrun{
#' update_station_locations()
#' }
#' @return Updated internal databases of BoM station locations and JSON URLs
#'
#' @references
#' Station location and other metadata are sourced from the Australian Bureau of
#' Meteorology (BoM) webpage, Bureau of Meteorology Site Numbers:
#' \url{http://www.bom.gov.au/climate/cdo/about/site-num.shtml}
#'
#' @author Adam H Sparks, \email{adamhsparks@gmail.com}
#' @export
#'
update_station_locations <- function() {
  # CRAN NOTE avoidance
  name <- site <- lat <- lon <- state_code <-  NULL
  tryCatch({
    curl::curl_download(
      url =
        "ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/sitelists/stations.zip",
                        destfile = file.path(tempdir(), "stations.zip"))
  },
  error = function(x)
    stop(
      "\nThe server with the location information is not responding.",
      "Please retry again later.\n"
    ))

  bom_stations_raw <-
    readr::read_table(
      file.path(tempdir(), "stations.zip"),
      skip = 5,
      guess_max = 20000,
      col_names = c(
        "site",
        "dist",
        "name",
        "start",
        "end",
        "lat",
        "lon",
        "source",
        "state",
        "elev",
        "bar_ht",
        "wmo"
      ),
      col_types = readr::cols(
        site = readr::col_character(),
        dist = readr::col_character(),
        name = readr::col_character(),
        start = readr::col_integer(),
        end = readr::col_integer(),
        lat = readr::col_double(),
        lon = readr::col_double(),
        source = readr::col_character(),
        state = readr::col_character(),
        elev = readr::col_double(),
        bar_ht = readr::col_double(),
        wmo = readr::col_integer()
      ),
      na = c("..")
    )

  # trim the end of the rows off that have extra info that's not in columns
  nrows <- nrow(bom_stations_raw) - 5
  bom_stations_raw <- bom_stations_raw[1:nrows, ]

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
        .$state != "ANT" & !is.na(.$wmo) ~
          paste0(
            "http://www.bom.gov.au/fwo/ID",
            .$state_code,
            "60801",
            "/",
            "ID",
            .$state_code,
            "60801",
            ".",
            .$wmo,
            ".json"
          ),
        .$state == "ANT" & !is.na(.$wmo) ~
          paste0(
            "http://www.bom.gov.au/fwo/ID",
            .$state_code,
            "60803",
            "/",
            "ID",
            .$state_code,
            "60803",
            ".",
            .$wmo,
            ".json"
          )
      )
    )

  # return only current stations listing
  stations_site_list <-
    stations_site_list[is.na(stations_site_list$end), ]
  stations_site_list$end <- format(Sys.Date(), "%Y")

  # There are weather stations that do have a wmo but don't report online,
  # most of these don't have a "state" value, e.g., KIRIBATI NTC AWS or
  # MARSHALL ISLANDS NTC AWS, remove these from the list

  JSONurl_site_list <-
    stations_site_list[!is.na(stations_site_list$url), ]

  JSONurl_site_list <-
    JSONurl_site_list %>%
    dplyr::rowwise() %>%
    dplyr::mutate(url = dplyr::if_else(httr::http_error(url),
                                       NA_character_,
                                       url))

  # Remove new NA values from invalid URLs and convert to data.table
  JSONurl_site_list <-
    data.table::data.table(JSONurl_site_list[!is.na(JSONurl_site_list$url), ])

  message("Overwriting existing databases")

  fname <- system.file("extdata", "JSONurl_site_list.rda",
                       package = "bomrang")
  save(JSONurl_site_list, file = fname, compress = "bzip2")

  stations_site_list <-
    stations_site_list %>%
    dplyr::select(-state_code, -source, -url)
  stations_site_list$site <-
    gsub("^0{1,2}", "", stations_site_list$site)

  fname <- system.file("extdata", "stations_site_list.rda", package = "bomrang")
  save(stations_site_list, file = fname, compress = "bzip2")
}
