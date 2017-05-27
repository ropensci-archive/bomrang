
<!-- README.md is generated from README.Rmd. Please edit that file -->
*bomrang*: Fetch Australian Government Bureau of Meteorology (BOM) Data
=======================================================================

[![Travis-CI Build Status](https://travis-ci.org/ToowoombaTrio/bomrang.svg?branch=master)](https://travis-ci.org/ToowoombaTrio/bomrang) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ToowoombaTrio/bomrang?branch=master&svg=true)](https://ci.appveyor.com/project/ToowoombaTrio/bomrang) [![Coverage Status](https://img.shields.io/codecov/c/github/ToowoombaTrio/bomrang/master.svg)](https://codecov.io/github/ToowoombaTrio/bomrang?branch=master) [![Last-changedate](https://img.shields.io/badge/last%20change-2017--05--27-brightgreen.svg)](https://github.com/toowoombatrio/bomrang/commits/master) [![minimal R version](https://img.shields.io/badge/R%3E%3D-3.4.0-brightgreen.svg)](https://cran.r-project.org/) [![Licence](https://img.shields.io/github/license/mashape/apistatus.svg)](http://choosealicense.com/licenses/mit/) [![DOI](https://zenodo.org/badge/89690315.svg)](https://zenodo.org/badge/latestdoi/89690315)

Fetches Australian Government Bureau of Meteorology data and returns a tidy data frame.

Credit for the name, *bomrang*, goes to [Di Cook](http://dicook.github.io), who suggested it attending the rOpenSci AUUnconf in Brisbane, 2016, when seeing the [vignette](https://github.com/saundersk1/auunconf16/blob/master/Vignette_BoM.pdf) that we had assembled during the Unconf.

Quick start
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

The main functionality of *bomrang* is provided through three functions, `get_precis_forecast()`, which retreives the précis (short) forecast; `get_current_weather()`, which fetches the current weather from a given station; and `get_ag_bulletin()`, which retrives the agriculture bulletin.

### Using `get_precis_forecast()`

This function only takes one parameter, `state`. States are specified using the official postal codes,

-   **ACT** - Australian Capital Territory
-   **NSW** - New South Wales
-   **NT** - Northern Territory
-   **QLD** - Queensland
-   **SA** - South Australia
-   **TAS** - Tasmania
-   **VIC** - Victoria
-   **WA** - Western Australia
-   **AUS** - Australia, returns national forecast including all states

#### Results

The function, `get_precis_forecast()` will return a tidy data frame of the weather forecast for the daily forecast with the following fields,

-   **aac** - AMOC Area Code, *e.g.*, WA\_MW008, a unique identifier for each location
-   **start\_time\_local** - Start of forecast date and time in local TZ
-   **end\_time\_local** - End of forecast date and time in local TZ
-   **UTC\_offset** - Hours offset from difference in hours and minutes from Coordinated Universal Time (UTC) for `start_time_local` and `end_time_local`
-   **start\_time\_utc** - Start of forecast date and time in UTC
-   **end\_time\_utc** - End of forecast date and time in UTC
-   **max\_temp** - Maximum forecasted temperature (degrees Celsius)
-   **min\_temp** - Minimum forecasted temperature (degrees Celsius)
-   **lower\_prcp\_limit** - Lower forecasted precipitation limit (millimetres)
-   **upper\_prcp\_limit** - Upper forecasted precipitation limit (millimetres)
-   **precis** - Précis forecast (a short summary, less than 30 characters)
-   **prob\_prcp** - Probability of precipitation (percent)
-   **location** - Named location for forecast
-   **state** - State name (postal code abbreviation)
-   **lon** - Longitude of named location (decimal degrees)
-   **lat** - Latitude of named location (decimal degrees)
-   **elev** - Elevation of named location (metres)

### Examples

Following is an example fetching the forecast for Queensland.

``` r
library("bomrang")

QLD_forecast <- get_precis_forecast(state = "QLD")
head(QLD_forecast)
```

    ##         aac index    start_time_local end_time_local UTC_offset
    ## 1 QLD_PT038     0 2017-05-27 05:00:00     2017-05-28      10:00
    ## 2 QLD_PT038     1 2017-05-28 00:00:00     2017-05-29      10:00
    ## 3 QLD_PT038     2 2017-05-29 00:00:00     2017-05-30      10:00
    ## 4 QLD_PT038     3 2017-05-30 00:00:00     2017-05-31      10:00
    ## 5 QLD_PT038     4 2017-05-31 00:00:00     2017-06-01      10:00
    ## 6 QLD_PT038     5 2017-06-01 00:00:00     2017-06-02      10:00
    ##        start_time_utc        end_time_utc maximum_temperature
    ## 1 2017-05-26 19:00:00 2017-05-27 14:00:00                  24
    ## 2 2017-05-27 14:00:00 2017-05-28 14:00:00                  25
    ## 3 2017-05-28 14:00:00 2017-05-29 14:00:00                  25
    ## 4 2017-05-29 14:00:00 2017-05-30 14:00:00                  24
    ## 5 2017-05-30 14:00:00 2017-05-31 14:00:00                  22
    ## 6 2017-05-31 14:00:00 2017-06-01 14:00:00                  21
    ##   minimum_temperature lower_prec_limit upper_prec_limit
    ## 1                  NA               NA             <NA>
    ## 2                  10                0              0.2
    ## 3                  11                0                0
    ## 4                   7                0                0
    ## 5                   7                0                0
    ## 6                   5                0                0
    ##                        precis probability_of_precipitation   location
    ## 1 Possible shower developing.                           40 Beaudesert
    ## 2 Early fog. Possible shower.                           30 Beaudesert
    ## 3                      Sunny.                            5 Beaudesert
    ## 4                      Sunny.                            0 Beaudesert
    ## 5                      Sunny.                            0 Beaudesert
    ## 6               Mostly sunny.                           20 Beaudesert
    ##   state      lon      lat elev
    ## 1   QLD 152.9898 -27.9707 48.2
    ## 2   QLD 152.9898 -27.9707 48.2
    ## 3   QLD 152.9898 -27.9707 48.2
    ## 4   QLD 152.9898 -27.9707 48.2
    ## 5   QLD 152.9898 -27.9707 48.2
    ## 6   QLD 152.9898 -27.9707 48.2

### Using `get_ag_bulletin()`

This function only takes one parameter, `state`. The `state` parameter allows the user to select the bulletin for just one state or a national bulletin. States are specified using the official postal codes,

-   **ACT** - Australian Capital Territory
-   **NSW** - New South Wales
-   **NT** - Northern Territory
-   **QLD** - Queensland
-   **SA** - South Australia
-   **TAS** - Tasmania
-   **VIC** - Victoria
-   **WA** - Western Australia
-   **AUS** - Australia, returns bulletin for all states

#### Results

The function, `get_ag_bulletin()` will return a tidy data frame of the agriculture bulletin with the following fields,

-   **obs\_time\_utc** - Observation time (Time in UTC)
-   **time\_zone** - Time zone for observation
-   **site** - Unique BOM identifier for each station
-   **name** - BOM station name
-   **r** - Rain to 9am (millimetres). *Trace will be reported as 0.01*
-   **tn** - Minimum temperature (degrees Celsius)
-   **tx** - Maximum temperature (degrees Celsius)
-   **twd** - Wetbulb depression (degress Celsius)
-   **ev** - Evaporation (millimetres)
-   **tg** - Terrestrial minimum temperature (degress Celsius)
-   **sn** - Sunshine (Hours)
-   **t5** - 5cm soil temperature (degrees Celsius)
-   **t10** - 10cm soil temperature (degrees Celsius)
-   **t20** - 20cm soil temperature (degrees Celsius)
-   **t50** - 50cm soil temperature (degrees Celsius)
-   **t1m** - 1m soil temperature (degrees Celsius)
-   **wr** - Wind run (kilometres)
-   **state** - State name (postal code abbreviation)
-   **lat** - Latitude (decimal degrees)
-   **lon** - Longitude (decimal degrees)

``` r
library("bomrang")

QLD_bulletin <- get_ag_bulletin(state = "QLD")
head(QLD_bulletin)
```

    ##        obs_time_local        obs_time_utc time_zone  site
    ## 1 2017-05-27 09:00:00 2017-05-26 23:00:00       EST 38026
    ## 2 2017-05-27 09:00:00 2017-05-26 23:00:00       EST 38003
    ## 3 2017-05-27 09:00:00 2017-05-26 23:00:00       EST 40842
    ## 4 2017-05-27 09:00:00 2017-05-26 23:00:00       EST 39128
    ## 5 2017-05-27 09:00:00 2017-05-26 23:00:00       EST 31011
    ## 6 2017-05-27 09:00:00 2017-05-26 23:00:00       EST 44021
    ##                 name r   tn   tx twd  ev   tg  sn   t5  t10  t20  t50  t1m
    ## 1 BIRDSVILLE AIRPORT 0 10.2 25.3 5.3  NA   NA  NA   NA   NA   NA   NA   NA
    ## 2     BOULIA AIRPORT 0 10.6 27.7 7.5 7.8  9.3  NA   NA   NA   NA   NA   NA
    ## 3      BRISBANE AERO 0 13.4 23.8 2.3 3.2 10.6 9.6 18.0 19.0 20.0 21.0 22.0
    ## 4     BUNDABERG AERO 0 14.4 26.0 2.8  NA   NA  NA 19.1 19.7 20.8 20.3 22.5
    ## 5        CAIRNS AERO 0 20.2 28.3 3.7  NA   NA  NA   NA   NA   NA   NA   NA
    ## 6   CHARLEVILLE AERO 0  9.3 26.0 5.9  NA   NA  NA   NA   NA   NA   NA   NA
    ##    wr state      lat      lon
    ## 1  NA   QLD -25.8975 139.3472
    ## 2  NA   QLD -22.9117 139.9039
    ## 3 143   QLD -27.3917 153.1292
    ## 4  NA   QLD -24.9069 152.3230
    ## 5  NA   QLD -16.8736 145.7458
    ## 6  NA   QLD -26.4139 146.2558

### Using `get_current_weather()`

Returns the latest 72 hours weather observations for a station.

This function accepts four parameters:

-   `station_name`, The name of the weather station. Fuzzy string matching via `base::agrep` is done.

-   `latlon`, A length-2 numeric vector. When given instead of station\_name, the nearest station (in this package) is used, with a message indicating the nearest such station. (See also `sweep_for_stations()`.) Ignored if used in combination with `station_name`, with a warning.

-   `raw` Logical. Do not convert the columns data.table to the appropriate classes. (FALSE by default.)

-   `emit_latlon_msg` Logical. If `TRUE` (the default), and `latlon` is selected, a message is emitted before the table is returned indicating which station was actually used (i.e. which station was found to be nearest to the given coordinate).

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
    ##   local_date_time local_date_time_full aifstime_utc   lat lon apparent_t
    ## 1      27/12:00pm                 <NA>         <NA> -37.8 145       12.3
    ## 2      27/11:30am                 <NA>         <NA> -37.8 145       11.9
    ## 3      27/11:00am                 <NA>         <NA> -37.8 145       12.4
    ## 4      27/10:30am                 <NA>         <NA> -37.8 145       12.2
    ## 5      27/10:00am                 <NA>         <NA> -37.8 145       11.5
    ## 6      27/09:30am                 <NA>         <NA> -37.8 145       10.9
    ##   cloud cloud_type delta_t gust_kmh gust_kt air_temp dewpt  press
    ## 1     -          -     3.8       39      21     16.9   9.6 1015.2
    ## 2     -          -     3.5       43      23     16.5   9.7 1015.9
    ## 3     -          -     3.2       35      19     16.4  10.3 1016.5
    ## 4     -          -     3.2       33      18     16.0   9.9 1016.7
    ## 5     -          -     2.6       32      17     15.2  10.2 1017.1
    ## 6     -          -     2.2       30      16     14.4  10.2 1017.3
    ##   press_msl press_qnh press_tend rain_trace rel_hum sea_state
    ## 1    1015.2    1015.2          -          0      62         -
    ## 2    1015.9    1015.9          -          0      64         -
    ## 3    1016.5    1016.5          -          0      67         -
    ## 4    1016.7    1016.7          -          0      67         -
    ## 5    1017.1    1017.1          -          0      72         -
    ## 6    1017.3    1017.3          -          0      76         -
    ##   swell_dir_worded vis_km weather wind_dir wind_spd_kmh wind_spd_kt
    ## 1                -     10       -        N           24          13
    ## 2                -     10       -        N           24          13
    ## 3                -     10       -        N           22          12
    ## 4                -     10       -        N           20          11
    ## 5                -     10       -        N           20          11
    ## 6                -      -       -        N           19          10

#### Results

The function, `get_current()` will return a tidy data frame of the current and past 72 hours observations for the requested station. The fields returned will vary between stations dependent upon the data that they provide. See the [BOM website](http://www.bom.gov.au/catalogue/observations/about-weather-observations.shtml) for more information.

Meta
----

-   Please [report any issues or bugs](https://github.com/ToowoombaTrio/bomrang/issues).
-   License: MIT
-   To cite *bomrang*, please use:
    Sparks A, Parsonage H, and Pembleton K (2017). *bomrang: Fetch Australian Government Bureau of Meteorology Weather Data*. R package version 0.0.1-1, &lt;URL: <https://github.com/ToowoombaTrio/bomrang>&gt;.
-   Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
-   BOM Copyright Notice <http://reg.bom.gov.au/other/copyright.shtml>

References
----------

[Australian Bureau of Meteorology (BOM) Weather Data Services](http://www.bom.gov.au/catalogue/data-feeds.shtml)

[Australian Bureau of Meteorology (BOM) Weather Data Services Agriculture Bulletins](http://www.bom.gov.au/catalogue/observations/about-agricultural.shtml)

[Australian Bureau of Meteorology (BOM) Weather Data Services Observation of Rainfall](http://www.bom.gov.au/climate/how/observations/rain-measure.shtml)
