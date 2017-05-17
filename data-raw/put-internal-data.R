library(data.table)
library(magrittr)

station_name_by_url <-
  fread("./data-raw/name-by-url.csv", key = "name") %>%
  .[name != "AAAA"] %>%
  unique(by = "name") %>%
  setnames("name", "station_name")

devtools::use_data(station_name_by_url, internal = TRUE)

