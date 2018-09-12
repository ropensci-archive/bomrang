
## Test environments

- local macOS install R version 3.5.1 (2018-07-02)

- local Ubuntu 18.04 R version 3.5.1 (2018-07-02)

- win-builder R Under development (unstable) (2018-09-10 r75281)

- win-builder R version 3.5.1 (2018-04-23)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new minor release that adds new functionality

## Bug fixes

- `get_historical()` now fetches data for any station with historical data
available corrected an issue where previously it only fetched data for stations
that currently reported

## Minor changes

- Add new functionality to interact with and download radar imagery from BOM,
`get_available_radar()` and `get_radar_imagery()`

- When using `update_station_locations()` or `update_forecast_towns()` the user
is now prompted with a message about reproducibility before proceeding

- Update code of conduct statement in README to reflect that it only applies to
the `bomrang` project

- Update authors' list in vignette to includ Dean Marchiori

- Add links to on-line versions of vignettes from README

- Standardise use of vocabulary in README

- Enforce standardised output for `get_coastal_forecast()`. In some cases BOM
does not report all fields available, _bomrang_ will always report these with
`NA` if empty

- Reorder vignette to have output from functions before maps

- Add maps of historical data completeness and availability to vignette,
Appendix 7

- Move copyright information from startup message into CITATION file

## Reverse dependencies

* No ERRORs or WARNINGs found
