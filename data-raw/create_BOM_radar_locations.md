Create BOM Radar Location Database
================

## Get BOM Radar Locations

BOM maintains a shapefile of radar site names and their geographic
locations. For ease, we’ll just use the .dbf file part of the shapefile
to extract the product codes and radar locations. The file is available
from BOM’s anonymous FTP server with spatial data
<ftp://ftp.bom.gov.au/anon/home/adfd/spatial/>, specifically the DBF
file portion of a shapefile,
<ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDR00007.dbf>

``` r
curl::curl_download(
  "ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDR00007.dbf",
  destfile = paste0(tempdir(), "radar_locations.dbf"),
  mode = "wb",
  quiet = TRUE
)

radar_locations <-
  foreign::read.dbf(paste0(tempdir(), "radar_locations.dbf"), as.is = TRUE)

radar_locations$LocationID <- ifelse(test = nchar(radar_locations$LocationID) == 1, 
                                     yes = paste0("0", radar_locations$LocationID), 
                                     no = radar_locations$LocationID)
```

Save the radar locations to disk for use in the R package.

``` r
if (!dir.exists("../inst/extdata")) {
  dir.create("../inst/extdata", recursive = TRUE)
}

save(radar_locations, file = "../inst/extdata/radar_locations.rda",
     compress = "bzip2")
```

## Session Info

``` r
sessioninfo::session_info()
```

    ## ─ Session info ──────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 3.5.3 (2019-03-11)
    ##  os       macOS Mojave 10.14.3        
    ##  system   x86_64, darwin18.2.0        
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  ctype    en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2019-03-18                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version date       lib source        
    ##  assertthat    0.2.0   2017-04-11 [1] CRAN (R 3.5.3)
    ##  cli           1.0.1   2018-09-25 [1] CRAN (R 3.5.3)
    ##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.5.3)
    ##  curl          3.3     2019-01-10 [1] CRAN (R 3.5.3)
    ##  digest        0.6.18  2018-10-10 [1] CRAN (R 3.5.3)
    ##  evaluate      0.13    2019-02-12 [1] CRAN (R 3.5.3)
    ##  foreign       0.8-71  2018-07-20 [3] CRAN (R 3.5.3)
    ##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.5.3)
    ##  knitr         1.22    2019-03-08 [1] CRAN (R 3.5.3)
    ##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.5.3)
    ##  Rcpp          1.0.1   2019-03-17 [1] CRAN (R 3.5.3)
    ##  rmarkdown     1.12    2019-03-14 [1] CRAN (R 3.5.3)
    ##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.5.3)
    ##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.5.3)
    ##  stringr       1.4.0   2019-02-10 [1] CRAN (R 3.5.3)
    ##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.5.3)
    ##  xfun          0.5     2019-02-20 [1] CRAN (R 3.5.3)
    ##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.5.3)
    ## 
    ## [1] /Users/adamsparks/Library/R/3.x/library
    ## [2] /usr/local/lib/R/3.5/site-library
    ## [3] /usr/local/Cellar/r/3.5.3/lib/R/library
