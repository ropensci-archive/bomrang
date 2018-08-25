Create Databases of BOM Station Locations and JSON URLs
================

This document provides details on methods used to create the database of
BOM JSON files for stations and corresponding metadata, *e.g.*,
latitude, longitude (which are more detailed than what is in the JSON
file), start, end, elevation, etc.

Refer to these BOM pages for more reference:

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
details](ftp://ftp2.bom.gov.au/anon2/home/ncc/metadata/sitelists/stations.zip).

``` r
library(magrittr)

# This file is a pseudo-fixed width file. Line five contains the headers at
# fixed widths which are coded in the read_table() call.
# The last seven lines contain other information that we don't want.
# For some reason, reading it directly from the BOM website does not work, so
# we use download.file to fetch it first and then import it from the R
# tempdir()

curl::curl_download(
  url = "ftp://ftp2.bom.gov.au/anon2/home/ncc/metadata/sitelists/stations.zip",
  destfile = file.path(tempdir(), "stations.zip"))

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
nrows <- nrow(bom_stations_raw) - 7
bom_stations_raw <- bom_stations_raw[1:nrows, ]

# add current year to stations that are still active
bom_stations_raw$end[is.na(bom_stations_raw$end)] <- format(Sys.Date(), "%Y")

bom_stations_raw
```

    ## # A tibble: 19,348 x 11
    ##    site   dist  name      start end     lat   lon state  elev bar_ht   wmo
    ##    <chr>  <chr> <chr>     <int> <chr> <dbl> <dbl> <chr> <dbl>  <dbl> <int>
    ##  1 001000 01    KARUNJIE   1940 1983  -16.3  127. WA    320     NA      NA
    ##  2 001001 01    OOMBULGU…  1914 2012  -15.2  128. WA      2     NA      NA
    ##  3 001002 01    BEVERLEY…  1959 1967  -16.6  125. WA     NA     NA      NA
    ##  4 001003 01    PAGO MIS…  1908 1940  -14.1  127. WA      5     24.4    NA
    ##  5 001004 01    KUNMUNYA   1915 1948  -15.4  125. WA     47     NA      NA
    ##  6 001005 01    WYNDHAM …  1886 1995  -15.5  128. WA     20     NA      NA
    ##  7 001006 01    WYNDHAM …  1951 2018  -15.5  128. WA      3.8    4.3 95214
    ##  8 001007 01    TROUGHTO…  1956 2018  -13.8  126. WA      6      8   94102
    ##  9 001008 01    MOUNT EL…  1959 1978  -16.3  126. WA    640     NA      NA
    ## 10 001009 01    KURI BAY   1961 2012  -15.5  125. WA     12     17      NA
    ## # ... with 19,338 more rows

## Check station locations

Occasionally the stations are listed in the wrong location, *e.g.*,
Alice Springs Airport in SA. Perform quality check to ensure that the
station locations are accurate based on the lat/lon values provided for
the currently reporting stations only.

``` r
bom_stations_current <- subset(bom_stations_raw,
                               end == format(Sys.Date(), "%Y"))

library(ASGS.foyer)
library(data.table)

`%notin%` <- function(x, table) {
  # Same as !(x %in% table)
  match(x, table, nomatch = 0L) == 0L
}

data.table::setDT(bom_stations_current)
latlon2state <- function(lat, lon) {
  ASGS.foyer::latlon2SA(lat, lon, to = "STE", yr = "2016", return = "v")
}

bom_stations_current %>%
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
  .[actual_state != state & state %notin% c("ANT", "ISL"),
    state := actual_state] %>%
  .[, actual_state := NULL]
```

    ## Loading required package: sp

``` r
data.table::setDF(bom_stations_current)
```

## Create state codes

Use the state values extracted from `ASGS.foyer` to set state codes from
BOM rather than the sometimes incorrect `state` column from BOM.

BOM state codes are as follows:

  - IDD - NT,

  - IDN - NSW/ACT,

  - IDQ - Qld,

  - IDS - SA,

  - IDT - Tas/Antarctica,

  - IDV - Vic, and

  - IDW - WA

<!-- end list -->

``` r
bom_stations_current$state_code <- NA
bom_stations_current$state_code[bom_stations_current$state == "WA"] <- "W"
bom_stations_current$state_code[bom_stations_current$state == "QLD"] <- "Q"
bom_stations_current$state_code[bom_stations_current$state == "VIC"] <- "V"
bom_stations_current$state_code[bom_stations_current$state == "NT"] <- "D"
bom_stations_current$state_code[bom_stations_current$state == "TAS" |
                              bom_stations_current$state == "ANT"] <- "T"
bom_stations_current$state_code[bom_stations_current$state == "NSW"] <- "N"
bom_stations_current$state_code[bom_stations_current$state == "SA"] <- "S"
```

## Generate station URLs

``` r
stations_site_list <-
  bom_stations_current %>%
  dplyr::select(site:wmo, state, state_code) %>%
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
```

## Save data

Now that we have the data frame of stations and have generated the URLs
for the JSON files for stations providing weather data feeds, save the
data as a database for *bomrang* to use.

There are weather stations that do have a WMO but don’t report online,
e.g., KIRIBATI NTC AWS or MARSHALL ISLANDS NTC AWS, in this section
remove these from the list and then create a database for use with the
current weather information from BOM.

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
in the XML file that holds the bulletin information. Lastly, create the
database for use in the package.

``` r
stations_site_list <-
  stations_site_list %>%
  dplyr::select(-state_code, -url) %>% 
  as.data.frame()

stations_site_list$site <-
  gsub("^0{1,2}", "", stations_site_list$site)

save(stations_site_list,
     file = "../inst/extdata/current_stations_site_list.rda",
     compress = "bzip2")
```

## Session Info

    ## ─ Session info ──────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 3.5.1 (2018-07-02)
    ##  os       macOS High Sierra 10.13.6   
    ##  system   x86_64, darwin17.7.0        
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2018-08-26                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version date       source                            
    ##  ASGS.foyer  * 0.2.1   2018-05-17 CRAN (R 3.5.1)                    
    ##  assertthat    0.2.0   2017-04-11 CRAN (R 3.5.1)                    
    ##  backports     1.1.2   2017-12-13 CRAN (R 3.5.1)                    
    ##  bindr         0.1.1   2018-03-13 CRAN (R 3.5.1)                    
    ##  bindrcpp    * 0.2.2   2018-03-29 CRAN (R 3.5.1)                    
    ##  cli           1.0.0   2017-11-05 CRAN (R 3.5.1)                    
    ##  clisymbols    1.2.0   2017-05-21 CRAN (R 3.5.1)                    
    ##  colorout    * 1.2-0   2018-08-16 Github (jalvesaq/colorout@cc5fbfa)
    ##  crayon        1.3.4   2017-09-16 CRAN (R 3.5.1)                    
    ##  curl          3.2     2018-03-28 CRAN (R 3.5.1)                    
    ##  data.table  * 1.11.4  2018-05-27 CRAN (R 3.5.1)                    
    ##  digest        0.6.16  2018-08-22 cran (@0.6.16)                    
    ##  dplyr         0.7.6   2018-06-29 CRAN (R 3.5.1)                    
    ##  evaluate      0.11    2018-07-17 CRAN (R 3.5.1)                    
    ##  fansi         0.3.0   2018-08-13 CRAN (R 3.5.1)                    
    ##  glue          1.3.0   2018-07-17 CRAN (R 3.5.1)                    
    ##  hms           0.4.2   2018-03-10 CRAN (R 3.5.1)                    
    ##  htmltools     0.3.6   2017-04-28 CRAN (R 3.5.1)                    
    ##  httr          1.3.1   2017-08-20 CRAN (R 3.5.1)                    
    ##  knitr         1.20    2018-02-20 CRAN (R 3.5.1)                    
    ##  lattice       0.20-35 2017-03-25 CRAN (R 3.5.1)                    
    ##  magrittr    * 1.5     2014-11-22 CRAN (R 3.5.1)                    
    ##  pillar        1.3.0   2018-07-14 CRAN (R 3.5.1)                    
    ##  pkgconfig     2.0.2   2018-08-16 CRAN (R 3.5.1)                    
    ##  purrr         0.2.5   2018-05-29 CRAN (R 3.5.1)                    
    ##  R6            2.2.2   2017-06-17 CRAN (R 3.5.1)                    
    ##  Rcpp          0.12.18 2018-07-23 CRAN (R 3.5.1)                    
    ##  readr         1.1.1   2017-05-16 CRAN (R 3.5.1)                    
    ##  rlang         0.2.2   2018-08-16 CRAN (R 3.5.1)                    
    ##  rmarkdown     1.10    2018-06-11 CRAN (R 3.5.1)                    
    ##  rprojroot     1.3-2   2018-01-03 CRAN (R 3.5.1)                    
    ##  sessioninfo   1.0.0   2017-06-21 CRAN (R 3.5.1)                    
    ##  sp          * 1.3-1   2018-06-05 CRAN (R 3.5.1)                    
    ##  stringi       1.2.4   2018-07-20 CRAN (R 3.5.1)                    
    ##  stringr       1.3.1   2018-05-10 CRAN (R 3.5.1)                    
    ##  tibble        1.4.2   2018-01-22 CRAN (R 3.5.1)                    
    ##  tidyselect    0.2.4   2018-02-26 CRAN (R 3.5.1)                    
    ##  utf8          1.1.4   2018-05-24 CRAN (R 3.5.1)                    
    ##  withr         2.1.2   2018-03-15 CRAN (R 3.5.1)                    
    ##  yaml          2.2.0   2018-07-25 CRAN (R 3.5.1)
