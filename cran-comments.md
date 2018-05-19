
## Test environments

* local macOS install, R version 3.5.0 (2018-04-23)

* local Ubuntu 18.04, R version 3.5.0 (2018-04-23)

* win-builder R Under development (unstable) (2018-05-15 r74727)

* win-builder R version 3.5.0 (2018-04-23)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new minor release with added functionality and corrections

## Requested corrections by CRAN

- Add `rappdirs` to Imports section of DESCRIPTION file to fix missing import

## New features

- `get_historical()` retrieves historical daily rainfall, min/max temperatures,
or solar exposure

## Minor changes

- `get_precis_forecast()` handles states/territories with no/missing
precipitation data gracefully

## Reverse dependencies

* No ERRORs or WARNINGs found
