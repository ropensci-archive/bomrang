
## Test environments

- local macOS install R version 3.6.2 (2019-12-12)

- Manjaro Linux 3.6.2 (2019-12-12)

- win-builder R Under development (unstable) (2020-01-07 r77633)

- win-builder R version 3.6.2 (2019-12-12)

## R CMD check results

0 errors | 0 warnings | 1 note

This is a new major release that fixes the issues with the CRAN checks as
requested and fixes other minor bugs and provides new functionality.

I am very sorry about the previous submission that still caused failing checks.
I trust that I've been able to correctly identify and fix the problems with the
previous version in this one.

## Bug fixes

* Adds `skip_on_cran()` to all tests causing failures in CRAN checks that
should not have been tested on CRAN

* Corrects (and skips) a test that failed on Solaris and macOS when writing to
disk by using `tempdir()` rather than the userspace

## Major changes

* Requires R >= 3.5.0 now due to changes in serialisation of internal .Rds files
used to store databases of station information

## Reverse dependencies

* No ERRORs or WARNINGs found
