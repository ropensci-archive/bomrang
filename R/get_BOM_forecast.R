
#' Get BOM Forecast for Queensland
#'
#'Fetch the BOM forecast and create a data frame object that can be used for
#'interpolating.
#'
#' @return
#' Data frame of a Australia BOM forecast for Queensland for max temperature,
#' min temperature and corresponding locations.
#'
#' @examples
#' \dontrun{
#' BOM_forecast <- get_BOM_forecast()
#' }
#' @export
#'
#' @importFrom dplyr %>%
get_BOM_forecast <- function() {
  # BOM station list - a .dbf file (part of a shapefile of station locations)
  # AAC codes can be used to add lat/lon to the forecast
  utils::download.file(
    "ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf",
    destfile = paste0(tempdir(), "AAC_codes.dbf"),
    mode = "wb"
  )

  AAC_codes <-
    foreign::read.dbf(paste0(tempdir(), "AAC_codes.dbf"), as.is = TRUE)
  AAC_codes <- AAC_codes[, c(2:3, 7:9)]

  # fetch BOM foreast for Qld
  xmlforecast <-
    xml2::read_xml("ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ11295.xml")

  # extract locations from forecast
  areas <- xml2::xml_find_all(xmlforecast, "//forecast/area")
  forecast_locations <-
    dplyr::bind_rows(lapply(xml2::xml_attrs(areas), as.list))

  # join locations with lat/lon values for mapping and interpolation
  forecast_locations <- dplyr::left_join(forecast_locations,
                                         AAC_codes,
                                         by = c("aac" = "AAC",
                                                "description" = "PT_NAME"))

  # unlist and add the locations aac code
  forecasts <-
    lapply(xml2::xml_find_all(xmlforecast, "//forecast/area"),
           xml2::as_list)
  forecasts <- plyr::llply(forecasts, unlist)
  names(forecasts) <- forecast_locations$aac

  # get all the <element> and <text> tags (the forecast)
  eltext <- xml2::xml_find_all(xmlforecast, "//element | //text")

  # extract and clean (if needed) (the labels for the forecast)
  labs <- trimws(xml2::xml_attrs(eltext, "type"))

  # use a loop to turn list of named character elements into a list of dataframes
  # with the location aac code for each line of the data frame
  y <- vector("list")
  for (i in unique(names(forecasts))) {
    x <- data.frame(
      keyName = names(forecasts[[i]]),
      value = forecasts[[i]],
      row.names = NULL
    )
    z <- names(forecasts[i])
    x <- data.frame(rep(as.character(z), nrow(x)), x)
    y[[i]] <- x
  }

  # combind list into a single dataframe
  y <- data.table::rbindlist(y, fill = TRUE)

  # add the forecast description to the dataframe
  forecast <- data.frame(y, labs, rep(NA, length(labs)))
  names(forecast) <- c("aac", "keyName", "value", "labs", "element")

  # label for min/max temperature in a new col to use for sorting in next step
  forecast$element <-
    as.character(stringr::str_match(forecast$labs,
                                    "air_temperature_[[:graph:]]{7}"))

  # convert object to tibble and remove rows we don't need, e.g., precip
  # keep only max and min temp
  forecast <-
    tibble::as_tibble(stats::na.omit(forecast[, c(1, 3, 5)]))

  # add dates to the data frame
  forecast$date <- c(Sys.Date(),
                     rep(seq(
                       lubridate::ymd(Sys.Date() + 1),
                       lubridate::ymd(Sys.Date() + 6),
                       by = "1 day"
                     ),
                     each = 2))

  forecast <-
    dplyr::left_join(forecast, forecast_locations, by = "aac")
}
