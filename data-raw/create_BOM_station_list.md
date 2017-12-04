Create Databases of BoM Station Locations and JSON URLs
================

This document provides details on methods used to create the database of
BoM JSON files for stations and corresponding metadata, *e.g.*,
latitude, longitude (which are more detailed than what is in the JSON
file), start, end, elevation, etc.

Refer to these BoM pages for more reference:

  - <http://www.bom.gov.au/inside/itb/dm/idcodes/struc.shtml>

  - <http://reg.bom.gov.au/catalogue/data-feeds.shtml>

  - <http://reg.bom.gov.au/catalogue/anon-ftp.shtml>

  - <http://www.bom.gov.au/climate/cdo/about/site-num.shtml>

## Product code definitions

### States

  - IDD - NT

  - IDN - NSW/ACT

  - IDQ - Qld

  - IDS - SA

  - IDT - Tas/Antarctica (distinguished by the product number)

  - IDV - Vic

  - IDW - WA

### Product code numbers

  - 60701 - coastal observations (duplicated in 60801)

  - 60801 - all weather observations (we will use this)

  - 60803 - Antarctica weather observations (and use this, this
    distinguishes Tas from Antarctica)

  - 60901 - capital city weather observations (duplicated in 60801)

  - 60903 - Canberra area weather observations (duplicated in 60801)

## Get station metadata

The station metadata are downloaded from a zip file linked from the
“[Bureau of Meteorology Site
Numbers](http://www.bom.gov.au/climate/cdo/about/site-num.shtml)”
website. The zip file may be directly downloaded, [file of site
details](ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/sitelists/stations.zip).

``` r
library(magrittr)

# This file is a pseudo-fixed width file. Line five contains the headers at
# fixed widths which are coded in the read_table() call.
# The last six lines contain other information that we don't want.
# For some reason, reading it directly from the BoM website does not work, so
# we use download.file to fetch it first and then import it from the R
# tempdir()

  curl::curl_download(
    url = "ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/sitelists/stations.zip",
                      destfile = file.path(tempdir(), "stations.zip"))

  bom_stations_raw <-
    readr::read_fwf(
    file.path(tempdir(), "stations.zip"),
    skip = 4,
    readr::fwf_positions(
    c(1, 9, 15, 56, 64, 72, 81, 91, 106, 110, 121, 130),
    c(8, 14, 55, 63, 71, 80, 90, 105, 109, 120, 129, 136),
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
    )),
    col_types = c("ccciiddccddi"),
    na = c("..", ".....")
    )
```

    ## Warning in rbind(names(probs), probs_f): number of columns of result is not
    ## a multiple of vector length (arg 1)

    ## Warning: 19356 parsing failures.
    ## row # A tibble: 5 x 5 col     row   col expected actual expected   <int> <chr>    <chr>  <chr> actual 1     1   wmo  7 chars      6 file 2     2   wmo  7 chars      6 row 3     3   wmo  7 chars      6 col 4     4   wmo  7 chars      6 expected 5     5   wmo  7 chars      6 actual # ... with 1 more variables: file <chr>
    ## ... ................. ... ............................. ........ ............................. ...... ............................. .... ............................. ... ............................. ... ............................. ........ ............................. ...... .......................................
    ## See problems(...) for more details.

``` r
    # trim the end of the rows off that have extra info that's not in columns
  nrows <- nrow(bom_stations_raw) - 6
  bom_stations_raw <- bom_stations_raw[1:nrows, ]

  # recode the states to match product codes
  # IDD - NT,
  # IDN - NSW/ACT,
  # IDQ - Qld,
  # IDS - SA,
  # IDT - Tas/Antarctica,
  # IDV - Vic, IDW - WA

  bom_stations_raw$state_code <- NA
  bom_stations_raw$state_code[bom_stations_raw$state == "WA"] <- "W"
  bom_stations_raw$state_code[bom_stations_raw$state == "QLD"] <- "Q"
  bom_stations_raw$state_code[bom_stations_raw$state == "VIC"] <- "V"
  bom_stations_raw$state_code[bom_stations_raw$state == "NT"] <- "D"
  bom_stations_raw$state_code[bom_stations_raw$state == "TAS" |
                              bom_stations_raw$state == "ANT"] <- "T"
  bom_stations_raw$state_code[bom_stations_raw$state == "NSW"] <- "N"
  bom_stations_raw$state_code[bom_stations_raw$state == "SA"] <- "S"

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

stations_site_list
```

    ## # A tibble: 7,347 x 14
    ##      site  dist             name start   end      lat      lon source
    ##     <chr> <chr>            <chr> <int> <chr>    <dbl>    <dbl>  <chr>
    ##  1 001006    01     WYNDHAM AERO  1951  2017 -15.5100 128.1503    GPS
    ##  2 001007    01 TROUGHTON ISLAND  1956  2017 -13.7542 126.1485    GPS
    ##  3 001010    01            THEDA  1965  2017 -14.7883 126.4964    GPS
    ##  4 001013    01          WYNDHAM  1968  2017 -15.4869 128.1236    GPS
    ##  5 001014    01       EMMA GORGE  1998  2017 -15.9083 128.1286   <NA>
    ##  6 001018    01  MOUNT ELIZABETH  1973  2017 -16.4181 126.1025    GPS
    ##  7 001019    01        KALUMBURU  1997  2017 -14.2964 126.6453    GPS
    ##  8 001020    01         TRUSCOTT  1944  2017 -14.0900 126.3867    GPS
    ##  9 001023    01       EL QUESTRO  1967  2017 -16.0086 127.9806    GPS
    ## 10 001024    01        ELLENBRAE  1986  2017 -15.9572 127.0628    GPS
    ## # ... with 7,337 more rows, and 6 more variables: state <chr>, elev <dbl>,
    ## #   bar_ht <dbl>, wmo <int>, state_code <chr>, url <chr>

## Save data

Now that we have the data frame of stations and have generated the URLs
for the JSON files for stations providing weather data feeds, save the
data as a database for *bomrang* to use.

There are weather stations that do have a WMO but don’t report online,
e.g., KIRIBATI NTC AWS or MARSHALL ISLANDS NTC AWS, in this section
remove these from the list and then create a database for use with the
current weather information from BoM.

### Save JSON URL database for `get_current_weather()`

``` r
JSONurl_site_list <-
  stations_site_list[!is.na(stations_site_list$url), ]

JSONurl_site_list <-
  JSONurl_site_list %>%
  dplyr::rowwise() %>%
  dplyr::mutate(url = dplyr::if_else(httr::http_error(url), NA_character_, url))
  
# Remove new NA values from invalid URLs and convert to data.table
JSONurl_site_list <-
  data.table::data.table(stations_site_list[!is.na(stations_site_list$url), ])

 if (!dir.exists("../inst/extdata")) {
      dir.create("../inst/extdata", recursive = TRUE)
    }

# Save database
  save(JSONurl_site_list,
       file = "../inst/extdata/JSONurl_site_list.rda",
     compress = "bzip2")
```

### Save station location data for `get_ag_bulletin()`

First, rename columns and drop a few that aren’t necessary for the ag
bulletin information. Then pad the `site` field with 0 to match the data
in the XML file that holds the bulletin information.

Lastly, create the database for use in the package.

``` r
stations_site_list <-
  stations_site_list %>%
  dplyr::select(-state_code, -source, -url) %>% 
  as.data.frame()

stations_site_list$site <-
  gsub("^0{1,2}", "", stations_site_list$site)

  save(stations_site_list, file = "../inst/extdata/stations_site_list.rda",
     compress = "bzip2")
```

## Session Info

    ## ─ Session info ──────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 3.4.3 (2017-11-30)
    ##  os       macOS Sierra 10.12.6        
    ##  system   x86_64, darwin16.7.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2017-12-04                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version    date      
    ##  assertthat    0.2.0      2017-04-11
    ##  backports     1.1.1      2017-09-25
    ##  bindr         0.1        2016-11-13
    ##  bindrcpp    * 0.2        2017-06-17
    ##  clisymbols    1.2.0      2017-11-07
    ##  curl          3.0        2017-10-06
    ##  data.table    1.10.4-3   2017-10-27
    ##  digest        0.6.12     2017-01-27
    ##  dplyr         0.7.4      2017-09-28
    ##  evaluate      0.10.1     2017-06-24
    ##  glue          1.2.0      2017-10-29
    ##  hms           0.4.0      2017-11-23
    ##  htmltools     0.3.6      2017-04-28
    ##  httr          1.3.1      2017-08-20
    ##  knitr         1.17       2017-08-10
    ##  magrittr    * 1.5        2014-11-22
    ##  pkgconfig     2.0.1      2017-03-21
    ##  R6            2.2.2      2017-06-17
    ##  Rcpp          0.12.14    2017-11-23
    ##  readr         1.1.1      2017-05-16
    ##  rlang         0.1.4.9000 2017-12-01
    ##  rmarkdown     1.8.3      2017-11-26
    ##  rprojroot     1.2        2017-01-16
    ##  sessioninfo   1.0.0      2017-06-21
    ##  stringi       1.1.6      2017-11-17
    ##  stringr       1.2.0      2017-02-18
    ##  tibble        1.3.4      2017-08-22
    ##  withr         2.1.0.9000 2017-11-26
    ##  yaml          2.1.14     2016-11-12
    ##  source                                 
    ##  CRAN (R 3.4.1)                         
    ##  cran (@1.1.1)                          
    ##  CRAN (R 3.4.1)                         
    ##  CRAN (R 3.4.1)                         
    ##  Github (gaborcsardi/clisymbols@e49b4f5)
    ##  cran (@3.0)                            
    ##  cran (@1.10.4-)                        
    ##  CRAN (R 3.4.1)                         
    ##  cran (@0.7.4)                          
    ##  CRAN (R 3.4.1)                         
    ##  cran (@1.2.0)                          
    ##  cran (@0.4.0)                          
    ##  CRAN (R 3.4.1)                         
    ##  CRAN (R 3.4.1)                         
    ##  CRAN (R 3.4.2)                         
    ##  CRAN (R 3.4.1)                         
    ##  CRAN (R 3.4.1)                         
    ##  CRAN (R 3.4.1)                         
    ##  cran (@0.12.14)                        
    ##  CRAN (R 3.4.1)                         
    ##  Github (tidyverse/rlang@f96007e)       
    ##  Github (rstudio/rmarkdown@07f7d8e)     
    ##  CRAN (R 3.4.1)                         
    ##  CRAN (R 3.4.2)                         
    ##  cran (@1.1.6)                          
    ##  CRAN (R 3.4.1)                         
    ##  cran (@1.3.4)                          
    ##  Github (jimhester/withr@fe81c00)       
    ##  CRAN (R 3.4.1)
