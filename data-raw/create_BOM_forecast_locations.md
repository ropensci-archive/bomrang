Get BOM Précis Forecast Town Names
================

## Get BOM Forecast Town Names and Geographic Locations

BOM maintains a shapefile of forecast town names and their geographic
locations. For ease, we’ll just use the .dbf file part of the shapefile
to extract AAC codes that can be used to add lat/lon values to the
forecast `data.frame` that `get_precis_forecast()` returns. The file is
available from BOM’s anonymous FTP server with spatial data ,
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
    ##  version  R version 3.4.4 (2018-03-15)
    ##  os       macOS High Sierra 10.13.4   
    ##  system   x86_64, darwin17.4.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2018-04-18                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version date       source                                 
    ##  backports     1.1.2   2017-12-13 cran (@1.1.2)                          
    ##  clisymbols    1.2.0   2018-01-30 Github (gaborcsardi/clisymbols@e49b4f5)
    ##  digest        0.6.15  2018-01-28 cran (@0.6.15)                         
    ##  evaluate      0.10.1  2017-06-24 cran (@0.10.1)                         
    ##  foreign       0.8-69  2017-06-22 CRAN (R 3.4.4)                         
    ##  htmltools     0.3.6   2017-04-28 cran (@0.3.6)                          
    ##  knitr         1.20    2018-02-20 CRAN (R 3.4.4)                         
    ##  magrittr      1.5     2014-11-22 CRAN (R 3.4.2)                         
    ##  Rcpp          0.12.16 2018-03-13 CRAN (R 3.4.4)                         
    ##  rmarkdown     1.9     2018-03-01 CRAN (R 3.4.4)                         
    ##  rprojroot     1.3-2   2018-01-03 cran (@1.3-2)                          
    ##  sessioninfo   1.0.0   2017-06-21 CRAN (R 3.4.2)                         
    ##  stringi       1.1.7   2018-03-12 CRAN (R 3.4.4)                         
    ##  stringr       1.3.0   2018-02-19 CRAN (R 3.4.4)                         
    ##  withr         2.1.2   2018-03-15 Github (r-lib/withr@79d7b0d)           
    ##  yaml          2.1.18  2018-03-08 CRAN (R 3.4.4)
