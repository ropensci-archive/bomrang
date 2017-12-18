Get BoM Précis Forecast Town Names
================

## Get BoM Forecast Town Names and Geographic Locations

BoM maintains a shapefile of forecast town names and their geographic
locations. For ease, we’ll just use the .dbf file part of the shapefile
to extract AAC codes that can be used to add lat/lon values to the
forecast `data.frame` that `get_precis_forecast()` returns. The file is
available from BoM’s anonymous FTP server with spatial data ,
specifically the DBF file portion of a shapefile,
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
sessioninfo::session_info()
```

    ## ─ Session info ──────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 3.4.3 (2017-11-30)
    ##  os       macOS Sierra 10.12.6        
    ##  system   x86_64, darwin16.7.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2017-12-18                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version    date      
    ##  backports     1.1.2      2017-12-13
    ##  clisymbols    1.2.0      2017-11-07
    ##  digest        0.6.13     2017-12-14
    ##  evaluate      0.10.1     2017-06-24
    ##  foreign       0.8-69     2017-06-22
    ##  htmltools     0.3.6      2017-04-28
    ##  knitr         1.17       2017-08-10
    ##  magrittr      1.5        2014-11-22
    ##  Rcpp          0.12.14    2017-11-23
    ##  rmarkdown     1.8.5      2017-12-13
    ##  rprojroot     1.2        2017-01-16
    ##  sessioninfo   1.0.0      2017-06-21
    ##  stringi       1.1.6      2017-11-17
    ##  stringr       1.2.0      2017-02-18
    ##  withr         2.1.0.9000 2017-11-26
    ##  yaml          2.1.16     2017-12-12
    ##  source                                 
    ##  cran (@1.1.2)                          
    ##  Github (gaborcsardi/clisymbols@e49b4f5)
    ##  cran (@0.6.13)                         
    ##  CRAN (R 3.4.1)                         
    ##  CRAN (R 3.4.3)                         
    ##  CRAN (R 3.4.1)                         
    ##  CRAN (R 3.4.2)                         
    ##  CRAN (R 3.4.1)                         
    ##  cran (@0.12.14)                        
    ##  Github (rstudio/rmarkdown@08c7567)     
    ##  CRAN (R 3.4.1)                         
    ##  CRAN (R 3.4.2)                         
    ##  cran (@1.1.6)                          
    ##  CRAN (R 3.4.1)                         
    ##  Github (jimhester/withr@fe81c00)       
    ##  cran (@2.1.16)
