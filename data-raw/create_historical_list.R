rain <- "http://www.bom.gov.au/climate/data/lists_by_element/alphaAUS_136.txt"

tmax <- "http://www.bom.gov.au/climate/data/lists_by_element/alphaAUS_122.txt"

tmin <- "http://www.bom.gov.au/climate/data/lists_by_element/alphaAUS_123.txt"

solar <- "http://www.bom.gov.au/climate/data/lists_by_element/alphaAUS_193.txt"

i <- rain

ncc <-
  readr::read_table(
    i,
    skip = 4,
    col_names = c(
      "site",
      "name",
      "lat",
      "lon",
      "start_month",
      "start_year",
      "end_month",
      "end_year",
      "years",
      "percent",
      "AWS"
    ),
    col_types = c(
      site = readr::col_integer(),
      name = readr::col_character(),
      lat = readr::col_double(),
      lon = readr::col_double(),
      start_month = readr::col_character(),
      start_year = readr::col_character(),
      end_month = readr::col_character(),
      end_year = readr::col_character(),
      years = readr::col_double(),
      percent = readr::col_integer(),
      AWS = readr::col_character()
    )
  )

# trim the end of the rows off that have extra info that's not in columns
nrows <- nrow(ncc) - 7
ncc <- ncc[1:nrows, ]

# unite month and year, convert to a date and add ncc_obs_code
ncc <- 
  ncc %>% 
  tidyr::unite(start, start_month, start_year, sep = "-") %>% 
  tidyr::unite(end, end_month, end_year, sep = "-") %>% 
  dplyr::mutate(start = lubridate::dmy(paste0("01-", start))) %>% 
  dplyr::mutate(end = lubridate::dmy(paste0("01-", end))) %>% 
  dplyr::mutate(ncc_obs_code = 136)


