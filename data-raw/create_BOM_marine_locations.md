Create BOM Marine Zones Database
================

<STYLE type='text/css' scoped>
PRE.fansi SPAN {padding-top: .25em; padding-bottom: .25em};
</STYLE>

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

new_marine_AAC_codes <-
  foreign::read.dbf(paste0(tempdir(), "marine_AAC_codes.dbf"), as.is = TRUE)

# convert names to lower case for consistency with bomrang output
names(new_marine_AAC_codes) <- tolower(names(new_marine_AAC_codes))

# reorder columns
new_marine_AAC_codes <- new_marine_AAC_codes[, c(1, 3, 4, 5, 6, 7)]

data.table::setDT(new_marine_AAC_codes)
data.table::setkey(new_marine_AAC_codes, "aac")
```

## Show Changes from Last Release

``` r
`%notin%` <- function(x, table) {
  match(x, table, nomatch = 0L) == 0L
}

load(system.file("extdata", "marine_AAC_codes.rda", package = "bomrang"))

(changes <-
    waldo::compare(new_marine_AAC_codes, marine_AAC_codes, max_diffs = Inf))
```

<PRE class="fansi fansi-output"><CODE>##      old$dist_name            | new$dist_name                
##  [6] <span style='color: #555555;'>"Macquarie"</span><span>              | </span><span style='color: #555555;'>"Macquarie"</span><span>              [6] 
##  [7] </span><span style='color: #555555;'>"Coffs"</span><span>                  | </span><span style='color: #555555;'>"Coffs"</span><span>                  [7] 
##  [8] </span><span style='color: #555555;'>"Byron"</span><span>                  | </span><span style='color: #555555;'>"Byron"</span><span>                  [8] 
##  [9] </span><span style='color: #00BB00;'>"Sydney Enclosed Waters"</span><span> - </span><span style='color: #00BB00;'>"Sydney Closed Waters"</span><span>   [9] 
## [10] </span><span style='color: #555555;'>"Beagle Bonaparte Coast"</span><span> | </span><span style='color: #555555;'>"Beagle Bonaparte Coast"</span><span> [10]
## [11] </span><span style='color: #555555;'>"North Tiwi Coast"</span><span>       | </span><span style='color: #555555;'>"North Tiwi Coast"</span><span>       [11]
## [12] </span><span style='color: #555555;'>"Van Diemen Gulf"</span><span>        | </span><span style='color: #555555;'>"Van Diemen Gulf"</span><span>        [12]
</span></CODE></PRE>

# Save the data

Save the marine zones’ metadata and changes to disk for use in
*bomrang*.

``` r
if (!dir.exists("../inst/extdata")) {
  dir.create("../inst/extdata", recursive = TRUE)
}

save(marine_AAC_codes,
     file = "../inst/extdata/marine_AAC_codes.rda",
     compress = "bzip2")

marine_AAC_code_changes <- list()

release_version <- paste0("v", packageVersion("bomrang"))
marine_AAC_code_changes[[release_version]] <- changes

save(marine_AAC_code_changes,
     file = "../inst/extdata/marine_AAC_code_changes.rda",
     compress = "bzip2")
```

## Session Info

``` r
sessioninfo::session_info()
```

    ## ─ Session info ───────────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 4.0.4 (2021-02-15)
    ##  os       macOS Big Sur 10.16         
    ##  system   x86_64, darwin17.0          
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  ctype    en_AU.UTF-8                 
    ##  tz       Australia/Perth             
    ##  date     2021-03-10                  
    ## 
    ## ─ Packages ───────────────────────────────────────────────────────────────────
    ##  package     * version date       lib source        
    ##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.2)
    ##  cli           2.3.1   2021-02-23 [1] CRAN (R 4.0.4)
    ##  crayon        1.4.1   2021-02-08 [1] CRAN (R 4.0.2)
    ##  curl          4.3     2019-12-02 [1] CRAN (R 4.0.1)
    ##  data.table    1.14.0  2021-02-21 [1] CRAN (R 4.0.4)
    ##  diffobj       0.3.3   2021-01-07 [1] CRAN (R 4.0.2)
    ##  digest        0.6.27  2020-10-24 [1] CRAN (R 4.0.2)
    ##  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.2)
    ##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.1)
    ##  fansi         0.4.2   2021-01-15 [1] CRAN (R 4.0.2)
    ##  foreign       0.8-81  2020-12-22 [2] CRAN (R 4.0.4)
    ##  glue          1.4.2   2020-08-27 [1] CRAN (R 4.0.2)
    ##  htmltools     0.5.1.1 2021-01-22 [1] CRAN (R 4.0.2)
    ##  knitr         1.31    2021-01-27 [1] CRAN (R 4.0.2)
    ##  lifecycle     1.0.0   2021-02-15 [1] CRAN (R 4.0.4)
    ##  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.0.2)
    ##  pillar        1.5.1   2021-03-05 [1] CRAN (R 4.0.2)
    ##  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.0.2)
    ##  rematch2      2.1.2   2020-05-01 [1] CRAN (R 4.0.2)
    ##  rlang         0.4.10  2020-12-30 [1] CRAN (R 4.0.2)
    ##  rmarkdown     2.7     2021-02-19 [1] CRAN (R 4.0.4)
    ##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.2)
    ##  stringi       1.5.3   2020-09-09 [1] CRAN (R 4.0.2)
    ##  stringr       1.4.0   2019-02-10 [1] CRAN (R 4.0.2)
    ##  tibble        3.1.0   2021-02-25 [1] CRAN (R 4.0.2)
    ##  utf8          1.1.4   2018-05-24 [1] CRAN (R 4.0.2)
    ##  vctrs         0.3.6   2020-12-17 [1] CRAN (R 4.0.2)
    ##  waldo         0.2.5   2021-03-08 [1] CRAN (R 4.0.4)
    ##  withr         2.4.1   2021-01-26 [1] CRAN (R 4.0.2)
    ##  xfun          0.21    2021-02-10 [1] CRAN (R 4.0.2)
    ##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.2)
    ## 
    ## [1] /Users/adamsparks/Library/R/4.0/library
    ## [2] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
