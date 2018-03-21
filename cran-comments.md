
## Test environments

* local macOS install, R version 3.4.4 (2017-11-30)

* Ubuntu 14.04.5 LTS (on travis-ci), R version 3.4.3 (2017-11-30)

* win-builder R Under development (unstable) (2018-03-18 r74422)

* win-builder R Release, R version 3.4.4 (2018-03-15)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new patch release

## Minor changes

- Validate internal database station locations using GIS methodology

- Update code to be compliant with current and future versions of `janitor`

- Vignettes no longer evaluate code on-the-fly that requires BOM servers to
respond in response to CRAN rejecting `bomrang` for a failure of a vingette to
build due to this issue

## Bug fixes

- Correct issue with converting the timzeone in ag bulletin to character where
the conversion resulted in a vector of numerals, not the expected string of 
characters, e.g. "EST"

- Remove redundant functionality in `update_station_locations()` where data were
fetched using `tryCatch()` and then again without

## Notes

- There is a note, `Missing or unexported object: 'janitor::remove_empty'`, this
is because `janitor::remove_empty` is a new function in a to-be-released version
of `janitor`. Sam Firke has a alerted me to the coming change so I've
incorporated the new functionality to future proof `bomrang`. See lines
74-83 of get_weather_bulletins.R for the `if` statement provided by Sam that
checks the version of `janitor`, this allows it to work even before the new
version is released. I've tested with the current version of `janitor` and the
development version as well to be sure it functions as desired.

Future versions of `bomrang` will remove this and require v1.0.0 of `janitor` in
the DESCRIPTION file.

## Reverse dependencies

* No ERRORs or WARNINGs found
