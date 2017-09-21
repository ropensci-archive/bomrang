---
title: 'bomrang: Fetch Australian Government Bureau of Meteorology Data in R'
authors:
- affiliation: 1
  name: Adam H Sparks
  orcid: 0000-0002-0061-8359
- affiliation: 2
  name: Mark Padgham
  orcid: 0000-0003-2172-5265
- affiliation: 3
  name: Hugh Parsonage
  orcid: 0000-0003-4055-0835
- affiliation: 4
  name: Keith Pembleton
  orcid: 0000-0002-1896-4516
date: "25 Aug 2017"
output:
  html_document: default
  pdf_document: default
bibliography: paper.bib
tags:
- Australia
- weather forecast
- meteorology
- weather data
- R
- xml
- json
affiliations:
- index: 1
  name: University of Southern Queensland, Centre for Crop Health, Toowoomba
    Queensland 4350, Australia
- index: 2
  name: University of Salzburg, Inter-Faculty Department of Geoinformatics,
    5020 Salzburg, Austria
- index: 3
  name: Grattan Institute, Carlton Victoria 3053, Australia
- index: 4
  name: University of Southern Queensland, School of Agricultural, Computational
    and Environmental Sciences, Toowoomba Queensland 4350, Australia

---

# Summary

The Australian Bureau of Meteorology (BoM) publicly provides data via an anonymous
FTP server, in XML and json files [@BoM_2017]. The files are well structured but
knowledge of how to use R and parse them is required to extract the data into a
data frame for use in R [@R-base] or requires external programs and scripting to
import the data for use. _bomrang_ provides functionality for
automated retrieval and parsing of selected weather data files from BoM. Data
that can be fetched include current weather at a given station, daily précis
(short summaries less than 30 characters) forecasts for all Australian forecast
locations, agricultural bulletins summarising weather observations useful for
agriculture for each state or territory and satellite imagery in GeoTIFF file
formats. A family of functions, `get_current_weather()`,
`get_precis_forecast()`, `get_ag_bulletin()` and `get_weather_bulletion()`,
provide the ability to easily download data from BoM, import it and create a
tidy data frame [@Wickham2014] of the data. To help identify stations given a
specific location, `sweep_for_station()` returns a data frame of all weather
stations (in this package) sorted by distance from a user specified latitude and
longitude, ascending. Two further functions, `update_forecast_towns()` and
`update_station_locations()`, provide the user with the ability to update
internal databases of forecast locations, station metadata and JSON URLs used by
the package to interface with BoM. The package's internal databases decrease the
time necessary to gather forecast information and return a data frame, while
rarely changing. Functionality for automated downloading and importing of
satellite imagery is provided by the `get_satellite_imagery()` function. A
helper function, `get_available_imagery()`, returns values of currently
available satellite imagery for download. 

The data have many applications. In agriculture the data are used in several
types of models, some of which include the estimation of surface moisture, crop
yield estimates, crop development stages or stress or forecasting of epidemics
of crop diseases or populations of insect pests [@VENALAINEN20021045;
@DeWolf2003; Sparks2017]. Other areas of use include mapping potential renewable
energy, _e.g._ wind or solar potential for exploration purposes
[@RAMACHANDRA20071460]. The data can also be used by decision makers for
municipalities to help planning for extreme weather events, energy needs and
other infrastructure [@SVENSSON200237; @ALCOFORADO200956].

# References
