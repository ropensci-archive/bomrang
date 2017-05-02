Get BOM Locations
================

Get BOM Locations
-----------------

BOM maintains a shapefile of a station list. For ease, we'll just use the .dbf file part of th shapefile to extract AAC codes that can be used to add lat/lon to the forecast.

``` r
  utils::download.file(
    "ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf",
    destfile = paste0(tempdir(), "AAC_codes.dbf"),
    mode = "wb"
  )

  AAC_codes <-
    foreign::read.dbf(paste0(tempdir(), "AAC_codes.dbf"), as.is = TRUE)
  AAC_codes <- AAC_codes[, c(2:3, 7:9)]
```

Save the stations to disk for use in the R package.

``` r
  devtools::use_data(AAC_codes, overwrite = TRUE)
```

    ## Saving AAC_codes as AAC_codes.rda to /Users/asparks/Development/BOMRang/data

Session Info
------------

``` r
devtools::session_info()
```

    ## Session info --------------------------------------------------------------

    ##  setting  value                       
    ##  version  R version 3.4.0 (2017-04-21)
    ##  system   x86_64, darwin16.5.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2017-05-03

    ## Packages ------------------------------------------------------------------

    ##  package   * version date       source        
    ##  backports   1.0.5   2017-01-18 CRAN (R 3.4.0)
    ##  devtools    1.12.0  2016-12-05 CRAN (R 3.4.0)
    ##  digest      0.6.12  2017-01-27 CRAN (R 3.4.0)
    ##  evaluate    0.10    2016-10-11 CRAN (R 3.4.0)
    ##  foreign     0.8-67  2016-09-13 CRAN (R 3.4.0)
    ##  htmltools   0.3.6   2017-04-28 cran (@0.3.6) 
    ##  knitr       1.15.1  2016-11-22 CRAN (R 3.4.0)
    ##  magrittr    1.5     2014-11-22 CRAN (R 3.4.0)
    ##  memoise     1.1.0   2017-04-21 CRAN (R 3.4.0)
    ##  Rcpp        0.12.10 2017-03-19 CRAN (R 3.4.0)
    ##  rmarkdown   1.5     2017-04-26 cran (@1.5)   
    ##  rprojroot   1.2     2017-01-16 CRAN (R 3.4.0)
    ##  stringi     1.1.5   2017-04-07 CRAN (R 3.4.0)
    ##  stringr     1.2.0   2017-02-18 CRAN (R 3.4.0)
    ##  withr       1.0.2   2016-06-20 CRAN (R 3.4.0)
    ##  yaml        2.1.14  2016-11-12 CRAN (R 3.4.0)
