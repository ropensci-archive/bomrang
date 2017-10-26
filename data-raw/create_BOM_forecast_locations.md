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
    ##  version  R version 3.4.2 (2017-09-28)
    ##  system   x86_64, darwin17.0.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2017-10-27

    ## Packages -----------------------------------------------------------------

    ##  package   * version date       source        
    ##  backports   1.1.1   2017-09-25 cran (@1.1.1) 
    ##  base      * 3.4.2   2017-09-30 local         
    ##  compiler    3.4.2   2017-09-30 local         
    ##  datasets  * 3.4.2   2017-09-30 local         
    ##  devtools    1.13.3  2017-08-02 CRAN (R 3.4.2)
    ##  digest      0.6.12  2017-01-27 CRAN (R 3.4.2)
    ##  evaluate    0.10.1  2017-06-24 cran (@0.10.1)
    ##  foreign     0.8-69  2017-06-22 CRAN (R 3.4.2)
    ##  graphics  * 3.4.2   2017-09-30 local         
    ##  grDevices * 3.4.2   2017-09-30 local         
    ##  htmltools   0.3.6   2017-04-28 cran (@0.3.6) 
    ##  knitr       1.17    2017-08-10 cran (@1.17)  
    ##  magrittr    1.5     2014-11-22 CRAN (R 3.4.2)
    ##  memoise     1.1.0   2017-04-21 CRAN (R 3.4.2)
    ##  methods   * 3.4.2   2017-09-30 local         
    ##  Rcpp        0.12.13 2017-09-28 CRAN (R 3.4.2)
    ##  rmarkdown   1.6     2017-06-15 cran (@1.6)   
    ##  rprojroot   1.2     2017-01-16 cran (@1.2)   
    ##  stats     * 3.4.2   2017-09-30 local         
    ##  stringi     1.1.5   2017-04-07 CRAN (R 3.4.2)
    ##  stringr     1.2.0   2017-02-18 CRAN (R 3.4.2)
    ##  tools       3.4.2   2017-09-30 local         
    ##  utils     * 3.4.2   2017-09-30 local         
    ##  withr       2.0.0   2017-07-28 CRAN (R 3.4.2)
    ##  yaml        2.1.14  2016-11-12 cran (@2.1.14)
