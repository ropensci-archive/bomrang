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
    ##  os       macOS Sierra 10.12.6        
    ##  system   x86_64, darwin16.7.0        
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  ctype    en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2018-10-16                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version date       lib source                            
    ##  assertthat    0.2.0   2017-04-11 [1] CRAN (R 3.5.1)                    
    ##  backports     1.1.2   2017-12-13 [1] CRAN (R 3.5.1)                    
    ##  cli           1.0.1   2018-09-25 [1] CRAN (R 3.5.1)                    
    ##  colorout    * 1.2-0   2018-08-16 [1] Github (jalvesaq/colorout@cc5fbfa)
    ##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.5.1)                    
    ##  digest        0.6.18  2018-10-10 [1] CRAN (R 3.5.1)                    
    ##  evaluate      0.12    2018-10-09 [1] CRAN (R 3.5.1)                    
    ##  foreign       0.8-71  2018-07-20 [3] CRAN (R 3.5.1)                    
    ##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.5.1)                    
    ##  knitr         1.20    2018-02-20 [1] CRAN (R 3.5.1)                    
    ##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.5.1)                    
    ##  Rcpp          0.12.19 2018-10-01 [1] CRAN (R 3.5.1)                    
    ##  rmarkdown     1.10    2018-06-11 [1] CRAN (R 3.5.1)                    
    ##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 3.5.1)                    
    ##  sessioninfo   1.1.0   2018-09-25 [1] CRAN (R 3.5.1)                    
    ##  stringi       1.2.4   2018-07-20 [1] CRAN (R 3.5.1)                    
    ##  stringr       1.3.1   2018-05-10 [1] CRAN (R 3.5.1)                    
    ##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.5.1)                    
    ##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.5.1)                    
    ## 
    ## [1] /Users/U8004755/Library/R/3.x/library
    ## [2] /usr/local/lib/R/3.5/site-library
    ## [3] /usr/local/Cellar/r/3.5.1/lib/R/library
