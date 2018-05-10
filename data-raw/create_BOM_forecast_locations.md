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
    ##  version  R version 3.5.0 (2018-04-23)
    ##  os       macOS Sierra 10.12.6        
    ##  system   x86_64, darwin16.7.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2018-05-10                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version date       source        
    ##  backports     1.1.2   2017-12-13 CRAN (R 3.5.0)
    ##  clisymbols    1.2.0   2017-05-21 CRAN (R 3.5.0)
    ##  digest        0.6.15  2018-01-28 CRAN (R 3.5.0)
    ##  evaluate      0.10.1  2017-06-24 CRAN (R 3.5.0)
    ##  foreign       0.8-70  2018-04-23 CRAN (R 3.5.0)
    ##  htmltools     0.3.6   2017-04-28 CRAN (R 3.5.0)
    ##  knitr         1.20    2018-02-20 CRAN (R 3.5.0)
    ##  magrittr      1.5     2014-11-22 CRAN (R 3.5.0)
    ##  Rcpp          0.12.16 2018-03-13 CRAN (R 3.5.0)
    ##  rmarkdown     1.9     2018-03-01 CRAN (R 3.5.0)
    ##  rprojroot     1.3-2   2018-01-03 CRAN (R 3.5.0)
    ##  sessioninfo   1.0.0   2017-06-21 CRAN (R 3.5.0)
    ##  stringi       1.2.2   2018-05-02 CRAN (R 3.5.0)
    ##  stringr       1.3.0   2018-02-19 CRAN (R 3.5.0)
    ##  withr         2.1.2   2018-03-15 CRAN (R 3.5.0)
    ##  yaml          2.1.19  2018-05-01 CRAN (R 3.5.0)
