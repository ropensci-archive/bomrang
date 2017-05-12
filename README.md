
<!-- README.md is generated from README.Rmd. Please edit that file -->
*BOMRang*: Fetch Australian Government Bureau of Meteorology Data
=================================================================

[![Travis-CI Build Status](https://travis-ci.org/ToowoombaTrio/BOMRang.svg?branch=master)](https://travis-ci.org/ToowoombaTrio/BOMRang) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ToowoombaTrio/BOMRang?branch=master&svg=true)](https://ci.appveyor.com/project/ToowoombaTrio/BOMRang) [![Coverage Status](https://img.shields.io/codecov/c/github/ToowoombaTrio/BOMRang/master.svg)](https://codecov.io/github/ToowoombaTrio/BOMRang?branch=master) [![Last-changedate](https://img.shields.io/badge/last%20change-2017--05--12-brightgreen.svg)](https://github.com/toowoombatrio/BOMRang/commits/master) [![minimal R version](https://img.shields.io/badge/R%3E%3D-3.4.0-brightgreen.svg)](https://cran.r-project.org/)

Fetches Australian Government Bureau of Meteorology Weather xml forecast and returns a tidy data frame ([Tibble](http://tibble.tidyverse.org)) of next six days' weather forecast.

Credit for the name, *BOMRang*, goes to [Di Cook](http://dicook.github.io), who suggested it attending the rOpenSci AUUnconf in Brisbane, 2016 when seeing the [vignette](https://github.com/saundersk1/auunconf16/blob/master/Vignette_BoM.pdf) that we had assembled during the Unconf.

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

*BOMRang* allows you to fetch forecasts for an individual state or all at once, your choice. To fetch an individual state, simply use the official postal code for the state for the `state` parameter.

Fetch the forecast for Queensland

``` r
library("BOMRang")

QLD_forecast <- get_forecast(state = "QLD")
QLD_forecast
```

    ## # A tibble: 672 × 13
    ##          aac       date max_temp min_temp lower_prcp_limit
    ##        <chr>      <chr>    <chr>    <chr>            <chr>
    ## 1  QLD_PT038 2017-05-13       24       12               0 
    ## 2  QLD_PT038 2017-05-14       24       13               5 
    ## 3  QLD_PT038 2017-05-15       26       10               0 
    ## 4  QLD_PT038 2017-05-16       25        9               0 
    ## 5  QLD_PT038 2017-05-17       25        9               0 
    ## 6  QLD_PT038 2017-05-18       24       11               0 
    ## 7  QLD_PT045 2017-05-13       23       11               0 
    ## 8  QLD_PT045 2017-05-14       23       12               3 
    ## 9  QLD_PT045 2017-05-15       25        9               0 
    ## 10 QLD_PT045 2017-05-16       25        7               0 
    ## # ... with 662 more rows, and 8 more variables: upper_prcp_limit <chr>,
    ## #   precis <chr>, prob_prcp <chr>, location <chr>, state <chr>, lon <dbl>,
    ## #   lat <dbl>, elev <dbl>

If you want the national forecast for all areas BOM offers, use the official three letter ISO code abbreviation for Australia, AUS, as the `state` parameter.

``` r
BOM_forecast <- get_forecast(state = "AUS")
```

Meta
----

-   Please [report any issues or bugs](https://github.com/ToowoombaTrio/BOMRang/issues).
-   License: MIT
-   To cite *BOMRang*, please use:
    Sparks A and Pembleton K (2017). *BOMRang: Fetch Australian Government Bureau of Meteorology Weather Data*. R package version 0.0.1-1, &lt;URL: <https://github.com/ToowoombaTrio/BOMRang>&gt;.
-   Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
