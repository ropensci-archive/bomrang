---
title: 'bomrang: Fetch Australian Government Bureau of Meteorology Data in R'
authors:
- affiliation: 1
  name: Adam H Sparks
  orcid: 0000-0002-0061-8359
- affiliation: 2
  name: Keith Pembleton
  orcid: 0000-0002-1896-4516
date: "16 May 2017"
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
affiliations:
- index: 1
  name: University of Southern Queensland, Centre for Crop Health, Toowoomba Queensland
    4350, Australia
- index: 2
  name: University of Southern Queensland, Institute for Agriculture and the Environment,
    Toowoomba Queensland 4350, Australia
---

# Summary

The Australian Bureau of Meteorology (BOM) publicly provides data via anonymous FTP in XML files [@BOM_2017]. The files are well structured but some knowledge of how to use R and parse XML is required to extract the data into a data frame for use in R [@R-base]. _bomrang_ provides functionality for automated retrieval and parsing of XML files from BOM for forecasts and agricultural bulletins. BOM provides daily précis (short summaries less than 30 characters) forecasts for all Australian forecast locations and agricultural bulletins summarising weather observations useful for agriculture for each State/Territory. Two functions, `get_forecast()` and `get_bulletin()`, provide the ability to easily download data from BOM, import it and create a tidy data frame [@Wickham2014] in a _tibble_ [@Wickham2017] object of the data along with latitude, longitude and elevation, information not originally included with the data. A third function, `update_locations()`, provides the user with the ability to update an internal database of forecast locations used by the package. The package's internal database of BOM forecast locations decreases the time necessary to gather forecast information and return a data frame, while rarely changing. The data have applications in applied meteorology, agricultural meteorology, agricultural and environmental modelling.

# References
