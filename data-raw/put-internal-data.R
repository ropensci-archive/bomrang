library(data.table)
library(magrittr)

JSONurl_latlon_by_station_name <-
  fread("./data-raw/JSONurl-latlon-by-station-name.csv")

devtools::use_data(JSONurl_latlon_by_station_name, internal = TRUE, overwrite = TRUE)

