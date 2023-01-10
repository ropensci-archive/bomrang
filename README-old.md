_bomrang_: Australian Government Bureau of Meteorology (BOM) Data Client <img align="right" src="man/figures/logo.png">
================
![tic](https://github.com/ropensci/bomrang/workflows/tic/badge.svg)
[![codecov](https://codecov.io/gh/ropensci/bomrang/branch/master/graph/badge.svg)](https://codecov.io/gh/ropensci/bomrang) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.598301.svg)](https://doi.org/10.5281/zenodo.598301)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/bomrang)](https://cran.r-project.org/package=bomrang)
[![](https://badges.ropensci.org/121_status.svg)](https://github.com/ropensci/software-review/issues/121)
[![status](https://joss.theoj.org/papers/10.21105/joss.00177/status.svg)](https://joss.theoj.org/papers/10.21105/joss.00177)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

Provides functions to interface with Australian Government Bureau of Meteorology (BOM) data, fetching data and returning a tidy data frame of précis forecasts, current weather data from stations, ag information bulletins, historical weather data and downloading and importing radar or satellite imagery.

Credit for the name, _bomrang_, goes to [Di Cook](http://dicook.org/), who suggested it while attending the rOpenSci AUUnconf in Brisbane, 2016.

NOTE
-----------
BOM have decided that the data that they provide should not all be easily available.
Therefore, some portions of this package (any that depend on HTTP requests) are now broken.
These include:

 * `get_historical_weather()`,
 * `get_weather_bulletins()`, and
 * `get_current_weather()`

All other functions in the package work as advertise assuming server availability as they rely on FTP requests.

BOM's official statement

> Website notification of change
Scheduled Release Date: 3 March 2021
A web application firewall policy has been implemented for www.bom.gov.au which will block screen scraping activity.
The Bureau is monitoring screen scraping activity on the site and will commence interrupting, and eventually blocking, this activity on www.bom.gov.au from Wednesday, 3 March 2021. This is aimed at protecting infrastructure, system access and security, intellectual property and server/service load.
Web or screen scraping is the act of copying information that shows on a digital display so it can be used for another purpose. This activity has always been at odds with the Bureau's terms and conditions.
We understand www.bom.gov.au contributes significantly to the work of many individuals and organisations and we are committed to continuing to provide access through our registered user’s channel.
For further information, or to discuss the ongoing use of our materials, please make contact with us via weatherquestions@bom.gov.au.

Quick Start
-----------

_bomrang_ has been archived from CRAN for reasons beyond _bomrang_ actually being broken.
As such at this time I've declined to "fix" the package.
It can still be installed using the following commands.

``` r
if (!require("remotes")) {
  install.packages("remotes", repos = "http://cran.rstudio.com/")
  library("remotes")
}

install_github("ropensci/bomrang", build_vignettes = TRUE)
```

Using *bomrang*
---------------

Several functions are provided by *bomrang* to retrieve Australian Bureau of Meteorology (BOM) data. A family of functions retrieve weather data and return tidy data frames;

  - `get_precis_forecast()`, which retrieves the précis (short) forecast;

  - `get_current_weather()`, which fetches the current weather for a given station;

  - `get_ag_bulletin()`, which retrieves the agriculture bulletin;
  
  - `get_weather_bulletin()`, which retrieves the BOM 0900 or 1500 bulletins;
  
  - `get_coastal_forecast()`, which returns coastal waters forecasts;
  
  - `get_historical_weather()`, which retrieves historical daily observations for a given station; and
  
A second group of functions retrieve information pertaining to satellite and radar imagery,
  
  - `get_available_imagery()`;
  
  -  the satellite imagery itself, `get_satellite_imagery()`;
  
  - `get_available_radar()`; and 
  
  - the radar imagery itself, `get_radar_imagery()`.
  
[Vignettes are provided illustrating examples](https://docs.ropensci.org/bomrang/articles/bomrang.html)
of all functions and a [use case](https://docs.ropensci.org/bomrang/articles/use_case.html).

Meta
----

-   Please [report any issues or bugs](https://github.com/ropensci/bomrang/issues).

-   License:

    - All code is licensed MIT

    - All data is copyright Australia Bureau of Meteorology, BOM Copyright Notice <br /><http://reg.bom.gov.au/other/copyright.shtml>

- To cite *bomrang*, please use the output from `citation("bomrang")`

- Please note that the *bomrang* project is released with a
[Contributor Code of Conduct](https://github.com/ropensci/bomrang/blob/master/CONDUCT.md).
By participating in the *bomrang* project you agree to abide by its terms.

References
----------

[Australian Bureau of Meteorology (BOM) Weather Data Services](http://www.bom.gov.au/catalogue/data-feeds.shtml)

[Australian Bureau of Meteorology (BOM) FTP Public Products](http://www.bom.gov.au/catalogue/anon-ftp.shtml)

[Australian Bureau of Meteorology (BOM) Weather Data Services Agriculture Bulletins](http://www.bom.gov.au/catalogue/observations/about-agricultural.shtml)

[Australian Bureau of Meteorology (BOM) Weather Data Services Observation of Rainfall](http://www.bom.gov.au/climate/how/observations/rain-measure.shtml)

[Australian Bureau of Meteorology (BOM) High-definition satellite images](http://www.bom.gov.au/australia/satellite/index.shtml)
