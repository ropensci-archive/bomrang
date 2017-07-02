Get BoM Locations
================

Get BoM Forecast Town Names and Geographic Locations
----------------------------------------------------

BoM maintains a shapefile of forecast locations. For ease, we'll just use the .dbf file part of th shapefile to extract AAC codes that can be used to add lat/lon to the forecast.

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

    ## Saving AAC_codes as AAC_codes.rda to /Users/U8004755/Development/bomrang/data

Session Info
------------

``` r
devtools::session_info()
```

    ## Session info -------------------------------------------------------------

    ##  setting  value                       
    ##  version  R version 3.4.0 (2017-04-21)
    ##  system   x86_64, darwin16.6.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2017-06-28

    ## Packages -----------------------------------------------------------------

    ##  package   * version date       source         
    ##  backports   1.1.0   2017-05-22 cran (@1.1.0)  
    ##  base      * 3.4.0   2017-06-26 local          
    ##  compiler    3.4.0   2017-06-26 local          
    ##  datasets  * 3.4.0   2017-06-26 local          
    ##  devtools    1.13.2  2017-06-02 cran (@1.13.2) 
    ##  digest      0.6.12  2017-01-27 CRAN (R 3.4.0) 
    ##  evaluate    0.10.1  2017-06-24 cran (@0.10.1) 
    ##  foreign     0.8-67  2016-09-13 CRAN (R 3.4.0) 
    ##  graphics  * 3.4.0   2017-06-26 local          
    ##  grDevices * 3.4.0   2017-06-26 local          
    ##  htmltools   0.3.6   2017-04-28 CRAN (R 3.4.0) 
    ##  knitr       1.16    2017-05-18 cran (@1.16)   
    ##  magrittr    1.5     2014-11-22 CRAN (R 3.4.0) 
    ##  memoise     1.1.0   2017-04-21 CRAN (R 3.4.0) 
    ##  methods   * 3.4.0   2017-06-26 local          
    ##  Rcpp        0.12.11 2017-05-22 cran (@0.12.11)
    ##  rmarkdown   1.6     2017-06-15 cran (@1.6)    
    ##  rprojroot   1.2     2017-01-16 CRAN (R 3.4.0) 
    ##  stats     * 3.4.0   2017-06-26 local          
    ##  stringi     1.1.5   2017-04-07 CRAN (R 3.4.0) 
    ##  stringr     1.2.0   2017-02-18 CRAN (R 3.4.0) 
    ##  tools       3.4.0   2017-06-26 local          
    ##  utils     * 3.4.0   2017-06-26 local          
    ##  withr       1.0.2   2016-06-20 CRAN (R 3.4.0) 
    ##  yaml        2.1.14  2016-11-12 CRAN (R 3.4.0)
