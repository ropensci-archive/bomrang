# bomrange 0.0.4 2017-06-09

## Major changes
* Use _jsonlite_ library rather than _rjson_

# bomrang 0.0.3-5 2017-06-03

## Major changes
* Wrap examples for `get_precis_forecast()` in a \dontrun{} tag due to CRAN NOTE taking too long to run  
* Use proper GitHub URL in DESCRIPTION file  

# bomrang 0.0.3-4 2017-06-03

## Major changes
* Run examples for all `get_*` functions in package  
* `update_precis_locations()` is now `update_forecast_locations()`  

# bomrang 0.0.3-3 2017-06-03

## Minor changes
* Add links to vignettes documenting the fields returned in the data frames from the `get_*()` functions  
* Use the DOI that always points to latest version  

# bomrang 0.0.3-2 2017-06-03

## Minor changes
* Add vignettes describing the data returned from `get_precis_forecast()` and `get_ag_bulletin()`, remove this from function help files  
* Correct documentation reference in README file  

# bomrang 0.0.3-1 2017-06-03

## Minor changes
* Add vignette describing the data returned from `get_current_weather()`

# bomrang 0.0.3 2017-06-03

## Major changes

* Include internal databases of station locations and metadata for `get_current_weather()` and `get_ag_bulletin()` both derived from the same BOM station master list  
* The new database includes a more complete list of JSON URLs and ag bulletin station locations  
* Generation of the JSON URL list is much faster, now can be updated by the user in a few seconds as desired using the new `update_station_locations()` function  

## Minor changes
* Better tests written for the package  
* Add a new file describing internal database creation for station locations, metadata and JSON URLs, create_BOM_station_list.md  

# bomrang 0.0.2-1

## Minor changes

* Add more information to description field in DESCRIPTION file

# bomrang 0.0.2

## Major changes

* Hugh Parsonage has joined as a contributor  
* Added a new function `get_current_weather()` to retrieve weather data from specified BOM weather stations  
* Added a new function `sweep_for_stations()` to find stations used in `get_current_weather()` function, based on distance from a specified latitude and longitude
* Renamed existing functions for more clarity.  
  * `get_forecast()` is now `get_precis_forecast()`  
  * `get_bulletin()` is now `get_ag_bulletin()`  
  * `update_locations()` is now `update_precis_locations()`

## Minor changes

* All functions will return a `data.frame` object, not a `tibble`  
* If a server is not responding, the function returns a more meaningful error message on exit  
* All date/times are returned in POSIXct format  
* UTC offset is returned in a separate `UTC_offset` field for `get_precis_forecast()` for both `start_time_local` and `end_time_local` fields  
* Spelling and typo corrections  
* Enhanced documentation  

## Bug fixes

* Correct output for ag bulletin where the observation site is listed but has no values. The site will be listed with location data and `NA` for all meteorological values  

###########

# bomrang 0.0.1

* Added a `NEWS.md` file to track changes to the package.
* New package for fetching BOM forecasts and ag information bulletins


