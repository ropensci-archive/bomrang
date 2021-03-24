Create BOM Précis Forecast Town Names Database
================

<STYLE type='text/css' scoped>
PRE.fansi SPAN {padding-top: .25em; padding-bottom: .25em};
</STYLE>

## Get BOM Forecast Town Names and Geographic Locations

BOM maintains a shapefile of forecast town names and their geographic
locations. For ease, we’ll just use the .dbf file part of the shapefile
to extract AAC codes that can be used to add lat/lon values to the
forecast `data.table` that `get_precis_forecast()` returns. The file is
available from BOM’s anonymous FTP server with spatial data
<ftp://ftp.bom.gov.au/anon/home/adfd/spatial/>, specifically the DBF
file portion of a shapefile,
<ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf>.

``` r
curl::curl_download(
  "ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf",
  destfile = paste0(tempdir(), "AAC_codes.dbf"),
  mode = "wb",
  quiet = TRUE
)

new_AAC_codes <-
  foreign::read.dbf(paste0(tempdir(), "AAC_codes.dbf"), as.is = TRUE)

# convert names to lower case for consistency with bomrang output
names(new_AAC_codes) <- tolower(names(new_AAC_codes))

# reorder columns
new_AAC_codes <- new_AAC_codes[, c(2:3, 7:9)]

data.table::setDT(new_AAC_codes)
data.table::setnames(new_AAC_codes, c(2, 5), c("town", "elev"))
data.table::setkey(new_AAC_codes, "aac")
```

## Show Changes from Last Release

To ensure that the data being compared is from the most recent release,
reinstall bomrang from CRAN.

``` r
install.packages("bomrang", repos = "http://cran.us.r-project.org")
```

    ## Installing package into '/Users/adamsparks/Library/R/4.0/library'
    ## (as 'lib' is unspecified)

    ## 
    ## The downloaded binary packages are in
    ##  /var/folders/hc/tft3s5bn48gb81cs99mycyf00000gn/T//RtmpJ1H8Ws/downloaded_packages

``` r
load(system.file("extdata", "AAC_codes.rda", package = "bomrang"))

(AAC_code_changes <- diffobj::diffPrint(new_AAC_codes, AAC_codes))
```

<PRE class="fansi fansi-output"><CODE>## <span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>new_AAC_codes</span><span>                                            
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>AAC_codes</span><span>                                                
## </span><span style='color: #00BBBB;'>@@ 6,7 / 6,7 @@                                            </span><span>
## </span><span style='color: #555555;'>~             aac               town   lon    lat   elev   </span><span>
##      5: NSW_PT006            Ballina 153.6 -28.84    1.3   
##     ---                                                    
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>1432:</span><span>  </span><span style='color: #0000BB;'>WA_PT285</span><span>   </span><span style='color: #0000BB;'>Halls</span><span> </span><span style='color: #0000BB;'>Creek</span><span> </span><span style='color: #0000BB;'>Airport</span><span> </span><span style='color: #0000BB;'>127.7</span><span> </span><span style='color: #0000BB;'>-18.23</span><span>  </span><span style='color: #0000BB;'>409.4</span><span>
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>1433:</span><span>  </span><span style='color: #0000BB;'>WA_PT286</span><span> </span><span style='color: #0000BB;'>Yampi</span><span> </span><span style='color: #0000BB;'>Sound</span><span> </span><span style='color: #0000BB;'>(Defence)</span><span> </span><span style='color: #0000BB;'>124.0</span><span> </span><span style='color: #0000BB;'>-16.77</span><span>   </span><span style='color: #0000BB;'>41.3</span><span>
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>1462:</span><span>  WA_PT287    Karijini (DPAW) 118.5 -22.49  692.4   
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>1434:</span><span>  WA_PT287       Karijini (DPAW) 118.5 -22.49  692.4
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>1463:</span><span>  WA_PT288  Pemberton (DAFWA) 115.9 -34.41  174.0   
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>1435:</span><span>  WA_PT288     Pemberton (DAFWA) 115.9 -34.41  174.0
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>1464:</span><span>  WA_PT289 Lancelin (Defence) 115.2 -30.84    7.0   
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>1436:</span><span>  WA_PT289    Lancelin (Defence) 115.2 -30.84    7.0
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>1465:</span><span>  </span><span style='color: #BBBB00;'>WA_PT290</span><span>          </span><span style='color: #BBBB00;'>Mundaring</span><span> </span><span style='color: #BBBB00;'>116.2</span><span> </span><span style='color: #BBBB00;'>-31.90</span><span>  </span><span style='color: #BBBB00;'>300.0</span><span>   
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>1466:</span><span>  </span><span style='color: #BBBB00;'>WA_PT291</span><span>     </span><span style='color: #BBBB00;'>Karijini</span><span> </span><span style='color: #BBBB00;'>North</span><span> </span><span style='color: #BBBB00;'>118.4</span><span> </span><span style='color: #BBBB00;'>-22.30</span><span>  </span><span style='color: #BBBB00;'>474.0</span><span>
</span></CODE></PRE>

# Save the data

Save the stations’ metadata and changes to disk for use in *bomrang*.

``` r
if (!dir.exists("../inst/extdata")) {
  dir.create("../inst/extdata", recursive = TRUE)
}

save(AAC_codes,
     file = "../inst/extdata/AAC_codes.rda",
     compress = "bzip2"
)

save(AAC_code_changes,
     file = "../inst/extdata/AAC_code_changes.rda",
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
