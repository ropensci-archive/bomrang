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
install.packages("bomrang", repos = "http://cran.us.r-project.org")
```

    ## Installing package into '/Users/adamsparks/Library/R/4.0/library'
    ## (as 'lib' is unspecified)

    ## 
    ## The downloaded binary packages are in
    ##  /var/folders/hc/tft3s5bn48gb81cs99mycyf00000gn/T//RtmpVeB5P6/downloaded_packages

``` r
load(system.file("extdata", "marine_AAC_codes.rda", package = "bomrang"))

(
  marine_AAC_code_changes <-
    diffobj::diffPrint(new_marine_AAC_codes, marine_AAC_codes)
)
```

<PRE class="fansi fansi-output"><CODE>## <span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>new_marine_AAC_codes</span><span>                                                 
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>marine_AAC_codes</span><span>                                                     
## </span><span style='color: #00BBBB;'>@@ 8,5 / 8,5 @@                                                        </span><span>
## </span><span style='color: #555555;'>~           aac                           dist_name state_code     type</span><span>
##   </span><span style='color: #555555;'> 7: </span><span>NSW_MW007                               Coffs        NSW  Coastal
##   </span><span style='color: #555555;'> 8: </span><span>NSW_MW008                               Byron        NSW  Coastal
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #555555;'> 9: </span><span>NSW_MW009              Sydney </span><span style='color: #BBBB00;'>Enclosed</span><span> Waters        NSW    Local
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #555555;'> 9: </span><span>NSW_MW009                Sydney </span><span style='color: #0000BB;'>Closed</span><span> Waters        NSW    Local
##   </span><span style='color: #555555;'>10: </span><span> NT_MW001              Beagle Bonaparte Coast         NT  Coastal
##   </span><span style='color: #555555;'>11: </span><span> NT_MW002                    North Tiwi Coast         NT  Coastal
</span></CODE></PRE>

# Save Marine Locations Data and Changes

Save the marine zones’ metadata and changes to disk for use in
*bomrang*.

``` r
if (!dir.exists("../inst/extdata")) {
  dir.create("../inst/extdata", recursive = TRUE)
}

save(marine_AAC_codes,
     file = "../inst/extdata/marine_AAC_codes.rda",
     compress = "bzip2")

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
    ##  date     2021-03-24                  
    ## 
    ## ─ Packages ───────────────────────────────────────────────────────────────────
    ##  package     * version date       lib source                            
    ##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.2)                    
    ##  cli           2.3.1   2021-02-23 [1] CRAN (R 4.0.4)                    
    ##  crayon        1.4.1   2021-02-08 [1] CRAN (R 4.0.2)                    
    ##  curl          4.3     2019-12-02 [1] CRAN (R 4.0.1)                    
    ##  data.table    1.14.0  2021-02-21 [1] CRAN (R 4.0.4)                    
    ##  diffobj       0.3.4   2021-03-22 [1] CRAN (R 4.0.4)                    
    ##  digest        0.6.27  2020-10-24 [1] CRAN (R 4.0.2)                    
    ##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.1)                    
    ##  fansi         0.4.2   2021-01-15 [1] CRAN (R 4.0.2)                    
    ##  foreign       0.8-81  2020-12-22 [2] CRAN (R 4.0.4)                    
    ##  glue          1.4.2   2020-08-27 [1] CRAN (R 4.0.2)                    
    ##  htmltools     0.5.1.1 2021-01-22 [1] CRAN (R 4.0.2)                    
    ##  knitr         1.31    2021-01-27 [1] CRAN (R 4.0.2)                    
    ##  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.0.2)                    
    ##  rlang         0.4.10  2020-12-30 [1] CRAN (R 4.0.2)                    
    ##  rmarkdown     2.7.3   2021-03-15 [1] Github (rstudio/rmarkdown@61db7a9)
    ##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.2)                    
    ##  stringi       1.5.3   2020-09-09 [1] CRAN (R 4.0.2)                    
    ##  stringr       1.4.0   2019-02-10 [1] CRAN (R 4.0.2)                    
    ##  withr         2.4.1   2021-01-26 [1] CRAN (R 4.0.2)                    
    ##  xfun          0.22    2021-03-11 [1] CRAN (R 4.0.4)                    
    ##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.2)                    
    ## 
    ## [1] /Users/adamsparks/Library/R/4.0/library
    ## [2] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
