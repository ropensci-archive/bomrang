
<!-- README.md is generated from README.Rmd. Please edit that file -->
*bomrang*: Fetch Australian Government Bureau of Meteorology (BOM) Data
=======================================================================

[![Travis-CI Build Status](https://travis-ci.org/ToowoombaTrio/bomrang.svg?branch=master)](https://travis-ci.org/ToowoombaTrio/bomrang) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ToowoombaTrio/bomrang?branch=master&svg=true)](https://ci.appveyor.com/project/ToowoombaTrio/bomrang) [![Coverage Status](https://img.shields.io/codecov/c/github/ToowoombaTrio/bomrang/master.svg)](https://codecov.io/github/ToowoombaTrio/bomrang?branch=master) [![Last-changedate](https://img.shields.io/badge/last%20change-2017--05--16-brightgreen.svg)](https://github.com/toowoombatrio/bomrang/commits/master) [![minimal R version](https://img.shields.io/badge/R%3E%3D-3.4.0-brightgreen.svg)](https://cran.r-project.org/) [![Licence](https://img.shields.io/github/license/mashape/apistatus.svg)](http://choosealicense.com/licenses/mit/)

Fetches Australian Government Bureau of Meteorology XML data and returns a tidy data frame ([tibble](http://tibble.tidyverse.org)).

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

Two functions are provided, `get_forecast()`, which retreives the précis forecast and `get_bulletin()`, which retrives the agriculture bulletin. Both of these functions in *bomrang* allow you to fetch data for an individual state or all at once, i.e., all of Australia. To fetch an individual state, simply use the official postal code for the state for the `state` parameter. To fetch data for all of Australia, use "AUS" in the `state` parameter.

### Using `get_forecast()`

This function only takes one parameter, `state`. States are specified using the official postal codes,

**ACT** - Australian Capital Territory
**NSW** - New South Wales
**NT** - Northern Territory
**QLD** - Queensland
**SA** - South Australia
**TAS** - Tasmania
**VIC** - Tasmania
**WA** - Western Australia
**AUS** - Australia, returns national forecast including all states

### Results

The function, `get_forecast()` will return a Tibble of the weather forecast for the daily forecast with the following fields,

-   **aac** - AMOC Area Code, e.g. WA\_MW008, a unique identifier for each location
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

QLD_forecast <- get_forecast(state = "QLD")
QLD_forecast
```

    ## # A tibble: 784 × 17
    ##          aac index          start_time_local            end_time_local
    ##        <chr> <chr>                     <chr>                     <chr>
    ## 1  QLD_PT038     0 2017-05-16T05:00:00+10:00 2017-05-17T00:00:00+10:00
    ## 2  QLD_PT038     1 2017-05-17T00:00:00+10:00 2017-05-18T00:00:00+10:00
    ## 3  QLD_PT038     2 2017-05-18T00:00:00+10:00 2017-05-19T00:00:00+10:00
    ## 4  QLD_PT038     3 2017-05-19T00:00:00+10:00 2017-05-20T00:00:00+10:00
    ## 5  QLD_PT038     4 2017-05-20T00:00:00+10:00 2017-05-21T00:00:00+10:00
    ## 6  QLD_PT038     5 2017-05-21T00:00:00+10:00 2017-05-22T00:00:00+10:00
    ## 7  QLD_PT038     6 2017-05-22T00:00:00+10:00 2017-05-23T00:00:00+10:00
    ## 8  QLD_PT045     0 2017-05-16T05:00:00+10:00 2017-05-17T00:00:00+10:00
    ## 9  QLD_PT045     1 2017-05-17T00:00:00+10:00 2017-05-18T00:00:00+10:00
    ## 10 QLD_PT045     2 2017-05-18T00:00:00+10:00 2017-05-19T00:00:00+10:00
    ## # ... with 774 more rows, and 13 more variables: start_time_utc <chr>,
    ## #   end_time_utc <chr>, maximum_temperature <dbl>,
    ## #   minimum_temperature <dbl>, lower_prec_limit <dbl>,
    ## #   upper_prec_limit <chr>, precis <chr>,
    ## #   probability_of_precipitation <chr>, location <chr>, state <chr>,
    ## #   lon <dbl>, lat <dbl>, elev <dbl>

### Using `get_bulletin()`

This function only takes one parameter, `state`. The `state` parameter allows the user to select the bulletin for just one state or a national bulletin. States are specified using the official postal codes,

**ACT** - Australian Capital Territory
**NSW** - New South Wales
**NT** - Northern Territory
**QLD** - Queensland
**SA** - South Australia
**TAS** - Tasmania
**VIC** - Tasmania
**WA** - Western Australia
**AUS** - Australia, returns forecast for all states

### Results

The function, `get_bulletin()` will return a tibble of the agriculture bulletin with the following fields,

-   **obs-time-utc** - Observation time (Time in UTC)
-   **time-zone** - Time zone for observation
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

QLD_forecast <- get_bulletin(state = "QLD")
QLD_forecast
```

    ## # A tibble: 26 × 20
    ##    `obs-time-utc` `time-zone`  site                     name     r    tn
    ##            <fctr>      <fctr> <chr>                    <chr> <dbl> <dbl>
    ## 1   20170514T2300         EST 38026       BIRDSVILLE AIRPORT  0.00  11.6
    ## 2   20170514T2300         EST 38003           BOULIA AIRPORT  0.00  14.5
    ## 3   20170514T2300         EST 40842            BRISBANE AERO  0.80  14.9
    ## 4   20170514T2300         EST 39128           BUNDABERG AERO  0.00  15.0
    ## 5   20170514T2300         EST 31011              CAIRNS AERO  0.00  19.4
    ## 6   20170514T2300         EST 44021         CHARLEVILLE AERO  1.20   7.2
    ## 7   20170514T2300         EST 33013 COLLINSVILLE POST OFFICE  0.01  15.0
    ## 8   20170514T2300         EST 41522            DALBY AIRPORT  4.60  10.5
    ## 9   20170514T2300         EST 30124       GEORGETOWN AIRPORT  0.00  13.4
    ## 10  20170514T2300         EST 32078         INGHAM COMPOSITE  0.01  17.3
    ## # ... with 16 more rows, and 14 more variables: tx <dbl>, twd <dbl>,
    ## #   ev <dbl>, tg <dbl>, sn <dbl>, t5 <dbl>, t10 <dbl>, t20 <dbl>,
    ## #   t50 <dbl>, t1m <dbl>, wr <dbl>, state <chr>, lat <dbl>, lon <dbl>

Meta
----

-   Please [report any issues or bugs](https://github.com/ToowoombaTrio/bomrang/issues).
-   License: MIT
-   To cite *bomrang*, please use:
    Sparks A and Pembleton K (2017). *bomrang: Fetch Australian Government Bureau of Meteorology Weather Data*. R package version 0.0.1-1, &lt;URL: <https://github.com/ToowoombaTrio/bomrang>&gt;.
-   Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

References
----------

[Australian Bureau of Meteorology (BOM) Weather Data Services](http://www.bom.gov.au/catalogue/data-feeds.shtml)

[Australian Bureau of Meteorology (BOM) Weather Data Services Agriculture Bulletins](http://www.bom.gov.au/catalogue/observations/about-agricultural.shtml)

[Australian Bureau of Meteorology (BOM) Weather Data Services Observation of Rainfall](http://www.bom.gov.au/climate/how/observations/rain-measure.shtml)
