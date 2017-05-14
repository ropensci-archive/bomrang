
<!-- README.md is generated from README.Rmd. Please edit that file -->
*BOMRang*: Fetch Australian Government Bureau of Meteorology (BOM) Data
=======================================================================

[![Travis-CI Build Status](https://travis-ci.org/ToowoombaTrio/BOMRang.svg?branch=master)](https://travis-ci.org/ToowoombaTrio/BOMRang) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ToowoombaTrio/BOMRang?branch=master&svg=true)](https://ci.appveyor.com/project/ToowoombaTrio/BOMRang) [![Coverage Status](https://img.shields.io/codecov/c/github/ToowoombaTrio/BOMRang/master.svg)](https://codecov.io/github/ToowoombaTrio/BOMRang?branch=master) [![Last-changedate](https://img.shields.io/badge/last%20change-2017--05--14-brightgreen.svg)](https://github.com/toowoombatrio/BOMRang/commits/master) [![minimal R version](https://img.shields.io/badge/R%3E%3D-3.4.0-brightgreen.svg)](https://cran.r-project.org/) [![Licence](https://img.shields.io/github/license/mashape/apistatus.svg)](http://choosealicense.com/licenses/mit/)

Fetches Australian Government Bureau of Meteorology XML précis forecast and returns a tidy data frame ([Tibble](http://tibble.tidyverse.org)) of the daily weather forecast.

Credit for the name, *BOMRang*, goes to [Di Cook](http://dicook.github.io), who suggested it attending the rOpenSci AUUnconf in Brisbane, 2016, when seeing the [vignette](https://github.com/saundersk1/auunconf16/blob/master/Vignette_BoM.pdf) that we had assembled during the Unconf.

Quick start
-----------

``` r
if (!require("devtools")) {
  install.packages("devtools", repos = "http://cran.rstudio.com/") 
  library("devtools")
}

devtools::install_github("toowoombatrio/BOMRang")
```

Using *BOMRang*
---------------

*BOMRang* allows you to fetch forecasts for an individual state or all at once, the national forecast. To fetch an individual state, simply use the official postal code for the state for the `state` parameter.

Fetch the forecast for Queensland

``` r
library("BOMRang")

QLD_forecast <- get_forecast(state = "QLD")
QLD_forecast
```

    ## # A tibble: 672 × 13
    ##          aac       date max_temp min_temp lower_prcp_limit
    ##        <chr>      <chr>    <chr>    <chr>            <chr>
    ## 1  QLD_PT038 2017-05-15       25       10               0 
    ## 2  QLD_PT038 2017-05-16       25        9               0 
    ## 3  QLD_PT038 2017-05-17       24        8               0 
    ## 4  QLD_PT038 2017-05-18       24       10               0 
    ## 5  QLD_PT038 2017-05-19       23       13               2 
    ## 6  QLD_PT038 2017-05-20       23       14               6 
    ## 7  QLD_PT045 2017-05-15       24        9               0 
    ## 8  QLD_PT045 2017-05-16       24        8               0 
    ## 9  QLD_PT045 2017-05-17       24        7               0 
    ## 10 QLD_PT045 2017-05-18       23        9               0 
    ## # ... with 662 more rows, and 8 more variables: upper_prcp_limit <chr>,
    ## #   precis <chr>, prob_prcp <chr>, location <chr>, state <chr>, lon <dbl>,
    ## #   lat <dbl>, elev <dbl>

If you want the national forecast for all areas BOM offers, use the official three letter ISO code abbreviation for Australia, AUS, as the `state` parameter.

``` r
BOM_forecast <- get_forecast(state = "AUS")
```

Results
-------

The function, `get_forecast()` will return a Tibble of the weather forecast for daily forecast with the following fields.

-   **aac** - AMOC Area Code, e.g. WA\_MW008, a unique identifier for each location
-   **date** - Date (YYYY-MM-DD)
-   **max\_temp** - Maximum forecasted temperature (degrees Celsius)
-   **min\_temp** - Minimum forecasted temperature (degrees Celsius)
-   **lower\_prcp\_limit** - Lower forecasted precipitation limit (millimetres)
-   **upper\_prcp\_limit** - Upper forecasted precipitation limit (millimetres)
-   **precis** - Précis forecast (a short summary, less than 30 characters)
-   **prob\_prcp** - Probability of precipitation (percent)
-   **location** - Named location for forecast
-   **state** - State name (postal code abbreviation)
-   **lon** - Longitude of named location (decimal Degrees)
-   **lat** - Latitude of named location (decimal Degrees)
-   **elev** - Elevation of named location (metres)

Meta
----

-   Please [report any issues or bugs](https://github.com/ToowoombaTrio/BOMRang/issues).
-   License: MIT
-   To cite *BOMRang*, please use:
    Sparks A and Pembleton K (2017). *BOMRang: Fetch Australian Government Bureau of Meteorology Weather Data*. R package version 0.0.1-1, &lt;URL: <https://github.com/ToowoombaTrio/BOMRang>&gt;.
-   Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

References
----------

[Australian Bureau of Meteorology (BOM) Weather Data Services](http://www.bom.gov.au/catalogue/data-feeds.shtml)
