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
str(AAC_codes)
```

    ## Classes 'data.table' and 'data.frame':   1436 obs. of  5 variables:
    ##  $ aac : chr  "NSW_PT001" "NSW_PT003" "NSW_PT004" "NSW_PT005" ...
    ##  $ town: chr  "Albion Park" "Armidale" "Armidale Airport" "Badgery's Creek" ...
    ##  $ lon : num  151 152 152 151 154 ...
    ##  $ lat : num  -34.6 -30.5 -30.5 -33.9 -28.8 ...
    ##  $ elev: num  8 987 1079 81.2 1.3 ...
    ##  - attr(*, ".internal.selfref")=<externalptr> 
    ##  - attr(*, "sorted")= chr "aac"

Save the stations to disk for use in the R package.

``` r
if (!dir.exists("../inst/extdata")) {
  dir.create("../inst/extdata", recursive = TRUE)
}

save(AAC_codes,
     file = "../inst/extdata/AAC_codes.rda",
     compress = "bzip2"
)
```

## Session Info

``` r
sessioninfo::session_info()
```

    ## ─ Session info ───────────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 3.6.2 (2019-12-12)
    ##  os       macOS Catalina 10.15.2      
    ##  system   x86_64, darwin15.6.0        
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  ctype    en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2020-01-20                  
    ## 
    ## ─ Packages ───────────────────────────────────────────────────────────────────
    ##  package     * version    date       lib source                             
    ##  assertthat    0.2.1      2019-03-21 [1] CRAN (R 3.6.0)                     
    ##  cli           2.0.1      2020-01-08 [1] CRAN (R 3.6.2)                     
    ##  clisymbols    1.2.0      2017-05-21 [1] CRAN (R 3.6.0)                     
    ##  crayon        1.3.4      2017-09-16 [1] CRAN (R 3.6.0)                     
    ##  curl          4.3        2019-12-02 [1] CRAN (R 3.6.0)                     
    ##  data.table    1.12.8     2019-12-09 [1] CRAN (R 3.6.0)                     
    ##  digest        0.6.23     2019-11-23 [1] CRAN (R 3.6.0)                     
    ##  evaluate      0.14       2019-05-28 [1] CRAN (R 3.6.0)                     
    ##  fansi         0.4.1      2020-01-08 [1] CRAN (R 3.6.2)                     
    ##  foreign       0.8-72     2019-08-02 [1] CRAN (R 3.6.2)                     
    ##  glue          1.3.1.9000 2020-01-17 [1] Github (tidyverse/glue@8094d3b)    
    ##  htmltools     0.4.0      2019-10-04 [1] CRAN (R 3.6.0)                     
    ##  knitr         1.27       2020-01-16 [1] CRAN (R 3.6.2)                     
    ##  magrittr      1.5        2014-11-22 [1] CRAN (R 3.6.0)                     
    ##  prompt        1.0.0      2020-01-12 [1] Github (gaborcsardi/prompt@b332c42)
    ##  Rcpp          1.0.3      2019-11-08 [1] CRAN (R 3.6.0)                     
    ##  rlang         0.4.2      2019-11-23 [1] CRAN (R 3.6.0)                     
    ##  rmarkdown     2.0        2019-12-12 [1] CRAN (R 3.6.0)                     
    ##  rstudioapi    0.10       2019-03-19 [1] CRAN (R 3.6.0)                     
    ##  sessioninfo   1.1.1      2018-11-05 [1] CRAN (R 3.6.0)                     
    ##  stringi       1.4.5      2020-01-11 [1] CRAN (R 3.6.2)                     
    ##  stringr       1.4.0      2019-02-10 [1] CRAN (R 3.6.0)                     
    ##  withr         2.1.2      2018-03-15 [1] CRAN (R 3.6.0)                     
    ##  xfun          0.12       2020-01-13 [1] CRAN (R 3.6.0)                     
    ##  yaml          2.2.0      2018-07-25 [1] CRAN (R 3.6.0)                     
    ## 
    ## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
