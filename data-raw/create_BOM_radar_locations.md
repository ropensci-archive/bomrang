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

``` r
`%notin%` <- function(x, table) {
  match(x, table, nomatch = 0L) == 0L
}

load(system.file("extdata", "radar_locations.rda", package = "bomrang"))

(changes <-
    waldo::compare(new_radar_locations, radar_locations, max_diffs = Inf))
```

<PRE class="fansi fansi-output"><CODE>## `attr(old, 'row.names')[60:63]`: <span style='color: #555555;'>60</span><span> </span><span style='color: #555555;'>61</span><span> </span><span style='color: #555555;'>62</span><span> </span><span style='color: #BBBB00;'>63</span><span>
## `attr(new, 'row.names')[60:62]`: </span><span style='color: #555555;'>60</span><span> </span><span style='color: #555555;'>61</span><span> </span><span style='color: #555555;'>62</span><span>   
## 
##     old$Name        | new$Name           
## [3] </span><span style='color: #555555;'>"Alice Springs"</span><span> | </span><span style='color: #555555;'>"Alice Springs"</span><span> [3]
## [4] </span><span style='color: #555555;'>"Bairnsdale"</span><span>    | </span><span style='color: #555555;'>"Bairnsdale"</span><span>    [4]
## [5] </span><span style='color: #555555;'>"Bowen"</span><span>         | </span><span style='color: #555555;'>"Bowen"</span><span>         [5]
## [6] </span><span style='color: #BBBB00;'>"Brewarrina"</span><span>    -                    
## [7] </span><span style='color: #555555;'>"Brisbane"</span><span>      | </span><span style='color: #555555;'>"Brisbane"</span><span>      [6]
## [8] </span><span style='color: #555555;'>"Broadmeadows"</span><span>  | </span><span style='color: #555555;'>"Broadmeadows"</span><span>  [7]
## [9] </span><span style='color: #555555;'>"Broome"</span><span>        | </span><span style='color: #555555;'>"Broome"</span><span>        [8]
## 
## `old$Longitude[3:9]`: </span><span style='color: #555555;'>133.888</span><span> </span><span style='color: #555555;'>147.5755</span><span> </span><span style='color: #555555;'>148.075</span><span> </span><span style='color: #BBBB00;'>146.814</span><span> </span><span style='color: #555555;'>153.24</span><span> </span><span style='color: #555555;'>144.946</span><span> </span><span style='color: #555555;'>122.2353</span><span>
## `new$Longitude[3:8]`: </span><span style='color: #555555;'>133.888</span><span> </span><span style='color: #555555;'>147.5755</span><span> </span><span style='color: #555555;'>148.075</span><span>         </span><span style='color: #555555;'>153.24</span><span> </span><span style='color: #555555;'>144.946</span><span> </span><span style='color: #555555;'>122.2353</span><span>
## 
## `old$Latitude[3:9]`: </span><span style='color: #555555;'>-23.796</span><span> </span><span style='color: #555555;'>-37.8876</span><span> </span><span style='color: #555555;'>-19.886</span><span> </span><span style='color: #BBBB00;'>-29.971</span><span> </span><span style='color: #555555;'>-27.7178</span><span> </span><span style='color: #555555;'>-37.691</span><span> </span><span style='color: #555555;'>-17.9483</span><span>
## `new$Latitude[3:8]`: </span><span style='color: #555555;'>-23.796</span><span> </span><span style='color: #555555;'>-37.8876</span><span> </span><span style='color: #555555;'>-19.886</span><span>         </span><span style='color: #555555;'>-27.7178</span><span> </span><span style='color: #555555;'>-37.691</span><span> </span><span style='color: #555555;'>-17.9483</span><span>
## 
## `old$Radar_id[3:9]`: </span><span style='color: #555555;'>25</span><span> </span><span style='color: #555555;'>68</span><span> </span><span style='color: #555555;'>24</span><span> </span><span style='color: #BBBB00;'>93</span><span> </span><span style='color: #555555;'>66</span><span> </span><span style='color: #555555;'>1</span><span> </span><span style='color: #555555;'>17</span><span>
## `new$Radar_id[3:8]`: </span><span style='color: #555555;'>25</span><span> </span><span style='color: #555555;'>68</span><span> </span><span style='color: #555555;'>24</span><span>    </span><span style='color: #555555;'>66</span><span> </span><span style='color: #555555;'>1</span><span> </span><span style='color: #555555;'>17</span><span>
## 
##     old$Full_Name              | new$Full_Name                 
## [3] </span><span style='color: #555555;'>"Alice Springs"</span><span>            | </span><span style='color: #555555;'>"Alice Springs"</span><span>            [3]
## [4] </span><span style='color: #555555;'>"Bairnsdale"</span><span>               | </span><span style='color: #555555;'>"Bairnsdale"</span><span>               [4]
## [5] </span><span style='color: #555555;'>"Bowen"</span><span>                    | </span><span style='color: #555555;'>"Bowen"</span><span>                    [5]
## [6] </span><span style='color: #BBBB00;'>"Brewarrina"</span><span>               -                               
## [7] </span><span style='color: #555555;'>"Brisbane (Mt Stapylton)"</span><span>  | </span><span style='color: #555555;'>"Brisbane (Mt Stapylton)"</span><span>  [6]
## [8] </span><span style='color: #555555;'>"Melbourne (Broadmeadows)"</span><span> | </span><span style='color: #555555;'>"Melbourne (Broadmeadows)"</span><span> [7]
## [9] </span><span style='color: #555555;'>"Broome"</span><span>                   | </span><span style='color: #555555;'>"Broome"</span><span>                   [8]
## 
##     old$IDRnn0name | new$IDRnn0name    
## [3] </span><span style='color: #555555;'>"AliceSp"</span><span>      | </span><span style='color: #555555;'>"AliceSp"</span><span>      [3]
## [4] </span><span style='color: #555555;'>"Bnsdale"</span><span>      | </span><span style='color: #555555;'>"Bnsdale"</span><span>      [4]
## [5] </span><span style='color: #555555;'>"Bowen"</span><span>        | </span><span style='color: #555555;'>"Bowen"</span><span>        [5]
## [6] </span><span style='color: #BBBB00;'>"Brewrna"</span><span>      -                   
## [7] </span><span style='color: #555555;'>"MtStapl"</span><span>      | </span><span style='color: #555555;'>"MtStapl"</span><span>      [6]
## [8] </span><span style='color: #555555;'>"CampRd"</span><span>       | </span><span style='color: #555555;'>"CampRd"</span><span>       [7]
## [9] </span><span style='color: #555555;'>"Broome"</span><span>       | </span><span style='color: #555555;'>"Broome"</span><span>       [8]
## 
##     old$IDRnn1name | new$IDRnn1name    
## [3] </span><span style='color: #555555;'>"AliceSprings"</span><span> | </span><span style='color: #555555;'>"AliceSprings"</span><span> [3]
## [4] </span><span style='color: #555555;'>"Bairnsdale"</span><span>   | </span><span style='color: #555555;'>"Bairnsdale"</span><span>   [4]
## [5] </span><span style='color: #555555;'>"Bowen"</span><span>        | </span><span style='color: #555555;'>"Bowen"</span><span>        [5]
## [6] </span><span style='color: #BBBB00;'>"Brewrna"</span><span>      -                   
## [7] </span><span style='color: #555555;'>"MtStapylton"</span><span>  | </span><span style='color: #555555;'>"MtStapylton"</span><span>  [6]
## [8] </span><span style='color: #555555;'>"CampRd"</span><span>       | </span><span style='color: #555555;'>"CampRd"</span><span>       [7]
## [9] </span><span style='color: #555555;'>"Broome"</span><span>       | </span><span style='color: #555555;'>"Broome"</span><span>       [8]
## 
## `old$State[3:9]`: </span><span style='color: #555555;'>"NT"</span><span> </span><span style='color: #555555;'>"VIC"</span><span> </span><span style='color: #555555;'>"QLD"</span><span> </span><span style='color: #BBBB00;'>"NSW"</span><span> </span><span style='color: #555555;'>"QLD"</span><span> </span><span style='color: #555555;'>"VIC"</span><span> </span><span style='color: #555555;'>"WA"</span><span>
## `new$State[3:8]`: </span><span style='color: #555555;'>"NT"</span><span> </span><span style='color: #555555;'>"VIC"</span><span> </span><span style='color: #555555;'>"QLD"</span><span>       </span><span style='color: #555555;'>"QLD"</span><span> </span><span style='color: #555555;'>"VIC"</span><span> </span><span style='color: #555555;'>"WA"</span><span>
## 
##     old$Type                 | new$Type                    
## [1] </span><span style='color: #555555;'>"Doppler"</span><span>                | </span><span style='color: #555555;'>"Doppler"</span><span>                [1]
## [2] </span><span style='color: #555555;'>"Doppler"</span><span>                | </span><span style='color: #555555;'>"Doppler"</span><span>                [2]
## [3] </span><span style='color: #555555;'>"Standard weather watch"</span><span> | </span><span style='color: #555555;'>"Standard weather watch"</span><span> [3]
## [4] </span><span style='color: #BBBB00;'>"Doppler"</span><span>                -                             
## [5] </span><span style='color: #555555;'>"Standard weather watch"</span><span> | </span><span style='color: #555555;'>"Standard weather watch"</span><span> [4]
## [6] </span><span style='color: #00BB00;'>"Doppler"</span><span>                - </span><span style='color: #00BB00;'>"Standard weather watch"</span><span> [5]
## [7] </span><span style='color: #555555;'>"Doppler"</span><span>                | </span><span style='color: #555555;'>"Doppler"</span><span>                [6]
## [8] </span><span style='color: #555555;'>"Doppler"</span><span>                | </span><span style='color: #555555;'>"Doppler"</span><span>                [7]
## [9] </span><span style='color: #555555;'>"Standard weather watch"</span><span> | </span><span style='color: #555555;'>"Standard weather watch"</span><span> [8]
## 
##      old$Type                 | new$Type                     
## [11] </span><span style='color: #555555;'>"Doppler"</span><span>                | </span><span style='color: #555555;'>"Doppler"</span><span>                [10]
## [12] </span><span style='color: #555555;'>"Standard weather watch"</span><span> | </span><span style='color: #555555;'>"Standard weather watch"</span><span> [11]
## [13] </span><span style='color: #555555;'>"Standard weather watch"</span><span> | </span><span style='color: #555555;'>"Standard weather watch"</span><span> [12]
## [14] </span><span style='color: #00BB00;'>"Doppler"</span><span>                - </span><span style='color: #00BB00;'>"Standard weather watch"</span><span> [13]
## [15] </span><span style='color: #555555;'>"Doppler"</span><span>                | </span><span style='color: #555555;'>"Doppler"</span><span>                [14]
## [16] </span><span style='color: #555555;'>"Standard weather watch"</span><span> | </span><span style='color: #555555;'>"Standard weather watch"</span><span> [15]
## [17] </span><span style='color: #555555;'>"Doppler"</span><span>                | </span><span style='color: #555555;'>"Doppler"</span><span>                [16]
## 
## `old$Group[12:18]`: </span><span style='color: #555555;'>"Yes"</span><span> </span><span style='color: #555555;'>"Yes"</span><span> </span><span style='color: #555555;'>"Yes"</span><span> </span><span style='color: #BBBB00;'>"Yes"</span><span> </span><span style='color: #555555;'>"No"</span><span> </span><span style='color: #555555;'>"Yes"</span><span> </span><span style='color: #555555;'>"Yes"</span><span>
## `new$Group[12:17]`: </span><span style='color: #555555;'>"Yes"</span><span> </span><span style='color: #555555;'>"Yes"</span><span> </span><span style='color: #555555;'>"Yes"</span><span>       </span><span style='color: #555555;'>"No"</span><span> </span><span style='color: #555555;'>"Yes"</span><span> </span><span style='color: #555555;'>"Yes"</span><span>
## 
##      old$Status  | new$Status     
##  [4] </span><span style='color: #555555;'>"Public"</span><span>    | </span><span style='color: #555555;'>"Public"</span><span>    [4]
##  [5] </span><span style='color: #555555;'>"Public"</span><span>    | </span><span style='color: #555555;'>"Public"</span><span>    [5]
##  [6] </span><span style='color: #555555;'>"Public"</span><span>    | </span><span style='color: #555555;'>"Public"</span><span>    [6]
##  [7] </span><span style='color: #BBBB00;'>"Public"</span><span>    -                
##  [8] </span><span style='color: #555555;'>"Reg_users"</span><span> | </span><span style='color: #555555;'>"Reg_users"</span><span> [7]
##  [9] </span><span style='color: #555555;'>"Public"</span><span>    | </span><span style='color: #555555;'>"Public"</span><span>    [8]
## [10] </span><span style='color: #555555;'>"Public"</span><span>    | </span><span style='color: #555555;'>"Public"</span><span>    [9]
## 
##     old$Archive | new$Archive    
## [3] </span><span style='color: #555555;'>"AliceSp"</span><span>   | </span><span style='color: #555555;'>"AliceSp"</span><span>   [3]
## [4] </span><span style='color: #555555;'>"Bnsdale"</span><span>   | </span><span style='color: #555555;'>"Bnsdale"</span><span>   [4]
## [5] </span><span style='color: #555555;'>"Bowen"</span><span>     | </span><span style='color: #555555;'>"Bowen"</span><span>     [5]
## [6] </span><span style='color: #BBBB00;'>"Brewrna"</span><span>   -                
## [7] </span><span style='color: #555555;'>"MtStapl"</span><span>   | </span><span style='color: #555555;'>"MtStapl"</span><span>   [6]
## [8] </span><span style='color: #555555;'>"CampRd"</span><span>    | </span><span style='color: #555555;'>"CampRd"</span><span>    [7]
## [9] </span><span style='color: #555555;'>"Broome"</span><span>    | </span><span style='color: #555555;'>"Broome"</span><span>    [8]
## 
## `old$LocationID[3:9]`: </span><span style='color: #555555;'>"25"</span><span> </span><span style='color: #555555;'>"68"</span><span> </span><span style='color: #555555;'>"24"</span><span> </span><span style='color: #BBBB00;'>"93"</span><span> </span><span style='color: #555555;'>"66"</span><span> </span><span style='color: #555555;'>"01"</span><span> </span><span style='color: #555555;'>"17"</span><span>
## `new$LocationID[3:8]`: </span><span style='color: #555555;'>"25"</span><span> </span><span style='color: #555555;'>"68"</span><span> </span><span style='color: #555555;'>"24"</span><span>      </span><span style='color: #555555;'>"66"</span><span> </span><span style='color: #555555;'>"01"</span><span> </span><span style='color: #555555;'>"17"</span><span>
</span></CODE></PRE>

# Save the data

Save the radar stations’ metadata and changes to disk for use in
*bomrang*.

``` r
if (!dir.exists("../inst/extdata")) {
  dir.create("../inst/extdata", recursive = TRUE)
}

save(radar_locations,
     file = "../inst/extdata/radar_locations.rda",
     compress = "bzip2")

radar_location_changes <- list()

release_version <- paste0("v", packageVersion("bomrang"))
radar_location_changes[[release_version]] <- changes

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
