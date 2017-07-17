*bomrang*: Fetch Australian Government Bureau of Meteorology (BoM) Data
=======================================================================

[![Travis-CI Build Status](https://travis-ci.org/ToowoombaTrio/bomrang.svg?branch=master)](https://travis-ci.org/ToowoombaTrio/bomrang) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ToowoombaTrio/bomrang?branch=master&svg=true)](https://ci.appveyor.com/project/ToowoombaTrio/bomrang) [![codecov](https://codecov.io/gh/ToowoombaTrio/bomrang/branch/master/graph/badge.svg)](https://codecov.io/gh/ToowoombaTrio/bomrang) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.598301.svg)](https://doi.org/10.5281/zenodo.598301)

Provides functions to interface with Australian Government Bureau of Meteorology (BoM) data, fetching data and returning a tidy data frame of précis forecasts, current weather data from stations or ag information bulletins.

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

The main functionality of *bomrang* is provided through three functions, `get_current_weather()`, which fetches the current weather from a given station; `get_precis_forecast()`, which retrieves the précis (short) forecast; and `get_ag_bulletin()`, which retrieves the agriculture bulletin.

### Using `get_current_weather()`

Returns the latest 72 hours weather observations for a station.

This function accepts four arguments:

-   `station_name`, The name of the weather station. Fuzzy string matching via `base::agrep` is done.

-   `latlon`, A length-2 numeric vector. When given instead of station\_name, the nearest station (in this package) is used, with a message indicating the nearest such station. (See also `sweep_for_stations()`.) Ignored if used in combination with `station_name`, with a warning.

-   `raw`, Logical. Do not convert the columns data.table to the appropriate classes. (FALSE by default.)

-   `emit_latlon_msg`, Logical. If `TRUE` (the default), and `latlon` is selected, a message is emitted before the table is returned indicating which station was actually used (i.e. which station was found to be nearest to the given coordinate).

#### Results of `get_current_weather()`

The function, `get_current_weather()` will return a tidy data frame of the current and past 72 hours observations for the requested station. For a complete listing of the fields in the data frame see Appendix 1, `Output from get_current_weather()` in the _bomrang_ vignette.

#### Example Using `get_current_weather()`

Following is an example fetching the current weather for Melbourne.

``` r
library("bomrang")

Melbourne_weather <- get_current_weather("Melbourne (Olympic Park)")
head(Melbourne_weather)
```

    ##   sort_order   wmo                     name history_product
    ## 1          0 95936 Melbourne (Olympic Park)        IDV60801
    ## 2          1 95936 Melbourne (Olympic Park)        IDV60801
    ## 3          2 95936 Melbourne (Olympic Park)        IDV60801
    ## 4          3 95936 Melbourne (Olympic Park)        IDV60801
    ## 5          4 95936 Melbourne (Olympic Park)        IDV60801
    ## 6          5 95936 Melbourne (Olympic Park)        IDV60801
    ##   local_date_time local_date_time_full        aifstime_utc   lat lon
    ## 1      14/10:00pm  2017-07-14 22:00:00 2017-07-14 12:00:00 -37.8 145
    ## 2      14/09:30pm  2017-07-14 21:30:00 2017-07-14 11:30:00 -37.8 145
    ## 3      14/09:00pm  2017-07-14 21:00:00 2017-07-14 11:00:00 -37.8 145
    ## 4      14/08:30pm  2017-07-14 20:30:00 2017-07-14 10:30:00 -37.8 145
    ## 5      14/08:00pm  2017-07-14 20:00:00 2017-07-14 10:00:00 -37.8 145
    ## 6      14/07:30pm  2017-07-14 19:30:00 2017-07-14 09:30:00 -37.8 145
    ##   apparent_t cloud cloud_base_m cloud_oktas cloud_type cloud_type_id
    ## 1        7.0     -           NA          NA          -            NA
    ## 2        6.7     -           NA          NA          -            NA
    ## 3        7.2     -           NA          NA          -            NA
    ## 4        7.4     -           NA          NA          -            NA
    ## 5        8.0     -           NA          NA          -            NA
    ## 6        7.9     -           NA          NA          -            NA
    ##   delta_t gust_kmh gust_kt air_temp dewpt  press press_msl press_qnh
    ## 1     2.8       20      11     10.1   3.8 1016.8    1016.8    1016.8
    ## 2     2.6       13       7      9.8   3.8 1016.5    1016.5    1016.5
    ## 3     2.9       19      10     10.3   3.6 1016.2    1016.2    1016.2
    ## 4     3.0       17       9     10.8   4.0 1016.0    1016.0    1016.0
    ## 5     3.3       17       9     11.1   3.6 1015.6    1015.6    1015.6
    ## 6     3.2       20      11     11.0   3.8 1015.2    1015.2    1015.2
    ##   press_tend rain_trace rel_hum sea_state swell_dir_worded swell_height
    ## 1          -          0      65         -                -           NA
    ## 2          -          0      66         -                -           NA
    ## 3          -          0      63         -                -           NA
    ## 4          -          0      63         -                -           NA
    ## 5          -          0      60         -                -           NA
    ## 6          -          0      61         -                -           NA
    ##   swell_period vis_km weather wind_dir wind_spd_kmh wind_spd_kt
    ## 1           NA     10       -        W            9           5
    ## 2           NA     10       -       NW            9           5
    ## 3           NA     10       -       NW            9           5
    ## 4           NA     10       -       NW           11           6
    ## 5           NA     10       -      WNW            9           5
    ## 6           NA     10       -      WNW            9           5

### Using `get_precis_forecast()`

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

#### `get_precis_forecast()` Results

The function `get_precis_forecast()` will return a tidy data frame of BoM data for the requested state(s) or territory. For a complete listing of the fields in the data frame see Appendix 2, `Output from get_precis_forecast()` in the _bomrang_ vignette.

#### Example Using `get_precis_forecast()`

Following is an example fetching the précis forecast for Queensland.

``` r
library("bomrang")
```

    ## 
    ## Data (c) Australian Government Bureau of Meteorology,
    ## Creative Commons (CC) Attribution 3.0 licence or
    ## Public Access Licence (PAL) as appropriate.
    ## See http://www.bom.gov.au/other/copyright.shtml

``` r
QLD_forecast <- get_precis_forecast(state = "QLD")
head(QLD_forecast)
```

    ##   index product_id state     town       aac      lon      lat elev
    ## 1     0   IDQ11295   QLD Brisbane QLD_PT001 153.0389 -27.4808  8.1
    ## 2     1   IDQ11295   QLD Brisbane QLD_PT001 153.0389 -27.4808  8.1
    ## 3     2   IDQ11295   QLD Brisbane QLD_PT001 153.0389 -27.4808  8.1
    ## 4     3   IDQ11295   QLD Brisbane QLD_PT001 153.0389 -27.4808  8.1
    ## 5     4   IDQ11295   QLD Brisbane QLD_PT001 153.0389 -27.4808  8.1
    ## 6     5   IDQ11295   QLD Brisbane QLD_PT001 153.0389 -27.4808  8.1
    ##      start_time_local end_time_local UTC_offset      start_time_utc
    ## 1 2017-07-15 05:00:00     2017-07-16      10:00 2017-07-14 19:00:00
    ## 2 2017-07-16 00:00:00     2017-07-17      10:00 2017-07-15 14:00:00
    ## 3 2017-07-17 00:00:00     2017-07-18      10:00 2017-07-16 14:00:00
    ## 4 2017-07-18 00:00:00     2017-07-19      10:00 2017-07-17 14:00:00
    ## 5 2017-07-19 00:00:00     2017-07-20      10:00 2017-07-18 14:00:00
    ## 6 2017-07-20 00:00:00     2017-07-21      10:00 2017-07-19 14:00:00
    ##          end_time_utc maximum_temperature minimum_temperature
    ## 1 2017-07-15 14:00:00                  13                  NA
    ## 2 2017-07-16 14:00:00                  11                   7
    ## 3 2017-07-17 14:00:00                  12                   6
    ## 4 2017-07-18 14:00:00                  14                   6
    ## 5 2017-07-19 14:00:00                   9                   6
    ## 6 2017-07-20 14:00:00                   9                   3
    ##   lower_precipitation_limit upper_precipitation_limit
    ## 1                         2                         4
    ## 2                         3                         6
    ## 3                         1                         0
    ## 4                         1                         1
    ## 5                         1                         0
    ## 6                         1                         0
    ##                                precis probability_of_precipitation
    ## 1 Mostly sunny. Possible late shower.                           60
    ## 2      Early rain then partly cloudy.                           70
    ## 3                      Partly cloudy.                           10
    ## 4               Possible late shower.                           30
    ## 5                              Sunny.                            5
    ## 6                              Sunny.                            0

### Using `get_ag_bulletin()`

This function only takes one argument, `state`. The `state` parameter allows the user to select the bulletin for just one state or a national bulletin. States or territories are specified using the official postal codes.

-   **NSW** - New South Wales

-   **NT** - Northern Territory

-   **QLD** - Queensland

-   **SA** - South Australia

-   **TAS** - Tasmania

-   **VIC** - Victoria

-   **WA** - Western Australia

-   **AUS** - Australia, returns bulletin for all states/territories.

#### `get_ag_bulletin()` Results

The function `get_ag_bulletin()` will return a tidy data frame of BoM data for the requested state(s) or territory. For a complete listing of the fields in the data frame see Appendix 3, `Output from get_ag_bulletin()` in the _bomrang_ vignette.

#### Example Using `get_ag_bulletin()`

Following is an example fetching the ag bulletin for Queensland.

``` r
library("bomrang")

QLD_bulletin <- get_ag_bulletin(state = "QLD")
head(QLD_bulletin)
```

    ##   product_id state dist   wmo  site    station          full_name
    ## 1   IDQ60604   QLD   38 95482 38026 Birdsville BIRDSVILLE AIRPORT
    ## 2   IDQ60604   QLD   38 95482 38026 Birdsville BIRDSVILLE AIRPORT
    ## 3   IDQ60604   QLD   38 95482 38026 Birdsville BIRDSVILLE AIRPORT
    ## 4   IDQ60604   QLD   38 95482 38026 Birdsville BIRDSVILLE AIRPORT
    ## 5   IDQ60604   QLD   38 94333 38003     Boulia     BOULIA AIRPORT
    ## 6   IDQ60604   QLD   38 94333 38003     Boulia     BOULIA AIRPORT
    ##        obs_time_local        obs_time_utc time_zone      lat      lon
    ## 1 2017-07-14 09:00:00 2017-07-13 23:00:00       EST -25.8975 139.3472
    ## 2 2017-07-14 09:00:00 2017-07-13 23:00:00       EST -25.8975 139.3472
    ## 3 2017-07-14 09:00:00 2017-07-13 23:00:00       EST -25.8975 139.3472
    ## 4 2017-07-14 09:00:00 2017-07-13 23:00:00       EST -25.8975 139.3472
    ## 5 2017-07-14 09:00:00 2017-07-13 23:00:00       EST -22.9117 139.9039
    ## 6 2017-07-14 09:00:00 2017-07-13 23:00:00       EST -22.9117 139.9039
    ##    elev bar_ht start  end  r   tn   tx twd ev tg sn t5 t10 t20 t50 t1m wr
    ## 1  46.6   47.0  2000 2017 NA   NA 27.1  NA NA NA NA NA  NA  NA  NA  NA NA
    ## 2  46.6   47.0  2000 2017 NA 11.5   NA  NA NA NA NA NA  NA  NA  NA  NA NA
    ## 3  46.6   47.0  2000 2017 NA   NA   NA 7.7 NA NA NA NA  NA  NA  NA  NA NA
    ## 4  46.6   47.0  2000 2017  0   NA   NA  NA NA NA NA NA  NA  NA  NA  NA NA
    ## 5 161.8  158.3  1886 2017 NA   NA 27.2  NA NA NA NA NA  NA  NA  NA  NA NA
    ## 6 161.8  158.3  1886 2017 NA 12.0   NA  NA NA NA NA NA  NA  NA  NA  NA NA

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
