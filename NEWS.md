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


