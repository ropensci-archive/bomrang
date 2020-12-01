Create BOM Marine Zones Database
================

## Get BOM Forecast Marine Zones

BOM maintains a shapefile of forecast marine zone names and their
geographic locations. For ease, we’ll just use the .dbf file part of the
shapefile to extract AAC codes that can be used to add locations to the
forecast `data.table` that `get_coastal_forecast()` returns. The file is
available from BOM’s anonymous FTP server with spatial data
<ftp://ftp.bom.gov.au/anon/home/adfd/spatial/>, specifically the DBF
file portion of a shapefile,
<ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00003.dbf>.

``` r
curl::curl_download(
  "ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00003.dbf",
  destfile = paste0(tempdir(), "marine_AAC_codes.dbf"),
  mode = "wb",
  quiet = TRUE
)

marine_AAC_codes <-
  foreign::read.dbf(paste0(tempdir(), "marine_AAC_codes.dbf"), as.is = TRUE)

# convert names to lower case for consistency with bomrang output
names(marine_AAC_codes) <- tolower(names(marine_AAC_codes))

# reorder columns
marine_AAC_codes <- marine_AAC_codes[, c(1, 3, 4, 5, 6, 7)]

data.table::setDT(marine_AAC_codes)
data.table::setkey(marine_AAC_codes, "aac")

str(marine_AAC_codes)
```

    ## Classes 'data.table' and 'data.frame':   81 obs. of  6 variables:
    ##  $ aac       : chr  "NSW_MW001" "NSW_MW002" "NSW_MW003" "NSW_MW004" ...
    ##  $ dist_name : chr  "Eden" "Batemans" "Illawarra" "Sydney" ...
    ##  $ state_code: chr  "NSW" "NSW" "NSW" "NSW" ...
    ##  $ type      : chr  "Coastal" "Coastal" "Coastal" "Coastal" ...
    ##  $ pt_1_name : chr  "Montague Island" "Ulladulla" "Port Hacking" "Broken Bay" ...
    ##  $ pt_2_name : chr  "Gabo Island" "Montague Island" "Ulladulla" "Port Hacking" ...
    ##  - attr(*, ".internal.selfref")=<externalptr> 
    ##  - attr(*, "sorted")= chr "aac"

Save the marine zones to disk for use in bomrang.

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

    ## ─ Session info ───────────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 4.0.3 (2020-10-10)
    ##  os       macOS Catalina 10.15.7      
    ##  system   x86_64, darwin17.0          
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  ctype    en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2020-12-01                  
    ## 
    ## ─ Packages ───────────────────────────────────────────────────────────────────
    ##  package     * version    date       lib source                       
    ##  assertthat    0.2.1      2019-03-21 [1] CRAN (R 4.0.3)               
    ##  cli           2.2.0      2020-11-20 [1] CRAN (R 4.0.3)               
    ##  crayon        1.3.4.9000 2020-11-15 [1] Github (r-lib/crayon@4bceba8)
    ##  curl          4.3        2019-12-02 [1] CRAN (R 4.0.3)               
    ##  data.table    1.13.3     2020-11-06 [1] local                        
    ##  digest        0.6.27     2020-10-24 [1] CRAN (R 4.0.2)               
    ##  evaluate      0.14       2019-05-28 [1] CRAN (R 4.0.3)               
    ##  fansi         0.4.1      2020-01-08 [1] CRAN (R 4.0.3)               
    ##  foreign       0.8-80     2020-05-24 [2] CRAN (R 4.0.3)               
    ##  glue          1.4.2      2020-08-27 [1] CRAN (R 4.0.2)               
    ##  htmltools     0.5.0      2020-06-16 [1] CRAN (R 4.0.2)               
    ##  knitr         1.30       2020-09-22 [1] CRAN (R 4.0.2)               
    ##  magrittr      2.0.1      2020-11-17 [1] CRAN (R 4.0.3)               
    ##  rlang         0.4.9      2020-11-26 [1] CRAN (R 4.0.3)               
    ##  rmarkdown     2.5        2020-10-21 [1] CRAN (R 4.0.3)               
    ##  sessioninfo   1.1.1      2018-11-05 [1] CRAN (R 4.0.2)               
    ##  stringi       1.5.3      2020-09-09 [1] CRAN (R 4.0.2)               
    ##  stringr       1.4.0      2019-02-10 [1] CRAN (R 4.0.3)               
    ##  withr         2.3.0      2020-09-22 [1] CRAN (R 4.0.2)               
    ##  xfun          0.19       2020-10-30 [1] CRAN (R 4.0.2)               
    ##  yaml          2.2.1      2020-02-01 [1] CRAN (R 4.0.3)               
    ## 
    ## [1] /Users/adamsparks/Library/R/4.0/library
    ## [2] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
