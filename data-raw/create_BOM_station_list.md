Get BOM Stations
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
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(readr)

# This file is a pseudo-fixed width file. Line five contains the headers at
# fixed widths which are coded in the read_table() call.
# The last six lines contain other information that we don't want.
# For some reason, reading it directly from the BOM website does not work, so
# we use download.file to fetch it first and then import it from the R tempdir()

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
  "NAME",
  "start",
  "end",
  "Lat",
  "Lon",
  "source",
  "state",
  "height",
  "bar_ht",
  "WMO"
  ),
  col_types = cols(
  site = col_character(),
  dist = col_character(),
  NAME = col_character(),
  start = col_integer(),
  end = col_integer(),
  Lat = col_double(),
  Lon = col_double(),
  source = col_character(),
  state = col_character(),
  height = col_double(),
  bar_ht = col_double(),
  WMO = col_integer()
  ),
  na = c("..")
  )

# trim the end of the rows off that have extra info that's not in columns
nrows <- nrow(bom_stations_raw) - 5
bom_stations_raw <- bom_stations_raw[1:nrows,]

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

# create JSON URLs
bom_stations_raw$url <- NA

bom_stations_raw <-
bom_stations_raw %>%
mutate(url = case_when(
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
))

bom_stations_raw
```

    ## # A tibble: 20,140 x 14
    ##      site  dist                     NAME start   end      Lat      Lon
    ##     <chr> <chr>                    <chr> <int> <int>    <dbl>    <dbl>
    ##  1 001001    01              OOMBULGURRI  1914  2012 -15.1806 127.8456
    ##  2 001002    01              BEVERLEY SP  1959  1967 -16.5825 125.4828
    ##  3 001003    01             PAGO MISSION  1908  1940 -14.1331 126.7158
    ##  4 001004    01                 KUNMUNYA  1915  1948 -15.4167 124.7167
    ##  5 001005    01             WYNDHAM PORT  1886  1995 -15.4644 128.1000
    ##  6 001006    01             WYNDHAM AERO  1951    NA -15.5100 128.1503
    ##  7 001007    01         TROUGHTON ISLAND  1956    NA -13.7542 126.1485
    ##  8 001008    01 MOUNT ELIZABETH OLD SITE  1959  1978 -16.3017 126.1825
    ##  9 001009    01                 KURI BAY  1961  2012 -15.4875 124.5222
    ## 10 001010    01                    THEDA  1965    NA -14.7883 126.4964
    ## # ... with 20,130 more rows, and 7 more variables: source <chr>,
    ## #   state <chr>, height <dbl>, bar_ht <dbl>, WMO <int>, state_code <chr>,
    ## #   url <chr>

Save station metadata
---------------------

Now that we have the dataframe of stations and have generated the URLs for the JSON files for stations providing weather data feeds, save the data as a database for *bomrang* to use.

``` r
JSONurl_latlon_by_station_name <- bom_stations_raw[!is.na(bom_stations_raw$url), ]
devtools::use_data(JSONurl_latlon_by_station_name, overwrite = TRUE)
```

Session Info
------------

``` r
devtools::session_info()
```

    ## Session info -------------------------------------------------------------

    ##  setting  value                       
    ##  version  R version 3.4.0 (2017-04-21)
    ##  system   x86_64, darwin15.6.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2017-05-31

    ## Packages -----------------------------------------------------------------

    ##  package    * version    date       source                       
    ##  assertthat   0.2.0      2017-04-11 CRAN (R 3.4.0)               
    ##  backports    1.1.0      2017-05-22 cran (@1.1.0)                
    ##  base       * 3.4.0      2017-05-11 local                        
    ##  compiler     3.4.0      2017-05-11 local                        
    ##  datasets   * 3.4.0      2017-05-11 local                        
    ##  DBI          0.6-1      2017-04-01 CRAN (R 3.4.0)               
    ##  devtools     1.13.1     2017-05-13 cran (@1.13.1)               
    ##  digest       0.6.12     2017-01-27 CRAN (R 3.4.0)               
    ##  dplyr      * 0.5.0      2016-06-24 CRAN (R 3.4.0)               
    ##  evaluate     0.10       2016-10-11 CRAN (R 3.4.0)               
    ##  graphics   * 3.4.0      2017-05-11 local                        
    ##  grDevices  * 3.4.0      2017-05-11 local                        
    ##  hms          0.3        2016-11-22 CRAN (R 3.4.0)               
    ##  htmltools    0.3.6      2017-04-28 CRAN (R 3.4.0)               
    ##  knitr        1.16       2017-05-18 cran (@1.16)                 
    ##  lazyeval     0.2.0      2016-06-12 CRAN (R 3.4.0)               
    ##  magrittr     1.5        2014-11-22 CRAN (R 3.4.0)               
    ##  memoise      1.1.0      2017-04-21 CRAN (R 3.4.0)               
    ##  methods    * 3.4.0      2017-05-11 local                        
    ##  R6           2.2.1      2017-05-10 cran (@2.2.1)                
    ##  Rcpp         0.12.11    2017-05-22 cran (@0.12.11)              
    ##  readr      * 1.1.1      2017-05-16 cran (@1.1.1)                
    ##  rlang        0.1.1.9000 2017-05-25 Github (hadley/rlang@c351186)
    ##  rmarkdown    1.5        2017-04-26 CRAN (R 3.4.0)               
    ##  rprojroot    1.2        2017-01-16 CRAN (R 3.4.0)               
    ##  stats      * 3.4.0      2017-05-11 local                        
    ##  stringi      1.1.5      2017-04-07 CRAN (R 3.4.0)               
    ##  stringr      1.2.0      2017-02-18 CRAN (R 3.4.0)               
    ##  tibble       1.3.1      2017-05-17 cran (@1.3.1)                
    ##  tools        3.4.0      2017-05-11 local                        
    ##  utils      * 3.4.0      2017-05-11 local                        
    ##  withr        1.0.2      2016-06-20 CRAN (R 3.4.0)               
    ##  yaml         2.1.14     2016-11-12 CRAN (R 3.4.0)
