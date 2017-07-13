Get BoM Précis Forecast Town Names
================

Get BoM Forecast Town Names and Geographic Locations
----------------------------------------------------

BoM maintains a shapefile of forecast town names and their geographic locations. For ease, we'll just use the .dbf file part of the shapefile to extract AAC codes that can be used to add lat/lon values to the forecast `data.frame` that `get_precis_forecast()` returns. The file is available from BoM's anonymous FTP server with spatial data , specifically the DBF file portion of a shapefile, <ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf>

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
 if (!dir.exists("../inst/extdata")) {
      dir.create("../inst/extdata", recursive = TRUE)
    }

  save(AAC_codes, file = "../inst/extdata/AAC_codes.rda",
     compress = "bzip2")
```

Session Info
------------

``` r
devtools::session_info()
```

    ## Session info -------------------------------------------------------------

    ##  setting  value                       
    ##  version  R version 3.4.1 (2017-06-30)
    ##  system   x86_64, darwin16.6.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2017-07-13

    ## Packages -----------------------------------------------------------------

    ##  package   * version date       source         
    ##  backports   1.1.0   2017-05-22 cran (@1.1.0)  
    ##  base      * 3.4.1   2017-07-07 local          
    ##  compiler    3.4.1   2017-07-07 local          
    ##  datasets  * 3.4.1   2017-07-07 local          
    ##  devtools    1.13.2  2017-06-02 cran (@1.13.2) 
    ##  digest      0.6.12  2017-01-27 CRAN (R 3.4.0) 
    ##  evaluate    0.10.1  2017-06-24 cran (@0.10.1) 
    ##  foreign     0.8-69  2017-06-22 CRAN (R 3.4.1) 
    ##  graphics  * 3.4.1   2017-07-07 local          
    ##  grDevices * 3.4.1   2017-07-07 local          
    ##  htmltools   0.3.6   2017-04-28 CRAN (R 3.4.0) 
    ##  knitr       1.16    2017-05-18 cran (@1.16)   
    ##  magrittr    1.5     2014-11-22 CRAN (R 3.4.0) 
    ##  memoise     1.1.0   2017-04-21 CRAN (R 3.4.0) 
    ##  methods   * 3.4.1   2017-07-07 local          
    ##  Rcpp        0.12.11 2017-05-22 cran (@0.12.11)
    ##  rmarkdown   1.6     2017-06-15 cran (@1.6)    
    ##  rprojroot   1.2     2017-01-16 CRAN (R 3.4.0) 
    ##  stats     * 3.4.1   2017-07-07 local          
    ##  stringi     1.1.5   2017-04-07 CRAN (R 3.4.0) 
    ##  stringr     1.2.0   2017-02-18 CRAN (R 3.4.0) 
    ##  tools       3.4.1   2017-07-07 local          
    ##  utils     * 3.4.1   2017-07-07 local          
    ##  withr       1.0.2   2016-06-20 CRAN (R 3.4.0) 
    ##  yaml        2.1.14  2016-11-12 CRAN (R 3.4.0)
