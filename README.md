_bomrang_: Australian Government Bureau of Meteorology Data from R <img align="right" src="man/figures/logo.png">
================

[![CircleCI](https://circleci.com/gh/ropensci/bomrang.svg?style=shield)](https://circleci.com/gh/ropensci/bomrang) [![Appveyor](https://ci.appveyor.com/api/projects/status/au6p6qy1ah2lrtl5/branch/master?svg=true)](https://ci.appveyor.com/project/adamhsparks/bomrang/branch/master) [![codecov](https://codecov.io/gh/ropensci/bomrang/branch/master/graph/badge.svg)](https://codecov.io/gh/ropensci/bomrang) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.598301.svg)](https://doi.org/10.5281/zenodo.598301)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/bomrang)](https://cran.r-project.org/package=bomrang)
[![](https://badges.ropensci.org/121_status.svg)](https://github.com/ropensci/onboarding/issues/121)
[![status](http://joss.theoj.org/papers/350bf005bded599e4b0f3ac2acf138e8/status.svg)](http://joss.theoj.org/papers/350bf005bded599e4b0f3ac2acf138e8)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

Provides functions to interface with Australian Government Bureau of Meteorology (BOM) data, fetching data and returning a tidy data frame of précis forecasts, current weather data from stations, ag information bulletins, historical weather data or a `raster::stack()` object of satellite imagery from GeoTIFF files.

Credit for the name, *bomrang*, goes to [Di Cook](http://dicook.github.io), who suggested it while attending the rOpenSci AUUnconf in Brisbane, 2016, upon seeing the [vignette](https://github.com/saundersk1/auunconf16/blob/master/Vignette_BOM.pdf) that we had assembled during the Unconf.

Quick Start
-----------

Install the stable release from CRAN.

``` r
install.packages("bomrang")
```

Or from GitHub for the version in development.

``` r
if (!require("devtools")) {
  install.packages("devtools", repos = "http://cran.rstudio.com/")
  library("devtools")
}

devtools::install_github("ropensci/bomrang", build_vignettes = TRUE)
```

Using *bomrang*
---------------

Several functions are provided by *bomrang* to retrieve Australian Bureau of Meteorology (BOM) data. A family of functions retrieve weather data and return tidy data frames; `get_precis_forecast()`, which retrieves the précis (short) forecast; `get_current_weather()`, which fetches the current weather from a given station; `get_ag_bulletin()`, which retrieves the agriculture bulletin; `get_weather_bulletin()`, which retrieves the BOM 0900 or 1500 bulletins; and `get_historical()`, which retrieves historical daily observations for a given station. A second group of functions retrieve information pertaining to satellite imagery, `get_available_imagery()` and the imagery itself, `get_satellite_imagery()`. Vignettes are provided illustrating examples of all functions and a use case.

Meta
----

-   Please [report any issues or bugs](https://github.com/ropensci/bomrang/issues).

-   License:
    -   All code is licenced MIT

    -   All data is copyright Australia Bureau of Meteorology, BOM Copyright Notice <http://reg.bom.gov.au/other/copyright.shtml>

-   To cite *bomrang*, please use the output from `citation("bomrang")` to
cite it properly

-   Please note that this project is released with a
[Contributor Code of Conduct](CONDUCT.md). By participating in this project you
agree to abide by its terms.

References
----------

[Australian Bureau of Meteorology (BOM) Weather Data Services](http://www.bom.gov.au/catalogue/data-feeds.shtml)

[Australian Bureau of Meteorology (BOM) Weather Data Services Agriculture Bulletins](http://www.bom.gov.au/catalogue/observations/about-agricultural.shtml)

[Australian Bureau of Meteorology (BOM) Weather Data Services Observation of Rainfall](http://www.bom.gov.au/climate/how/observations/rain-measure.shtml)

[![](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
