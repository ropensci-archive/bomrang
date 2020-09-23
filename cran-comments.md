
## Test environments

- local macOS install R version 4.0.2 (2020-06-22)

- win-builder R Under development (unstable) (2020-09-17 r79226)

- win-builder R version 4.0.2 (2020-06-22)

## R CMD check results

0 errors | 0 warnings | 1 note

This is a resubmission that removes functionality due to a broken CRAN package so that all examples in this package pass checks

## Removal of functionality

* `get_subdaily_weather()` has been removed due to CRAN policy for failing examples so that I can get the bug fixes in this package submitted to deal with errors that do originate in this package as the failing example is a direct result of the _stationAry_ package which is already on CRAN, not _bomrang_.

## Bug fixes

* For a time BOM was not listing historical rainfall records.
A message is emitted now if records are missing or unavailable rather than `get_historical_weather()` failing.
Thanks to James Goldie, [@rensa](https://github.com/rensa) for this fix.

* Cross-links in the function documentation have been fixed.

## Standardised function naming

* `get_historical()` is now an alias for `get_historical_weather()` to bring this function into line with the other function names.
Neither name is preferred and both will be provided going forward.
This is simply to provide a standard nomenclature across the package for function names.

## Internal changes

* Update internal databases of station and forecast locations.

* Reorganise functions and files to be more consistent within the package.

## Reverse dependencies

* No ERRORs or WARNINGs found
