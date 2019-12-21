Create BOM Précis Forecast Town Names Database
================

## Get BOM Forecast Town Names and Geographic Locations

BOM maintains a shapefile of forecast town names and their geographic
locations. For ease, we’ll just use the .dbf file part of the shapefile
to extract AAC codes that can be used to add lat/lon values to the
forecast `data.table` that `get_precis_forecast()` returns. The file is
available from BOM’s anonymous FTP server with spatial data
<ftp://ftp.bom.gov.au/anon/home/adfd/spatial/>, specifically the DBF
file portion of a shapefile,
<ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf>

``` r
curl::curl_download(
  "ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf",
  destfile = paste0(tempdir(), "AAC_codes.dbf"),
  mode = "wb",
  quiet = TRUE
)

AAC_codes <-
  foreign::read.dbf(paste0(tempdir(), "AAC_codes.dbf"), as.is = TRUE)

# convert names to lower case for consistency with bomrang output
names(AAC_codes) <- tolower(names(AAC_codes))

# reorder columns
AAC_codes <- AAC_codes[, c(2:3, 7:9)]

data.table::setDT(AAC_codes)
data.table::setnames(AAC_codes, c(2, 5), c("town", "elev"))
data.table::setkey(AAC_codes, "aac")
```

Save the stations to disk for use in the R package.

``` r
if (!dir.exists("../inst/extdata")) {
  dir.create("../inst/extdata", recursive = TRUE)
}

save(AAC_codes,
     file = "../inst/extdata/AAC_codes.rda",
     compress = "bzip2",
     version = 2)
```

## Session Info

``` r
sessioninfo::session_info()
```

    ## ─ Session info ───────────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 3.6.1 (2019-07-05)
    ##  os       macOS Mojave 10.14.6        
    ##  system   x86_64, darwin15.6.0        
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  ctype    en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2019-12-21                  
    ## 
    ## ─ Packages ───────────────────────────────────────────────────────────────────
    ##  package     * version date       lib source        
    ##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
    ##  cli           2.0.0   2019-12-09 [1] CRAN (R 3.6.0)
    ##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
    ##  curl          4.3     2019-12-02 [1] CRAN (R 3.6.0)
    ##  data.table    1.12.8  2019-12-09 [1] CRAN (R 3.6.0)
    ##  digest        0.6.23  2019-11-23 [1] CRAN (R 3.6.0)
    ##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
    ##  fansi         0.4.0   2018-10-05 [1] CRAN (R 3.6.0)
    ##  foreign       0.8-71  2018-07-20 [2] CRAN (R 3.6.1)
    ##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
    ##  htmltools     0.4.0   2019-10-04 [1] CRAN (R 3.6.0)
    ##  knitr         1.26    2019-11-12 [1] CRAN (R 3.6.0)
    ##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
    ##  Rcpp          1.0.3   2019-11-08 [1] CRAN (R 3.6.0)
    ##  rlang         0.4.2   2019-11-23 [1] CRAN (R 3.6.0)
    ##  rmarkdown     2.0     2019-12-12 [1] CRAN (R 3.6.0)
    ##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
    ##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
    ##  stringr       1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
    ##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
    ##  xfun          0.11    2019-11-12 [1] CRAN (R 3.6.0)
    ##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
    ## 
    ## [1] /Users/adamsparks/Library/R/3.x/library
    ## [2] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
