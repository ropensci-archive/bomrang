
## Test environments

- local macOS install R version 3.6.2 (2019-12-12)

- Manjaro Linux 3.6.2 (2019-12-12)

- win-builder R Under development (unstable) (2020-01-03 r77630)

- win-builder R version 3.6.2 (2019-12-12)

## R CMD check results

0 errors | 0 warnings | 1 note

This is a new minor release that fixes the issues with the CRAN checks as
requested and fixes other minor bugs and provides further enhancements

## Bug fixes

* Adds `skip_on_cran()` to some tests causing failures in CRAN checks that
should not have been tested on CRAN

* resolves the `group_by` issues of
[#105](https://github.com/ropensci/bomrang/issues/105) reported by
[Blundys](https://github.com/Blundys)

* Fixes bug in functions returning `data.table` objects that don't print to
console

* Fixes an incorrect vignette reference

* Fixes bugs that removed station locations from internal lists being
distributed with bomrang and when user updated them on their own machine

## Minor changes

* Prebuild main vignette with examples depending on Internet connection, which
allows for example output to be displayed for more functions

* Updates my name to align with other packages I maintain by using my middle
initial, "H."

## Reverse dependencies

* No ERRORs or WARNINGs found
