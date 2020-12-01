Create Databases of BOM Station Locations and JSON URLs
================

This document provides details on methods used to create the database of
BOM JSON files for stations and corresponding metadata, *e.g.*,
latitude, longitude (which are more detailed than what is in the JSON
file), start, end, elevation, etc.

Refer to these BOM pages for more reference:

-   <http://www.bom.gov.au/inside/itb/dm/idcodes/struc.shtml>

-   <http://reg.bom.gov.au/catalogue/data-feeds.shtml>

-   <http://reg.bom.gov.au/catalogue/anon-ftp.shtml>

-   <http://www.bom.gov.au/climate/cdo/about/site-num.shtml>

## Product code definitions

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

-   60801 - State weather observations excluding Canberra

-   60803 - Antarctica weather observations

-   60901 - capital city weather observations (duplicated in 60801)

-   60903 - Canberra area weather observations

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
# The last seven lines contain other information that we don't want.
# For some reason, reading it directly from the BOM website does not work, so
# we use curl to fetch it first and then import it from the R tempdir()

curl::curl_download(
  url = "ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/sitelists/stations.zip",
  destfile = file.path(tempdir(), "stations.zip"),
  mode = "wb",
  quiet = TRUE)

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
nrows <- nrow(bom_stations_raw) - 3
bom_stations_raw <- bom_stations_raw[1:nrows, ]

# add current year to stations that are still active
bom_stations_raw["end"][is.na(bom_stations_raw["end"])] <- 
    as.double(format(Sys.Date(), "%Y"))

# keep only currently reporting stations
bom_stations_raw <- 
  bom_stations_raw[bom_stations_raw$end == format(Sys.Date(), "%Y"), ] %>% 
  dplyr::mutate(start = as.integer(start),
                end = as.integer(end))

str(bom_stations_raw)
```

    ## tibble [6,842 × 11] (S3: tbl_df/tbl/data.frame)
    ##  $ site  : chr [1:6842] "001006" "001007" "001010" "001013" ...
    ##  $ dist  : chr [1:6842] "01" "01" "01" "01" ...
    ##  $ name  : chr [1:6842] "WYNDHAM AERO" "TROUGHTON ISLAND" "THEDA" "WYNDHAM" ...
    ##  $ start : int [1:6842] 1951 1956 1965 1968 1998 1973 1997 1944 1967 1986 ...
    ##  $ end   : int [1:6842] 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 ...
    ##  $ lat   : num [1:6842] -15.5 -13.8 -14.8 -15.5 -15.9 ...
    ##  $ lon   : num [1:6842] 128 126 126 128 128 ...
    ##  $ state : chr [1:6842] "WA" "WA" "WA" "WA" ...
    ##  $ elev  : num [1:6842] 3.8 6 210 11 130 546 23 51 90 300 ...
    ##  $ bar_ht: num [1:6842] 4.3 8 NA NA NA 547 24 52.5 NA NA ...
    ##  $ wmo   : num [1:6842] 95214 94102 NA NA NA ...
    ##  - attr(*, "problems")= tibble [15 × 4] (S3: tbl_df/tbl/data.frame)
    ##   ..$ row     : int [1:15] 19386 19386 19387 19387 19387 19387 19387 19387 19388 19388 ...
    ##   ..$ col     : int [1:15] 3 NA 4 5 6 7 8 NA 4 5 ...
    ##   ..$ expected: chr [1:15] "0 chars" "12 columns" "a double" "a double" ...
    ##   ..$ actual  : chr [1:15] "0" "3 columns" "teor" "y (A" ...

``` r
bom_stations_raw
```

    ## # A tibble: 6,842 x 11
    ##    site   dist  name            start   end   lat   lon state  elev bar_ht   wmo
    ##    <chr>  <chr> <chr>           <int> <int> <dbl> <dbl> <chr> <dbl>  <dbl> <dbl>
    ##  1 001006 01    WYNDHAM AERO     1951  2020 -15.5  128. WA      3.8    4.3 95214
    ##  2 001007 01    TROUGHTON ISLA…  1956  2020 -13.8  126. WA      6      8   94102
    ##  3 001010 01    THEDA            1965  2020 -14.8  126. WA    210     NA      NA
    ##  4 001013 01    WYNDHAM          1968  2020 -15.5  128. WA     11     NA      NA
    ##  5 001014 01    EMMA GORGE       1998  2020 -15.9  128. WA    130     NA      NA
    ##  6 001018 01    MOUNT ELIZABETH  1973  2020 -16.4  126. WA    546    547   94211
    ##  7 001019 01    KALUMBURU        1997  2020 -14.3  127. WA     23     24   94100
    ##  8 001020 01    TRUSCOTT         1944  2020 -14.1  126. WA     51     52.5 95101
    ##  9 001023 01    EL QUESTRO       1967  2020 -16.0  128. WA     90     NA      NA
    ## 10 001024 01    ELLENBRAE        1986  2020 -16.0  127. WA    300     NA      NA
    ## # … with 6,832 more rows

## Check station locations

Occasionally the stations are listed in the wrong location, *e.g.*,
Alice Springs Airport in SA. Perform quality check to ensure that the
station locations are accurate based on the lat/lon values.

``` r
`%notin%`  <- function(x, table) {
  # Same as !(x %in% table)
  match(x, table, nomatch = 0L) == 0L
}

data.table::setDT(bom_stations_raw)
latlon2state <- function(lat, lon) {
  ASGS.foyer::latlon2SA(lat,
                        lon,
                        to = "STE",
                        yr = "2016",
                        return = "v")
}

bom_stations_raw %>%
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
data.table::setDF(bom_stations_raw)
```

## Create state codes

Use the state values extracted from `ASGS.foyer` to set state codes from
BOM rather than the sometimes incorrect `state` column from BOM.

BOM state codes are as follows:

-   IDD - NT,

-   IDN - NSW/ACT,

-   IDQ - Qld,

-   IDS - SA,

-   IDT - Tas/Antarctica,

-   IDV - Vic, and

-   IDW - WA

``` r
bom_stations_raw$state_code <- NA
bom_stations_raw$state_code[bom_stations_raw$state == "WA"] <- "W"
bom_stations_raw$state_code[bom_stations_raw$state == "QLD"] <- "Q"
bom_stations_raw$state_code[bom_stations_raw$state == "VIC"] <- "V"
bom_stations_raw$state_code[bom_stations_raw$state == "NT"] <- "D"
bom_stations_raw$state_code[bom_stations_raw$state == "TAS" |
                              bom_stations_raw$state == "ANT"] <-
  "T"
bom_stations_raw$state_code[bom_stations_raw$state == "NSW"] <- "N"
bom_stations_raw$state_code[bom_stations_raw$state == "SA"] <- "S"
```

## Generate station URLs

``` r
stations_site_list <-
  bom_stations_raw %>%
  dplyr::select(site:wmo, state, state_code) %>%
  tidyr::drop_na(wmo) %>%
  dplyr::mutate(
    url = dplyr::case_when(
      .$state == "NSW" |
        .$state == "NT" |
        .$state == "QLD" |
        .$state == "SA" |
        .$state == "TAS" |
        .$state == "VIC" |
        .$state == "WA" ~
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
      .$state == "ACT" ~
        paste0(
          "http://www.bom.gov.au/fwo/IDN",
          "60903",
          "/",
          "IDN",
          "60903",
          ".",
          .$wmo,
          ".json"
        ),
      .$state == "ANT" ~
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
data as databases for *bomrang* to use.

There are weather stations that do have a WMO but don’t report online,
*e.g.*, KIRIBATI NTC AWS or MARSHALL ISLANDS NTC AWS, in this section
remove these from the list and then create a database to provide URLs
for valid JSON files providing weather data from BOM.

### Save URL database for get\_current\_weather() and get\_historical\_weather()

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

str(JSONurl_site_list)
```

    ## Classes 'data.table' and 'data.frame':   890 obs. of  13 variables:
    ##  $ site      : chr  "001006" "001007" "001018" "001019" ...
    ##  $ dist      : chr  "01" "01" "01" "01" ...
    ##  $ name      : chr  "WYNDHAM AERO" "TROUGHTON ISLAND" "MOUNT ELIZABETH" "KALUMBURU" ...
    ##  $ start     : int  1951 1956 1973 1997 1944 1988 2012 1944 1897 1971 ...
    ##  $ end       : int  2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 ...
    ##  $ lat       : num  -15.5 -13.8 -16.4 -14.3 -14.1 ...
    ##  $ lon       : num  128 126 126 127 126 ...
    ##  $ state     : chr  "WA" "WA" "WA" "WA" ...
    ##  $ elev      : num  3.8 6 546 23 51 ...
    ##  $ bar_ht    : num  4.3 8 547 24 52.5 ...
    ##  $ wmo       : num  95214 94102 94211 94100 95101 ...
    ##  $ state_code: chr  "W" "W" "W" "W" ...
    ##  $ url       : chr  "http://www.bom.gov.au/fwo/IDW60801/IDW60801.95214.json" "http://www.bom.gov.au/fwo/IDW60801/IDW60801.94102.json" "http://www.bom.gov.au/fwo/IDW60801/IDW60801.94211.json" "http://www.bom.gov.au/fwo/IDW60801/IDW60801.94100.json" ...
    ##  - attr(*, ".internal.selfref")=<externalptr>

``` r
# Save database
save(JSONurl_site_list,
     file = "../inst/extdata/JSONurl_site_list.rda",
     compress = "bzip2")
```

### Save station location database for get\_ag\_bulletin()

First, rename columns and drop a few that aren’t necessary for the ag
bulletin information. Filter for only stations currently reporting
values. Then pad the `site` field with 0 to match the data in the XML
file that holds the ag bulletin information. Lastly, create the
databases for use in `bomrang`.

``` r
stations_site_list <-
  stations_site_list %>%
  dplyr::select(-state_code, -url) %>% 
  dplyr::filter(end == lubridate::year(Sys.Date())) %>% 
  dplyr::mutate(end = as.integer(end))

stations_site_list$site <-
  gsub("^0{1,2}", "", stations_site_list$site)

data.table::setDT(stations_site_list)
data.table::setkey(stations_site_list, "site")

str(stations_site_list)
```

    ## Classes 'data.table' and 'data.frame':   890 obs. of  11 variables:
    ##  $ site  : chr  "10007" "10058" "1006" "1007" ...
    ##  $ dist  : chr  "10" "10" "01" "01" ...
    ##  $ name  : chr  "BENCUBBIN" "GOOMALLING" "WYNDHAM AERO" "TROUGHTON ISLAND" ...
    ##  $ start : int  1912 1887 1951 1956 1892 1903 1877 1973 1997 1944 ...
    ##  $ end   : int  2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 ...
    ##  $ lat   : num  -30.8 -31.3 -15.5 -13.8 -31.6 ...
    ##  $ lon   : num  118 117 128 126 118 ...
    ##  $ state : chr  "WA" "WA" "WA" "WA" ...
    ##  $ elev  : num  359 239 3.8 6 250 315 170 546 23 51 ...
    ##  $ bar_ht: num  353.5 NA 4.3 8 NA ...
    ##  $ wmo   : num  94632 95631 95214 94102 95603 ...
    ##  - attr(*, ".internal.selfref")=<externalptr> 
    ##  - attr(*, "sorted")= chr "site"

``` r
save(stations_site_list,
     file = "../inst/extdata/current_stations_site_list.rda",
     compress = "bzip2")
```

## Session Info

    ## ─ Session info ───────────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 4.0.3 (2020-10-10)
    ##  os       macOS Catalina 10.15.7      
    ##  system   x86_64, darwin17.0          
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  ctype    en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2020-12-01                  
    ## 
    ## ─ Packages ───────────────────────────────────────────────────────────────────
    ##  package     * version    date       lib source                              
    ##  ASGS.foyer    0.2.1      2018-05-17 [1] CRAN (R 4.0.2)                      
    ##  assertthat    0.2.1      2019-03-21 [1] CRAN (R 4.0.3)                      
    ##  cli           2.2.0      2020-11-20 [1] CRAN (R 4.0.3)                      
    ##  crayon        1.3.4.9000 2020-11-15 [1] Github (r-lib/crayon@4bceba8)       
    ##  curl          4.3        2019-12-02 [1] CRAN (R 4.0.3)                      
    ##  data.table    1.13.3     2020-11-06 [1] local                               
    ##  digest        0.6.27     2020-10-24 [1] CRAN (R 4.0.2)                      
    ##  dplyr         1.0.2      2020-08-18 [1] CRAN (R 4.0.2)                      
    ##  ellipsis      0.3.1      2020-05-15 [1] CRAN (R 4.0.2)                      
    ##  evaluate      0.14       2019-05-28 [1] CRAN (R 4.0.3)                      
    ##  fansi         0.4.1      2020-01-08 [1] CRAN (R 4.0.3)                      
    ##  generics      0.1.0      2020-10-31 [1] CRAN (R 4.0.2)                      
    ##  glue          1.4.2      2020-08-27 [1] CRAN (R 4.0.2)                      
    ##  hms           0.5.3      2020-01-08 [1] CRAN (R 4.0.3)                      
    ##  htmltools     0.5.0      2020-06-16 [1] CRAN (R 4.0.2)                      
    ##  httr          1.4.2.9000 2020-11-03 [1] Github (hadley/httr@cb4e20c)        
    ##  knitr         1.30       2020-09-22 [1] CRAN (R 4.0.2)                      
    ##  lattice       0.20-41    2020-04-02 [1] CRAN (R 4.0.2)                      
    ##  lifecycle     0.2.0      2020-03-06 [1] CRAN (R 4.0.3)                      
    ##  lubridate     1.7.9.9001 2020-11-25 [1] Github (tidyverse/lubridate@6c535c8)
    ##  magrittr    * 2.0.1      2020-11-17 [1] CRAN (R 4.0.3)                      
    ##  pillar        1.4.7      2020-11-20 [1] CRAN (R 4.0.3)                      
    ##  pkgconfig     2.0.3      2019-09-22 [1] CRAN (R 4.0.3)                      
    ##  purrr         0.3.4      2020-04-17 [1] CRAN (R 4.0.2)                      
    ##  R6            2.5.0      2020-10-28 [1] CRAN (R 4.0.2)                      
    ##  Rcpp          1.0.5      2020-07-06 [1] CRAN (R 4.0.2)                      
    ##  readr         1.4.0      2020-10-05 [1] CRAN (R 4.0.2)                      
    ##  rlang         0.4.9      2020-11-26 [1] CRAN (R 4.0.3)                      
    ##  rmarkdown     2.5        2020-10-21 [1] CRAN (R 4.0.3)                      
    ##  sessioninfo   1.1.1      2018-11-05 [1] CRAN (R 4.0.2)                      
    ##  sp          * 1.4-4      2020-10-07 [1] CRAN (R 4.0.3)                      
    ##  stringi       1.5.3      2020-09-09 [1] CRAN (R 4.0.2)                      
    ##  stringr       1.4.0      2019-02-10 [1] CRAN (R 4.0.3)                      
    ##  tibble        3.0.4      2020-10-12 [1] CRAN (R 4.0.2)                      
    ##  tidyr         1.1.2      2020-08-27 [1] CRAN (R 4.0.2)                      
    ##  tidyselect    1.1.0      2020-05-11 [1] CRAN (R 4.0.2)                      
    ##  utf8          1.1.4      2018-05-24 [1] CRAN (R 4.0.3)                      
    ##  vctrs         0.3.5      2020-11-17 [1] CRAN (R 4.0.3)                      
    ##  withr         2.3.0      2020-09-22 [1] CRAN (R 4.0.2)                      
    ##  xfun          0.19       2020-10-30 [1] CRAN (R 4.0.2)                      
    ##  yaml          2.2.1      2020-02-01 [1] CRAN (R 4.0.3)                      
    ## 
    ## [1] /Users/adamsparks/Library/R/4.0/library
    ## [2] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
