Build BOM Station Locations and JSON URL Database
================

This document provides details on methods used to create the database of BOM JSON files for stations and corresponding metadata, e.g., latitude, longitude (which are more detailed than what is in the JSON file), start, end, elevation, etc.

Refer to these BOM pages for more reference:
- <http://www.bom.gov.au/inside/itb/dm/idcodes/struc.shtml>
- <http://reg.bom.gov.au/catalogue/data-feeds.shtml>
- <http://reg.bom.gov.au/catalogue/anon-ftp.shtml>
- <http://www.bom.gov.au/climate/cdo/about/site-num.shtml>

Product code definitions
------------------------

### States

-   IDD - NT
-   IDN - NSW/ACT
-   IDQ - Qld
-   IDS - SA
-   IDT - Tas/Antarctica (distinguished by the product number)
-   IDV - Vic
-   IDW - WA

### Product code numbers

-   60701 - coastal observations (duplicated in 60801)
-   60801 - all weather observations (we will use this)
-   60803 - Antarctica weather observations (and use this, this distinguishes Tas from Antarctica)
-   60901 - capital city weather observations (duplicated in 60801)
-   60903 - Canberra area weather observations (duplicated in 60801)

Get station metadata
--------------------

``` r
library(magrittr)

# This file is a pseudo-fixed width file. Line five contains the headers at
# fixed widths which are coded in the read_table() call.
# The last six lines contain other information that we don't want.
# For some reason, reading it directly from the BOM website does not work, so
# we use download.file to fetch it first and then import it from the R tempdir()

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

  # return only current stations listing
  stations_site_list <-
  stations_site_list[is.na(stations_site_list$end),]
  stations_site_list$end <- format(Sys.Date(), "%Y")

stations_site_list
```

    ## # A tibble: 7,434 x 14
    ##      site  dist             name start   end      Lat      Lon source
    ##     <chr> <chr>            <chr> <int> <chr>    <dbl>    <dbl>  <chr>
    ##  1 001006    01     WYNDHAM AERO  1951  2017 -15.5100 128.1503    GPS
    ##  2 001007    01 TROUGHTON ISLAND  1956  2017 -13.7542 126.1485    GPS
    ##  3 001010    01            THEDA  1965  2017 -14.7883 126.4964    GPS
    ##  4 001013    01          WYNDHAM  1968  2017 -15.4869 128.1236    GPS
    ##  5 001014    01       EMMA GORGE  1998  2017 -15.9083 128.1286  .....
    ##  6 001018    01  MOUNT ELIZABETH  1973  2017 -16.4181 126.1025    GPS
    ##  7 001019    01        KALUMBURU  1997  2017 -14.2964 126.6453    GPS
    ##  8 001020    01         TRUSCOTT  1944  2017 -14.0900 126.3867    GPS
    ##  9 001023    01       EL QUESTRO  1967  2017 -16.0086 127.9806    GPS
    ## 10 001024    01        ELLENBRAE  1986  2017 -15.9572 127.0628    GPS
    ## # ... with 7,424 more rows, and 6 more variables: state <chr>, elev <dbl>,
    ## #   bar_ht <dbl>, WMO <int>, state_code <chr>, url <chr>

Save data
---------

Now that we have the dataframe of stations and have generated the URLs for the JSON files for stations providing weather data feeds, save the data as a database for *bomrang* to use.

There are weather stations that do have a WMO but don't report online, e.g., KIRIBATI NTC AWS or MARSHALL ISLANDS NTC AWS, in this section remove these from the list and then create a database for use with the current weather information from BOM.

### Save JSON URL database for `get_current_weather()`

``` r
JSONurl_latlon_by_station_name <-
  stations_site_list[!is.na(stations_site_list$url), ]
  
JSONurl_latlon_by_station_name <-
  JSONurl_latlon_by_station_name %>%
  dplyr::rowwise() %>%
  dplyr::mutate(url = dplyr::if_else(httr::http_error(url), NA_character_, url))

JSONurl_latlon_by_station_name <-
    data.table::data.table(bom_stations_raw[!is.na(stations_site_list$url),])
  
devtools::use_data(JSONurl_latlon_by_station_name, overwrite = TRUE)
```

### Save station location data for `get_ag_bulletin()`

First, rename columns and drop a few that aren't necessary for the ag bulletin information. Then pad the `site` field with 0 to match the data in the XML file that holds the bulletin information.

Lastly, create the database for use in the package.

``` r
stations_site_list <-
  stations_site_list %>%
  dplyr::rename(lat = Lat,
  lon = Lon) %>%
  dplyr::select(-state_code, -source, -url)

stations_site_list$site <-
  gsub("^0{1,2}", "", stations_site_list$site)

devtools::use_data(stations_site_list, overwrite = TRUE)
```

Session Info
------------

``` r
devtools::session_info()
```

    ## Session info -------------------------------------------------------------

    ##  setting  value                       
    ##  version  R version 3.4.0 (2017-04-21)
    ##  system   x86_64, darwin16.5.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2017-06-03

    ## Packages -----------------------------------------------------------------

    ##  package    * version    date       source                       
    ##  assertthat   0.2.0      2017-04-11 CRAN (R 3.4.0)               
    ##  backports    1.1.0      2017-05-22 cran (@1.1.0)                
    ##  base       * 3.4.0      2017-05-05 local                        
    ##  compiler     3.4.0      2017-05-05 local                        
    ##  curl         2.6        2017-04-27 CRAN (R 3.4.0)               
    ##  data.table   1.10.4     2017-02-01 CRAN (R 3.4.0)               
    ##  datasets   * 3.4.0      2017-05-05 local                        
    ##  DBI          0.6-1      2017-04-01 CRAN (R 3.4.0)               
    ##  devtools     1.13.2     2017-06-02 cran (@1.13.2)               
    ##  digest       0.6.12     2017-01-27 CRAN (R 3.4.0)               
    ##  dplyr        0.5.0      2016-06-24 CRAN (R 3.4.0)               
    ##  evaluate     0.10       2016-10-11 CRAN (R 3.4.0)               
    ##  graphics   * 3.4.0      2017-05-05 local                        
    ##  grDevices  * 3.4.0      2017-05-05 local                        
    ##  hms          0.3        2016-11-22 CRAN (R 3.4.0)               
    ##  htmltools    0.3.6      2017-04-28 CRAN (R 3.4.0)               
    ##  httr         1.2.1      2016-07-03 CRAN (R 3.4.0)               
    ##  knitr        1.16       2017-05-18 cran (@1.16)                 
    ##  lazyeval     0.2.0      2016-06-12 CRAN (R 3.4.0)               
    ##  magrittr   * 1.5        2014-11-22 CRAN (R 3.4.0)               
    ##  memoise      1.1.0      2017-04-21 CRAN (R 3.4.0)               
    ##  methods    * 3.4.0      2017-05-05 local                        
    ##  R6           2.2.1      2017-05-10 CRAN (R 3.4.0)               
    ##  Rcpp         0.12.11    2017-05-22 cran (@0.12.11)              
    ##  readr        1.1.1      2017-05-16 cran (@1.1.1)                
    ##  rlang        0.1.1.9000 2017-05-27 Github (hadley/rlang@c351186)
    ##  rmarkdown    1.5        2017-04-26 CRAN (R 3.4.0)               
    ##  rprojroot    1.2        2017-01-16 CRAN (R 3.4.0)               
    ##  stats      * 3.4.0      2017-05-05 local                        
    ##  stringi      1.1.5      2017-04-07 CRAN (R 3.4.0)               
    ##  stringr      1.2.0      2017-02-18 CRAN (R 3.4.0)               
    ##  tibble       1.3.3      2017-05-28 CRAN (R 3.4.0)               
    ##  tools        3.4.0      2017-05-05 local                        
    ##  utils      * 3.4.0      2017-05-05 local                        
    ##  withr        1.0.2      2016-06-20 CRAN (R 3.4.0)               
    ##  yaml         2.1.14     2016-11-12 CRAN (R 3.4.0)
