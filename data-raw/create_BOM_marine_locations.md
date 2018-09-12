Get BOM Marine Zones
================

## Get BOM Forecast Marine Zones

BOM maintains a shapefile of forecast marine zone names and their
geographic locations. For ease, we’ll just use the .dbf file part of the
shapefile to extract AAC codes that can be used to add locations to the
forecast `data.frame` that `get_coastal_forecast()` returns. The file is
available from BOM’s anonymous FTP server with spatial data
<ftp://ftp.bom.gov.au/anon/home/adfd/spatial/>, specifically the DBF
file portion of a shapefile,
<ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00003.dbf>

``` r
  utils::download.file(
    "ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00003.dbf",
    destfile = paste0(tempdir(), "marine_AAC_codes.dbf"),
    mode = "wb"
  )

  marine_AAC_codes <-
    foreign::read.dbf(paste0(tempdir(), "marine_AAC_codes.dbf"), as.is = TRUE)
  
  marine_AAC_codes <- marine_AAC_codes[, c(1,3,4,5,6,7)]
```

Save the marine zones to disk for use in the R package.

``` r
 if (!dir.exists("../inst/extdata")) {
      dir.create("../inst/extdata", recursive = TRUE)
    }

  save(marine_AAC_codes, file = "../inst/extdata/marine_AAC_codes.rda",
     compress = "bzip2")
```

## Session Info

``` r
sessioninfo::session_info()
```

    ## ─ Session info ──────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 3.5.1 (2018-07-02)
    ##  os       macOS High Sierra 10.13.6   
    ##  system   x86_64, darwin17.7.0        
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2018-09-12                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version date       source                            
    ##  backports     1.1.2   2017-12-13 CRAN (R 3.5.1)                    
    ##  clisymbols    1.2.0   2017-05-21 CRAN (R 3.5.1)                    
    ##  colorout    * 1.2-0   2018-08-16 Github (jalvesaq/colorout@cc5fbfa)
    ##  devtools      1.13.6  2018-06-27 CRAN (R 3.5.1)                    
    ##  digest        0.6.16  2018-08-22 CRAN (R 3.5.1)                    
    ##  evaluate      0.11    2018-07-17 CRAN (R 3.5.1)                    
    ##  foreign       0.8-71  2018-07-20 CRAN (R 3.5.1)                    
    ##  htmltools     0.3.6   2017-04-28 CRAN (R 3.5.1)                    
    ##  knitr         1.20    2018-02-20 CRAN (R 3.5.1)                    
    ##  magrittr      1.5     2014-11-22 CRAN (R 3.5.1)                    
    ##  memoise       1.1.0   2017-04-21 CRAN (R 3.5.1)                    
    ##  Rcpp          0.12.18 2018-07-23 CRAN (R 3.5.1)                    
    ##  rmarkdown     1.10    2018-06-11 CRAN (R 3.5.1)                    
    ##  rprojroot     1.3-2   2018-01-03 CRAN (R 3.5.1)                    
    ##  sessioninfo   1.0.0   2017-06-21 CRAN (R 3.5.1)                    
    ##  stringi       1.2.4   2018-07-20 CRAN (R 3.5.1)                    
    ##  stringr       1.3.1   2018-05-10 CRAN (R 3.5.1)                    
    ##  withr         2.1.2   2018-03-15 CRAN (R 3.5.1)                    
    ##  yaml          2.2.0   2018-07-25 CRAN (R 3.5.1)
