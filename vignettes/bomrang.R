## ---- eval=FALSE---------------------------------------------------------
#  library("bomrang")
#  
#  Melbourne_weather <- get_current_weather("Melbourne (Olympic Park)")
#  head(Melbourne_weather)

## ---- eval=FALSE---------------------------------------------------------
#  library("bomrang")
#  
#  QLD_forecast <- get_precis_forecast(state = "QLD")
#  head(QLD_forecast)

## ---- eval=FALSE---------------------------------------------------------
#  library("bomrang")
#  
#  QLD_bulletin <- get_ag_bulletin(state = "QLD")
#  head(QLD_bulletin)

## ---- eval=FALSE---------------------------------------------------------
#  # Show only the first ten stations in the list
#  head(sweep_for_stations(latlon = c(-35.3, 149.2)), 10)

## ---- eval=FALSE---------------------------------------------------------
#  update_forecast_locations()

## ---- eval=FALSE---------------------------------------------------------
#  update_station_locations()

## ----station-locations-map, fig.width = 7, fig.height = 7----------------
if (requireNamespace("ggplot2", quietly = TRUE) &&
    requireNamespace("ggthemes", quietly = TRUE) &&
    requireNamespace("maps", quietly = TRUE) &&
    requireNamespace("mapproj", quietly = TRUE)) {
  library(ggplot2)
  library(mapproj)
  library(ggthemes)
  library(maps)
  library(data.table)
  load(system.file("extdata", "stations_site_list.rda", package = "bomrang"))
  setDT(stations_site_list)

  Aust_stations <- 
    stations_site_list[(!(state %in% c("ANT", "null"))) & !grepl("VANUATU|HONIARA", name)]
  
  Aust_map <- map_data("world", region = "Australia")
  
  ggplot(Aust_stations, aes(x = lon, y = lat)) + 
    geom_polygon(data = Aust_map, aes(x = long, y = lat, group = group), 
                 color = grey(0.7),
                 fill = NA) +
    geom_point(color = "red",
               size = 0.05) +
    coord_map(ylim = c(-45, -5),
              xlim = c(96, 167)) +
    theme_map() + 
    ggtitle("BoM Station Locations",
            subtitle = "Australia, outlying islands and buoys (excl. Antarctic stations)")
}

