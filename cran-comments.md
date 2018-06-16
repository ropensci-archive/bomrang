
## Test environments

- local macOS install, R version 3.5.0 (2018-04-23)

- local Ubuntu 18.04, R version 3.5.0 (2018-04-23)

- win-builder R Under development (unstable) (2018-06-15 r74904)

- win-builder R version 3.5.0 (2018-04-23)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new patch release

## Minor changes

- Reduce R requirement back to >= 3.2.0 from 3.5.0

- Related to above, check for R version in `get_precis_forecast()` and adjust
field names according to the R version due to `tidyr`'s behaviour

- Clean up and reformat documentation, standardise references to packages,
links and author e-mail addresses

- Remove deprecated functions

## Bug fixes

- Correct field names in `get_precis_forecast()` where `maximum_temperature` and
`minimum_temperature` were reversed

- Move rappdirs to Suggests to fix NOTEs on https://cran.rstudio.com/web/checks/check_results_bomrang.html

## Reverse dependencies

* No ERRORs or WARNINGs found
