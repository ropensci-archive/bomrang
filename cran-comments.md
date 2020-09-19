
## Test environments

- local macOS install R version 4.0.2 (2020-06-22)

- win-builder R Under development (unstable) (2020-09-17 r79226)

- win-builder R version 4.0.2 (2020-06-22)

## R CMD check results

0 errors | 0 warnings | 1 note

This is a new minor release that adds new functionality and allows the package to handle missing data from the BOM more gracefully.

## New function

* `get_subdaily_weather()` is added to fetch weather data in one hour or less intervals for stations in the BOM network using the CRAN package [stationarRy](https://cran.r-project.org/package=stationaRy).

## Bug fixes

* For a time BOM was not listing historical rainfall records.
A message is emitted now if records are missing or unavailable rather than `get_historical_weather()` failing.
Thanks to James Goldie, [@rensa](https://github.com/rensa) for this fix.

* Cross-links in the function documentation have been fixed.

## Enhanced vignette

* The new `get_subdaily_weather()` function is detailed in the vignette, along with an example of how to use `sweep_for_stations()` to identify stations that possibly provide sub-daily weather data within a given radius of a given point.
Thanks to Paul Melloy, [@PaulMelloy](https://github.com/PaulMelloy) for this.

## Standardised function naming

* `get_historical()` is now an alias for `get_historical_weather()` to bring this function into line with the other function names.
Neither name is preferred and both will be provided going forward.
This is simply to provide a standard nomenclature across the package for function names.

## Internal changes

* Update internal databases of station and forecast locations.

* Reorganise functions and files to be more consistent within the package.

## Reverse dependencies

* No ERRORs or WARNINGs found
