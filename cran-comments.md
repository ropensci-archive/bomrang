
## Test environments

- local macOS install R version 3.6.0

- Circle-CI debian:9 R version 3.6.0 (2019-03-11)

- win-builder R Under development (unstable) 

- win-builder R version 3.6.0 (2019-03-11)

## R CMD check results

0 errors | 0 warnings | 1 note

This is a new minor release that adds new functionality, corrects bugs and
makes minor changes to documentation

## Bug fixes

- Fixes a bug with links to documentation from `get_historical()` and `%>%`

- Updates station location databases to use updated BOM URLs

- Updates file and error handling for image downloads when downloads fail

- Ensures that .Rds/.Rda files are saved using version 2, for R from 1.4.0 to
3.5.0 such that users using older versions of R do not have to upgrade to use
`bomrang`

- Fixes bug that prevents end-user from self-updating internal databases

## Minor changes

- Plots radar images natively using re-exported `raster::plot()`

- Adds `sweep_for_forecast_towns()`, which works analogously to
`sweep_for_stations()`

## Reverse dependencies

* No ERRORs or WARNINGs found
