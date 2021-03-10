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

``` r
`%notin%` <- function(x, table) {
  match(x, table, nomatch = 0L) == 0L
}

load(system.file("extdata", "AAC_codes.rda", package = "bomrang"))

(changes <- waldo::compare(new_AAC_codes, AAC_codes, max_diffs = Inf))
```

<PRE class="fansi fansi-output"><CODE>##        attr(old, 'row.names') | attr(new, 'row.names')       
## [1434] <span style='color: #555555;'>1434</span><span>                   | </span><span style='color: #555555;'>1434</span><span>                   [1434]
## [1435] </span><span style='color: #555555;'>1435</span><span>                   | </span><span style='color: #555555;'>1435</span><span>                   [1435]
## [1436] </span><span style='color: #555555;'>1436</span><span>                   | </span><span style='color: #555555;'>1436</span><span>                   [1436]
## [1437] </span><span style='color: #BBBB00;'>1437</span><span>                   -                              
## [1438] </span><span style='color: #BBBB00;'>1438</span><span>                   -                              
## [1439] </span><span style='color: #BBBB00;'>1439</span><span>                   -                              
## [1440] </span><span style='color: #BBBB00;'>1440</span><span>                   -                              
## [1441] </span><span style='color: #BBBB00;'>1441</span><span>                   -                              
## [1442] </span><span style='color: #BBBB00;'>1442</span><span>                   -                              
## [1443] </span><span style='color: #BBBB00;'>1443</span><span>                   -                              
## [1444] </span><span style='color: #BBBB00;'>1444</span><span>                   -                              
## [1445] </span><span style='color: #BBBB00;'>1445</span><span>                   -                              
## [1446] </span><span style='color: #BBBB00;'>1446</span><span>                   -                              
## [1447] </span><span style='color: #BBBB00;'>1447</span><span>                   -                              
## [1448] </span><span style='color: #BBBB00;'>1448</span><span>                   -                              
## [1449] </span><span style='color: #BBBB00;'>1449</span><span>                   -                              
## [1450] </span><span style='color: #BBBB00;'>1450</span><span>                   -                              
## [1451] </span><span style='color: #BBBB00;'>1451</span><span>                   -                              
## [1452] </span><span style='color: #BBBB00;'>1452</span><span>                   -                              
## [1453] </span><span style='color: #BBBB00;'>1453</span><span>                   -                              
## [1454] </span><span style='color: #BBBB00;'>1454</span><span>                   -                              
## [1455] </span><span style='color: #BBBB00;'>1455</span><span>                   -                              
## [1456] </span><span style='color: #BBBB00;'>1456</span><span>                   -                              
## [1457] </span><span style='color: #BBBB00;'>1457</span><span>                   -                              
## [1458] </span><span style='color: #BBBB00;'>1458</span><span>                   -                              
## [1459] </span><span style='color: #BBBB00;'>1459</span><span>                   -                              
## [1460] </span><span style='color: #BBBB00;'>1460</span><span>                   -                              
## [1461] </span><span style='color: #BBBB00;'>1461</span><span>                   -                              
## [1462] </span><span style='color: #BBBB00;'>1462</span><span>                   -                              
## [1463] </span><span style='color: #BBBB00;'>1463</span><span>                   -                              
## [1464] </span><span style='color: #BBBB00;'>1464</span><span>                   -                              
## [1465] </span><span style='color: #BBBB00;'>1465</span><span>                   -                              
## [1466] </span><span style='color: #BBBB00;'>1466</span><span>                   -                              
## 
##       old$aac     | new$aac          
## [307] </span><span style='color: #555555;'>"NSW_PT329"</span><span> | </span><span style='color: #555555;'>"NSW_PT329"</span><span> [307]
## [308] </span><span style='color: #555555;'>"NSW_PT330"</span><span> | </span><span style='color: #555555;'>"NSW_PT330"</span><span> [308]
## [309] </span><span style='color: #555555;'>"NSW_PT331"</span><span> | </span><span style='color: #555555;'>"NSW_PT331"</span><span> [309]
## [310] </span><span style='color: #BBBB00;'>"NSW_PT332"</span><span> -                  
## [311] </span><span style='color: #BBBB00;'>"NSW_PT333"</span><span> -                  
## [312] </span><span style='color: #BBBB00;'>"NSW_PT334"</span><span> -                  
## [313] </span><span style='color: #BBBB00;'>"NSW_PT335"</span><span> -                  
## [314] </span><span style='color: #BBBB00;'>"NSW_PT336"</span><span> -                  
## [315] </span><span style='color: #BBBB00;'>"NSW_PT337"</span><span> -                  
## [316] </span><span style='color: #BBBB00;'>"NSW_PT338"</span><span> -                  
## [317] </span><span style='color: #BBBB00;'>"NSW_PT339"</span><span> -                  
## [318] </span><span style='color: #BBBB00;'>"NSW_PT340"</span><span> -                  
## [319] </span><span style='color: #BBBB00;'>"NSW_PT341"</span><span> -                  
## [320] </span><span style='color: #BBBB00;'>"NSW_PT342"</span><span> -                  
## [321] </span><span style='color: #BBBB00;'>"NSW_PT343"</span><span> -                  
## [322] </span><span style='color: #BBBB00;'>"NSW_PT344"</span><span> -                  
## [323] </span><span style='color: #BBBB00;'>"NSW_PT345"</span><span> -                  
## [324] </span><span style='color: #BBBB00;'>"NSW_PT346"</span><span> -                  
## [325] </span><span style='color: #BBBB00;'>"NSW_PT347"</span><span> -                  
## [326] </span><span style='color: #BBBB00;'>"NSW_PT348"</span><span> -                  
## [327] </span><span style='color: #BBBB00;'>"NSW_PT349"</span><span> -                  
## [328] </span><span style='color: #BBBB00;'>"NSW_PT350"</span><span> -                  
## [329] </span><span style='color: #BBBB00;'>"NSW_PT351"</span><span> -                  
## [330] </span><span style='color: #BBBB00;'>"NSW_PT352"</span><span> -                  
## [331] </span><span style='color: #555555;'>"NT_PT001"</span><span>  | </span><span style='color: #555555;'>"NT_PT001"</span><span>  [310]
## [332] </span><span style='color: #555555;'>"NT_PT002"</span><span>  | </span><span style='color: #555555;'>"NT_PT002"</span><span>  [311]
## [333] </span><span style='color: #555555;'>"NT_PT003"</span><span>  | </span><span style='color: #555555;'>"NT_PT003"</span><span>  [312]
## 
##       old$aac     | new$aac          
## [734] </span><span style='color: #555555;'>"QLD_PT252"</span><span> | </span><span style='color: #555555;'>"QLD_PT252"</span><span> [713]
## [735] </span><span style='color: #555555;'>"QLD_PT253"</span><span> | </span><span style='color: #555555;'>"QLD_PT253"</span><span> [714]
## [736] </span><span style='color: #555555;'>"QLD_PT254"</span><span> | </span><span style='color: #555555;'>"QLD_PT254"</span><span> [715]
## [737] </span><span style='color: #BBBB00;'>"QLD_PT255"</span><span> -                  
## [738] </span><span style='color: #BBBB00;'>"QLD_PT256"</span><span> -                  
## [739] </span><span style='color: #BBBB00;'>"QLD_PT257"</span><span> -                  
## [740] </span><span style='color: #BBBB00;'>"QLD_PT258"</span><span> -                  
## [741] </span><span style='color: #BBBB00;'>"QLD_PT259"</span><span> -                  
## [742] </span><span style='color: #BBBB00;'>"QLD_PT260"</span><span> -                  
## [743] </span><span style='color: #555555;'>"SA_PT001"</span><span>  | </span><span style='color: #555555;'>"SA_PT001"</span><span>  [716]
## [744] </span><span style='color: #555555;'>"SA_PT002"</span><span>  | </span><span style='color: #555555;'>"SA_PT002"</span><span>  [717]
## [745] </span><span style='color: #555555;'>"SA_PT003"</span><span>  | </span><span style='color: #555555;'>"SA_PT003"</span><span>  [718]
## 
##        old$aac     | new$aac           
## [1191] </span><span style='color: #555555;'>"VIC_PT204"</span><span> | </span><span style='color: #555555;'>"VIC_PT204"</span><span> [1164]
## [1192] </span><span style='color: #555555;'>"VIC_PT205"</span><span> | </span><span style='color: #555555;'>"VIC_PT205"</span><span> [1165]
## [1193] </span><span style='color: #555555;'>"VIC_PT206"</span><span> | </span><span style='color: #555555;'>"VIC_PT206"</span><span> [1166]
## [1194] </span><span style='color: #BBBB00;'>"VIC_PT208"</span><span> -                   
## [1195] </span><span style='color: #555555;'>"WA_PT001"</span><span>  | </span><span style='color: #555555;'>"WA_PT001"</span><span>  [1167]
## [1196] </span><span style='color: #555555;'>"WA_PT002"</span><span>  | </span><span style='color: #555555;'>"WA_PT002"</span><span>  [1168]
## [1197] </span><span style='color: #555555;'>"WA_PT003"</span><span>  | </span><span style='color: #555555;'>"WA_PT003"</span><span>  [1169]
## 
## `old$aac[1462:1466]`: </span><span style='color: #555555;'>"WA_PT287"</span><span> </span><span style='color: #555555;'>"WA_PT288"</span><span> </span><span style='color: #555555;'>"WA_PT289"</span><span> </span><span style='color: #BBBB00;'>"WA_PT290"</span><span> </span><span style='color: #BBBB00;'>"WA_PT291"</span><span>
## `new$aac[1434:1436]`: </span><span style='color: #555555;'>"WA_PT287"</span><span> </span><span style='color: #555555;'>"WA_PT288"</span><span> </span><span style='color: #555555;'>"WA_PT289"</span><span>                      
## 
##       old$town                  | new$town                 
## [307] </span><span style='color: #555555;'>"Portable RFSACT03"</span><span>       | </span><span style='color: #555555;'>"Portable RFSACT03"</span><span> [307]
## [308] </span><span style='color: #555555;'>"Portable RFSACT04"</span><span>       | </span><span style='color: #555555;'>"Portable RFSACT04"</span><span> [308]
## [309] </span><span style='color: #555555;'>"Bermagui"</span><span>                | </span><span style='color: #555555;'>"Bermagui"</span><span>          [309]
## [310] </span><span style='color: #BBBB00;'>"Jervis Bay Airfield AWS"</span><span> -                          
## [311] </span><span style='color: #BBBB00;'>"Crinolyn"</span><span>                -                          
## [312] </span><span style='color: #BBBB00;'>"Burndoo"</span><span>                 -                          
## [313] </span><span style='color: #BBBB00;'>"Inkerman"</span><span>                -                          
## [314] </span><span style='color: #BBBB00;'>"Nelia Gaari"</span><span>             -                          
## [315] </span><span style='color: #BBBB00;'>"Tandou"</span><span>                  -                          
## [316] </span><span style='color: #BBBB00;'>"Killala"</span><span>                 -                          
## [317] </span><span style='color: #BBBB00;'>"Waiko"</span><span>                   -                          
## [318] </span><span style='color: #BBBB00;'>"Boullia"</span><span>                 -                          
## [319] </span><span style='color: #BBBB00;'>"Cawnalmurtee"</span><span>            -                          
## [320] </span><span style='color: #BBBB00;'>"Grasmere"</span><span>                -                          
## [321] </span><span style='color: #BBBB00;'>"Mt Jack"</span><span>                 -                          
## [322] </span><span style='color: #BBBB00;'>"Mount Woowoolarah"</span><span>       -                          
## [323] </span><span style='color: #BBBB00;'>"Westwood Downs"</span><span>          -                          
## [324] </span><span style='color: #BBBB00;'>"Winnathee"</span><span>               -                          
## [325] </span><span style='color: #BBBB00;'>"Burrawantie"</span><span>             -                          
## [326] </span><span style='color: #BBBB00;'>"Gumbooka"</span><span>                -                          
## [327] </span><span style='color: #BBBB00;'>"Knightvale"</span><span>              -                          
## [328] </span><span style='color: #BBBB00;'>"Keveline"</span><span>                -                          
## [329] </span><span style='color: #BBBB00;'>"Nulla"</span><span>                   -                          
## [330] </span><span style='color: #BBBB00;'>"Overnewton"</span><span>              -                          
## [331] </span><span style='color: #555555;'>"Darwin"</span><span>                  | </span><span style='color: #555555;'>"Darwin"</span><span>            [310]
## [332] </span><span style='color: #555555;'>"Uluru"</span><span>                   | </span><span style='color: #555555;'>"Uluru"</span><span>             [311]
## [333] </span><span style='color: #555555;'>"Wangi Falls"</span><span>             | </span><span style='color: #555555;'>"Wangi Falls"</span><span>       [312]
## 
##       old$town                                | new$town                   
## [734] </span><span style='color: #555555;'>"Canungra (Defence)"</span><span>                    | </span><span style='color: #555555;'>"Canungra (Defence)"</span><span>  [713]
## [735] </span><span style='color: #555555;'>"Greenbank (Defence)"</span><span>                   | </span><span style='color: #555555;'>"Greenbank (Defence)"</span><span> [714]
## [736] </span><span style='color: #555555;'>"Port Douglas"</span><span>                          | </span><span style='color: #555555;'>"Port Douglas"</span><span>        [715]
## [737] </span><span style='color: #BBBB00;'>"Cairns Racecourse"</span><span>                     -                            
## [738] </span><span style='color: #BBBB00;'>"Lake Julius AWS"</span><span>                       -                            
## [739] </span><span style='color: #BBBB00;'>"Carters Bore"</span><span>                          -                            
## [740] </span><span style='color: #BBBB00;'>"New May Downs"</span><span>                         -                            
## [741] </span><span style='color: #BBBB00;'>"Ooralea Racecourse (Mackay Turf Club)"</span><span> -                            
## [742] </span><span style='color: #BBBB00;'>"Windorah Airport"</span><span>                      -                            
## [743] </span><span style='color: #555555;'>"Adelaide"</span><span>                              | </span><span style='color: #555555;'>"Adelaide"</span><span>            [716]
## [744] </span><span style='color: #555555;'>"Waikerie"</span><span>                              | </span><span style='color: #555555;'>"Waikerie"</span><span>            [717]
## [745] </span><span style='color: #555555;'>"Stirling"</span><span>                              | </span><span style='color: #555555;'>"Stirling"</span><span>            [718]
## 
##        old$town                | new$town                  
## [1191] </span><span style='color: #555555;'>"Drouin"</span><span>                | </span><span style='color: #555555;'>"Drouin"</span><span>            [1164]
## [1192] </span><span style='color: #555555;'>"Traralgon"</span><span>             | </span><span style='color: #555555;'>"Traralgon"</span><span>         [1165]
## [1193] </span><span style='color: #555555;'>"East Sale Airport"</span><span>     | </span><span style='color: #555555;'>"East Sale Airport"</span><span> [1166]
## [1194] </span><span style='color: #BBBB00;'>"Warracknabeal Airport"</span><span> -                           
## [1195] </span><span style='color: #555555;'>"Albany"</span><span>                | </span><span style='color: #555555;'>"Albany"</span><span>            [1167]
## [1196] </span><span style='color: #555555;'>"Broome"</span><span>                | </span><span style='color: #555555;'>"Broome"</span><span>            [1168]
## [1197] </span><span style='color: #555555;'>"Bunbury"</span><span>               | </span><span style='color: #555555;'>"Bunbury"</span><span>           [1169]
## 
##        old$town             | new$town                   
## [1462] </span><span style='color: #555555;'>"Karijini (DPAW)"</span><span>    | </span><span style='color: #555555;'>"Karijini (DPAW)"</span><span>    [1434]
## [1463] </span><span style='color: #555555;'>"Pemberton (DAFWA)"</span><span>  | </span><span style='color: #555555;'>"Pemberton (DAFWA)"</span><span>  [1435]
## [1464] </span><span style='color: #555555;'>"Lancelin (Defence)"</span><span> | </span><span style='color: #555555;'>"Lancelin (Defence)"</span><span> [1436]
## [1465] </span><span style='color: #BBBB00;'>"Mundaring"</span><span>          -                            
## [1466] </span><span style='color: #BBBB00;'>"Karijini North"</span><span>     -                            
## 
##      old$lon    | new$lon        
## [90] </span><span style='color: #555555;'>148.772544</span><span> | </span><span style='color: #555555;'>148.772544</span><span> [90]
## [91] </span><span style='color: #555555;'>149.616</span><span>    | </span><span style='color: #555555;'>149.616</span><span>    [91]
## [92] </span><span style='color: #555555;'>148.9899</span><span>   | </span><span style='color: #555555;'>148.9899</span><span>   [92]
## [93] </span><span style='color: #00BB00;'>150.8418</span><span>   - </span><span style='color: #00BB00;'>150.8362</span><span>   [93]
## [94] </span><span style='color: #555555;'>153.3784</span><span>   | </span><span style='color: #555555;'>153.3784</span><span>   [94]
## [95] </span><span style='color: #555555;'>150.1358</span><span>   | </span><span style='color: #555555;'>150.1358</span><span>   [95]
## [96] </span><span style='color: #555555;'>149.8302</span><span>   | </span><span style='color: #555555;'>149.8302</span><span>   [96]
## 
##       old$lon  | new$lon       
## [124] </span><span style='color: #555555;'>153.087</span><span>  | </span><span style='color: #555555;'>153.087</span><span>  [124]
## [125] </span><span style='color: #555555;'>150.5694</span><span> | </span><span style='color: #555555;'>150.5694</span><span> [125]
## [126] </span><span style='color: #555555;'>151.1725</span><span> | </span><span style='color: #555555;'>151.1725</span><span> [126]
## [127] </span><span style='color: #00BB00;'>151.2048</span><span> - </span><span style='color: #00BB00;'>151.205</span><span>  [127]
## [128] </span><span style='color: #555555;'>151.0718</span><span> | </span><span style='color: #555555;'>151.0718</span><span> [128]
## [129] </span><span style='color: #555555;'>152.4507</span><span> | </span><span style='color: #555555;'>152.4507</span><span> [129]
## [130] </span><span style='color: #555555;'>150.8362</span><span> | </span><span style='color: #555555;'>150.8362</span><span> [130]
## 
##       old$lon  | new$lon       
## [295] </span><span style='color: #555555;'>143.1128</span><span> | </span><span style='color: #555555;'>143.1128</span><span> [295]
## [296] </span><span style='color: #555555;'>144.9314</span><span> | </span><span style='color: #555555;'>144.9314</span><span> [296]
## [297] </span><span style='color: #555555;'>141.0017</span><span> | </span><span style='color: #555555;'>141.0017</span><span> [297]
## [298] </span><span style='color: #00BB00;'>147.5327</span><span> - </span><span style='color: #00BB00;'>147.5328</span><span> [298]
## [299] </span><span style='color: #555555;'>146.9294</span><span> | </span><span style='color: #555555;'>146.9294</span><span> [299]
## [300] </span><span style='color: #555555;'>147.2513</span><span> | </span><span style='color: #555555;'>147.2513</span><span> [300]
## [301] </span><span style='color: #555555;'>150.9009</span><span> | </span><span style='color: #555555;'>150.9009</span><span> [301]
## 
##       old$lon   | new$lon        
## [307] </span><span style='color: #555555;'>149.3162</span><span>  | </span><span style='color: #555555;'>149.3162</span><span>  [307]
## [308] </span><span style='color: #555555;'>148.9757</span><span>  | </span><span style='color: #555555;'>148.9757</span><span>  [308]
## [309] </span><span style='color: #555555;'>150.06356</span><span> | </span><span style='color: #555555;'>150.06356</span><span> [309]
## [310] </span><span style='color: #BBBB00;'>150.6974</span><span>  -                
## [311] </span><span style='color: #BBBB00;'>149.1265</span><span>  -                
## [312] </span><span style='color: #BBBB00;'>143.65</span><span>    -                
## [313] </span><span style='color: #BBBB00;'>142.153</span><span>   -                
## [314] </span><span style='color: #BBBB00;'>142.8181</span><span>  -                
## [315] </span><span style='color: #BBBB00;'>142.1115</span><span>  -                
## [316] </span><span style='color: #BBBB00;'>145.9736</span><span>  -                
## [317] </span><span style='color: #BBBB00;'>144.4645</span><span>  -                
## [318] </span><span style='color: #BBBB00;'>141.8795</span><span>  -                
## [319] </span><span style='color: #BBBB00;'>143.3528</span><span>  -                
## [320] </span><span style='color: #BBBB00;'>142.6258</span><span>  -                
## [321] </span><span style='color: #BBBB00;'>143.7085</span><span>  -                
## [322] </span><span style='color: #BBBB00;'>141.2389</span><span>  -                
## [323] </span><span style='color: #BBBB00;'>141.3335</span><span>  -                
## [324] </span><span style='color: #BBBB00;'>141.1105</span><span>  -                
## [325] </span><span style='color: #BBBB00;'>145.4066</span><span>  -                
## [326] </span><span style='color: #BBBB00;'>146.2857</span><span>  -                
## [327] </span><span style='color: #BBBB00;'>146.3283</span><span>  -                
## [328] </span><span style='color: #BBBB00;'>147.9422</span><span>  -                
## [329] </span><span style='color: #BBBB00;'>141.3592</span><span>  -                
## [330] </span><span style='color: #BBBB00;'>143.5386</span><span>  -                
## [331] </span><span style='color: #555555;'>130.84184</span><span> | </span><span style='color: #555555;'>130.84184</span><span> [310]
## [332] </span><span style='color: #555555;'>131.0354</span><span>  | </span><span style='color: #555555;'>131.0354</span><span>  [311]
## [333] </span><span style='color: #555555;'>130.68529</span><span> | </span><span style='color: #555555;'>130.68529</span><span> [312]
## 
##       old$lon    | new$lon         
## [734] </span><span style='color: #555555;'>153.1871</span><span>   | </span><span style='color: #555555;'>153.1871</span><span>   [713]
## [735] </span><span style='color: #555555;'>152.9934</span><span>   | </span><span style='color: #555555;'>152.9934</span><span>   [714]
## [736] </span><span style='color: #555555;'>145.463536</span><span> | </span><span style='color: #555555;'>145.463536</span><span> [715]
## [737] </span><span style='color: #BBBB00;'>145.7474</span><span>   -                 
## [738] </span><span style='color: #BBBB00;'>139.7256</span><span>   -                 
## [739] </span><span style='color: #BBBB00;'>139.2964</span><span>   -                 
## [740] </span><span style='color: #BBBB00;'>139.3411</span><span>   -                 
## [741] </span><span style='color: #BBBB00;'>149.1515</span><span>   -                 
## [742] </span><span style='color: #BBBB00;'>142.6647</span><span>   -                 
## [743] </span><span style='color: #555555;'>138.5986</span><span>   | </span><span style='color: #555555;'>138.5986</span><span>   [716]
## [744] </span><span style='color: #555555;'>139.983808</span><span> | </span><span style='color: #555555;'>139.983808</span><span> [717]
## [745] </span><span style='color: #555555;'>138.73682</span><span>  | </span><span style='color: #555555;'>138.73682</span><span>  [718]
## 
##       old$lon  | new$lon       
## [864] </span><span style='color: #555555;'>138.0684</span><span> | </span><span style='color: #555555;'>138.0684</span><span> [837]
## [865] </span><span style='color: #555555;'>136.5026</span><span> | </span><span style='color: #555555;'>136.5026</span><span> [838]
## [866] </span><span style='color: #555555;'>135.3741</span><span> | </span><span style='color: #555555;'>135.3741</span><span> [839]
## [867] </span><span style='color: #00BB00;'>137.9971</span><span> - </span><span style='color: #00BB00;'>138.001</span><span>  [840]
## [868] </span><span style='color: #555555;'>137.3995</span><span> | </span><span style='color: #555555;'>137.3995</span><span> [841]
## [869] </span><span style='color: #555555;'>138.6281</span><span> | </span><span style='color: #555555;'>138.6281</span><span> [842]
## [870] </span><span style='color: #555555;'>138.7088</span><span> | </span><span style='color: #555555;'>138.7088</span><span> [843]
## 
##        old$lon   | new$lon         
## [1191] </span><span style='color: #555555;'>145.85838</span><span> | </span><span style='color: #555555;'>145.85838</span><span> [1164]
## [1192] </span><span style='color: #555555;'>146.51447</span><span> | </span><span style='color: #555555;'>146.51447</span><span> [1165]
## [1193] </span><span style='color: #555555;'>147.1399</span><span>  | </span><span style='color: #555555;'>147.1399</span><span>  [1166]
## [1194] </span><span style='color: #BBBB00;'>142.4161</span><span>  -                 
## [1195] </span><span style='color: #555555;'>117.8808</span><span>  | </span><span style='color: #555555;'>117.8808</span><span>  [1167]
## [1196] </span><span style='color: #555555;'>122.2353</span><span>  | </span><span style='color: #555555;'>122.2353</span><span>  [1168]
## [1197] </span><span style='color: #555555;'>115.6447</span><span>  | </span><span style='color: #555555;'>115.6447</span><span>  [1169]
## 
##        old$lon  | new$lon        
## [1258] </span><span style='color: #555555;'>123.1556</span><span> | </span><span style='color: #555555;'>123.1556</span><span> [1230]
## [1259] </span><span style='color: #555555;'>117.8022</span><span> | </span><span style='color: #555555;'>117.8022</span><span> [1231]
## [1260] </span><span style='color: #555555;'>115.5394</span><span> | </span><span style='color: #555555;'>115.5394</span><span> [1232]
## [1261] </span><span style='color: #00BB00;'>127.9892</span><span> - </span><span style='color: #00BB00;'>127.9867</span><span> [1233]
## [1262] </span><span style='color: #555555;'>123.864</span><span>  | </span><span style='color: #555555;'>123.864</span><span>  [1234]
## [1263] </span><span style='color: #555555;'>115.4056</span><span> | </span><span style='color: #555555;'>115.4056</span><span> [1235]
## [1264] </span><span style='color: #555555;'>119.0997</span><span> | </span><span style='color: #555555;'>119.0997</span><span> [1236]
## 
##        old$lon  | new$lon        
## [1359] </span><span style='color: #555555;'>116.6706</span><span> | </span><span style='color: #555555;'>116.6706</span><span> [1331]
## [1360] </span><span style='color: #555555;'>128.2175</span><span> | </span><span style='color: #555555;'>128.2175</span><span> [1332]
## [1361] </span><span style='color: #555555;'>122.3122</span><span> | </span><span style='color: #555555;'>122.3122</span><span> [1333]
## [1362] </span><span style='color: #00BB00;'>120.2194</span><span> - </span><span style='color: #00BB00;'>120.225</span><span>  [1334]
## [1363] </span><span style='color: #555555;'>116.0308</span><span> | </span><span style='color: #555555;'>116.0308</span><span> [1335]
## [1364] </span><span style='color: #555555;'>115.1042</span><span> | </span><span style='color: #555555;'>115.1042</span><span> [1336]
## [1365] </span><span style='color: #555555;'>118.336</span><span>  | </span><span style='color: #555555;'>118.336</span><span>  [1337]
## 
## `old$lon[1462:1466]`: </span><span style='color: #555555;'>118.4715</span><span> </span><span style='color: #555555;'>115.9105</span><span> </span><span style='color: #555555;'>115.2284</span><span> </span><span style='color: #BBBB00;'>116.1581</span><span> </span><span style='color: #BBBB00;'>118.4498</span><span>
## `new$lon[1434:1436]`: </span><span style='color: #555555;'>118.4715</span><span> </span><span style='color: #555555;'>115.9105</span><span> </span><span style='color: #555555;'>115.2284</span><span>                  
## 
## `old$lat[90:96]`: </span><span style='color: #555555;'>-35.5293</span><span> </span><span style='color: #555555;'>-32.5624</span><span> </span><span style='color: #555555;'>-28.9786</span><span> </span><span style='color: #00BB00;'>-31.7678</span><span> </span><span style='color: #555555;'>-28.3408</span><span> </span><span style='color: #555555;'>-36.2144</span><span> </span><span style='color: #555555;'>-30.3154</span><span>
## `new$lat[90:96]`: </span><span style='color: #555555;'>-35.5293</span><span> </span><span style='color: #555555;'>-32.5624</span><span> </span><span style='color: #555555;'>-28.9786</span><span> </span><span style='color: #00BB00;'>-31.7631</span><span> </span><span style='color: #555555;'>-28.3408</span><span> </span><span style='color: #555555;'>-36.2144</span><span> </span><span style='color: #555555;'>-30.3154</span><span>
## 
##       old$lat  | new$lat       
## [124] </span><span style='color: #555555;'>-30.9225</span><span> | </span><span style='color: #555555;'>-30.9225</span><span> [124]
## [125] </span><span style='color: #555555;'>-33.6984</span><span> | </span><span style='color: #555555;'>-33.6984</span><span> [125]
## [126] </span><span style='color: #555555;'>-33.9411</span><span> | </span><span style='color: #555555;'>-33.9411</span><span> [126]
## [127] </span><span style='color: #00BB00;'>-33.8593</span><span> - </span><span style='color: #00BB00;'>-33.8607</span><span> [127]
## [128] </span><span style='color: #555555;'>-33.8338</span><span> | </span><span style='color: #555555;'>-33.8338</span><span> [128]
## [129] </span><span style='color: #555555;'>-28.7551</span><span> | </span><span style='color: #555555;'>-28.7551</span><span> [129]
## [130] </span><span style='color: #555555;'>-31.0742</span><span> | </span><span style='color: #555555;'>-31.0742</span><span> [130]
## 
##       old$lat   | new$lat        
## [307] </span><span style='color: #555555;'>-35.3111</span><span>  | </span><span style='color: #555555;'>-35.3111</span><span>  [307]
## [308] </span><span style='color: #555555;'>-35.7345</span><span>  | </span><span style='color: #555555;'>-35.7345</span><span>  [308]
## [309] </span><span style='color: #555555;'>-36.419</span><span>   | </span><span style='color: #555555;'>-36.419</span><span>   [309]
## [310] </span><span style='color: #BBBB00;'>-35.144</span><span>   -                
## [311] </span><span style='color: #BBBB00;'>-29.2403</span><span>  -                
## [312] </span><span style='color: #BBBB00;'>-32.0679</span><span>  -                
## [313] </span><span style='color: #BBBB00;'>-31.9772</span><span>  -                
## [314] </span><span style='color: #BBBB00;'>-32.0079</span><span>  -                
## [315] </span><span style='color: #BBBB00;'>-32.7107</span><span>  -                
## [316] </span><span style='color: #BBBB00;'>-31.9945</span><span>  -                
## [317] </span><span style='color: #BBBB00;'>-32.8323</span><span>  -                
## [318] </span><span style='color: #BBBB00;'>-30.0708</span><span>  -                
## [319] </span><span style='color: #BBBB00;'>-30.5807</span><span>  -                
## [320] </span><span style='color: #BBBB00;'>-31.4198</span><span>  -                
## [321] </span><span style='color: #BBBB00;'>-30.8693</span><span>  -                
## [322] </span><span style='color: #BBBB00;'>-31.2554</span><span>  -                
## [323] </span><span style='color: #BBBB00;'>-30.496</span><span>   -                
## [324] </span><span style='color: #BBBB00;'>-29.751</span><span>   -                
## [325] </span><span style='color: #BBBB00;'>-29.1544</span><span>  -                
## [326] </span><span style='color: #BBBB00;'>-29.7859</span><span>  -                
## [327] </span><span style='color: #BBBB00;'>-30.4864</span><span>  -                
## [328] </span><span style='color: #BBBB00;'>-30.4934</span><span>  -                
## [329] </span><span style='color: #BBBB00;'>-33.8218</span><span>  -                
## [330] </span><span style='color: #BBBB00;'>-32.9416</span><span>  -                
## [331] </span><span style='color: #555555;'>-12.46083</span><span> | </span><span style='color: #555555;'>-12.46083</span><span> [310]
## [332] </span><span style='color: #555555;'>-25.342</span><span>   | </span><span style='color: #555555;'>-25.342</span><span>   [311]
## [333] </span><span style='color: #555555;'>-13.16357</span><span> | </span><span style='color: #555555;'>-13.16357</span><span> [312]
## 
##       old$lat    | new$lat         
## [734] </span><span style='color: #555555;'>-28.0437</span><span>   | </span><span style='color: #555555;'>-28.0437</span><span>   [713]
## [735] </span><span style='color: #555555;'>-27.6935</span><span>   | </span><span style='color: #555555;'>-27.6935</span><span>   [714]
## [736] </span><span style='color: #555555;'>-16.486807</span><span> | </span><span style='color: #555555;'>-16.486807</span><span> [715]
## [737] </span><span style='color: #BBBB00;'>-16.9463</span><span>   -                 
## [738] </span><span style='color: #BBBB00;'>-20.1167</span><span>   -                 
## [739] </span><span style='color: #BBBB00;'>-20.9358</span><span>   -                 
## [740] </span><span style='color: #BBBB00;'>-20.59</span><span>     -                 
## [741] </span><span style='color: #BBBB00;'>-21.17</span><span>     -                 
## [742] </span><span style='color: #BBBB00;'>-25.4117</span><span>   -                 
## [743] </span><span style='color: #555555;'>-34.92866</span><span>  | </span><span style='color: #555555;'>-34.92866</span><span>  [716]
## [744] </span><span style='color: #555555;'>-34.182415</span><span> | </span><span style='color: #555555;'>-34.182415</span><span> [717]
## [745] </span><span style='color: #555555;'>-34.99383</span><span>  | </span><span style='color: #555555;'>-34.99383</span><span>  [718]
## 
##       old$lat  | new$lat       
## [864] </span><span style='color: #555555;'>-29.6587</span><span> | </span><span style='color: #555555;'>-29.6587</span><span> [837]
## [865] </span><span style='color: #555555;'>-33.7081</span><span> | </span><span style='color: #555555;'>-33.7081</span><span> [838]
## [866] </span><span style='color: #555555;'>-34.3749</span><span> | </span><span style='color: #555555;'>-34.3749</span><span> [839]
## [867] </span><span style='color: #00BB00;'>-33.2371</span><span> - </span><span style='color: #00BB00;'>-33.2341</span><span> [840]
## [868] </span><span style='color: #555555;'>-34.9906</span><span> | </span><span style='color: #555555;'>-34.9906</span><span> [841]
## [869] </span><span style='color: #555555;'>-34.7977</span><span> | </span><span style='color: #555555;'>-34.7977</span><span> [842]
## [870] </span><span style='color: #555555;'>-34.9784</span><span> | </span><span style='color: #555555;'>-34.9784</span><span> [843]
## 
##        old$lat   | new$lat         
## [1191] </span><span style='color: #555555;'>-38.13658</span><span> | </span><span style='color: #555555;'>-38.13658</span><span> [1164]
## [1192] </span><span style='color: #555555;'>-38.20194</span><span> | </span><span style='color: #555555;'>-38.20194</span><span> [1165]
## [1193] </span><span style='color: #555555;'>-38.1017</span><span>  | </span><span style='color: #555555;'>-38.1017</span><span>  [1166]
## [1194] </span><span style='color: #BBBB00;'>-36.3204</span><span>  -                 
## [1195] </span><span style='color: #555555;'>-35.0289</span><span>  | </span><span style='color: #555555;'>-35.0289</span><span>  [1167]
## [1196] </span><span style='color: #555555;'>-17.9475</span><span>  | </span><span style='color: #555555;'>-17.9475</span><span>  [1168]
## [1197] </span><span style='color: #555555;'>-33.3567</span><span>  | </span><span style='color: #555555;'>-33.3567</span><span>  [1169]
## 
##        old$lat  | new$lat        
## [1258] </span><span style='color: #555555;'>-15.5114</span><span> | </span><span style='color: #555555;'>-15.5114</span><span> [1230]
## [1259] </span><span style='color: #555555;'>-34.9414</span><span> | </span><span style='color: #555555;'>-34.9414</span><span> [1231]
## [1260] </span><span style='color: #555555;'>-30.3381</span><span> | </span><span style='color: #555555;'>-30.3381</span><span> [1232]
## [1261] </span><span style='color: #00BB00;'>-20.135</span><span>  - </span><span style='color: #00BB00;'>-20.1417</span><span> [1233]
## [1262] </span><span style='color: #555555;'>-32.4583</span><span> | </span><span style='color: #555555;'>-32.4583</span><span> [1234]
## [1263] </span><span style='color: #555555;'>-20.875</span><span>  | </span><span style='color: #555555;'>-20.875</span><span>  [1235]
## [1264] </span><span style='color: #555555;'>-19.5886</span><span> | </span><span style='color: #555555;'>-19.5886</span><span> [1236]
## 
##        old$lat  | new$lat        
## [1359] </span><span style='color: #555555;'>-32.6722</span><span> | </span><span style='color: #555555;'>-32.6722</span><span> [1331]
## [1360] </span><span style='color: #555555;'>-17.0156</span><span> | </span><span style='color: #555555;'>-17.0156</span><span> [1332]
## [1361] </span><span style='color: #555555;'>-17.8964</span><span> | </span><span style='color: #555555;'>-17.8964</span><span> [1333]
## [1362] </span><span style='color: #00BB00;'>-26.6274</span><span> - </span><span style='color: #00BB00;'>-26.5914</span><span> [1334]
## [1363] </span><span style='color: #555555;'>-34.8361</span><span> | </span><span style='color: #555555;'>-34.8361</span><span> [1335]
## [1364] </span><span style='color: #555555;'>-34.0281</span><span> | </span><span style='color: #555555;'>-34.0281</span><span> [1336]
## [1365] </span><span style='color: #555555;'>-22.2425</span><span> | </span><span style='color: #555555;'>-22.2425</span><span> [1337]
## 
## `old$lat[1462:1466]`: </span><span style='color: #555555;'>-22.4936</span><span> </span><span style='color: #555555;'>-34.4091</span><span> </span><span style='color: #555555;'>-30.8393</span><span> </span><span style='color: #BBBB00;'>-31.8978</span><span> </span><span style='color: #BBBB00;'>-22.2999</span><span>
## `new$lat[1434:1436]`: </span><span style='color: #555555;'>-22.4936</span><span> </span><span style='color: #555555;'>-34.4091</span><span> </span><span style='color: #555555;'>-30.8393</span><span>                  
## 
## `old$elev[90:96]`: </span><span style='color: #555555;'>1760</span><span> </span><span style='color: #555555;'>471</span><span> </span><span style='color: #555555;'>160</span><span> </span><span style='color: #00BB00;'>467</span><span> </span><span style='color: #555555;'>18</span><span> </span><span style='color: #555555;'>25</span><span> </span><span style='color: #555555;'>229</span><span>
## `new$elev[90:96]`: </span><span style='color: #555555;'>1760</span><span> </span><span style='color: #555555;'>471</span><span> </span><span style='color: #555555;'>160</span><span> </span><span style='color: #00BB00;'>466</span><span> </span><span style='color: #555555;'>18</span><span> </span><span style='color: #555555;'>25</span><span> </span><span style='color: #555555;'>229</span><span>
## 
## `old$elev[124:130]`: </span><span style='color: #555555;'>117</span><span> </span><span style='color: #555555;'>362</span><span> </span><span style='color: #555555;'>6</span><span> </span><span style='color: #00BB00;'>43.4</span><span> </span><span style='color: #555555;'>28</span><span> </span><span style='color: #555555;'>555</span><span> </span><span style='color: #555555;'>394.9</span><span>
## `new$elev[124:130]`: </span><span style='color: #555555;'>117</span><span> </span><span style='color: #555555;'>362</span><span> </span><span style='color: #555555;'>6</span><span>   </span><span style='color: #00BB00;'>39</span><span> </span><span style='color: #555555;'>28</span><span> </span><span style='color: #555555;'>555</span><span> </span><span style='color: #555555;'>394.9</span><span>
## 
##       old$elev | new$elev      
## [307] </span><span style='color: #555555;'>719</span><span>      | </span><span style='color: #555555;'>719</span><span>      [307]
## [308] </span><span style='color: #555555;'>1039</span><span>     | </span><span style='color: #555555;'>1039</span><span>     [308]
## [309] </span><span style='color: #555555;'>3.9</span><span>      | </span><span style='color: #555555;'>3.9</span><span>      [309]
## [310] </span><span style='color: #BBBB00;'>57.2</span><span>     -               
## [311] </span><span style='color: #BBBB00;'>163</span><span>      -               
## [312] </span><span style='color: #BBBB00;'>78</span><span>       -               
## [313] </span><span style='color: #BBBB00;'>120</span><span>      -               
## [314] </span><span style='color: #BBBB00;'>86</span><span>       -               
## [315] </span><span style='color: #BBBB00;'>59</span><span>       -               
## [316] </span><span style='color: #BBBB00;'>259</span><span>      -               
## [317] </span><span style='color: #BBBB00;'>95</span><span>       -               
## [318] </span><span style='color: #BBBB00;'>100</span><span>      -               
## [319] </span><span style='color: #BBBB00;'>146</span><span>      -               
## [320] </span><span style='color: #BBBB00;'>172</span><span>      -               
## [321] </span><span style='color: #BBBB00;'>103</span><span>      -               
## [322] </span><span style='color: #BBBB00;'>153</span><span>      -               
## [323] </span><span style='color: #BBBB00;'>68</span><span>       -               
## [324] </span><span style='color: #BBBB00;'>124</span><span>      -               
## [325] </span><span style='color: #BBBB00;'>143</span><span>      -               
## [326] </span><span style='color: #BBBB00;'>113</span><span>      -               
## [327] </span><span style='color: #BBBB00;'>143</span><span>      -               
## [328] </span><span style='color: #BBBB00;'>134</span><span>      -               
## [329] </span><span style='color: #BBBB00;'>55</span><span>       -               
## [330] </span><span style='color: #BBBB00;'>82</span><span>       -               
## [331] </span><span style='color: #555555;'>44.6</span><span>     | </span><span style='color: #555555;'>44.6</span><span>     [310]
## [332] </span><span style='color: #555555;'>530</span><span>      | </span><span style='color: #555555;'>530</span><span>      [311]
## [333] </span><span style='color: #555555;'>96.8</span><span>     | </span><span style='color: #555555;'>96.8</span><span>     [312]
## 
## `old$elev[734:745]`: </span><span style='color: #555555;'>110</span><span> </span><span style='color: #555555;'>44</span><span> </span><span style='color: #555555;'>70.4</span><span> </span><span style='color: #BBBB00;'>4.1</span><span> </span><span style='color: #BBBB00;'>237</span><span> </span><span style='color: #BBBB00;'>396</span><span> </span><span style='color: #BBBB00;'>392</span><span> </span><span style='color: #BBBB00;'>10.3</span><span> </span><span style='color: #BBBB00;'>132.2</span><span> </span><span style='color: #555555;'>36.7</span><span> </span><span style='color: #555555;'>22.2</span><span> </span><span style='color: #555555;'>496</span><span>
## `new$elev[713:718]`: </span><span style='color: #555555;'>110</span><span> </span><span style='color: #555555;'>44</span><span> </span><span style='color: #555555;'>70.4</span><span>                            </span><span style='color: #555555;'>36.7</span><span> </span><span style='color: #555555;'>22.2</span><span> </span><span style='color: #555555;'>496</span><span>
## 
## `old$elev[864:870]`: </span><span style='color: #555555;'>50</span><span> </span><span style='color: #555555;'>175</span><span> </span><span style='color: #555555;'>28</span><span> </span><span style='color: #00BB00;'>12</span><span> </span><span style='color: #555555;'>53</span><span> </span><span style='color: #555555;'>9.5</span><span> </span><span style='color: #555555;'>685</span><span>
## `new$elev[837:843]`: </span><span style='color: #555555;'>50</span><span> </span><span style='color: #555555;'>175</span><span> </span><span style='color: #555555;'>28</span><span> </span><span style='color: #00BB00;'>10</span><span> </span><span style='color: #555555;'>53</span><span> </span><span style='color: #555555;'>9.5</span><span> </span><span style='color: #555555;'>685</span><span>
## 
## `old$elev[1191:1197]`: </span><span style='color: #555555;'>137.9</span><span> </span><span style='color: #555555;'>57.8</span><span> </span><span style='color: #555555;'>5.3</span><span> </span><span style='color: #BBBB00;'>118.3</span><span> </span><span style='color: #555555;'>1.8</span><span> </span><span style='color: #555555;'>7</span><span> </span><span style='color: #555555;'>5.2</span><span>
## `new$elev[1164:1169]`: </span><span style='color: #555555;'>137.9</span><span> </span><span style='color: #555555;'>57.8</span><span> </span><span style='color: #555555;'>5.3</span><span>       </span><span style='color: #555555;'>1.8</span><span> </span><span style='color: #555555;'>7</span><span> </span><span style='color: #555555;'>5.2</span><span>
## 
## `old$elev[1258:1264]`: </span><span style='color: #555555;'>4.6</span><span> </span><span style='color: #555555;'>68</span><span> </span><span style='color: #555555;'>275</span><span> </span><span style='color: #00BB00;'>421.1</span><span> </span><span style='color: #555555;'>148</span><span> </span><span style='color: #555555;'>6.4</span><span> </span><span style='color: #555555;'>9</span><span>
## `new$elev[1230:1236]`: </span><span style='color: #555555;'>4.6</span><span> </span><span style='color: #555555;'>68</span><span> </span><span style='color: #555555;'>275</span><span>   </span><span style='color: #00BB00;'>420</span><span> </span><span style='color: #555555;'>148</span><span> </span><span style='color: #555555;'>6.4</span><span> </span><span style='color: #555555;'>9</span><span>
## 
## `old$elev[1359:1365]`: </span><span style='color: #555555;'>275</span><span> </span><span style='color: #555555;'>203</span><span> </span><span style='color: #555555;'>32</span><span> </span><span style='color: #00BB00;'>502.4</span><span> </span><span style='color: #555555;'>4.5</span><span> </span><span style='color: #555555;'>80</span><span> </span><span style='color: #555555;'>463</span><span>
## `new$elev[1331:1337]`: </span><span style='color: #555555;'>275</span><span> </span><span style='color: #555555;'>203</span><span> </span><span style='color: #555555;'>32</span><span>   </span><span style='color: #00BB00;'>521</span><span> </span><span style='color: #555555;'>4.5</span><span> </span><span style='color: #555555;'>80</span><span> </span><span style='color: #555555;'>463</span><span>
## 
## `old$elev[1462:1466]`: </span><span style='color: #555555;'>692.4</span><span> </span><span style='color: #555555;'>174</span><span> </span><span style='color: #555555;'>7</span><span> </span><span style='color: #BBBB00;'>300</span><span> </span><span style='color: #BBBB00;'>474</span><span>
## `new$elev[1434:1436]`: </span><span style='color: #555555;'>692.4</span><span> </span><span style='color: #555555;'>174</span><span> </span><span style='color: #555555;'>7</span><span>
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

AAC_code_changes <- list()

release_version <- paste0("v", packageVersion("bomrang"))
AAC_code_changes[[release_version]] <- changes

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
