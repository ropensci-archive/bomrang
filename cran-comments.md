
## Test environments

- local macOS install, R version 3.5.1 (2018-07-02)

- local Ubuntu 18.04, R version 3.5.1 (2018-07-02)

- win-builder R Under development (unstable) (2018-08-14 r75146)

- win-builder R version 3.5.1 (2018-04-23)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new minor release that adds new functionality

## Minor changes

- Add new function, `get_coastal_forecast()` to get BOM coastal waters forecast

- Add spaces between sentences in some error messages

- Enhance testing for `get_historical()`

- Add spaces between sentences in some error messages when interacting with the
BOM servers

- Handle checking multiple imagery files gracefully without returning warning
message if more than one file is to be loaded in current session
## Reverse dependencies

* No ERRORs or WARNINGs found
