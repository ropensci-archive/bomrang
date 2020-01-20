# bomrang 0.7.0

## Bug fixes

* Resolves an issue where `select()` was not recognised as being re-exported
by bomrang from dplyr

* Fixes bug where precipitation to 9am, column `r`, in ag bulletin was not
reported at 0.01 for "Tce" as documented in vignette

* Fixes bug where weather bulletin contained empty cells rather than a proper
`NA` value where data was missing

* Adds `skip_on_cran()` to all tests causing failures in CRAN checks that
should not have been tested on CRAN

* Corrects (and skips) a test that failed on Solaris and macOS when writing to
disk by using `tempdir()` rather than the userspace

## Major changes

* Requires R >= 3.5.0 now due to changes in serialisation of internal .Rds files
used to store databases of station information

* Adds three new functions to parse local XML files, not relying on R's ability
to fetch files from an insecure FTP server, thanks to @paulmelloy for this

  * `parse_ag_bulletin()`
  
  * `parse_coastal_forecast()`
  
  * `parse_precis_forecast()`
  
* Improved test coverage, ~93&nbsp;%
  
  * Adds tests for previously untested `get_weather_bulletin()`
  
  * Adds tests for `bomrang_tbl()` functionality
  
* Fail gracefully with message and returns `invisble(NULL)` if a resource is not
available for XML or JSON files, not erroring. In cases where a file is not
found, error 404 or on the FTP server, an error message is still returned

## Minor changes

* Comprehensive cleaning of the vignette and reformatting of help files for all
functions

* Precompile use_case vignette as well as main vignette

* Improved matching of possible character strings entered by user for state to
include variations of two-letter abbreviations of Australia

# bomrang 0.6.1

## Bug fixes

* resolves the `group_by` issues of
[#105](https://github.com/ropensci/bomrang/issues/105) reported by
[Blundys](https://github.com/Blundys)

* Adds `skip_on_cran()` to some tests causing failures in CRAN checks that
should not have been tested on CRAN

* Fixes bug in functions returning data.table objects that don't print to
console

* Fixes bugs that removed station locations from internal lists being
distributed with bomrang and when user updated them on their own machine

## Minor changes

* Prebuild main vignette with examples depending on Internet connection, which
allows for example output to be displayed for more functions

# bomrang 0.6.0

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

# bomrang 0.5.0

## Bug fixes

- Update functionality of `get_precis_forecast()`, `get_coastal_forecast()` and
`get_ag_bulletin()` to work with latest BOM XML files

## Major changes

- New print method for `get_historical()` and `get_current_weather()` using
`bomrang_tbl` class and re-exporting _dplyr_ methods to handle the new class,
thanks to @jonocarroll for this huge effort

- Add new aliases for `get_current_weather()`, `get_current()` and
`get_historical()`, `get_historical_weather()` for consistency

- Add new aliases for `get_radar_imagery()`, `get_radar()` and
`get_satellite_imagery()`, `get_satellite()` to save typing

- If images fail to download for any functions, a default image is returned
with an error message to try again 
[![](inst/error_images/image_error_message.png)](inst/error_images/image_error_message.png)

- `get_current_weather()` no longer has `raw` or `as.data.table` parameters, all
data are returned with columns in proper class as with all other _bomrang_
functions and the returned data.frame is a `bomrang_tbl` object. The `raw`
parameter was set to `FALSE` by default, so the effect should be minimal for
most end users.

## Minor changes

- Updates documentation formatting and corrects minor issues including
spellchecking package and correcting spelling where necessary

- Uses `curl` to download XML files before parsing them, rather than reading
directly from the server. `curl` gives more flexibility in handling the
server connections

- Uses `curl::curl_download()` in place of `utils::download.file()` for a
newer implementation of the same protocols

- Correct formatting of DESCRIPTION file to conform with CRAN guidelines

- Replaces `\dontrun{}` with `\donttest{}` for examples in documentation

# bomrang 0.4.0

## Bug fixes

- `get_historical()` now fetches data for any station with historical data
available corrected an issue where previously it only fetched data for stations
that currently reported

- Enforce standardised output for `get_coastal_forecast()`. In some cases BOM
does not report all fields available, _bomrang_ will always report these with
`NA` if empty

## Minor changes

- Add new functionality to interact with and download radar imagery from BOM,
`get_available_radar()` and `get_radar_imagery()`

- When using `update_station_locations()` or `update_forecast_towns()` the user
is now prompted with a message about reproducibility before proceeding

- Update code of conduct statement in README to reflect that it only applies to
the `bomrang` project

- Update authors' list in vignette to include Dean Marchiori

- Add links to on-line versions of vignettes from README

- Standardise use of vocabulary in README

- Reorder vignette to have output from functions before maps

- Add maps of historical data completeness and availability to vignette,
Appendix 7

- Move copyright information from start-up message into CITATION file

--------------------------------------------------------------------------------

# bomrang 0.3.0

## Major changes

- Add new function `get_coastal_forecast()`, which fetches the BOM coastal
waters forecast

## Minor changes

- Add spaces between sentences in some error messages when interacting with the
BOM servers

- Enhance testing for `get_historical()`

- Handle checking multiple imagery files gracefully without returning warning
message if more than one file is to be loaded in current session

- Update citations for package to reflect current package and paper citation

--------------------------------------------------------------------------------

# bomrang 0.2.2

## Bug fixes

Fix corrupted zip file download issue for `get_historical()` on Windows

## Minor changes

- Update citations for package to reflect current package and paper citation

--------------------------------------------------------------------------------

# bomrang 0.2.1

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

- Move rappdirs to Suggests to fix NOTEs on
https://cran.rstudio.com/web/checks/check_results_bomrang.html

--------------------------------------------------------------------------------

# bomrang 0.2.0

## New features

- `get_historical()` retrieves historical daily rainfall, min/max temperatures,
or solar exposure. (@jonocarroll)

## Minor changes

- `get_precis_forecast()` handles states/territories with no/missing
precipitation data gracefully

## Bug fixes

- Add `rappdirs` to Imports section of DESCRIPTION file to fix missing import

--------------------------------------------------------------------------------

# bomrang 0.1.4

## Minor changes

- Much faster station location checking using `ASDS.foyer::latlon2SA`

- "BoM" is replaced with "BOM" throughout the package for consistency

- `janitor` >= 1.0.0 is now required

# bomrang 0.1.3

## Minor changes

- Much faster station location checking using `sf::st_join()`

## Bug fixes

- Correct issues with updating internal databases

--------------------------------------------------------------------------------

# bomrang 0.1.2

## Minor changes

- The internal `stations_site_list` now is checked against GADM 
(Global Administrative Areas), http://www.gadm.org/ to ensure state listed is
correct. This is in response to an error where Alice Springs Airport was
reported in South Australia in the March 2018 update from BOM. There may be
others. The original BOM values for state are in an `org_state` column.
However, `bomrang` will use the corrected `state` column values.

- Update code to be compliant with current and future versions of `janitor`

- Vignettes no longer evaluate code on-the-fly that requires BOM servers to
respond in response to CRAN rejecting `bomrang` for a failure of a vignette to
build due to this issue

## Bug fixes

- Correct issue with converting the timzeone in ag bulletin to character where
the conversion resulted in a vector of numerals, not the expected string of 
characters, _e.g._ "EST"

- Remove redundant functionality in `update_station_locations()` where data were
fetched using `tryCatch()` and then again without

--------------------------------------------------------------------------------

# bomrang 0.1.1

## Minor changes

- Correct comments for ORCID's in DESCRIPTION at the request of CRAN maintainers

- Update internal databases of metadata for station locations and URLs

- Add new hex-sticker image to README

--------------------------------------------------------------------------------

# bomrang 0.1.0

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

- `bomrang_cache_list()`, now superseded by `manage_cache$list()`

- `bomrang_cache_details()`, now superseded by `manage_cache$details()`

- `bomrang_cache_delete()`, now superseded by `manage_cache$delete()`

- `bomrang_cache_delete_all()`, now superseded by `manage_cache$delete_all()`

--------------------------------------------------------------------------------

# bomrang 0.0.8

## Major changes

- Antarctic stations reporting with a valid .json file are now included in
internal database

## Minor changes

- Fix typo in DESCRIPTION, Scott's ORCID wasn't given as a full URL

- Update authors in vignettes to credit everyone who helped write them

- Update vignette style to use normal vignette style with table of contents

- Fix error in vignette that referred to `update_forecast_locations()`, it
should instead refer to `update_forecast_towns()`

- Update internal stations list with latest data from BOM

## Bug fixes

- Fix issue where updating internal stations would fail

--------------------------------------------------------------------------------

# bomrang 0.0.7

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

# bomrang 0.0.6

## Bug Fixes

- Fix typo in `check_states()`

- Replace `warning()` with `message()` in `get_states()`

## Major changes

- Fetch BOM 0900 and 1500 weather bulletins from SHTML sources and create a
tidy data frame of the data

--------------------------------------------------------------------------------

# bomrang 0.0.5

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

- Fetch BOM satellite images available through public FTP

- New use-case vignette, using _bomrang_ for the _WINS_ project

- Welcome message included with statement regarding BOM copyright

- Concatenate vignettes into a single file with appendices for descriptions of
data returned by functions

- Product IDs are included in outputs from `get_*()` functions that return a
tidy dataframe

- Full station names are reported along with BOM's current name used to refer
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
that document the data fields and units, rather than separate vignettes

- ramifications of updating station lists are now stated clearly in the vignette
and help files for applicable functions

- a map of BOM stations is included in an appendix of the _bomrang_ vignette

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
 values to query BOM data

- best practices for programming with `dplyr 0.7` using `rlang` are now
employed, which reduces the need for the `# CRAN NOTE avoidance`

- "JSONurl_latlon_by_station_name" has been shortened to
"JSONurl_site_list".

- The DESCRIPTION file now states minimum package versions for packages that are
undergoing rapid development

- Code has been re-factored to be shorter, _e.g._, `xml_bulletin_url` in
`get_ag_bulletion()`

- `.get_obs()` has been moved out of the `.parse_bulletin()` function for easier
reading/maintenance

- fixed a repeat of `return(tidy_df)` in `get_precis_forecast()`

--------------------------------------------------------------------------------

# bomrang 0.0.4-1

## Major changes

- Update internal functionality for _dplyr_ 0.7.0

--------------------------------------------------------------------------------

# bomrang 0.0.4

## Major changes

- Use _jsonlite_ library rather than _rjson_

--------------------------------------------------------------------------------

# bomrang 0.0.3-5

## Major changes

- Wrap examples for `get_precis_forecast()` in a \dontrun{} tag due to CRAN NOTE
taking too long to run

- Use proper GitHub URL in DESCRIPTION file

--------------------------------------------------------------------------------

# bomrang 0.0.3-4

## Major changes

- Run examples for all `get_*` functions in package

- `update_precis_locations()` is now `update_forecast_towns()`

--------------------------------------------------------------------------------

# bomrang 0.0.3-3

## Minor changes

- Add links to vignettes documenting the fields returned in the data frames from
the `get_*()` functions

- Use the DOI that always points to latest version

# bomrang 0.0.3-2 2017-06-03

## Minor changes
- Add vignettes describing the data returned from `get_precis_forecast()` and
`get_ag_bulletin()`, remove this from function help files

- Correct documentation reference in README file

--------------------------------------------------------------------------------

# bomrang 0.0.3-1

## Minor changes
- Add vignette describing the data returned from `get_current_weather()`

--------------------------------------------------------------------------------

# bomrang 0.0.3

## Major changes

- Include internal databases of station locations and metadata for
`get_current_weather()` and `get_ag_bulletin()` both derived from the same BOM
station master list

- The new database includes a more complete list of JSON URLs and ag bulletin
station locations

- Generation of the JSON URL list is much faster, now can be updated by the user
in a few seconds as desired using the new `update_station_locations()` function

## Minor changes
- Better tests written for the package  

- Add a new file describing internal database creation for station locations,
metadata and JSON URLs, create_BOM_station_list.md

--------------------------------------------------------------------------------

# bomrang 0.0.2-1

## Minor changes

- Add more information to description field in DESCRIPTION file

--------------------------------------------------------------------------------

# bomrang 0.0.2

## Major changes

- Hugh Parsonage has joined as a contributor  

- Added a new function `get_current_weather()` to retrieve weather data from 
specified BOM weather stations  

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

# bomrang 0.0.1

- Added a `NEWS.md` file to track changes to the package.

- New package for fetching BOM forecasts and ag information bulletins
