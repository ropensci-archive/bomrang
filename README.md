
<!-- README.md is generated from README.Rmd. Please edit that file -->
*bomrang*: Fetch Australian Government Bureau of Meteorology (BOM) Data
=======================================================================

[![Travis-CI Build Status](https://travis-ci.org/ToowoombaTrio/bomrang.svg?branch=master)](https://travis-ci.org/ToowoombaTrio/bomrang) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ToowoombaTrio/bomrang?branch=master&svg=true)](https://ci.appveyor.com/project/ToowoombaTrio/bomrang) [![Coverage Status](https://img.shields.io/codecov/c/github/ToowoombaTrio/bomrang/master.svg)](https://codecov.io/github/ToowoombaTrio/bomrang?branch=master) [![Last-changedate](https://img.shields.io/badge/last%20change-2017--05--31-brightgreen.svg)](https://github.com/toowoombatrio/bomrang/commits/master) [![minimal R version](https://img.shields.io/badge/R%3E%3D-3.4.0-brightgreen.svg)](https://cran.r-project.org/) [![Licence](https://img.shields.io/github/license/mashape/apistatus.svg)](http://choosealicense.com/licenses/mit/) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.583811.svg)](https://doi.org/10.5281/zenodo.583811)

Provides functions to interface with Australian Government Bureau of Meteorology (BOM) data, fetching data and returning a tidy data frame of précis forecasts, current weather data from stations or ag information bulletins.

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

The main functionality of *bomrang* is provided through three functions, `get_precis_forecast()`, which retrieves the précis (short) forecast; `get_current_weather()`, which fetches the current weather from a given station; and `get_ag_bulletin()`, which retrieves the agriculture bulletin.

### Using `get_precis_forecast()`

This function only takes one parameter, `state`. States or territories are specified using the official postal codes.

-   **ACT** - Australian Capital Territory
-   **NSW** - New South Wales
-   **NT** - Northern Territory
-   **QLD** - Queensland
-   **SA** - South Australia
-   **TAS** - Tasmania
-   **VIC** - Victoria
-   **WA** - Western Australia
-   **AUS** - Australia, returns national forecast including all states/territories.

#### Results

The function, `get_precis_forecast()`, will return a tidy data frame of the weather forecast for the daily forecast with the following fields:

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
-   **elev** - Elevation of named location (metres).

#### Example

Following is an example fetching the précis forecast for Queensland.

``` r
library("bomrang")
```

    ## bomrang is not associated with the Australian Bureau of Meteorology (BOM).
    ##  BOM aims to make public sector information available on an open and
    ##  reusable basis where possible, including on its websites. bomrang retrieves
    ##  these data and formats them for use in R.
    ##  For full terms and conditions of the use of BOM data, please see:
    ##  http://www.bom.gov.au/other/copyright.shtml

``` r
QLD_forecast <- get_precis_forecast(state = "QLD")
head(QLD_forecast)
```

    ##         aac index    start_time_local end_time_local UTC_offset
    ## 1 QLD_PT001     0 2017-05-31 17:00:00     2017-06-01      10:00
    ## 2 QLD_PT001     1 2017-06-01 00:00:00     2017-06-02      10:00
    ## 3 QLD_PT001     2 2017-06-02 00:00:00     2017-06-03      10:00
    ## 4 QLD_PT001     3 2017-06-03 00:00:00     2017-06-04      10:00
    ## 5 QLD_PT001     4 2017-06-04 00:00:00     2017-06-05      10:00
    ## 6 QLD_PT001     5 2017-06-05 00:00:00     2017-06-06      10:00
    ##        start_time_utc        end_time_utc maximum_temperature
    ## 1 2017-05-31 07:00:00 2017-05-31 14:00:00                  NA
    ## 2 2017-05-31 14:00:00 2017-06-01 14:00:00                   9
    ## 3 2017-06-01 14:00:00 2017-06-02 14:00:00                  10
    ## 4 2017-06-02 14:00:00 2017-06-03 14:00:00                  10
    ## 5 2017-06-03 14:00:00 2017-06-04 14:00:00                  10
    ## 6 2017-06-04 14:00:00 2017-06-05 14:00:00                  10
    ##   minimum_temperature lower_prec_limit upper_prec_limit        precis
    ## 1                  NA               NA             <NA>        Clear.
    ## 2                  25                1                0 Mostly sunny.
    ## 3                   4                1                0 Mostly sunny.
    ## 4                   4                1                0 Mostly sunny.
    ## 5                   6                1                0 Mostly sunny.
    ## 6                   6                1                0 Mostly sunny.
    ##   probability_of_precipitation location state      lon      lat elev
    ## 1                            0 Brisbane   QLD 153.0389 -27.4808  8.1
    ## 2                           10 Brisbane   QLD 153.0389 -27.4808  8.1
    ## 3                           20 Brisbane   QLD 153.0389 -27.4808  8.1
    ## 4                           20 Brisbane   QLD 153.0389 -27.4808  8.1
    ## 5                           20 Brisbane   QLD 153.0389 -27.4808  8.1
    ## 6                           20 Brisbane   QLD 153.0389 -27.4808  8.1

### Using `get_ag_bulletin()`

This function only takes one parameter, `state`. The `state` parameter allows the user to select the bulletin for just one state or a national bulletin. States or territories are specified using the official postal codes.

-   **NSW** - New South Wales
-   **NT** - Northern Territory
-   **QLD** - Queensland
-   **SA** - South Australia
-   **TAS** - Tasmania
-   **VIC** - Victoria
-   **WA** - Western Australia
-   **AUS** - Australia, returns bulletin for all states/territories.

#### Results

The function, `get_ag_bulletin()`, will return a tidy data frame of the agriculture bulletin with the following fields:

-   **obs\_time\_utc** - Observation time (Time in UTC)
-   **time\_zone** - Time zone for observation
-   **site** - Unique BOM identifier for each station
-   **name** - BOM station name
-   **r** - Rain to 9am (millimetres). *Trace will be reported as 0.01*
-   **tn** - Minimum temperature (degrees Celsius)
-   **tx** - Maximum temperature (degrees Celsius)
-   **twd** - Wet bulb depression (degrees Celsius)
-   **ev** - Evaporation (millimetres)
-   **tg** - Terrestrial minimum temperature (degrees Celsius)
-   **sn** - Sunshine (hours)
-   **t5** - 5cm soil temperature (degrees Celsius)
-   **t10** - 10cm soil temperature (degrees Celsius)
-   **t20** - 20cm soil temperature (degrees Celsius)
-   **t50** - 50cm soil temperature (degrees Celsius)
-   **t1m** - 1m soil temperature (degrees Celsius)
-   **wr** - Wind run (kilometres)
-   **state** - State name (postal code abbreviation)
-   **lat** - Latitude (decimal degrees)
-   **lon** - Longitude (decimal degrees).

#### Example

Following is an example fetching the ag bulletin for Queensland.

``` r
library("bomrang")

QLD_bulletin <- get_ag_bulletin(state = "QLD")
head(QLD_bulletin)
```

    ##        obs_time_local        obs_time_utc time_zone  site dist
    ## 1 2017-05-31 09:00:00 2017-05-30 23:00:00       EST 38026   38
    ## 2 2017-05-31 09:00:00 2017-05-30 23:00:00       EST 38003   38
    ## 3 2017-05-31 09:00:00 2017-05-30 23:00:00       EST 40842   40
    ## 4 2017-05-31 09:00:00 2017-05-30 23:00:00       EST 39128   39
    ## 5 2017-05-31 09:00:00 2017-05-30 23:00:00       EST 31011   31
    ## 6 2017-05-31 09:00:00 2017-05-30 23:00:00       EST 44021   44
    ##                 name start end state      lat      lon height bar_ht   WMO
    ## 1 BIRDSVILLE AIRPORT  2000  NA   QLD -25.8975 139.3472   46.6   47.0 95482
    ## 2     BOULIA AIRPORT  1886  NA   QLD -22.9117 139.9039  161.8  158.3 94333
    ## 3      BRISBANE AERO  1992  NA   QLD -27.3917 153.1292    4.5    9.5 94578
    ## 4     BUNDABERG AERO  1942  NA   QLD -24.9069 152.3230   30.8   31.5 94387
    ## 5        CAIRNS AERO  1941  NA   QLD -16.8736 145.7458    2.2    8.3 94287
    ## 6   CHARLEVILLE AERO  1942  NA   QLD -26.4139 146.2558  301.6  303.3 94510
    ##   r   tn   tx twd  ev  tg  sn   t5  t10  t20  t50  t1m  wr
    ## 1 0  7.6 22.0 3.8  NA  NA  NA   NA   NA   NA   NA   NA  NA
    ## 2 0 10.3 23.9 6.1 9.6 8.6  NA   NA   NA   NA   NA   NA  NA
    ## 3 0  9.0 23.0 6.6 1.8 2.6 8.4 15.0 17.0 19.0 21.0 22.0 118
    ## 4 0 13.1 24.8 4.5  NA  NA  NA 18.4 19.2 20.6 19.8 22.4 132
    ## 5 0 22.2 28.0 3.7  NA  NA  NA   NA   NA   NA   NA   NA  NA
    ## 6 0  4.2 21.6 5.4  NA  NA  NA   NA   NA   NA   NA   NA  NA

### Using `get_current_weather()`

Returns the latest 72 hours weather observations for a station.

This function accepts four parameters:

-   `station_name`, The name of the weather station. Fuzzy string matching via `base::agrep` is done.

-   `latlon`, A length-2 numeric vector. When given instead of station\_name, the nearest station (in this package) is used, with a message indicating the nearest such station. (See also `sweep_for_stations()`.) Ignored if used in combination with `station_name`, with a warning.

-   `raw` Logical. Do not convert the columns data.table to the appropriate classes. (FALSE by default.)

-   `emit_latlon_msg` Logical. If `TRUE` (the default), and `latlon` is selected, a message is emitted before the table is returned indicating which station was actually used (i.e. which station was found to be nearest to the given coordinate).

#### Results

The function, `get_current_weather()` will return a tidy data frame of the current and past 72 hours observations for the requested station. The fields returned will vary between stations dependent upon the data that they provide. See the [BOM website](http://www.bom.gov.au/catalogue/observations/about-weather-observations.shtml) for more information.

#### Example

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
    ##   local_date_time local_date_time_full aifstime_utc   lat lon apparent_t
    ## 1      31/04:30pm                 <NA>         <NA> -37.8 145        8.6
    ## 2      31/04:00pm                 <NA>         <NA> -37.8 145        8.7
    ## 3      31/03:30pm                 <NA>         <NA> -37.8 145       10.0
    ## 4      31/03:00pm                 <NA>         <NA> -37.8 145        8.7
    ## 5      31/02:30pm                 <NA>         <NA> -37.8 145        9.8
    ## 6      31/02:00pm                 <NA>         <NA> -37.8 145        8.9
    ##   cloud cloud_type delta_t gust_kmh gust_kt air_temp dewpt  press
    ## 1     -          -     3.5       24      13     12.3   4.5 1033.7
    ## 2     -          -     3.2       22      12     12.3   5.2 1033.4
    ## 3     -          -     2.2       19      10     12.2   7.7 1033.3
    ## 4     -          -     2.4       26      14     12.2   7.1 1033.1
    ## 5     -          -     2.3       13       7     11.8   6.9 1033.0
    ## 6     -          -     2.4       26      14     12.4   7.3 1033.0
    ##   press_msl press_qnh press_tend rain_trace rel_hum sea_state
    ## 1    1033.7    1033.7          -        0.4      59         -
    ## 2    1033.4    1033.4          -        0.4      62         -
    ## 3    1033.3    1033.3          -        0.4      74         -
    ## 4    1033.1    1033.1          -        0.4      71         -
    ## 5    1033.0    1033.0          -        0.4      72         -
    ## 6    1033.0    1033.0          -        0.2      71         -
    ##   swell_dir_worded vis_km        weather wind_dir wind_spd_kmh wind_spd_kt
    ## 1                -     10              -        S           13           7
    ## 2                -     10              -      SSW           13           7
    ## 3                -     10              -       SW            9           5
    ## 4                -     10 Recent precip.       SW           15           8
    ## 5                -     10              -      SSE            7           4
    ## 6                -     10              -      SSW           15           8

Meta
----

-   Please [report any issues or bugs](https://github.com/ToowoombaTrio/bomrang/issues).
-   License: MIT
-   To cite *bomrang*, please use:
    Sparks A, Parsonage H, and Pembleton K (2017). *bomrang: Fetch Australian Government Bureau of Meteorology Weather Data*. R package version 0.0.2, &lt;URL: <https://github.com/ToowoombaTrio/bomrang>&gt;.
-   Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
-   BOM Copyright Notice <http://reg.bom.gov.au/other/copyright.shtml>

References
----------

[Australian Bureau of Meteorology (BOM) Weather Data Services](http://www.bom.gov.au/catalogue/data-feeds.shtml)

[Australian Bureau of Meteorology (BOM) Weather Data Services Agriculture Bulletins](http://www.bom.gov.au/catalogue/observations/about-agricultural.shtml)

[Australian Bureau of Meteorology (BOM) Weather Data Services Observation of Rainfall](http://www.bom.gov.au/climate/how/observations/rain-measure.shtml)
