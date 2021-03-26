Create BOM Radar Location Database
================

<STYLE type='text/css' scoped>
PRE.fansi SPAN {padding-top: .25em; padding-bottom: .25em};
</STYLE>

## Get BOM Radar Locations

BOM maintains a shapefile of radar site names and their geographic
locations. For ease, we’ll just use the .dbf file part of the shapefile
to extract the product codes and radar locations. The file is available
from BOM’s anonymous FTP server with spatial data
<ftp://ftp.bom.gov.au/anon/home/adfd/spatial/>, specifically the DBF
file portion of a shapefile,
<ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDR00007.dbf>.

``` r
curl::curl_download(
  "ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDR00007.dbf",
  destfile = paste0(tempdir(), "radar_locations.dbf"),
  mode = "wb",
  quiet = TRUE
)

new_radar_locations <-
  foreign::read.dbf(paste0(tempdir(), "radar_locations.dbf"), as.is = TRUE)

new_radar_locations$LocationID <-
  ifelse(
    test = nchar(new_radar_locations$LocationID) == 1,
    yes = paste0("0", new_radar_locations$LocationID),
    no = new_radar_locations$LocationID
  )

data.table::setDT(new_radar_locations)
data.table::setkey(new_radar_locations, "Name")

str(new_radar_locations)
```

    ## Classes 'data.table' and 'data.frame':   63 obs. of  13 variables:
    ##  $ Name      : chr  "Adelaide" "Albany" "Alice Springs" "Bairnsdale" ...
    ##  $ Longitude : num  138 118 134 148 148 ...
    ##  $ Latitude  : num  -34.6 -34.9 -23.8 -37.9 -19.9 ...
    ##  $ Radar_id  : int  64 31 25 68 24 93 66 1 17 19 ...
    ##  $ Full_Name : chr  "Adelaide (Buckland Park)" "Albany" "Alice Springs" "Bairnsdale" ...
    ##  $ IDRnn0name: chr  "BuckPk" "Albany" "AliceSp" "Bnsdale" ...
    ##  $ IDRnn1name: chr  "BucklandPk" "Albany" "AliceSprings" "Bairnsdale" ...
    ##  $ State     : chr  "SA" "WA" "NT" "VIC" ...
    ##  $ Type      : chr  "Doppler" "Doppler" "Standard weather watch" "Doppler" ...
    ##  $ Group     : chr  "Yes" "Yes" "Yes" "Yes" ...
    ##  $ Status    : chr  "Public" "Public" "Public" "Public" ...
    ##  $ Archive   : chr  "BuckPk" "Albany" "AliceSp" "Bnsdale" ...
    ##  $ LocationID: chr  "64" "31" "25" "68" ...
    ##  - attr(*, "data_types")= chr [1:13] "C" "F" "F" "N" ...
    ##  - attr(*, ".internal.selfref")=<externalptr> 
    ##  - attr(*, "sorted")= chr "Name"

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
    ##  /var/folders/hc/tft3s5bn48gb81cs99mycyf00000gn/T//Rtmp8LjsfH/downloaded_packages

``` r
load(system.file("extdata", "radar_locations.rda", package = "bomrang"))

(
  radar_location_changes <-
    diffobj::diffPrint(new_radar_locations, radar_locations)
)
```

<PRE class="fansi fansi-output"><CODE>## <span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>new_radar_locations</span><span>                                                     
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>radar_locations</span><span>                                                         
## </span><span style='color: #00BBBB;'>@@ 5,5 / 5,4 @@                                                           </span><span>
## </span><span style='color: #555555;'>~                 Name Longitude Latitude Radar_id                        </span><span>
##   </span><span style='color: #555555;'> 4: </span><span>      Bairnsdale     147.6   -37.89       68                        
##   </span><span style='color: #555555;'> 5: </span><span>           Bowen     148.1   -19.89       24                        
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #555555;'> 6: </span><span>      </span><span style='color: #BBBB00;'>Brewarrina</span><span>     </span><span style='color: #BBBB00;'>146.8</span><span>   </span><span style='color: #BBBB00;'>-29.97</span><span>       </span><span style='color: #BBBB00;'>93</span><span>                        
##   </span><span style='color: #555555;'> 7: </span><span>        Brisbane     153.2   -27.72       66                        
##   </span><span style='color: #555555;'> 8: </span><span>    Broadmeadows     144.9   -37.69        1                        
## </span><span style='color: #00BBBB;'>@@ 35,5 / 34,5 @@                                                         </span><span>
##   </span><span style='color: #555555;'>34: </span><span>         Marburg     152.5   -27.61       50                        
##   </span><span style='color: #555555;'>35: </span><span>       Melbourne     144.8   -37.86        2                        
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #555555;'>36: </span><span>         Mildura     </span><span style='color: #BBBB00;'>141.6</span><span>   </span><span style='color: #BBBB00;'>-34.29</span><span>       </span><span style='color: #BBBB00;'>97</span><span>                        
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #555555;'>35: </span><span>         Mildura     </span><span style='color: #0000BB;'>142.1</span><span>   </span><span style='color: #0000BB;'>-34.24</span><span>       </span><span style='color: #0000BB;'>30</span><span>                        
##   </span><span style='color: #555555;'>37: </span><span>           Moree     149.8   -29.50       53                        
##   </span><span style='color: #555555;'>38: </span><span>   Mornington Is     139.2   -16.67       36                        
## </span><span style='color: #00BBBB;'>@@ 70,5 / 69,4 @@                                                         </span><span>
##   </span><span style='color: #555555;'> 4: </span><span>                             Bairnsdale     Bnsdale       Bairnsdale
##   </span><span style='color: #555555;'> 5: </span><span>                                  Bowen       Bowen            Bowen
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #555555;'> 6: </span><span>                             </span><span style='color: #BBBB00;'>Brewarrina</span><span>     </span><span style='color: #BBBB00;'>Brewrna</span><span>          </span><span style='color: #BBBB00;'>Brewrna</span><span>
##   </span><span style='color: #555555;'> 7: </span><span>                Brisbane (Mt Stapylton)     MtStapl      MtStapylton
##   </span><span style='color: #555555;'> 8: </span><span>               Melbourne (Broadmeadows)      CampRd           CampRd
## </span><span style='color: #00BBBB;'>@@ 133,7 / 131,6 @@                                                       </span><span>
##   </span><span style='color: #555555;'> 2: </span><span>   WA                Doppler   Yes    Public  Albany         31     
##   </span><span style='color: #555555;'> 3: </span><span>   NT Standard weather watch   Yes    Public AliceSp         25     
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #555555;'> 4: </span><span>  VIC                </span><span style='color: #BBBB00;'>Doppler</span><span>   Yes    Public Bnsdale         68     
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #555555;'> 4: </span><span>  VIC </span><span style='color: #0000BB;'>Standard</span><span> </span><span style='color: #0000BB;'>weather</span><span> </span><span style='color: #0000BB;'>watch</span><span>   Yes    Public Bnsdale         68     
##   </span><span style='color: #555555;'> 5: </span><span>  QLD Standard weather watch   Yes    Public   Bowen         24     
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #555555;'> 6: </span><span>  </span><span style='color: #BBBB00;'>NSW</span><span>                </span><span style='color: #BBBB00;'>Doppler</span><span>   </span><span style='color: #BBBB00;'>Yes</span><span>    </span><span style='color: #BBBB00;'>Public</span><span> </span><span style='color: #BBBB00;'>Brewrna</span><span>         </span><span style='color: #BBBB00;'>93</span><span>     
##   </span><span style='color: #555555;'> 7: </span><span>  QLD                Doppler   Yes    Public MtStapl         66     
##   </span><span style='color: #555555;'> 8: </span><span>  VIC                Doppler   Yes Reg_users  CampRd         01     
## </span><span style='color: #00BBBB;'>@@ 143,5 / 140,5 @@                                                       </span><span>
##   </span><span style='color: #555555;'>12: </span><span>   WA Standard weather watch   Yes    Public  Carnvn         05     
##   </span><span style='color: #555555;'>13: </span><span>   SA Standard weather watch   Yes    Public  Ceduna         33     
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #555555;'>14: </span><span>   WA                </span><span style='color: #BBBB00;'>Doppler</span><span>   Yes    Public Dampier         15     
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #555555;'>13: </span><span>   WA </span><span style='color: #0000BB;'>Standard</span><span> </span><span style='color: #0000BB;'>weather</span><span> </span><span style='color: #0000BB;'>watch</span><span>   Yes    Public Dampier         15     
##   </span><span style='color: #555555;'>15: </span><span>   NT                Doppler   Yes    Public Berrima         63     
##   </span><span style='color: #555555;'>16: </span><span>   NT Standard weather watch    No Reg_users  Darwin         10     
## </span><span style='color: #00BBBB;'>@@ 165,5 / 162,5 @@                                                       </span><span>
##   </span><span style='color: #555555;'>34: </span><span>  QLD Standard weather watch   Yes    Public Marburg         50     
##   </span><span style='color: #555555;'>35: </span><span>  VIC                Doppler   Yes    Public    Melb         02     
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #555555;'>36: </span><span>  VIC                </span><span style='color: #BBBB00;'>Doppler</span><span>   Yes    Public Mildura         </span><span style='color: #BBBB00;'>97</span><span>     
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #555555;'>35: </span><span>  VIC </span><span style='color: #0000BB;'>Standard</span><span> </span><span style='color: #0000BB;'>weather</span><span> </span><span style='color: #0000BB;'>watch</span><span>   Yes    Public Mildura         </span><span style='color: #0000BB;'>30</span><span>     
##   </span><span style='color: #555555;'>37: </span><span>  NSW Standard weather watch   Yes    Public   Moree         53     
##   </span><span style='color: #555555;'>38: </span><span>  QLD Standard weather watch   Yes    Public GlfCarp         36
</span></CODE></PRE>

# Save Radar Stations Data and Changes

Save the radar stations’ metadata and changes to disk for use in
*bomrang*.

``` r
if (!dir.exists("../inst/extdata")) {
  dir.create("../inst/extdata", recursive = TRUE)
}

radar_locations <- new_radar_locations

save(radar_locations,
     file = "../inst/extdata/radar_locations.rda",
     compress = "bzip2")

save(radar_location_changes,
     file = "../inst/extdata/radar_location_changes.rda",
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
    ##  date     2021-03-26                  
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
