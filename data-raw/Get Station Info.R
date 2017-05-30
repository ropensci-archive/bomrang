
# Refer to these pages for reference:
# http://www.bom.gov.au/inside/itb/dm/idcodes/struc.shtml
# http://reg.bom.gov.au/catalogue/data-feeds.shtml
# http://reg.bom.gov.au/catalogue/anon-ftp.shtml


    library(httr)
    library(dtplyr)
    library(dplyr)
    library(readr)
    library(data.table)
    library(stringi)

    # This file is a pseudo-fixed width file.
    # Line five contains the headers at fixed widths
    # The last six lines contain other information that we don't want
    # For some reason, reading it directly does not work, so we use download.file
    # to fetch it first and then import

    download.file(
      "ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/sitelists/stations.zip",
      paste0(tempdir(), "stations.zip")
    )

    bom_stations_raw <-
      read_table(
        paste0(tempdir(), "stations.zip"),
        skip = 5,
        guess_max = 20000,
        col_names = c(
          "site",
          "dist",
          "site_name",
          "start",
          "end",
          "lat",
          "lon",
          "source",
          "state",
          "height",
          "bar_ht",
          "WMO"
        ),
        col_types = cols(
          site = col_character(),
          dist = col_character(),
          site_name = col_character(),
          start = col_integer(),
          end = col_integer(),
          lat = col_double(),
          lon = col_double(),
          source = col_character(),
          state = col_character(),
          height = col_double(),
          bar_ht = col_double(),
          WMO = col_integer()
        ),
        na = c("..", "null")
      )

    # trim the end of the rows off that have extra info that's not in columns
    nrows <- nrow(bom_stations_raw) - 5
    bom_stations_raw <- bom_stations_raw[1:nrows, ]

    # recode the states to match product codes
    # IDD - NT, IDN - NSW/ACT, IDQ - Qld, IDS - SA, IDT - Tas/Antarctica, IDV - Vic, IDW - WA

    bom_stations_raw$state_code <- NA
    bom_stations_raw$state_code[bom_stations_raw$state == "WA"] <- "W"
    bom_stations_raw$state_code[bom_stations_raw$state == "QLD"] <- "Q"
    bom_stations_raw$state_code[bom_stations_raw$state == "VIC"] <- "V"
    bom_stations_raw$state_code[bom_stations_raw$state == "NT"] <- "D"
    bom_stations_raw$state_code[bom_stations_raw$state == "TAS" |
                                bom_stations_raw$state == "ANT"] <- "T"
    bom_stations_raw$state_code[bom_stations_raw$state == "NSW"] <- "N"
    bom_stations_raw$state_code[bom_stations_raw$state == "SA"] <- "S"

    # Product codes
    # 60701 - coastal observations (duplicate)
    # 60801 - all weather observations (we will use this)
    # 60803 - Antarctica weather observations (and use this)
    # 60901 - capital city weather observations (duplicate)
    # 60903 - Canberra area weather observations (duplicate)

    # create JSON URLs
    bom_stations_raw$json_url <- NA
    bom_stations_raw$json_url[bom_stations_raw$state != "ANT"] <-
                              paste0("http://www.bom.gov.au/fwo/ID",
                                     bom_stations_raw$state_code, "60801",
                                     "/", "ID", bom_stations_raw$state_code,
                                     "60801", ".", bom_stations_raw$WMO, ".json")

    http://www.bom.gov.au/fwo/IDN60801/IDN60801.94596.json

    bom_stations_raw <- mutate(bom_stations_raw, json_url = paste(
      "http://www.bom.gov.au/fwo/ID", state_code, WMO,
      "/", "ID", state_code, WMO, ".", WMO, ".json", sep = ""))

    bom_stations_raw$json_url[is.na(bom_stations_raw$WMO)] <- NA


    # bom_stations_by_url %>%
    #   mutate(Name = toupper(name)) %>%
    #   as.data.table %>%
    #   unique(by = "Name") %>%
    #   merge(bom_stations, by = "Name", all.y = TRUE) %>%
    #   as.data.table %>%
    #   # Only concerned with those still operating
    #   .[End == "May 2017" & is.na(url)]

    nrow(bom_stations)


    if (regenerate_BOM_urls) {
      get_BOM_data <- function(url, filename, write = FALSE) {
        out <-
          rjson::fromJSON(file = url) %>%
          use_series("observations") %>%
          use_series("data") %>%
          lapply(as.data.table) %>%
          rbindlist(use.names = TRUE, fill = TRUE)

        if (write) {
          out %>%
            fwrite(paste0("./bom/",
                          gsub(
                            "[^0-9]", "-", as.character(the_time)
                          ),
                          filename))
        }
      }

      # By cursory inspection, the varying part of the url runs from 90000 to 99999.
      # Idea here is to try to retrieve the JSON from each URL. Saving the result if
      # there is such a URL.

      # AS 30/05/2017 - the varying URL is the WMO number, we can make this faster
      # by using known WMO numbers and the

      name_by_url <- fread("./data-raw/name-by-url.csv")



      .closure <- function(bom_stations_raw) {
        for (x in 90e3:100e3) {
          .first <- TRUE
          for (STATE in c("V", "N", "Q", "S", "W", "T", "D")) {
            for (y in c("60701", "60801", "60803", "60901", "60903")) {
              url <-
                paste0("http://www.bom.gov.au/fwo/ID",
                       STATE,
                       y,
                       "/ID",
                       STATE,
                       y,
                       ".",
                       x,
                       ".json")
              if (.first && (x %% 10) == 0) {
                # Poor man's progress bar
                cat(".")
                # if (.first && (x %% 1000) == 0) {
                #   cat("\n")
                # }
              }

              html_status <-
                HEAD(url = url) %>%
                status_code

              if (html_status != 404) {
                out <- rjson::fromJSON(file = url)
                if ("observations" %in% names(out)) {
                  name <- out$observations$header[[1]]$name
                  data.table(name = name,
                             url = url) %>%
                    # append, noting to use unique() on the file later.
                    fwrite("./data-raw/name-by-url.csv", append = TRUE)

                }
              }
            }

          }
          .first <- FALSE
        }
      }
      .closure()
    }

    name_by_url <-
      fread("./data-raw/name-by-url.csv") %>%
      .[url != "AAAA"] %>%
      .[!grepl("100000", url)] %>%
      .[order(url)] %>%
      .[, xx := as.integer(gsub("^.*\\.(9[0-9]{4})\\.json", "\\1", url))] %>%
      .[, row_id := 1:.N] %>%
      .[, xx_diff := c(NA, diff(xx))] %>%
      # unique(by = "xx", fromLast = TRUE) %>%
      .[, dup_url := duplicated(url)] %>%
      .[]

    urls <- sum(!name_by_url$dup_url)

    library(magrittr)

    url_ok <- function(url) {
      HEAD(url = url) %>%
        status_code %>%
        equals(404) %>%
        not
    }

    url_ok <- function(url) {
      url_status <- status_code(HEAD(url = url))
      # print(url_status)
      # identical(status_code, 200)
      url_status == 200
    }


    name_by_url %<>%
      rowwise %>%
      mutate(url_ok = url_ok(url))

    name_by_url %>%
      as.data.table %>%
      .[(url_ok)] %>%
      unique(by = c("name", "url")) %>%
      fwrite("./data-raw/name-by-url.csv")

    current_bom_stations <-
      bom_stations %>%
      as.data.table %>%
      .[End == "May 2017", .(Name, Lat, Lon, Site)] %>%
      .[, NAME := toupper(Name)] %>%
      .[, NAME_NO_AIRPORT := gsub(" ((AIRPORT)|(AERO)|(AIRSTRIP))?( AWS)?$", "", NAME)] %>%
      .[, .nomatch := TRUE]

    uniqueDT <- function(...)
      data.table:::unique.data.table(...)

    url_latlon_by_station_name <-
      fread("./data-raw/name-by-url.csv") %>%
      select(name, url) %>%
      as.data.table %>%
      unique %>%
      .[, NAME := toupper(name)] %>%
      merge(current_bom_stations, by = "NAME", all = TRUE) %>%
      .[, NAME_NO_AIRPORT := gsub(" ((AIRPORT)|(AERO)|(AIRSTRIP))?( AWS)?$", "", toupper(name))] %>%
      .[, .nomatch := is.na(Lat)] %>%
      .[] %>%
      merge(
        current_bom_stations[, .(NAME, Lat, Lon, .nomatch)],
        by.x = c(".nomatch", "NAME_NO_AIRPORT"),
        by.y = c(".nomatch", "NAME"),
        all = TRUE
      ) %>%
      .[, Lat := coalesce(Lat.x, Lat.y)] %>%
      .[, Lon := coalesce(Lon.x, Lon.y)] %>%
      .[, c("Lat.x", "Lat.y", "Lon.x", "Lon.y") := NULL] %>%
      .[, .nomatch := is.na(Lat)] %>%
      .[] %>%
      merge(
        current_bom_stations[, .(NAME_NO_AIRPORT, Lat, Lon, .nomatch)],
        by.x = c(".nomatch", "NAME_NO_AIRPORT"),
        by.y = c(".nomatch", "NAME_NO_AIRPORT"),
        all = TRUE
      ) %>%
      .[, Lat := coalesce(Lat.x, Lat.y)] %>%
      .[, Lon := coalesce(Lon.x, Lon.y)] %>%
      .[, c("Lat.x", "Lat.y", "Lon.x", "Lon.y") := NULL] %>%
      .[, .(NAME, name, url, Lat, Lon)] %>%
      .[!is.na(url)] %>%
      unique(by = "name") %>%
      .[order(name)] %T>%
      fwrite("./data-raw/JSONurl-latlon-by-station-name.csv") %>%
      .[]

    # url_latlon_by_station_name %>%
    #   filter(between(Lon, 135, 150),
    #          between(Lat, -39, -34)) %>%
    #   ggplot(aes(Lon, Lat, label = name)) +
    #   geom_point() +
    #   geom_text_repel() +
    #   coord_map() +
    #   theme_map()