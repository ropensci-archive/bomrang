## ----libraries, echo=FALSE, message=FALSE--------------------------------
library(bomrang)

## ----current_weather, eval=FALSE-----------------------------------------
#  Melbourne_weather <- get_current_weather("Melbourne (Olympic Park)")

## ----precis_forecast, eval=FALSE-----------------------------------------
#  QLD_forecast <- get_precis_forecast(state = "QLD")

## ----ag_bulletin, eval=FALSE---------------------------------------------
#  QLD_bulletin <- get_ag_bulletin(state = "QLD")

## ----weather-bulletin-AM, eval=FALSE-------------------------------------
#  qld_weather <- get_weather_bulletin(state = "QLD", morning = TRUE)

## ----weather-bulletin-PM, eval=FALSE-------------------------------------
#  qld_weather <- get_weather_bulletin(state = "QLD")

## ----sweep_stations, eval=TRUE-------------------------------------------
# Show only the first ten stations in the list
head(sweep_for_stations(latlon = c(-35.3, 149.2)), 10)

## ---- eval = FALSE-------------------------------------------------------
#  paste0(.libPaths(), "/bomrang/extdata")[1]

## ----update_forecast_towns, eval=FALSE-----------------------------------
#  update_forecast_towns()

## ----update_station_locations, eval=FALSE--------------------------------
#  update_station_locations()

## ----get_available_imagery, eval=FALSE-----------------------------------
#  avail <- get_available_imagery(product_id = "IDE00425")

## ----get_satellite_imagery, eval=FALSE-----------------------------------
#  # Specify product ID and scans
#  i <- get_satellite_imagery(product_id = "IDE00425", scans = 1)
#
#  # Same, but use "avail" from prior to specify images for download
#  i <- get_satellite_imagery(product_id = avail, scans = 1)
#
#  # Cache image for later use
#  i <- get_satellite_imagery(product_id = avail, scans = 1, cache = TRUE)
#
#  # load the raster library to work with the GeoTIFF files
#  library(raster)
#  plot(i)

## ----station-locations-map, fig.width = 7, fig.height = 5, message = FALSE----
if (requireNamespace("ggplot2", quietly = TRUE) &&
    requireNamespace("ggthemes", quietly = TRUE) &&
    requireNamespace("maps", quietly = TRUE) &&
    requireNamespace("mapproj", quietly = TRUE) &&
    requireNamespace("gridExtra", quietly = TRUE) &&
    requireNamespace("grid", quietly = TRUE)) {
  library(ggplot2)
  library(mapproj)
  library(ggthemes)
  library(maps)
  library(data.table)
  library(grid)
  library(gridExtra)
  load(system.file("extdata", "stations_site_list.rda", package = "bomrang"))
  setDT(stations_site_list)

  Aust_stations <-
    stations_site_list[(!(state %in% c("ANT", "null"))) & !grepl("VANUATU|HONIARA", name)]

  Aust_map <- map_data("world", region = "Australia")

  BOM_stations <- ggplot(Aust_stations, aes(x = lon, y = lat)) +
    geom_polygon(data = Aust_map, aes(x = long, y = lat, group = group),
                 color = grey(0.7),
                 fill = NA) +
    geom_point(color = "red",
               size = 0.05) +
    coord_map(ylim = c(-45, -5),
              xlim = c(96, 167)) +
    theme_map() +
    labs(title = "BOM Station Locations",
         subtitle = "Australia, outlying islands and buoys (excl. Antarctic stations)",
         caption = "Data: Australia Bureau of Meteorology (BOM)\n
         and NaturalEarthdata, http://naturalearthdata.com")

  # Using the gridExtra and grid packages add a neatline to the map
  grid.arrange(BOM_stations, ncol = 1)
  grid.rect(width = 0.98,
            height = 0.98,
            gp = grid::gpar(lwd = 0.25,
                            col = "black",
                            fill = NA))
}

