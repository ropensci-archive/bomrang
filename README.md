_bomrang_: Australian Government Bureau of Meteorology (BOM) Data Client <img align="right" src="man/figures/logo.png">
================
![](https://github.com/ropensci/bomrang/workflows/R-CMD-check/badge.svg) [![codecov](https://codecov.io/gh/ropensci/bomrang/branch/master/graph/badge.svg)](https://codecov.io/gh/ropensci/bomrang) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.598301.svg)](https://doi.org/10.5281/zenodo.598301)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/bomrang)](https://cran.r-project.org/package=bomrang)
[![](https://badges.ropensci.org/121_status.svg)](https://github.com/ropensci/onboarding/issues/121)
[![status](http://joss.theoj.org/papers/350bf005bded599e4b0f3ac2acf138e8/status.svg)](http://joss.theoj.org/papers/350bf005bded599e4b0f3ac2acf138e8)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

Provides functions to interface with Australian Government Bureau of Meteorology
(BOM) data, fetching data and returning a tidy data frame of précis forecasts,
current weather data from stations, ag information bulletins, historical weather
data and downloading and importing radar or satellite imagery.

Credit for the name, *bomrang*, goes to [Di Cook](http://dicook.org/), who
suggested it while attending the rOpenSci AUUnconf in Brisbane, 2016.

Quick Start
-----------

Install the stable release from CRAN.

``` r
install.packages("bomrang")
```

Or from GitHub for the version in development.

``` r
if (!require("remotes")) {
  install.packages("remotes", repos = "http://cran.rstudio.com/")
  library("remotes")
}

install_github("ropensci/bomrang", build_vignettes = TRUE)
```

Using *bomrang*
---------------

Several functions are provided by *bomrang* to retrieve Australian Bureau of
Meteorology (BOM) data. A family of functions retrieve weather data and return
tidy data frames;
  - `get_precis_forecast()`, which retrieves the précis (short) forecast;
  - `get_current_weather()`, which fetches the current weather for a given
  station;
  - `get_ag_bulletin()`, which retrieves the agriculture bulletin;
  - `get_weather_bulletin()`, which retrieves the BOM 0900 or 1500 bulletins;
  - `get_coastal_forecast()`, which returns coastal waters forecasts; and
  - `get_historical()`, which retrieves historical daily observations for a given
station.

A second group of functions retrieve information pertaining to satellite
and radar imagery,
  - `get_available_imagery()`;
  -  the satellite imagery itself, `get_satellite_imagery()`;
  - `get_available_radar()`; and 
  - the radar imagery itself, `get_radar_imagery()`.
  
[Vignettes are provided illustrating examples](https://docs.ropensci.org/bomrang/articles/bomrang.html)
of all functions and a [use case](https://docs.ropensci.org/bomrang/articles/use_case.html).

Meta
----

-   Please
  [report any issues or bugs](https://github.com/ropensci/bomrang/issues).

-   License:
    - All code is licensed MIT

    - All data is copyright Australia Bureau of Meteorology, BOM Copyright
    Notice <br /><http://reg.bom.gov.au/other/copyright.shtml>

- To cite *bomrang*, please use the output from `citation("bomrang")`

- Please note that the *bomrang* project is released with a
[Contributor Code of Conduct](https://github.com/ropensci/bomrang/blob/master/CONDUCT.md).
By participating in the *bomrang* project you agree to abide by its terms.

References
----------

[Australian Bureau of Meteorology (BOM) Weather Data Services](http://www.bom.gov.au/catalogue/data-feeds.shtml)

[Australian Bureau of Meteorology (BOM) FTP Public 
Products](http://www.bom.gov.au/catalogue/anon-ftp.shtml)

[Australian Bureau of Meteorology (BOM) Weather Data Services Agriculture Bulletins](http://www.bom.gov.au/catalogue/observations/about-agricultural.shtml)

[Australian Bureau of Meteorology (BOM) Weather Data Services Observation of Rainfall](http://www.bom.gov.au/climate/how/observations/rain-measure.shtml)

[Australian Bureau of Meteorology (BOM) High-definition satellite images](http://www.bom.gov.au/australia/satellite/index.shtml)


[![](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
