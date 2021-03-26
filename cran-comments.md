## bomrang version 0.7.3

## Test environments

- local macOS install R version  4.0.4 (2021-02-15)

- win-builder R Under development (unstable) (2021-03-25 r80117)

- win-builder R version   4.0.4 (2021-02-15)

## R CMD check results

0 errors | 0 warnings | 1 note

This is a new patch release that fixes bugs in data retrieval and enhances other functionality

## Bug fixes

* `get_weather_bulletin()` now works properly with new versions of *tibble* and *rvest* (@mpadge, #134).

* A custom useragent is specified for the *bomrang* package as the RStudio useragent results in an error 403 (denied) when attempting to connect to BOM servers. This did not appear to affect R running in sessions outside of RStudio (@jonocarroll, #130).

* _curl_ options are now set to handle the slow responses from BOM servers rather than timing out.

## Minor changes and improvements

* Changes to internal databases of BOM metadata for station, radar and forecast locations are now tracked in the `data_raw` directory of the repository on GitHub with the changes being stored in `extdata` and available in the package through:
  * `load(system.file("extdata", "AAC_code_changes.rda", package = "bomrang"))`
  * `load(system.file("extdata", "JSONurl_site_list_changes.rda", package = "bomrang"))`
  * `load(system.file("extdata", "marine_AAC_code_changes.rda", package = "bomrang"))`
  * `load(system.file("extdata", "radar_location_changes.rda", package = "bomrang"))`
  * `load(system.file("extdata", "stations_site_list_changes.rda", package = "bomrang"))`
  
* Station numbers are padded with "0" in output from `get_historical_weather()` to align with BOM naming conventions and other _bomrang_ functions (@jonocarroll).

* Remove rOpenSci footer from README.

## Reverse dependencies

* No ERRORs or WARNINGs found
