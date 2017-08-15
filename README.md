README
================

*bomrang*: Fetch Australian Government Bureau of Meteorology (BoM) Data
=======================================================================

[![Travis-CI Build Status](https://travis-ci.org/ToowoombaTrio/bomrang.svg?branch=master)](https://travis-ci.org/ToowoombaTrio/bomrang) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ToowoombaTrio/bomrang?branch=master&svg=true)](https://ci.appveyor.com/project/ToowoombaTrio/bomrang) [![codecov](https://codecov.io/gh/ToowoombaTrio/bomrang/branch/master/graph/badge.svg)](https://codecov.io/gh/ToowoombaTrio/bomrang) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.598301.svg)](https://doi.org/10.5281/zenodo.598301)

Provides functions to interface with Australian Government Bureau of Meteorology (BoM) data, fetching data and returning a tidy data frame of précis forecasts, current weather data from stations, ag information bulletins or a `raster::stack()` object of satellite imagery from GeoTIFF files.

Credit for the name, *bomrang*, goes to [Di Cook](http://dicook.github.io), who suggested it attending the rOpenSci AUUnconf in Brisbane, 2016, when seeing the [vignette](https://github.com/saundersk1/auunconf16/blob/master/Vignette_BoM.pdf) that we had assembled during the Unconf.

Quick Start
-----------

``` r
if (!require("devtools")) {
  install.packages("devtools", repos = "http://cran.rstudio.com/")
  library("devtools")
}

devtools::install_github("toowoombatrio/bomrang")
```

Using *bomrang*
---------------

Several functions are provided by *bomrang* to retrieve Australian Bureau of Meteorology (BoM) data. A family of functions retrieve weather data and return tidy data frames; `get_precis_forecast()`, which retrieves the précis (short) forecast; `get_current_weather()`, which fetches the current weather from a given station; and `get_ag_bulletin()`, which retrieves the agriculture bulletin. A second group of functions retrieve information pertaining to satellite imagery, `get_available_imagery()` and the imagery itself, `get_satellite_imagery()`.

### Using `get_current_weather`

Returns the latest 72 hours weather observations for a station.

This function accepts four arguments:

-   `station_name`, The name of the weather station. Fuzzy string matching via `base::agrep` is done.

-   `latlon`, A length-2 numeric vector. When given instead of station\_name, the nearest station (in this package) is used, with a message indicating the nearest such station. (See also `sweep_for_stations()`.) Ignored if used in combination with `station_name`, with a warning.

-   `raw`, Logical. Do not convert the columns data.table to the appropriate classes. (FALSE by default.)

-   `emit_latlon_msg`, Logical. If `TRUE` (the default), and `latlon` is selected, a message is emitted before the table is returned indicating which station was actually used (i.e. which station was found to be nearest to the given coordinate).

#### Results of `get_current_weather`

The function, `get_current_weather()` will return a tidy data frame of the current and past 72 hours observations for the requested station. For a complete listing of the fields in the data frame see Appendix 1, `Output from get_current_weather()` in the *bomrang* vignette.

#### Example Using `get_current_weather`

Following is an example fetching the current weather for Melbourne.

``` r
library("bomrang")
```

    ## 
    ## Data (c) Australian Government Bureau of Meteorology,
    ## Creative Commons (CC) Attribution 3.0 licence or
    ## Public Access Licence (PAL) as appropriate.
    ## See http://www.bom.gov.au/other/copyright.shtml

``` r
Melbourne_weather <- get_current_weather("Melbourne (Olympic Park)")
head(Melbourne_weather)
```

    ##   sort_order   wmo                full_name history_product
    ## 1          0 95936 Melbourne (Olympic Park)        IDV60801
    ## 2          1 95936 Melbourne (Olympic Park)        IDV60801
    ## 3          2 95936 Melbourne (Olympic Park)        IDV60801
    ## 4          3 95936 Melbourne (Olympic Park)        IDV60801
    ## 5          4 95936 Melbourne (Olympic Park)        IDV60801
    ## 6          5 95936 Melbourne (Olympic Park)        IDV60801
    ##   local_date_time local_date_time_full        aifstime_utc   lat lon
    ## 1      13/12:30pm  2017-08-13 12:30:00 2017-08-13 02:30:00 -37.8 145
    ## 2      13/12:00pm  2017-08-13 12:00:00 2017-08-13 02:00:00 -37.8 145
    ## 3      13/11:30am  2017-08-13 11:30:00 2017-08-13 01:30:00 -37.8 145
    ## 4      13/11:00am  2017-08-13 11:00:00 2017-08-13 01:00:00 -37.8 145
    ## 5      13/10:30am  2017-08-13 10:30:00 2017-08-13 00:30:00 -37.8 145
    ## 6      13/10:00am  2017-08-13 10:00:00 2017-08-13 00:00:00 -37.8 145
    ##   apparent_t cloud cloud_base_m cloud_oktas cloud_type cloud_type_id
    ## 1       12.6     -           NA          NA          -            NA
    ## 2       11.0     -           NA          NA          -            NA
    ## 3       11.9     -           NA          NA          -            NA
    ## 4       11.6     -           NA          NA          -            NA
    ## 5        9.9     -           NA          NA          -            NA
    ## 6       10.0     -           NA          NA          -            NA
    ##   delta_t gust_kmh gust_kt air_temp dewpt  press press_msl press_qnh
    ## 1     4.7       28      15     16.5   6.9 1018.8    1018.8    1018.8
    ## 2     4.6       30      16     15.7   6.2 1019.7    1019.7    1019.7
    ## 3     4.5       32      17     16.3   7.3 1020.1    1020.1    1020.1
    ## 4     3.6       26      14     15.3   8.1 1020.5    1020.5    1020.5
    ## 5     3.1       28      15     14.2   7.9 1020.7    1020.7    1020.7
    ## 6     2.4       28      15     13.5   8.6 1020.9    1020.9    1020.9
    ##   press_tend rain_trace rel_hum sea_state swell_dir_worded swell_height
    ## 1          -          0      53         -                -           NA
    ## 2          -          0      53         -                -           NA
    ## 3          -          0      55         -                -           NA
    ## 4          -          0      62         -                -           NA
    ## 5          -          0      66         -                -           NA
    ## 6          -          0      72         -                -           NA
    ##   swell_period vis_km weather wind_dir wind_spd_kmh wind_spd_kt
    ## 1           NA     10       -        N           17           9
    ## 2           NA     10       -        N           20          11
    ## 3           NA     10       -      NNW           20          11
    ## 4           NA     10       -        N           17           9
    ## 5           NA     10       -        N           20          11
    ## 6           NA     10       -        N           17           9

### Using `get_precis_forecast`

This function only takes one argument, `state`. States or territories are specified using the official postal codes.

-   **ACT** - Australian Capital Territory

-   **NSW** - New South Wales

-   **NT** - Northern Territory

-   **QLD** - Queensland

-   **SA** - South Australia

-   **TAS** - Tasmania

-   **VIC** - Victoria

-   **WA** - Western Australia

-   **AUS** - Australia, returns national forecast including all states or territories.

#### `get_precis_forecast` Results

The function `get_precis_forecast()` will return a tidy data frame of BoM data for the requested state(s) or territory. For a complete listing of the fields in the data frame see Appendix 2, `Output from get_precis_forecast()` in the *bomrang* vignette.

#### Example Using `get_precis_forecast`

Following is an example fetching the précis forecast for Queensland.

``` r
QLD_forecast <- get_precis_forecast(state = "QLD")
head(QLD_forecast)
```

    ##   index product_id state     town       aac      lat      lon elev
    ## 1     0   IDQ11295   QLD Brisbane QLD_PT001 -27.4808 153.0389  8.1
    ## 2     1   IDQ11295   QLD Brisbane QLD_PT001 -27.4808 153.0389  8.1
    ## 3     2   IDQ11295   QLD Brisbane QLD_PT001 -27.4808 153.0389  8.1
    ## 4     3   IDQ11295   QLD Brisbane QLD_PT001 -27.4808 153.0389  8.1
    ## 5     4   IDQ11295   QLD Brisbane QLD_PT001 -27.4808 153.0389  8.1
    ## 6     5   IDQ11295   QLD Brisbane QLD_PT001 -27.4808 153.0389  8.1
    ##      start_time_local end_time_local UTC_offset      start_time_utc
    ## 1 2017-08-13 05:00:00     2017-08-14      10:00 2017-08-12 19:00:00
    ## 2 2017-08-14 00:00:00     2017-08-15      10:00 2017-08-13 14:00:00
    ## 3 2017-08-15 00:00:00     2017-08-16      10:00 2017-08-14 14:00:00
    ## 4 2017-08-16 00:00:00     2017-08-17      10:00 2017-08-15 14:00:00
    ## 5 2017-08-17 00:00:00     2017-08-18      10:00 2017-08-16 14:00:00
    ## 6 2017-08-18 00:00:00     2017-08-19      10:00 2017-08-17 14:00:00
    ##          end_time_utc minimum_temperature maximum_temperature
    ## 1 2017-08-13 14:00:00                  NA                  26
    ## 2 2017-08-14 14:00:00                  12                  26
    ## 3 2017-08-15 14:00:00                  12                  28
    ## 4 2017-08-16 14:00:00                  14                  30
    ## 5 2017-08-17 14:00:00                  15                  30
    ## 6 2017-08-18 14:00:00                  16                  27
    ##   lower_precipitation_limit upper_precipitation_limit precis
    ## 1                         0                         0 Sunny.
    ## 2                         0                         0 Sunny.
    ## 3                         0                         0 Sunny.
    ## 4                         0                         0 Sunny.
    ## 5                         0                         0 Sunny.
    ## 6                         0                         0 Sunny.
    ##   probability_of_precipitation
    ## 1                            5
    ## 2                            0
    ## 3                            0
    ## 4                            0
    ## 5                            5
    ## 6                            0

### Using `get_ag_bulletin`

This function only takes one argument, `state`. The `state` parameter allows the user to select the bulletin for just one state or a national bulletin. States or territories are specified using the official postal codes.

-   **NSW** - New South Wales

-   **NT** - Northern Territory

-   **QLD** - Queensland

-   **SA** - South Australia

-   **TAS** - Tasmania

-   **VIC** - Victoria

-   **WA** - Western Australia

-   **AUS** - Australia, returns bulletin for all states/territories.

#### `get_ag_bulletin` Results

The function `get_ag_bulletin()` will return a tidy data frame of BoM data for the requested state(s) or territory. For a complete listing of the fields in the data frame see Appendix 3, `Output from get_ag_bulletin()` in the *bomrang* vignette.

#### Example Using `get_ag_bulletin`

Following is an example fetching the ag bulletin for Queensland.

``` r
QLD_bulletin <- get_ag_bulletin(state = "QLD")
head(QLD_bulletin)
```

    ##   product_id state dist   wmo  site          station
    ## 1   IDQ60604   QLD   38 95482 38026       Birdsville
    ## 2   IDQ60604   QLD   40 94578 40842 Brisbane Airport
    ## 3   IDQ60604   QLD   39 94387 39128        Bundaberg
    ## 4   IDQ60604   QLD   31 94287 31011           Cairns
    ## 5   IDQ60604   QLD   44 94510 44021      Charleville
    ## 6   IDQ60604   QLD   33 94360 33013     Collinsville
    ##                  full_name      obs_time_local        obs_time_utc
    ## 1       BIRDSVILLE AIRPORT 2017-08-13 09:00:00 2017-08-12 23:00:00
    ## 2            BRISBANE AERO 2017-08-13 09:00:00 2017-08-12 23:00:00
    ## 3           BUNDABERG AERO 2017-08-13 09:00:00 2017-08-12 23:00:00
    ## 4              CAIRNS AERO 2017-08-13 09:00:00 2017-08-12 23:00:00
    ## 5         CHARLEVILLE AERO 2017-08-13 09:00:00 2017-08-12 23:00:00
    ## 6 COLLINSVILLE POST OFFICE 2017-08-13 09:00:00 2017-08-12 23:00:00
    ##   time_zone      lat      lon  elev bar_ht start  end r   tn   tx twd  ev
    ## 1       EST -25.8975 139.3472  46.6   47.0  2000 2017 0  9.8 27.6 8.4  NA
    ## 2       EST -27.3917 153.1292   4.5    9.5  1992 2017 0 11.5 25.3 5.6 3.4
    ## 3       EST -24.9069 152.3230  30.8   31.5  1942 2017 0 10.3 27.5 2.7  NA
    ## 4       EST -16.8736 145.7458   2.2    8.3  1941 2017 0 18.8 28.8 5.2  NA
    ## 5       EST -26.4139 146.2558 301.6  303.3  1942 2017 0  6.8 29.3 8.0  NA
    ## 6       EST -20.5533 147.8464 196.0     NA  1939 2017 0  8.0 28.2 3.1 5.2
    ##    tg  sn   t5  t10  t20  t50  t1m  wr
    ## 1  NA  NA   NA   NA   NA   NA   NA  NA
    ## 2 9.5 8.6 16.0 17.0 18.0 18.0 19.0 158
    ## 3  NA  NA 17.8 18.3 19.6 19.1 20.7  NA
    ## 4  NA  NA   NA   NA   NA   NA   NA  NA
    ## 5  NA  NA   NA   NA   NA   NA   NA  NA
    ## 6  NA  NA   NA   NA   NA   NA   NA  NA

#### Example using `get_available_imagery`

The function `get_available_imagery()` only takes one argument, `product_id`, a BoM identifier for the imagery that you wish to check for available imagery. Using this function will fetch a listing of BoM GeoTIFF satellite imagery from <ftp://ftp.bom.gov.au/anon/gen/gms/> to display which files are currently available for download. These files are available at ten minute update frequency with a 24 hour delete time. This function can be used see the most recent files available and then specify in the `get_satellite_imagery()` function. If no valid Product ID is supplied, defaults to all GeoTIFF images currently available.

``` r
# Most recent 5 images available for IDE00425
avail <- get_available_imagery(product_id = "IDE00426")
```

    ## 
    ## The following files are currently available for download:

    ##   [1] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120210.tif"
    ##   [2] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120220.tif"
    ##   [3] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120230.tif"
    ##   [4] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120250.tif"
    ##   [5] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120300.tif"
    ##   [6] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120310.tif"
    ##   [7] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120320.tif"
    ##   [8] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120330.tif"
    ##   [9] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120340.tif"
    ##  [10] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120350.tif"
    ##  [11] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120400.tif"
    ##  [12] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120410.tif"
    ##  [13] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120420.tif"
    ##  [14] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120430.tif"
    ##  [15] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120440.tif"
    ##  [16] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120450.tif"
    ##  [17] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120500.tif"
    ##  [18] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120510.tif"
    ##  [19] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120520.tif"
    ##  [20] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120530.tif"
    ##  [21] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120540.tif"
    ##  [22] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120550.tif"
    ##  [23] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120600.tif"
    ##  [24] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120610.tif"
    ##  [25] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120620.tif"
    ##  [26] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120630.tif"
    ##  [27] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120640.tif"
    ##  [28] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120650.tif"
    ##  [29] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120700.tif"
    ##  [30] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120710.tif"
    ##  [31] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120720.tif"
    ##  [32] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120730.tif"
    ##  [33] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120740.tif"
    ##  [34] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120750.tif"
    ##  [35] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120800.tif"
    ##  [36] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120810.tif"
    ##  [37] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120820.tif"
    ##  [38] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120830.tif"
    ##  [39] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120840.tif"
    ##  [40] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120850.tif"
    ##  [41] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120900.tif"
    ##  [42] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120910.tif"
    ##  [43] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120920.tif"
    ##  [44] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120930.tif"
    ##  [45] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120940.tif"
    ##  [46] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708120950.tif"
    ##  [47] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121000.tif"
    ##  [48] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121010.tif"
    ##  [49] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121020.tif"
    ##  [50] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121030.tif"
    ##  [51] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121040.tif"
    ##  [52] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121050.tif"
    ##  [53] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121100.tif"
    ##  [54] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121110.tif"
    ##  [55] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121120.tif"
    ##  [56] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121130.tif"
    ##  [57] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121140.tif"
    ##  [58] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121150.tif"
    ##  [59] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121200.tif"
    ##  [60] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121210.tif"
    ##  [61] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121220.tif"
    ##  [62] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121230.tif"
    ##  [63] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121240.tif"
    ##  [64] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121250.tif"
    ##  [65] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121300.tif"
    ##  [66] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121310.tif"
    ##  [67] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121320.tif"
    ##  [68] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121330.tif"
    ##  [69] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121340.tif"
    ##  [70] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121350.tif"
    ##  [71] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121400.tif"
    ##  [72] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121410.tif"
    ##  [73] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121420.tif"
    ##  [74] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121430.tif"
    ##  [75] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121450.tif"
    ##  [76] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121500.tif"
    ##  [77] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121510.tif"
    ##  [78] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121520.tif"
    ##  [79] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121530.tif"
    ##  [80] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121540.tif"
    ##  [81] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121550.tif"
    ##  [82] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121600.tif"
    ##  [83] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121610.tif"
    ##  [84] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121620.tif"
    ##  [85] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121630.tif"
    ##  [86] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121640.tif"
    ##  [87] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121650.tif"
    ##  [88] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121700.tif"
    ##  [89] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121710.tif"
    ##  [90] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121720.tif"
    ##  [91] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121730.tif"
    ##  [92] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121740.tif"
    ##  [93] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121750.tif"
    ##  [94] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121800.tif"
    ##  [95] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121810.tif"
    ##  [96] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121820.tif"
    ##  [97] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121830.tif"
    ##  [98] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121840.tif"
    ##  [99] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121850.tif"
    ## [100] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121900.tif"
    ## [101] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121910.tif"
    ## [102] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121920.tif"
    ## [103] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121930.tif"
    ## [104] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121940.tif"
    ## [105] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708121950.tif"
    ## [106] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122000.tif"
    ## [107] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122010.tif"
    ## [108] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122020.tif"
    ## [109] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122030.tif"
    ## [110] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122040.tif"
    ## [111] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122050.tif"
    ## [112] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122100.tif"
    ## [113] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122110.tif"
    ## [114] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122120.tif"
    ## [115] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122130.tif"
    ## [116] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122140.tif"
    ## [117] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122150.tif"
    ## [118] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122200.tif"
    ## [119] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122210.tif"
    ## [120] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122220.tif"
    ## [121] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122230.tif"
    ## [122] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122240.tif"
    ## [123] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122250.tif"
    ## [124] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122300.tif"
    ## [125] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122310.tif"
    ## [126] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122320.tif"
    ## [127] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122330.tif"
    ## [128] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122340.tif"
    ## [129] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708122350.tif"
    ## [130] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708130000.tif"
    ## [131] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708130010.tif"
    ## [132] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708130020.tif"
    ## [133] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708130030.tif"
    ## [134] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708130040.tif"
    ## [135] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708130050.tif"
    ## [136] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708130100.tif"
    ## [137] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708130110.tif"
    ## [138] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708130120.tif"
    ## [139] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708130130.tif"
    ## [140] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708130140.tif"
    ## [141] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708130150.tif"
    ## [142] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708130200.tif"
    ## [143] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708130210.tif"
    ## [144] "ftp://ftp.bom.gov.au/anon/gen/gms/IDE00426.201708130220.tif"

### Example using `get_satellite_imagery`

`get_satellite_imagery()` fetches BoM satellite GeoTIFF imagery, returning a raster stack object and takes three arguments. Files are available at ten minute update frequency with a 24 hour delete time. It is suggested to check file availability first by using `get_available_imagery()`. The arguments are:

-   `product_id`, a character value of the BoM product ID to download. Alternatively, a vector of values from `get_available_imagery()` may be used here. This argument is mandatory.

-   `scans` a numeric value for the number of scans to download, starting with the most recent and progressing backwards, *e.g.*, `1` - the most recent single scan available , `6` - the most recent hour available, `12` - the most recent 2 hours available, etc. Negating will return the oldest files first. Defaults to 1. This argument is optional.

-   `cache` a logical value that indicates whether or not to store image files locally for later use? If `FALSE`, the downloaded files are removed when R session is closed. To take advantage of cached files in future sessions, set `TRUE`. Defaults to `FALSE`. This argument is optional. Cached files may be managed with the `manage_bomrang_cache()` function.

``` r
# Use `avail` from prior and download only most recent scan
imagery <- get_satellite_imagery(product_id = avail, scans = 1)

# load the raster library to work with the GeoTIFF files
library(raster)
```

    ## Loading required package: sp

``` r
plot(imagery)
```

![man/figures/get_satellite_imagery-1.png](man/figures/get_satellite_imagery-1.png)

Meta
----

-   Please [report any issues or bugs](https://github.com/ToowoombaTrio/bomrang/issues).

-   License:
    -   All code is licenced MIT

    -   All data is copyright Australia Bureau of Meteorology, BoM Copyright Notice <http://reg.bom.gov.au/other/copyright.shtml>

-   To cite *bomrang*, please use: Sparks A, Parsonage H and Pembleton K (2017). *bomrang: Fetch Australian Government Bureau of Meteorology Weather Data*. doi: 10.5281/zenodo.598301 (URL: <http://doi.org/10.5281/zenodo.598301>), R package version 0.0.4-1,

    or the BibTeX entry:

    ``` tex
    @Manual{R-pkg-bomrang,
    author       = {Adam Sparks and Hugh Parsonage and Keith Pembleton},
    title        = {bomrang: Fetch Australian Government Bureau of Meteorology
    Weather Data},
    year         = {2017},
    doi          = {10.5281/zenodo.598301},
    url          = {https://github.com/ToowoombaTrio/bomrang}
    ```

-   Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

References
----------

[Australian Bureau of Meteorology (BoM) Weather Data Services](http://www.bom.gov.au/catalogue/data-feeds.shtml)

[Australian Bureau of Meteorology (BoM) Weather Data Services Agriculture Bulletins](http://www.bom.gov.au/catalogue/observations/about-agricultural.shtml)

[Australian Bureau of Meteorology (BoM) Weather Data Services Observation of Rainfall](http://www.bom.gov.au/climate/how/observations/rain-measure.shtml)
