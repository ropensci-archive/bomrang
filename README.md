
<!-- README.md is generated from README.Rmd. Please edit that file -->
*bomrang*: Fetch Australian Government Bureau of Meteorology (BOM) Data
=======================================================================

[![Travis-CI Build Status](https://travis-ci.org/ToowoombaTrio/bomrang.svg?branch=master)](https://travis-ci.org/ToowoombaTrio/bomrang) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ToowoombaTrio/bomrang?branch=master&svg=true)](https://ci.appveyor.com/project/ToowoombaTrio/bomrang) [![Coverage Status](https://img.shields.io/codecov/c/github/ToowoombaTrio/bomrang/master.svg)](https://codecov.io/github/ToowoombaTrio/bomrang?branch=master) [![Last-changedate](https://img.shields.io/badge/last%20change-2017--06--05-brightgreen.svg)](https://github.com/toowoombatrio/bomrang/commits/master) [![minimal R version](https://img.shields.io/badge/R%3E%3D-3.4.0-brightgreen.svg)](https://cran.r-project.org/) [![Licence](https://img.shields.io/github/license/mashape/apistatus.svg)](http://choosealicense.com/licenses/mit/) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.598301.svg)](https://doi.org/10.5281/zenodo.598301)

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

This function only takes one argument, `state`. States or territories are specified using the official postal codes.

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

The function `get_precis_forecast()` will return a tidy data frame of BOM data for the requested state(s) or territory. For a complete listing of the fields in the data frame see the `Précis Forecast Fields` vignette.

#### Example

Following is an example fetching the précis forecast for Queensland.

``` r
library("bomrang")

QLD_forecast <- get_precis_forecast(state = "QLD")
head(QLD_forecast)
```

    ##         aac index    start_time_local end_time_local UTC_offset
    ## 1 QLD_PT001     0 2017-06-05 05:00:00     2017-06-06      10:00
    ## 2 QLD_PT001     1 2017-06-06 00:00:00     2017-06-07      10:00
    ## 3 QLD_PT001     2 2017-06-07 00:00:00     2017-06-08      10:00
    ## 4 QLD_PT001     3 2017-06-08 00:00:00     2017-06-09      10:00
    ## 5 QLD_PT001     4 2017-06-09 00:00:00     2017-06-10      10:00
    ## 6 QLD_PT001     5 2017-06-10 00:00:00     2017-06-11      10:00
    ##        start_time_utc        end_time_utc maximum_temperature
    ## 1 2017-06-04 19:00:00 2017-06-05 14:00:00                  10
    ## 2 2017-06-05 14:00:00 2017-06-06 14:00:00                  10
    ## 3 2017-06-06 14:00:00 2017-06-07 14:00:00                   8
    ## 4 2017-06-07 14:00:00 2017-06-08 14:00:00                   9
    ## 5 2017-06-08 14:00:00 2017-06-09 14:00:00                  10
    ## 6 2017-06-09 14:00:00 2017-06-10 14:00:00                  10
    ##   minimum_temperature lower_prec_limit upper_prec_limit precis
    ## 1                  NA                1                0 Sunny.
    ## 2                   5                1                0 Sunny.
    ## 3                  26                1                0 Sunny.
    ## 4                  26                1                0 Sunny.
    ## 5                   4                1                0 Sunny.
    ## 6                   4                1                0 Sunny.
    ##   probability_of_precipitation location state      lon      lat elev
    ## 1                            0 Brisbane   QLD 153.0389 -27.4808  8.1
    ## 2                            0 Brisbane   QLD 153.0389 -27.4808  8.1
    ## 3                            0 Brisbane   QLD 153.0389 -27.4808  8.1
    ## 4                            0 Brisbane   QLD 153.0389 -27.4808  8.1
    ## 5                            0 Brisbane   QLD 153.0389 -27.4808  8.1
    ## 6                           20 Brisbane   QLD 153.0389 -27.4808  8.1

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

#### Results

The function `get_ag_bulletin()` will return a tidy data frame of BOM data for the requested state(s) or territory. For a complete listing of the fields in the data frame see the `Ag Bulletin Fields` vignette.

#### Example

Following is an example fetching the ag bulletin for Queensland.

``` r
library("bomrang")

QLD_bulletin <- get_ag_bulletin(state = "QLD")
head(QLD_bulletin)
```

    ##        obs_time_local        obs_time_utc time_zone  site dist
    ## 1 2017-06-05 09:00:00 2017-06-04 23:00:00       EST 38026   38
    ## 2 2017-06-05 09:00:00 2017-06-04 23:00:00       EST 38003   38
    ## 3 2017-06-05 09:00:00 2017-06-04 23:00:00       EST 40842   40
    ## 4 2017-06-05 09:00:00 2017-06-04 23:00:00       EST 39128   39
    ## 5 2017-06-05 09:00:00 2017-06-04 23:00:00       EST 31011   31
    ## 6 2017-06-05 09:00:00 2017-06-04 23:00:00       EST 44021   44
    ##            station start  end state      lat      lon  elev bar_ht   WMO
    ## 1       Birdsville  2000 2017   QLD -25.8975 139.3472  46.6   47.0 95482
    ## 2           Boulia  1886 2017   QLD -22.9117 139.9039 161.8  158.3 94333
    ## 3 Brisbane Airport  1992 2017   QLD -27.3917 153.1292   4.5    9.5 94578
    ## 4        Bundaberg  1942 2017   QLD -24.9069 152.3230  30.8   31.5 94387
    ## 5           Cairns  1941 2017   QLD -16.8736 145.7458   2.2    8.3 94287
    ## 6      Charleville  1942 2017   QLD -26.4139 146.2558 301.6  303.3 94510
    ##     r   tn   tx twd ev  tg  sn   t5  t10  t20  t50  t1m  wr
    ## 1 0.0  6.9 23.0 5.2 NA  NA  NA   NA   NA   NA   NA   NA  NA
    ## 2 0.0  7.2 25.8  NA  8 4.4  NA   NA   NA   NA   NA   NA  NA
    ## 3 0.0  9.8 22.6 3.1  4 7.9 8.6 16.0 17.0 18.0 20.0 21.0 216
    ## 4 0.0 11.7 24.0 2.8 NA  NA  NA 16.8 17.4 18.7 18.3 21.1  NA
    ## 5 7.8 19.2 26.5 1.9 NA  NA  NA   NA   NA   NA   NA   NA  NA
    ## 6 0.0  3.0 22.0 4.4 NA  NA  NA   NA   NA   NA   NA   NA  NA

### Using `get_current_weather()`

Returns the latest 72 hours weather observations for a station.

This function accepts four arguments:

-   `station_name`, The name of the weather station. Fuzzy string matching via `base::agrep` is done.

-   `latlon`, A length-2 numeric vector. When given instead of station\_name, the nearest station (in this package) is used, with a message indicating the nearest such station. (See also `sweep_for_stations()`.) Ignored if used in combination with `station_name`, with a warning.

-   `raw` Logical. Do not convert the columns data.table to the appropriate classes. (FALSE by default.)

-   `emit_latlon_msg` Logical. If `TRUE` (the default), and `latlon` is selected, a message is emitted before the table is returned indicating which station was actually used (i.e. which station was found to be nearest to the given coordinate).

#### Results

The function, `get_current_weather()` will return a tidy data frame of the current and past 72 hours observations for the requested station. For a complete listing of the fields in the data frame see the `Current Weather Fields` vignette.

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
    ##   local_date_time local_date_time_full        aifstime_utc   lat lon
    ## 1      05/10:00am  2017-06-05 10:00:00 2017-06-05 00:00:00 -37.8 145
    ## 2      05/09:30am  2017-06-05 09:30:00 2017-06-04 23:30:00 -37.8 145
    ## 3      05/09:00am  2017-06-05 09:00:00 2017-06-04 23:00:00 -37.8 145
    ## 4      05/08:30am  2017-06-05 08:30:00 2017-06-04 22:30:00 -37.8 145
    ## 5      05/08:00am  2017-06-05 08:00:00 2017-06-04 22:00:00 -37.8 145
    ## 6      05/07:30am  2017-06-05 07:30:00 2017-06-04 21:30:00 -37.8 145
    ##   apparent_t cloud cloud_type delta_t gust_kmh gust_kt air_temp dewpt
    ## 1        7.4     -          -     1.7       13       7     10.0   6.2
    ## 2        6.9     -          -     1.6       13       7      9.5   6.0
    ## 3        6.0     -          -     1.3       13       7      8.7   5.8
    ## 4        5.0     -          -     1.1       13       7      8.1   5.6
    ## 5        4.9     -          -     0.9       13       7      7.6   5.6
    ## 6        4.2     -          -     0.8       13       7      7.3   5.4
    ##    press press_msl press_qnh press_tend rain_trace rel_hum sea_state
    ## 1 1025.3    1025.3    1025.3          -          0      77         -
    ## 2 1025.5    1025.5    1025.5          -          0      79         -
    ## 3 1025.5    1025.5    1025.5          -          0      82         -
    ## 4 1025.4    1025.4    1025.4          -          0      84         -
    ## 5 1025.3    1025.3    1025.3          -          0      87         -
    ## 6 1025.3    1025.3    1025.3          -          0      88         -
    ##   swell_dir_worded vis_km weather wind_dir wind_spd_kmh wind_spd_kt
    ## 1                -     10       -      NNE            9           5
    ## 2                -     10       -      NNE            9           5
    ## 3                -     10       -      NNE            9           5
    ## 4                -     10       -      NNE           11           6
    ## 5                -     10       -       NE            9           5
    ## 6                -     10       -      NNE           11           6

Meta
----

-   Please [report any issues or bugs](https://github.com/ToowoombaTrio/bomrang/issues).
-   License: MIT
-   To cite *bomrang*, please use:
    Sparks A, Parsonage H and Pembleton K (2017). *BOMRang: Fetch Australian Government Bureau of Meteorology Weather Data*. doi: 10.5281/zenodo.598301 (URL: <http://doi.org/10.5281/zenodo.598301>), R package version 0.0.3-3, &lt;URL: <https://github.com/ToowoombaTrio/BOMRang>&gt;.
-   Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
-   BOM Copyright Notice <http://reg.bom.gov.au/other/copyright.shtml>

References
----------

[Australian Bureau of Meteorology (BOM) Weather Data Services](http://www.bom.gov.au/catalogue/data-feeds.shtml)

[Australian Bureau of Meteorology (BOM) Weather Data Services Agriculture Bulletins](http://www.bom.gov.au/catalogue/observations/about-agricultural.shtml)

[Australian Bureau of Meteorology (BOM) Weather Data Services Observation of Rainfall](http://www.bom.gov.au/climate/how/observations/rain-measure.shtml)
