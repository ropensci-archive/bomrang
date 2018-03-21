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
      "NULL2",
      "state",
      "elev",
      "bar_ht",
      "wmo"
    )
  )
```

    ## Parsed with column specification:
    ## cols(
    ##   site = col_character(),
    ##   dist = col_character(),
    ##   name = col_character(),
    ##   start = col_integer(),
    ##   end = col_integer(),
    ##   lat = col_double(),
    ##   lon = col_double(),
    ##   NULL1 = col_character(),
    ##   NULL2 = col_character(),
    ##   state = col_character(),
    ##   elev = col_double(),
    ##   bar_ht = col_double(),
    ##   wmo = col_integer()
    ## )

``` r
# remove extra columns for source of location
bom_stations_raw <- bom_stations_raw[, -c(8:9)]

# trim the end of the rows off that have extra info that's not in columns
nrows <- nrow(bom_stations_raw) - 6
bom_stations_raw <- bom_stations_raw[1:nrows, ]

# return only current stations listing
bom_stations_raw <-
  bom_stations_raw[is.na(bom_stations_raw$end), ]
bom_stations_raw$end <- format(Sys.Date(), "%Y")

bom_stations_raw
```

    ## # A tibble: 7,320 x 11
    ##    site   dist  name     start end     lat   lon state   elev bar_ht   wmo
    ##    <chr>  <chr> <chr>    <int> <chr> <dbl> <dbl> <chr>  <dbl>  <dbl> <int>
    ##  1 001006 01    WYNDHAM…  1951 2018  -15.5  128. WA      3.80   4.30 95214
    ##  2 001007 01    TROUGHT…  1956 2018  -13.8  126. WA      6.00   8.00 94102
    ##  3 001010 01    THEDA     1965 2018  -14.8  126. WA    210.    NA       NA
    ##  4 001013 01    WYNDHAM   1968 2018  -15.5  128. WA     11.0   NA       NA
    ##  5 001014 01    EMMA GO…  1998 2018  -15.9  128. WA    130.    NA       NA
    ##  6 001018 01    MOUNT E…  1973 2018  -16.4  126. WA    546.   547.   94211
    ##  7 001019 01    KALUMBU…  1997 2018  -14.3  127. WA     23.0   24.0  94100
    ##  8 001020 01    TRUSCOTT  1944 2018  -14.1  126. WA     51.0   52.5  95101
    ##  9 001023 01    EL QUES…  1967 2018  -16.0  128. WA     90.0   NA       NA
    ## 10 001024 01    ELLENBR…  1986 2018  -16.0  127. WA    300.    NA       NA
    ## # ... with 7,310 more rows

## Check that station locations

Occasionally the stations are listed in the wrong location, e.g. Alice
Springs Airport in SA. Perform quality check to ensure that the station
locations are accurate based on the lat/lon values provided.

``` r
library(sf)
```

    ## Linking to GEOS 3.6.2, GDAL 2.2.3, proj.4 5.0.0

``` r
library(raster)
```

    ## Loading required package: sp

    ## 
    ## Attaching package: 'raster'

    ## The following object is masked from 'package:magrittr':
    ## 
    ##     extract

``` r
points <- st_as_sf(x = bom_stations_raw, 
                   coords = c("lon", "lat"),
                   crs = "+proj=longlat +datum=WGS84") %>%
  st_transform(., 3576)

Oz <- st_as_sf(raster::getData(name = "GADM",
                               country = "AUS",
                               level = 1)) %>% 
  st_transform(., 3576)

# check which state points fall in
bom_locations <- 
  st_join(points, Oz)

# join the new data from checking points with the BOM data
bom_locations <- dplyr::full_join(bom_stations_raw, bom_locations)
```

    ## Joining, by = c("site", "dist", "name", "start", "end", "state", "elev", "bar_ht", "wmo")

## Create state codes

Using the state values extracted from GADM to set state codes from BOM
rather than the sometimes incorrect `state` column from BOM.

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
# rename original state column from BOM and keep for reference
bom_locations$org_state <- bom_locations$state

# create new list of corrected state abbreviations based on spatial check
bom_locations$state <- substr(bom_locations$HASC_1, 4, 5)

# recode states from two to three letters where needed
bom_locations$state[bom_locations$state == "QL"] <- "QLD"
bom_locations$state[bom_locations$state == "VI"] <- "VIC"
bom_locations$state[bom_locations$state == "TS"] <- "TAS"
bom_locations$state[bom_locations$state == "NS"] <- "NSW"
bom_locations$state[bom_locations$state == "CT"] <- "ACT"

# fill any states not present in corrected set
bom_locations$state[is.na(bom_locations$state)] <- 
  bom_locations$state[is.na(bom_locations$state)]

# replace state values with state code to generate URLs
bom_locations$state_code <- NA
bom_locations$state_code[bom_locations$state == "WA"] <- "W"
bom_locations$state_code[bom_locations$state == "QL" |
                           bom_locations$state == "QLD"] <- "Q"
bom_locations$state_code[bom_locations$state == "VI" |
                           bom_locations$state == "VIC"] <- "V"
bom_locations$state_code[bom_locations$state == "NT"] <- "D"
bom_locations$state_code[bom_locations$state == "TS" |
                           bom_locations$state == "TAS"] <- "T"
bom_locations$state_code[bom_locations$state == "NS" |
                           bom_locations$state == "NSW"] <- "N"
bom_locations$state_code[bom_locations$state == "SA"] <- "S"
bom_locations$state_code[bom_locations$state == "ANT"] <- "T"

# generate URLs
stations_site_list <-
  bom_locations %>%
  dplyr::select(site:wmo, org_state, state, state_code) %>%
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
in the XML file that holds the bulletin information. Lastly, create the
database for use in the package.

``` r
stations_site_list <-
  stations_site_list %>%
  dplyr::select(-state_code, -url) %>% 
  as.data.frame()

stations_site_list$site <-
  gsub("^0{1,2}", "", stations_site_list$site)

  save(stations_site_list, file = "../inst/extdata/stations_site_list.rda",
     compress = "bzip2")
```

# Cleanup

``` r
unlink("GADM_2.8_AUS_adm1.rds")
```

## Session Info

    ## ─ Session info ──────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 3.4.4 (2018-03-15)
    ##  os       macOS High Sierra 10.13.3   
    ##  system   x86_64, darwin17.4.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2018-03-21                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version    date      
    ##  assertthat    0.2.0      2017-04-11
    ##  backports     1.1.2      2017-12-13
    ##  bindr         0.1.1      2018-03-13
    ##  bindrcpp    * 0.2        2017-06-17
    ##  class         7.3-14     2015-08-30
    ##  classInt      0.1-24     2017-04-16
    ##  cli           1.0.0      2017-11-05
    ##  clisymbols    1.2.0      2017-11-07
    ##  crayon        1.3.4      2017-09-16
    ##  curl          3.1        2017-12-12
    ##  data.table    1.10.4-3   2017-10-27
    ##  DBI           0.8        2018-03-02
    ##  digest        0.6.15     2018-01-28
    ##  dplyr         0.7.4      2017-09-28
    ##  e1071         1.6-8      2017-02-02
    ##  evaluate      0.10.1     2017-06-24
    ##  glue          1.2.0      2017-10-29
    ##  hms           0.4.2      2018-03-10
    ##  htmltools     0.3.6      2017-04-28
    ##  httr          1.3.1      2017-08-20
    ##  knitr         1.20       2018-02-20
    ##  lattice       0.20-35    2017-03-25
    ##  magrittr    * 1.5        2014-11-22
    ##  pillar        1.2.1      2018-02-27
    ##  pkgconfig     2.0.1      2017-03-21
    ##  R6            2.2.2      2017-06-17
    ##  raster      * 2.6-7      2017-11-13
    ##  Rcpp          0.12.16    2018-03-13
    ##  readr         1.1.1      2017-05-16
    ##  rlang         0.2.0.9000 2018-03-21
    ##  rmarkdown     1.9.5      2018-03-21
    ##  rprojroot     1.3-2      2018-01-03
    ##  sessioninfo   1.0.0      2017-06-21
    ##  sf          * 0.6-0      2018-01-06
    ##  sp          * 1.2-7      2018-01-19
    ##  stringi       1.1.7      2018-03-12
    ##  stringr       1.3.0      2018-02-19
    ##  tibble        1.4.2      2018-01-22
    ##  udunits2      0.13       2016-11-17
    ##  units         0.5-1      2018-01-08
    ##  utf8          1.1.3      2018-01-03
    ##  withr         2.1.2      2018-03-21
    ##  yaml          2.1.18     2018-03-08
    ##  source                                 
    ##  CRAN (R 3.4.1)                         
    ##  cran (@1.1.2)                          
    ##  cran (@0.1.1)                          
    ##  CRAN (R 3.4.1)                         
    ##  CRAN (R 3.4.4)                         
    ##  cran (@0.1-24)                         
    ##  cran (@1.0.0)                          
    ##  Github (gaborcsardi/clisymbols@e49b4f5)
    ##  cran (@1.3.4)                          
    ##  cran (@3.1)                            
    ##  cran (@1.10.4-)                        
    ##  cran (@0.8)                            
    ##  cran (@0.6.15)                         
    ##  cran (@0.7.4)                          
    ##  cran (@1.6-8)                          
    ##  CRAN (R 3.4.1)                         
    ##  cran (@1.2.0)                          
    ##  cran (@0.4.2)                          
    ##  CRAN (R 3.4.1)                         
    ##  CRAN (R 3.4.3)                         
    ##  cran (@1.20)                           
    ##  CRAN (R 3.4.4)                         
    ##  CRAN (R 3.4.1)                         
    ##  cran (@1.2.1)                          
    ##  CRAN (R 3.4.1)                         
    ##  CRAN (R 3.4.1)                         
    ##  cran (@2.6-7)                          
    ##  cran (@0.12.16)                        
    ##  CRAN (R 3.4.1)                         
    ##  Github (tidyverse/rlang@1b81816)       
    ##  Github (rstudio/rmarkdown@b73f4ce)     
    ##  cran (@1.3-2)                          
    ##  CRAN (R 3.4.2)                         
    ##  CRAN (R 3.4.3)                         
    ##  cran (@1.2-7)                          
    ##  cran (@1.1.7)                          
    ##  cran (@1.3.0)                          
    ##  cran (@1.4.2)                          
    ##  CRAN (R 3.4.1)                         
    ##  cran (@0.5-1)                          
    ##  CRAN (R 3.4.3)                         
    ##  Github (jimhester/withr@79d7b0d)       
    ##  cran (@2.1.18)
