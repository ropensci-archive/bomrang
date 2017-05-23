library(httr)
library(dtplyr)
library(dplyr)
library(readr)
library(data.table)
library(stringi)

regenerate_BOM_urls <- FALSE

bom_stations_raw <-
  read_lines("ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/lists_by_element/alpha/alphaAUS_3.txt")

# This file is a pseudo-fixed width file.
# Line three contains the headers at fixed widths

bom_stations_header_line <- bom_stations_raw[3]

write_lines(bom_stations_raw[grep("^ +[0-9]", bom_stations_raw, perl = TRUE)],
            "./data-raw/bom-stations-no-header.txt")

column_widths <- stri_locate_all_boundaries(bom_stations_header_line)

col_names <- stri_split(bom_stations_raw[3], regex = "\\s+")[[1]]

if (FALSE) {
  # You can run these lines to verify the fwf widths
  underline <- rep(" ", nchar(bom_stations_header_line))
  underline[column_widths[[1]][, 1]] <- "."
  underline <- paste0(underline, collapse = "")

  cat(bom_stations_header_line,
      underline, sep = "\n")
}

starts <- column_widths[[1]][, 1]
ends <- column_widths[[1]][, 2]
ends[7] <- ends[7] - 1
starts[8] <- starts[8] - 1

bom_stations <-
  read_fwf("./data-raw/bom-stations-no-header.txt",
           col_positions = fwf_positions(start = starts,
                                         end = ends,
                                         col_names = col_names))

fwrite(bom_stations, "bom_stations.csv")

bom_stations_by_url %>%
  mutate(Name = toupper(name)) %>%
  as.data.table %>%
  unique(by = "Name") %>%
  merge(bom_stations, by = "Name", all.y = TRUE) %>%
  as.data.table %>%
  # Only concerned with those still operating
  .[End == "May 2017" & is.na(url)]

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
                      gsub("[^0-9]", "-", as.character(the_time)),
                      filename))
    }
  }

  # By cursory inspection, the varying part of the url runs from 90000 to 99999.
  # Idea here is to try to retrieve the JSON from each URL. Saving the result if
  # there is such a URL.
  name_by_url <- fread("./data-raw/name-by-url.csv")

  .closure <- function() {
    for (x in 90e3:100e3) {
      .first <- TRUE
      for (STATE in c("V", "N", "Q", "S", "W", "T", "D")) {
        for (y in c("60801", "60901", "60803", "60901", "60903")) {
          url <- paste0("http://www.bom.gov.au/fwo/ID", STATE, y, "/ID", STATE, y, ".", x, ".json")
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
  .[, NAME_NO_AIRPORT := gsub(" ((AIRPORT)|(AWS)|(AERO)|(AIRSTRIP))$", "", NAME)] %>%
  .[, .nomatch := TRUE]

uniqueDT <- function(...) data.table:::unique.data.table(...)

url_latlon_by_station_name <-
  fread("./data-raw/name-by-url.csv") %>%
  select(name, url) %>%
  as.data.table %>%
  unique %>%
  .[, NAME := toupper(name)] %>%
  merge(current_bom_stations, by = "NAME", all = TRUE) %>%
  .[, NAME_NO_AIRPORT := gsub(" ((AIRPORT)|(AWS)|(AERO)|(AIRSTRIP))$", "", toupper(name))] %>%
  .[, .nomatch := is.na(Lat)] %>%
  .[] %>%
  merge(current_bom_stations[, .(NAME, Lat, Lon, .nomatch)],
        by.x = c(".nomatch", "NAME_NO_AIRPORT"),
        by.y = c(".nomatch", "NAME"),
        all = TRUE) %>%
  .[, Lat := coalesce(Lat.x, Lat.y)] %>%
  .[, Lon := coalesce(Lon.x, Lon.y)] %>%
  .[, c("Lat.x", "Lat.y", "Lon.x", "Lon.y") := NULL] %>%
  .[] %>%
  merge(current_bom_stations[, .(NAME_NO_AIRPORT, Lat, Lon, .nomatch)],
        by.x = c(".nomatch", "NAME_NO_AIRPORT"),
        by.y = c(".nomatch", "NAME_NO_AIRPORT"),
        all = TRUE) %>%
  .[, Lat := coalesce(Lat.x, Lat.y)] %>%
  .[, Lon := coalesce(Lon.x, Lon.y)] %>%
  .[, c("Lat.x", "Lat.y", "Lon.x", "Lon.y") := NULL] %>%
  .[, .(NAME, name, url, Lat, Lon)] %>%
  .[!is.na(url)] %>%
  unique(by = "name") %T>%
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

