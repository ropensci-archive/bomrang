
#' Update internal databases with latest BOM station metadata
#'
#' Download the latest station locations and metadata and update internal
#' databases that support the use of \code{\link{get_current_weather}}
#' \code{\link{get_ag_bulletin}} and \code{\link{get_historical}}.  There is no
#' need to use this unless you know that a station exists in BOM's database
#' that is not available in the databases distributed with \pkg{bomrang}. In
#' fact, for reproducibility purposes, users are discouraged from using this
#' function.
#'
#' If \pkg{ASGS.foyer} is installed locally, this function will automatically
#' check and correct any invalid state values for stations located in Australia.
#' If \pkg{ASGS.foyer} is not installed, the function will update the internal
#' database without validating the state values for stations by reported
#' longitude/latitude location.
#'
#' @examples
#' \dontrun{
#' update_station_locations()
#' }
#' @return Updated internal databases of \acronym{BOM} station locations and
#' \acronym{JSON} \acronym{URL}s
#'
#' @references
#' Station location and other metadata are sourced from the Australian Bureau of
#' Meteorology (\acronym{BOM}) webpage, Bureau of Meteorology Site Numbers:\cr
#' \url{http://www.bom.gov.au/climate/cdo/about/site-num.shtml}
#'
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#' @export update_station_locations

update_station_locations <- function() {
  message(
    "This will overwrite the current internal databases of BOM stations.\n",
    "If reproducibility is necessary, you may not wish to proceed.\n",
    "Do you understand and wish to proceed (Y/n)?\n"
  )

  answer <-
    readLines(con = getOption("bomrang.connection"), n = 1)

  answer <- toupper(answer)

  if (answer %notin% c("Y", "YES")) {
    stop("Station databases were not updated.",
         call. = FALSE)
  }

  message("Updating internal station databases.\n")

  # CRAN NOTE avoidance
  site <- state_code <- wmo <- state <- lon <- lat <- # nocov start
  actual_state <- state_from_latlon <- start <- end <- NULL # nocov end

  tryCatch({
    curl::curl_download(
      url =
        "ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/sitelists/stations.zip",
      destfile = file.path(tempdir(), "stations.zip"),
      mode = "wb",
      quiet = TRUE
    )
  },
  error = function(x)
    stop(
      "\nThe server with the location information is not responding.",
      "Please retry again later.\n",
      call. = FALSE
    ))

  bom_stations_raw <-
    readr::read_table(
      file.path(tempdir(), "stations.zip"),
      skip = 4,
      na = c("..", ".....", " "),
      col_names = c(
        "site",
        "dist",
        "name",
        "start",
        "end",
        "lat",
        "lon",
        "NULL1",
        "state",
        "elev",
        "bar_ht",
        "wmo"
      ),
      col_types = c(
        site = readr::col_character(),
        dist = readr::col_character(),
        name = readr::col_character(),
        start = readr::col_integer(),
        end = readr::col_integer(),
        lat = readr::col_double(),
        lon = readr::col_double(),
        NULL1 = readr::col_character(),
        state = readr::col_character(),
        elev = readr::col_double(),
        bar_ht = readr::col_double(),
        wmo = readr::col_integer()
      )
    )

  # remove extra columns for source of location
  bom_stations_raw <- bom_stations_raw[, -8]

  # trim the end of the rows off that have extra info that's not in columns
  nrows <- nrow(bom_stations_raw) - 3
  bom_stations_raw <- bom_stations_raw[1:nrows,]

  bom_stations_raw["end"][is.na(bom_stations_raw["end"])] <-
    as.integer(format(Sys.Date(), "%Y"))

  # keep only currently reporting stations
  bom_stations_raw <-
    bom_stations_raw[bom_stations_raw$end == format(Sys.Date(), "%Y"), ] %>%
    dplyr::mutate(start = as.integer(start),
                  end = as.integer(end))

  # if sf is installed, correct the state column, otherwise skip
  if (requireNamespace("ASGS.foyer", quietly = TRUE)) {
    message(
      "The package 'ASGS.foyer' is installed. Station locations will\n",
      "be checked against lat/lon location values and corrected in the\n",
      "updated internal database lists of stations."
    )
    data.table::setDT(bom_stations_raw)
    latlon2state <- function(lat, lon) {
      ASGS.foyer::latlon2SA(lat,
                            lon,
                            to = "STE",
                            yr = "2016",
                            return = "v")
    }

    bom_stations_raw %>%
      .[lon > -50, state_from_latlon := latlon2state(lat, lon)] %>%
      .[state_from_latlon == "New South Wales", actual_state := "NSW"] %>%
      .[state_from_latlon == "Victoria", actual_state := "VIC"] %>%
      .[state_from_latlon == "Queensland", actual_state := "QLD"] %>%
      .[state_from_latlon == "South Australia", actual_state := "SA"] %>%
      .[state_from_latlon == "Western Australia", actual_state := "WA"] %>%
      .[state_from_latlon == "Tasmania", actual_state := "TAS"] %>%
      .[state_from_latlon == "Australian Capital Territory",
        actual_state := "ACT"] %>%
      .[state_from_latlon == "Northern Territory", actual_state := "NT"] %>%
      .[actual_state != state &
          state %notin% c("ANT", "ISL"), state := actual_state] %>%
      .[, actual_state := NULL]

    data.table::setDF(bom_stations_raw)
  }

  # recode the states to match product codes
  # IDD - NT,
  # IDN - NSW/ACT,
  # IDQ - Qld,
  # IDS - SA,
  # IDT - Tas/Antarctica,
  # IDV - Vic, IDW - WA

  bom_stations_raw$state_code <- NA
  bom_stations_raw$state_code[bom_stations_raw$state == "WA"] <- "W"
  bom_stations_raw$state_code[bom_stations_raw$state == "QLD"] <-
    "Q"
  bom_stations_raw$state_code[bom_stations_raw$state == "VIC"] <-
    "V"
  bom_stations_raw$state_code[bom_stations_raw$state == "NT"] <- "D"
  bom_stations_raw$state_code[bom_stations_raw$state == "TAS" |
                                bom_stations_raw$state == "ANT"] <-
    "T"
  bom_stations_raw$state_code[bom_stations_raw$state == "NSW"] <-
    "N"
  bom_stations_raw$state_code[bom_stations_raw$state == "SA"] <- "S"

  stations_site_list <-
    bom_stations_raw %>%
    dplyr::select(site:wmo, state, state_code) %>%
    tidyr::drop_na(wmo) %>%
    dplyr::mutate(
      url = dplyr::case_when(
        .$state == "NSW" |
          .$state == "NT" |
          .$state == "QLD" |
          .$state == "SA" |
          .$state == "TAS" |
          .$state == "VIC" |
          .$state == "WA" ~
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
        .$state == "ACT" ~
          paste0(
            "http://www.bom.gov.au/fwo/IDN",
            "60903",
            "/",
            "IDN",
            "60903",
            ".",
            .$wmo,
            ".json"
          ),
        .$state == "ANT" ~
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
  save(
    JSONurl_site_list,
    file = fname,
    compress = "bzip2"
  )

  stations_site_list <-
    stations_site_list %>%
    dplyr::select(-state_code, -url) %>%
    dplyr::filter(end == lubridate::year(Sys.Date()))

  stations_site_list$site <-
    gsub("^0{1,2}", "", stations_site_list$site)

  fname <-
    system.file("extdata", "stations_site_list.rda", package = "bomrang")
  save(stations_site_list, file = fname, compress = "bzip2")
}
