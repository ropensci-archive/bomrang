# bomrang 0.1.0.9000


# 0.1.0

## Major changes

- Use _hoardr_ to manage file caching

## Minor changes

- Enhanced documentation for the cached files in satellite imagery

- Update internal databases of metadata for station locations and URLs

## Bug fixes

- Fix issues with `get_precis_forecast()` and `get_ag_bulletin()` where they
failed to work properly. This fix lessens internal dependencies on _dplyr_ and
removes _rlang_ usage from package.

## Deprecated functions

- `bomrang_cache_list()`, now superceded by `manage_cache$list()`

- `bomrang_cache_details()`, now superceded by `manage_cache$details()`

- `bomrang_cache_delete()`, now superceded by `manage_cache$delete()`

- `bomrang_cache_delete_all()`, now superceded by `manage_cache$delete_all()`

--------------------------------------------------------------------------------

# 0.0.8

## Major changes

- Antarctic stations reporting with a valid .json file are now included in
internal database

## Minor changes

- Fix typo in DESCRIPTION, Scott's ORCID wasn't given as a full URL

- Update authors in vignettes to credit everyone who helped write them

- Update vignette style to use normal vignette style with table of contents

- Fix error in vignette that referred to `update_forecast_locations()`, it
should instead refer to `update_forecast_towns()`

- Update internal stations list with latest data from BoM

## Bug fixes

- Fix issue where updating internal stations would fail

--------------------------------------------------------------------------------

# 0.0.7

## Major changes

- Handle typos in the weather bulletins

## Minor changes

- Document `get_current_weather()` functionality in Appendix 4 of _bomrang_
vignette, thanks @mpadge 

- Spell checking

- Ready for submission to JOSS

- Update codemeta json file

- Ensure authorship order is the same order in all files

--------------------------------------------------------------------------------

# 0.0.6

## Bug Fixes

- Fix typo in `check_states()`

- Replace `warning()` with `message()` in `get_states()`

## Major changes

- Fetch BoM 0900 and 1500 weather bulletins from SHTML sources and create a
tidy data frame of the data

--------------------------------------------------------------------------------

# 0.0.5

## Bug Fixes

- Recommended `station_name` values are separated by spaces in
`get_current_weather()`

- Station names and location names are more consistent in the supplied data and
returned data frames.

- Lat/Lon values for `get_current_weather()` results are now reported using the
values from the internal database, which has a higher degree of accuracy. The
json file values are rounded while the values from the stations list has four
decimal places

## Major changes

- Fetch BoM satellite images available through public FTP

- New use-case vignette, using _bomrang_ for the _WINS_ project

- Welcome message included with statement regarding BoM copyright

- Concatenate vignettes into a single file with appendices for descriptions of
data returned by functions

- Product IDs are included in outputs from `get_*()` functions that return a
tidy dataframe

- Full station names are reported along with BoM's current name used to refer
to a station location. In some cases a station "name" may be the same for both
a current and retired station.

- Fuzzy matching is used for all functions now when user enters a value for a
desired state, station or the whole country for functions that require a `state`
argument

- Onload a message regarding the copyright and data source,
```r
                Data (c) Australian Government Bureau of Meteorology,,
                Creative Commons (CC) Attribution 3.0 licence or,
                Public Access Licence (PAL) as appropriate.,
                See http://www.bom.gov.au/other/copyright.shtml
```
is displayed

- the _bomrang_ vignette now contains instructions for use along with appendices
that document the data fields and units, rather than separate vingettes

- ramifications of updating station lists are now stated clearly in the vignette
and help files for applicable functions

- a map of BoM stations is included in an appendix of the _bomrang_ vingette

- Lat/Lon values are specified to be in decimal degrees in
`get_current_weather()` help and vignette

- Databases station locations and other metadata are internal an not exposed to
the user

- Use `file.path()` in place of `paste0()`

- The package has been linted,

    - line lengths are <80 chars,

    - best practice naming conventions are followed (where possible)

- Lint md files

- Spellchecking in all files

- `agrep` is now used in all functions where the user enters state or Australia
 values to query BoM data

- best practices for programming with `dplyr 0.7` using `rlang` are now
employed, which reduces the need for the `# CRAN NOTE avoidance`

- "JSONurl_latlon_by_station_name" has been shortened to
"JSONurl_site_list".

- The DESCRIPTION file now states minimum package versions for packages that are
undergoing rapid development

- Code has been refactored to be shorter, _e.g._, `xml_bulletin_url` in
`get_ag_bulletion()`

- `.get_obs()` has been moved out of the `.parse_bulletin()` function for easier
reading/maintenance

- fixed a repeat of `return(tidy_df)` in `get_precis_forecast()`

--------------------------------------------------------------------------------

# 0.0.4-1

## Major changes

- Update internal functionality for _dplyr_ 0.7.0

--------------------------------------------------------------------------------

# bomrang 0.0.4 2017-06-09

## Major changes

- Use _jsonlite_ library rather than _rjson_

--------------------------------------------------------------------------------

# bomrang 0.0.3-5 2017-06-03

## Major changes

- Wrap examples for `get_precis_forecast()` in a \dontrun{} tag due to CRAN NOTE
taking too long to run

- Use proper GitHub URL in DESCRIPTION file

--------------------------------------------------------------------------------

# bomrang 0.0.3-4 2017-06-03

## Major changes

- Run examples for all `get_*` functions in package

- `update_precis_locations()` is now `update_forecast_towns()`

--------------------------------------------------------------------------------

# bomrang 0.0.3-3 2017-06-03

## Minor changes

- Add links to vignettes documenting the fields returned in the data frames from
the `get_*()` functions

- Use the DOI that always points to latest version

# bomrang 0.0.3-2 2017-06-03

## Minor changes
- Add vignettes describing the data returned from `get_precis_forecast()` and
`get_ag_bulletin()`, remove this from function help files

- Correct documentation reference in README file

# bomrang 0.0.3-1 2017-06-03

## Minor changes
- Add vignette describing the data returned from `get_current_weather()`

--------------------------------------------------------------------------------

# 0.0.3

## Major changes

- Include internal databases of station locations and metadata for
`get_current_weather()` and `get_ag_bulletin()` both derived from the same BoM
station master list

- The new database includes a more complete list of JSON URLs and ag bulletin
station locations

- Generation of the JSON URL list is much faster, now can be updated by the user
in a few seconds as desired using the new `update_station_locations()` function

## Minor changes
- Better tests written for the package  

- Add a new file describing internal database creation for station locations,
metadata and JSON URLs, create_BoM_station_list.md

--------------------------------------------------------------------------------

# bomrang 0.0.2-1

## Minor changes

- Add more information to description field in DESCRIPTION file

--------------------------------------------------------------------------------

# 0.0.2

## Major changes

- Hugh Parsonage has joined as a contributor  

- Added a new function `get_current_weather()` to retrieve weather data from 
specified BoM weather stations  

- Added a new function `sweep_for_stations()` to find stations used in 
`get_current_weather()` function, based on distance from a specified latitude 
and longitude

- Renamed existing functions for more clarity.

  - `get_forecast()` is now `get_precis_forecast()`

  - `get_bulletin()` is now `get_ag_bulletin()`

  - `update_locations()` is now `update_precis_locations()`

## Minor changes

- All functions will return a `data.frame` object, not a `tibble`  

- If a server is not responding, the function returns a more meaningful error
message on exit  

- All date/times are returned in POSIXct format

- UTC offset is returned in a separate `UTC_offset` field for
`get_precis_forecast()` for both `start_time_local` and `end_time_local` fields

- Spelling and typo corrections

- Enhanced documentation  

## Bug fixes

- Correct output for ag bulletin where the observation site is listed but has no
values. The site will be listed with location data and `NA` for all
meteorological values  

--------------------------------------------------------------------------------

# 0.0.1

- Added a `NEWS.md` file to track changes to the package.

- New package for fetching BoM forecasts and ag information bulletins
