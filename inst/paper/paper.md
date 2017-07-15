---
title: 'bomrang: Fetch Australian Government Bureau of Meteorology Data in R'
authors:
- affiliation: 1
  name: Adam H Sparks
  orcid: 0000-0002-0061-8359
- afilliation: 2
  name: Hugh Parsonage
  orcid: 0000-0003-4055-0835
- affiliation: 3
  name: Keith Pembleton
  orcid: 0000-0002-1896-4516
date: "27 May 2017"
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
  name: Grattan Institute, Carlton Victoria 3053, Australia
- index: 3
  name: University of Southern Queensland, Institute for Agriculture and the
    Environment, Toowoomba Queensland 4350, Australia
---

# Summary

The Australian Bureau of Meteorology (BoM) publicly provides data via anonymous
FTP in XML and json files [@BoM_2017]. The files are well structured but some
knowledge of how to use R and parse them is required to extract the data into a
data frame for use in R [@R-base]. _bomrang_ provides functionality for
automated retrieval and parsing of selected weather data files from BOM. Data
that can be fetched include current weather at a given station, daily précis
(short summaries less than 30 characters) forecasts for all Australian forecast
locations and agricultural bulletins summarising weather observations useful for
agriculture for each State/Territory. Three functions, `get_current_weather()`,
`get_precis_forecast()` and `get_ag_bulletin()`, provide the ability to easily
download data from BOM, import it and create a tidy data frame [@Wickham2014]
object of the data. To help identify stations given a specific location,
`sweep_for_station()` returns a data frame of all weather stations (in this
package) sorted by distance from a user specified latitude and longitude,
ascending. Two further functions, `update_forecast_towns()` and
`update_station_locations()`, provide the user with the ability to update
internal databases of forecast locations, station metadata and JSON URLs used by
the package to interface with BOM. The package's internal databases decrease the
time necessary to gather forecast information and return a data frame, while
rarely changing. The data have applications in applied meteorology, agricultural
meteorology, agricultural and environmental modelling.

# References
