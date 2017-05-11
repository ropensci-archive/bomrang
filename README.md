
<!-- README.md is generated from README.Rmd. Please edit that file -->
*BOMRang*: Fetch Australian Government Bureau of Meteorology Data
=================================================================

[![Travis-CI Build Status](https://travis-ci.org/ToowoombaTrio/BOMRang.svg?branch=master)](https://travis-ci.org/ToowoombaTrio/BOMRang) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ToowoombaTrio/BOMRang?branch=master&svg=true)](https://ci.appveyor.com/project/ToowoombaTrio/BOMRang) [![Last-changedate](https://img.shields.io/badge/last%20change-2017--05--11-brightgreen.svg)](https://github.com/toowoombatrio/BOMRang/commits/master) [![minimal R version](https://img.shields.io/badge/R%3E%3D-3.4.0-brightgreen.svg)](https://cran.r-project.org/)

Fetches Fetch Australian Government Bureau of Meteorology Weather forecasts and returns a tidy data frame in a [*Tibble*](http://tibble.tidyverse.org) of the current and next six days weather.

*Limited to Queensland and temperature values only at the moment*

Credit for the name, *BOMRang*, goes to [Di Cook](http://dicook.github.io), who suggested it attending the rOpenSci AUUnconf in Brisbane, 2016 when seeing the [vignette](https://github.com/saundersk1/auunconf16/blob/master/Vignette_BoM.pdf) that we had assembled during the Unconf.

Quick start
-----------

``` r
if (!require("devtools")) {
  install.packages("devtools", repos = "http://cran.rstudio.com/") 
  library("devtools")
}

devtools::install_github("toowoombatrio/BOMRang")
library("BOMRang")
```

Meta
----

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
