
# *bomrang*: Fetch Australian Government Bureau of Meteorology (BoM) Data

[![Travis-CI Build Status](https://travis-ci.org/ToowoombaTrio/bomrang.svg?branch=master)](https://travis-ci.org/ToowoombaTrio/bomrang)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ToowoombaTrio/bomrang?branch=master&svg=true)](https://ci.appveyor.com/project/ToowoombaTrio/bomrang) [![codecov](https://codecov.io/gh/ToowoombaTrio/bomrang/branch/master/graph/badge.svg)](https://codecov.io/gh/ToowoombaTrio/bomrang) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.598301.svg)](https://doi.org/10.5281/zenodo.598301)

Provides functions to interface with Australian Government Bureau of Meteorology
(BoM) data, fetching data and returning a tidy data frame of précis forecasts,
current weather data from stations or ag information bulletins.

Credit for the name, *bomrang*, goes to [Di Cook](http://dicook.github.io), who
suggested it attending the rOpenSci AUUnconf in Brisbane, 2016, when seeing the [vignette](https://github.com/saundersk1/auunconf16/blob/master/Vignette_BoM.pdf)
that we had assembled during the Unconf.

## Quick Start

``` r
if (!require("devtools")) {
  install.packages("devtools", repos = "http://cran.rstudio.com/")
  library("devtools")
}

devtools::install_github("toowoombatrio/bomrang")
```

## Using *bomrang*

The main functionality of *bomrang* is provided through three functions,
`get_precis_forecast()`, which retrieves the précis (short) forecast;
`get_current_weather()`, which fetches the current weather from a given station;
and `get_ag_bulletin()`, which retrieves the agriculture bulletin.

### Using `get_precis_forecast()`

This function only takes one argument, `state`. States or territories are
specified using the official postal codes.

- **ACT** - Australian Capital Territory

- **NSW** - New South Wales

- **NT** - Northern Territory

- **QLD** - Queensland

- **SA** - South Australia

- **TAS** - Tasmania

- **VIC** - Victoria

- **WA** - Western Australia

- **AUS** - Australia, returns national forecast including all states or
territories.

#### `get_precis_forecast()` Results

The function `get_precis_forecast()` will return a tidy data frame of BoM data
for the requested state(s) or territory. For a complete listing of the fields in
the data frame see the `Précis Forecast Fields` vignette.

#### Example Using `get_precis_forecast()`

Following is an example fetching the précis forecast for Queensland.

``` r
library("bomrang")

QLD_forecast <- get_precis_forecast(state = "QLD")
head(QLD_forecast)

    ##         aac index    start_time_local end_time_local UTC_offset
    ## 1 QLD_PT001     0 2017-06-12 17:00:00     2017-06-13      10:00
    ## 2 QLD_PT001     1 2017-06-13 00:00:00     2017-06-14      10:00
    ## 3 QLD_PT001     2 2017-06-14 00:00:00     2017-06-15      10:00
    ## 4 QLD_PT001     3 2017-06-15 00:00:00     2017-06-16      10:00
    ## 5 QLD_PT001     4 2017-06-16 00:00:00     2017-06-17      10:00
    ## 6 QLD_PT001     5 2017-06-17 00:00:00     2017-06-18      10:00
    ##        start_time_utc        end_time_utc maximum_temperature
    ## 1 2017-06-12 07:00:00 2017-06-12 14:00:00                  NA
    ## 2 2017-06-12 14:00:00 2017-06-13 14:00:00                   7
    ## 3 2017-06-13 14:00:00 2017-06-14 14:00:00                   8
    ## 4 2017-06-14 14:00:00 2017-06-15 14:00:00                   9
    ## 5 2017-06-15 14:00:00 2017-06-16 14:00:00                  10
    ## 6 2017-06-16 14:00:00 2017-06-17 14:00:00                  10
    ##   minimum_temperature lower_prec_limit upper_prec_limit           precis
    ## 1                  NA               NA             <NA>   Shower or two.
    ## 2                   7                7               50   Rain at times.
    ## 3                   8                3               25  Showers easing.
    ## 4                   8                1                8   Shower or two.
    ## 5                   7                1                2 Possible shower.
    ## 6                   7                1                1 Possible shower.
    ##   probability_of_precipitation location state      lon      lat elev
    ## 1                           50 Brisbane   QLD 153.0389 -27.4808  8.1
    ## 2                           95 Brisbane   QLD 153.0389 -27.4808  8.1
    ## 3                           80 Brisbane   QLD 153.0389 -27.4808  8.1
    ## 4                           50 Brisbane   QLD 153.0389 -27.4808  8.1
    ## 5                           40 Brisbane   QLD 153.0389 -27.4808  8.1
    ## 6                           40 Brisbane   QLD 153.0389 -27.4808  8.1
```

### Using `get_ag_bulletin()`

This function only takes one argument, `state`. The `state` parameter allows the
user to select the bulletin for just one state or a national bulletin. States or
territories are specified using the official postal codes.

- **NSW** - New South Wales

- **NT** - Northern Territory

- **QLD** - Queensland

- **SA** - South Australia

- **TAS** - Tasmania

- **VIC** - Victoria

- **WA** - Western Australia

- **AUS** - Australia, returns bulletin for all states/territories.

#### `get_ag_bulletin()` Results

The function `get_ag_bulletin()` will return a tidy data frame of BoM data for
the requested state(s) or territory. For a complete listing of the fields in the
data frame see the `Ag Bulletin Fields` vignette.

#### Example Using `get_ag_bulletin()`

Following is an example fetching the ag bulletin for Queensland.

``` r
library("bomrang")

QLD_bulletin <- get_ag_bulletin(state = "QLD")
head(QLD_bulletin)

    ##        obs_time_local        obs_time_utc time_zone  site dist
    ## 1 2017-06-12 09:00:00 2017-06-11 23:00:00       EST 38026   38
    ## 2 2017-06-12 09:00:00 2017-06-11 23:00:00       EST 38003   38
    ## 3 2017-06-12 09:00:00 2017-06-11 23:00:00       EST 40842   40
    ## 4 2017-06-12 09:00:00 2017-06-11 23:00:00       EST 39128   39
    ## 5 2017-06-12 09:00:00 2017-06-11 23:00:00       EST 31011   31
    ## 6 2017-06-12 09:00:00 2017-06-11 23:00:00       EST 44021   44
    ##            station start  end state      lat      lon  elev bar_ht   WMO
    ## 1       Birdsville  2000 2017   QLD -25.8975 139.3472  46.6   47.0 95482
    ## 2           Boulia  1886 2017   QLD -22.9117 139.9039 161.8  158.3 94333
    ## 3 Brisbane Airport  1992 2017   QLD -27.3917 153.1292   4.5    9.5 94578
    ## 4        Bundaberg  1942 2017   QLD -24.9069 152.3230  30.8   31.5 94387
    ## 5           Cairns  1941 2017   QLD -16.8736 145.7458   2.2    8.3 94287
    ## 6      Charleville  1942 2017   QLD -26.4139 146.2558 301.6  303.3 94510
    ##      r   tn   tx twd  ev   tg  sn   t5  t10  t20  t50  t1m  wr
    ## 1  0.0  6.2 21.0 2.7  NA   NA  NA   NA   NA   NA   NA   NA  NA
    ## 2  0.0  7.4 20.6 3.8 6.9  5.9  NA   NA   NA   NA   NA   NA  NA
    ## 3 16.4 13.7 20.5 2.0 0.8 11.1 2.4 17.0 17.0 18.0 19.0 20.0 179
    ## 4  1.4 15.7 23.7 1.3  NA   NA  NA 18.4 18.8 19.5 19.1 20.5  73
    ## 5  1.4 17.7 23.3 3.3  NA   NA  NA   NA   NA   NA   NA   NA  NA
    ## 6  0.6 11.2 22.5 3.2  NA   NA  NA   NA   NA   NA   NA   NA  NA
```

### Using `get_current_weather()`

Returns the latest 72 hours weather observations for a station.

This function accepts four arguments:

- `station_name`, The name of the weather station. Fuzzy string matching via
 `base::agrep` is done.

- `latlon`, A length-2 numeric vector. When given instead of station\_name,
the nearest station (in this package) is used, with a message indicating the
nearest such station. (See also `sweep_for_stations()`.) Ignored if used in
combination with `station_name`, with a warning.

- `raw` Logical. Do not convert the columns data.table to the appropriate
classes. (FALSE by default.)

- `emit_latlon_msg` Logical. If `TRUE` (the default), and `latlon` is
selected, a message is emitted before the table is returned indicating which
station was actually used (i.e. which station was found to be nearest to the
given coordinate).

#### Results of `get_current_weather()`

The function, `get_current_weather()` will return a tidy data frame of the
current and past 72 hours observations for the requested station. For a complete
listing of the fields in the data frame see the `Current Weather Fields`
vignette.

#### Example Using `get_current_weather()`

Following is an example fetching the current weather for Melbourne.

``` r
library("bomrang")

Melbourne_weather <- get_current_weather("Melbourne (Olympic Park)")
head(Melbourne_weather)

    ##   sort_order   wmo                     name history_product
    ## 1          0 95936 Melbourne (Olympic Park)        IDV60801
    ## 2          1 95936 Melbourne (Olympic Park)        IDV60801
    ## 3          2 95936 Melbourne (Olympic Park)        IDV60801
    ## 4          3 95936 Melbourne (Olympic Park)        IDV60801
    ## 5          4 95936 Melbourne (Olympic Park)        IDV60801
    ## 6          5 95936 Melbourne (Olympic Park)        IDV60801
    ##   local_date_time local_date_time_full        aifstime_utc   lat lon
    ## 1      12/07:00pm  2017-06-12 19:00:00 2017-06-12 09:00:00 -37.8 145
    ## 2      12/06:30pm  2017-06-12 18:30:00 2017-06-12 08:30:00 -37.8 145
    ## 3      12/06:00pm  2017-06-12 18:00:00 2017-06-12 08:00:00 -37.8 145
    ## 4      12/05:30pm  2017-06-12 17:30:00 2017-06-12 07:30:00 -37.8 145
    ## 5      12/05:00pm  2017-06-12 17:00:00 2017-06-12 07:00:00 -37.8 145
    ## 6      12/04:30pm  2017-06-12 16:30:00 2017-06-12 06:30:00 -37.8 145
    ##   apparent_t cloud cloud_base_m cloud_oktas cloud_type cloud_type_id
    ## 1       12.7     -           NA          NA          -            NA
    ## 2       13.4     -           NA          NA          -            NA
    ## 3       14.2     -           NA          NA          -            NA
    ## 4       14.8     -           NA          NA          -            NA
    ## 5       14.8     -           NA          NA          -            NA
    ## 6       13.9     -           NA          NA          -            NA
    ##   delta_t gust_kmh gust_kt air_temp dewpt  press press_msl press_qnh
    ## 1     0.3        0       0     12.2  11.6 1027.9    1027.9    1027.9
    ## 2     0.7        7       4     13.2  11.9 1027.4    1027.4    1027.4
    ## 3     0.7        0       0     13.5  12.1 1027.4    1027.4    1027.4
    ## 4     1.4        0       0     14.3  11.6 1027.0    1027.0    1027.0
    ## 5     1.6        0       0     14.4  11.4 1026.8    1026.8    1026.8
    ## 6     1.7        9       5     14.6  11.4 1026.7    1026.7    1026.7
    ##   press_tend rain_trace rel_hum sea_state swell_dir_worded swell_height
    ## 1          -          0      96         -                -           NA
    ## 2          -          0      92         -                -           NA
    ## 3          -          0      91         -                -           NA
    ## 4          -          0      84         -                -           NA
    ## 5          -          0      82         -                -           NA
    ## 6          -          0      81         -                -           NA
    ##   swell_period vis_km weather wind_dir wind_spd_kmh wind_spd_kt
    ## 1           NA     10       -     CALM            0           0
    ## 2           NA     10       -       NW            2           1
    ## 3           NA     10       -     CALM            0           0
    ## 4           NA     10       -     CALM            0           0
    ## 5           NA     10       -     CALM            0           0
    ## 6           NA     10       -      WSW            6           3
```

## Meta

- Please [report any issues or bugs](https://github.com/ToowoombaTrio/bomrang/issues).

- License: MIT

- To cite *bomrang*, please use:
    Sparks A, Parsonage H and Pembleton K (2017). *BoMRang: Fetch Australian
    Government Bureau of Meteorology Weather Data*. doi: 10.5281/zenodo.598301
    (URL: <http://doi.org/10.5281/zenodo.598301>), R package version 0.0.4-1,

    or the BibTeX entry:
```bibtex
@Manual{R-pkg-bomrang,
  author       = {Adam Sparks and Hugh Parsonage and Keith Pembleton},
  title        = {bomrang: Fetch Australian Government Bureau of Meteorology Weather Data},
  year         = {2017},
  doi          = {10.5281/zenodo.598301},
  url          = {https://github.com/ToowoombaTrio/bomrang},
}

```
    
- Please note that this project is released with a
[Contributor Code of Conduct](CONDUCT.md). By participating in this project you
agree to abide by its terms.

- BoM Copyright Notice <http://reg.bom.gov.au/other/copyright.shtml>

## References

[Australian Bureau of Meteorology (BoM) Weather Data Services](http://www.bom.gov.au/catalogue/data-feeds.shtml)

[Australian Bureau of Meteorology (BoM) Weather Data Services Agriculture Bulletins](http://www.bom.gov.au/catalogue/observations/about-agricultural.shtml)

[Australian Bureau of Meteorology (BoM) Weather Data Services Observation of Rainfall](http://www.bom.gov.au/climate/how/observations/rain-measure.shtml)
