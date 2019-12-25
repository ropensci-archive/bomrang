
## Test environments

- local macOS 10.14.16 install R version 3.6.1 (2019-07-05)

- Circle-CI debian:9 R version 3.6.1 (2019-07-05)

- win-builder R Under development (unstable) (2019-06-27 r76748)

- win-builder R version 3.6.1 (2019-07-05)

## R CMD check results

0 errors | 0 warnings | 1 note

This is a new minor release that adds enhanced functionality, corrects bugs and
makes improves the documentation

## Bug fixes

* resolves the `group_by` issues of
[#105](https://github.com/ropensci/bomrang/issues/105) reported by
[Blundys](https://github.com/Blundys)

* Adds `skip_on_cran()` to some tests causing failures in CRAN checks that
should not have been tested on CRAN

## Minor changes

* Changes `get_precis_forecast()` to allow it to import forecast from xml files
stored on the local machine, thanks to Paul Melloy for the enhanced
functionality

* Changes `get_historical()` so it will allow batch downloads using `lapply()`,
now a `warning()` and a `data.frame()` with NA values is returned rather than
stopping the process, thanks to Paul Melloy for the new functionality

* Prebuild main vignette with examples depending on Internet connection, which
allows for example output to be displayed for more functions

## Reverse dependencies

* No ERRORs or WARNINGs found
