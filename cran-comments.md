## bomrang version 0.7.3

## Test environments

- local macOS install R version 4.0.3 (2020-10-10)

- win-builder R Under development (unstable) (2020-11-27 r79522)

- win-builder R version  4.0.3 (2020-10-10)

## R CMD check results

0 errors | 0 warnings | 1 note

This is a new patch release that fixes a bug in data retrieval and enhances other functionality

## Bug fixes

* `get_current_weather()` now returns the correct values for `rel_hum`, rather than returning a column of `NA`

* `get_available_imagery()` now fails properly if a non-numeric `radar_id` is supplied

## Minor changes

* Switch GIS raster file support from `raster` to `terra`

* `radar_id` values in `get_available_radar()` are now provided as a numeric value.
This previously was a character that was internally coerced to numeric

* `get_radar_imagery()` now returns a `magick-image` object rather than a `raster` object.
The files are .gif natively, this is a better way to handle them

## Reverse dependencies

* No ERRORs or WARNINGs found
