
## Test environments

* local macOS install, R version 3.4.4 (2017-11-30)

* Ubuntu 14.04.5 LTS (on travis-ci), R version 3.4.3 (2017-11-30)

* win-builder R Under development (unstable) (2018-03-18 r74422)

* local Windows 7 install, R version 3.4.4 (2018-03-15)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new patch release

## Minor changes

- Validate internal database station locations using GIS methodology

- Update code to be compliant with current and future versions of `janitor`

## Bug fixes

- Correct issue with converting the timzeone in ag bulletin to character where
the conversion resulted in a vector of numerals, not the expected string of 
characters, e.g. "EST"

- Remove redundant functionality in `update_station_locations()` where data were
fetched using `tryCatch()` and then again without

## Reverse dependencies

* No ERRORs or WARNINGs found
