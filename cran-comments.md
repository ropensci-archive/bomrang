
## Test environments

* local macOS install, R version 3.4.4 (2017-11-30)

* Ubuntu 14.04.5 LTS (on travis-ci), R version 3.4.3 (2017-11-30)

* win-builder R Under development (unstable) (2018-03-18 r74422)

* win-builder R Release, R version 3.4.4 (2018-03-15)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new patch release

## Minor changes

- Much faster station location checking using `ASDS.foyer::latlon2SA`

- "BoM" is replaced with "BOM" throughout the package for consistency

- `janitor` >= 1.0.0 is now required

## Reverse dependencies

* No ERRORs or WARNINGs found
