Get BoM Précis Forecast Town Names
================

## Get BoM Forecast Town Names and Geographic Locations

BoM maintains a shapefile of forecast town names and their geographic
locations. For ease, we’ll just use the .dbf file part of the shapefile
to extract AAC codes that can be used to add lat/lon values to the
forecast `data.frame` that `get_precis_forecast()` returns. The file is
available from BoM’s anonymous FTP server with spatial data
\url{ftp://ftp.bom.gov.au/anon/home/adfd/spatial/}, specifically the DBF
file portion of a shapefile,
<ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf>

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

## Session Info

``` r
devtools::session_info()
```

    ## Session info -------------------------------------------------------------

    ##  setting  value                       
    ##  version  R version 3.4.3 (2017-11-30)
    ##  system   x86_64, darwin16.7.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2017-12-04

    ## Packages -----------------------------------------------------------------

    ##  package   * version    date       source                            
    ##  backports   1.1.1      2017-09-25 cran (@1.1.1)                     
    ##  base      * 3.4.3      2017-12-03 local                             
    ##  compiler    3.4.3      2017-12-03 local                             
    ##  datasets  * 3.4.3      2017-12-03 local                             
    ##  devtools    1.13.4     2017-11-09 cran (@1.13.4)                    
    ##  digest      0.6.12     2017-01-27 CRAN (R 3.4.1)                    
    ##  evaluate    0.10.1     2017-06-24 CRAN (R 3.4.1)                    
    ##  foreign     0.8-69     2017-06-22 CRAN (R 3.4.3)                    
    ##  graphics  * 3.4.3      2017-12-03 local                             
    ##  grDevices * 3.4.3      2017-12-03 local                             
    ##  htmltools   0.3.6      2017-04-28 CRAN (R 3.4.1)                    
    ##  knitr       1.17       2017-08-10 CRAN (R 3.4.2)                    
    ##  magrittr    1.5        2014-11-22 CRAN (R 3.4.1)                    
    ##  memoise     1.1.0      2017-04-21 CRAN (R 3.4.1)                    
    ##  methods   * 3.4.3      2017-12-03 local                             
    ##  Rcpp        0.12.14    2017-11-23 cran (@0.12.14)                   
    ##  rmarkdown   1.8.3      2017-11-26 Github (rstudio/rmarkdown@07f7d8e)
    ##  rprojroot   1.2        2017-01-16 CRAN (R 3.4.1)                    
    ##  stats     * 3.4.3      2017-12-03 local                             
    ##  stringi     1.1.6      2017-11-17 cran (@1.1.6)                     
    ##  stringr     1.2.0      2017-02-18 CRAN (R 3.4.1)                    
    ##  tools       3.4.3      2017-12-03 local                             
    ##  utils     * 3.4.3      2017-12-03 local                             
    ##  withr       2.1.0.9000 2017-11-26 Github (jimhester/withr@fe81c00)  
    ##  yaml        2.1.14     2016-11-12 CRAN (R 3.4.1)
