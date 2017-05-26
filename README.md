
<!-- README.md is generated from README.Rmd. Please edit that file -->
*bomrang*: Fetch Australian Government Bureau of Meteorology (BOM) Data
=======================================================================

[![Travis-CI Build Status](https://travis-ci.org/ToowoombaTrio/bomrang.svg?branch=master)](https://travis-ci.org/ToowoombaTrio/bomrang) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ToowoombaTrio/bomrang?branch=master&svg=true)](https://ci.appveyor.com/project/ToowoombaTrio/bomrang) [![Coverage Status](https://img.shields.io/codecov/c/github/ToowoombaTrio/bomrang/master.svg)](https://codecov.io/github/ToowoombaTrio/bomrang?branch=master) [![Last-changedate](https://img.shields.io/badge/last%20change-2017--05--26-brightgreen.svg)](https://github.com/toowoombatrio/bomrang/commits/master) [![minimal R version](https://img.shields.io/badge/R%3E%3D-3.4.0-brightgreen.svg)](https://cran.r-project.org/) [![Licence](https://img.shields.io/github/license/mashape/apistatus.svg)](http://choosealicense.com/licenses/mit/) [![DOI](https://zenodo.org/badge/89690315.svg)](https://zenodo.org/badge/latestdoi/89690315)

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

Three main functions are provided. `get_precis_forecast()`, which retreives the précis forecast; `get_current_weather()`, which fetches the current weather at a given station; and `get_ag_bulletin()`, which retrives the agriculture bulletin. `get_precis_forecast()` and `get_ag_bulletin()` will allow you to fetch data for an individual state or all at once, i.e., all of Australia. To fetch an individual state, simply use the official postal code for the state for the `state` parameter. To fetch data for all of Australia, use "AUS" in the `state` parameter.

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

### Results

The function, `get_precis_forecast()` will return a tidy data frame of the weather forecast for the daily forecast with the following fields,

-   **aac** - AMOC Area Code, *e.g.*, WA\_MW008, a unique identifier for each location
-   **start\_time\_local** - Start of forecast date and time in local TZ
-   **end\_time\_local** - End of forecast date and time in local TZ
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

    ##         aac index          start_time_local            end_time_local
    ## 1 QLD_PT038     0 2017-05-26T05:00:00+10:00 2017-05-27T00:00:00+10:00
    ## 2 QLD_PT038     1 2017-05-27T00:00:00+10:00 2017-05-28T00:00:00+10:00
    ## 3 QLD_PT038     2 2017-05-28T00:00:00+10:00 2017-05-29T00:00:00+10:00
    ## 4 QLD_PT038     3 2017-05-29T00:00:00+10:00 2017-05-30T00:00:00+10:00
    ## 5 QLD_PT038     4 2017-05-30T00:00:00+10:00 2017-05-31T00:00:00+10:00
    ## 6 QLD_PT038     5 2017-05-31T00:00:00+10:00 2017-06-01T00:00:00+10:00
    ##         start_time_utc         end_time_utc maximum_temperature
    ## 1 2017-05-25T19:00:00Z 2017-05-26T14:00:00Z                  24
    ## 2 2017-05-26T14:00:00Z 2017-05-27T14:00:00Z                  24
    ## 3 2017-05-27T14:00:00Z 2017-05-28T14:00:00Z                  25
    ## 4 2017-05-28T14:00:00Z 2017-05-29T14:00:00Z                  26
    ## 5 2017-05-29T14:00:00Z 2017-05-30T14:00:00Z                  23
    ## 6 2017-05-30T14:00:00Z 2017-05-31T14:00:00Z                  22
    ##   minimum_temperature lower_prec_limit upper_prec_limit           precis
    ## 1                  NA               NA             <NA>   Partly cloudy.
    ## 2                   9                0              0.4 Possible shower.
    ## 3                   9                0                0   Partly cloudy.
    ## 4                  10                0                0           Sunny.
    ## 5                   7                0                0           Sunny.
    ## 6                   7                0                0           Sunny.
    ##   probability_of_precipitation   location state      lon      lat elev
    ## 1                            5 Beaudesert   QLD 152.9898 -27.9707 48.2
    ## 2                           30 Beaudesert   QLD 152.9898 -27.9707 48.2
    ## 3                           10 Beaudesert   QLD 152.9898 -27.9707 48.2
    ## 4                            5 Beaudesert   QLD 152.9898 -27.9707 48.2
    ## 5                            0 Beaudesert   QLD 152.9898 -27.9707 48.2
    ## 6                            0 Beaudesert   QLD 152.9898 -27.9707 48.2

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

    ##   obs_time_local  obs_time_utc time_zone  site               name r   tn
    ## 1  20170526T0900 20170525T2300       EST 38026 BIRDSVILLE AIRPORT 0  8.9
    ## 2  20170526T0900 20170525T2300       EST 38003     BOULIA AIRPORT 0 11.0
    ## 3  20170526T0900 20170525T2300       EST 40842      BRISBANE AERO 0 12.7
    ## 4  20170526T0900 20170525T2300       EST 39128     BUNDABERG AERO 0 14.1
    ## 5  20170526T0900 20170525T2300       EST 31011        CAIRNS AERO 0 21.7
    ## 6  20170526T0900 20170525T2300       EST 44021   CHARLEVILLE AERO 0  6.0
    ##     tx twd  ev   tg  sn   t5  t10  t20  t50  t1m  wr state      lat
    ## 1 25.2 4.0  NA   NA  NA   NA   NA   NA   NA   NA  NA   QLD -25.8975
    ## 2 30.4 6.1 9.2  8.7  NA   NA   NA   NA   NA   NA  NA   QLD -22.9117
    ## 3 24.0 3.2 3.6 11.1 9.5 18.0 19.0 20.0 21.0 22.0 213   QLD -27.3917
    ## 4 26.0 2.6  NA   NA  NA 18.9 19.5 20.7 20.3 22.6  NA   QLD -24.9069
    ## 5 27.9 4.0  NA   NA  NA   NA   NA   NA   NA   NA  NA   QLD -16.8736
    ## 6 24.5 5.4  NA   NA  NA   NA   NA   NA   NA   NA  NA   QLD -26.4139
    ##        lon
    ## 1 139.3472
    ## 2 139.9039
    ## 3 153.1292
    ## 4 152.3230
    ## 5 145.7458
    ## 6 146.2558

### Using `get_current_weather()`

Returns the latest 72 hours weather observations for a station.

This function accepts four parameters:

-   `station_name`, The name of the weather station. Fuzzy string matching via `base::agrep` is done.

-   `latlon`, A length-2 numeric vector. When given instead of station\_name, the nearest station (in this package) is used, with a message indicating the nearest such station. (See also `sweep_for_stations()`.) Ignored if used in combination with `station_name`, with a warning.

-   `raw` Do not convert the columns data.table to the appropriate classes. (FALSE by default.)

-   `emit_latlon_msg` Logical. If `TRUE` (the default), and `latlon`} is selected, a message is emitted before the table is returned indicating which station was actually used (i.e. which station was found to be nearest to the given coordinate).

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
    ## 1      26/03:00pm  2017-05-26 15:00:00 2017-05-26 05:00:00 -37.8 145
    ## 2      26/02:30pm  2017-05-26 14:30:00 2017-05-26 04:30:00 -37.8 145
    ## 3      26/02:00pm  2017-05-26 14:00:00 2017-05-26 04:00:00 -37.8 145
    ## 4      26/01:30pm  2017-05-26 13:30:00 2017-05-26 03:30:00 -37.8 145
    ## 5      26/01:00pm  2017-05-26 13:00:00 2017-05-26 03:00:00 -37.8 145
    ## 6      26/12:30pm  2017-05-26 12:30:00 2017-05-26 02:30:00 -37.8 145
    ##   apparent_t cloud cloud_type delta_t gust_kmh gust_kt air_temp dewpt
    ## 1       15.2     -          -     4.4       11       6     16.9   8.3
    ## 2       16.0     -          -     4.8        9       5     17.7   8.3
    ## 3       14.8     -          -     4.5        7       4     16.5   7.4
    ## 4       15.1     -          -     4.2        6       3     16.0   7.7
    ## 5       13.1     -          -     3.9       11       6     14.9   7.0
    ## 6       13.3     -          -     3.0       15       8     14.8   9.0
    ##    press press_msl press_qnh press_tend rain_trace rel_hum sea_state
    ## 1 1019.3    1019.3    1019.3          -          0      57         -
    ## 2 1019.8    1019.8    1019.8          -          0      54         -
    ## 3 1020.1    1020.1    1020.1          -          0      55         -
    ## 4 1020.6    1020.6    1020.6          -          0      58         -
    ## 5 1020.9    1020.9    1020.9          -          0      59         -
    ## 6 1021.5    1021.5    1021.5          -          0      68         -
    ##   swell_dir_worded vis_km weather wind_dir wind_spd_kmh wind_spd_kt
    ## 1                -     10       -      SSW            7           4
    ## 2                -     10       -      SSW            7           4
    ## 3                -     10       -      SSE            6           3
    ## 4                -     10       -      SSW            2           1
    ## 5                -     10       -        S            6           3
    ## 6                -     10       -      SSW            7           4

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
