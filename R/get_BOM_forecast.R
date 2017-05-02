
#' Get BOM Forecast for Queensland
#'
#'Fetch the BOM forecast and create a data frame object that can be used for
#'interpolating.
#'
#' @return
#' Data frame of a Australia BOM forecast for Queensland for max temperature,
#' min temperature and corresponding locations with lat/lon values for the next
#' six days.
#'
#' @examples
#' \dontrun{
#' BOM_forecast <- get_BOM_QLD()
#' }
#' @export
#'
#' @importFrom dplyr %>%
get_BOM_QLD <- function() {

  # Load BOM location data
  utils::data("AAC_codes", package = "BOMRang")
  AAC_codes <- AAC_codes

  # fetch BOM foreast for Qld
  xmlforecast <-
    xml2::read_xml("ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ11295.xml")

  # remove index=0 (today's "forecast"), it varies and we're not interested anyway
  xml2::xml_find_all(xmlforecast, ".//*[@index='0']") %>%
    xml2::xml_remove()

  # extract locations from forecast
  areas <- xml2::xml_find_all(xmlforecast, ".//*[@type='location']")
  forecast_locations <-
    dplyr::bind_rows(lapply(xml2::xml_attrs(areas), as.list))

  # join locations with lat/lon values for mapping and interpolation
  forecast_locations <- dplyr::left_join(forecast_locations,
                                         AAC_codes,
                                         by = c("aac" = "AAC",
                                                "description" = "PT_NAME"))

    # unlist and add the locations aac code
  forecasts <-
    lapply(xml2::xml_find_all(xmlforecast, ".//*[@type='location']"),
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

  # add dates to the new object
  forecast$date <- c(rep(seq(
    lubridate::ymd(Sys.Date() + 1),
    lubridate::ymd(Sys.Date() + 7),
    by = "1 day"
  ),
  each = 2))

  # label for min/max temperature in a new col to use for sorting in next step
  forecast$element <-
    as.character(stringr::str_match(forecast$labs,
                                    "air_temperature_[[:graph:]]{7}"))

  # convert object to tibble and remove rows we don't need, e.g., precip
  # keep only max and min temp
  forecast <-
    tibble::as_tibble(stats::na.omit(forecast[, c(1, 3, 5:6)]))

  # convert forecast_locations$aac to factor for merging
  forecast$aac <- as.character(forecast$aac)

  # merge the forecast with the locations
  forecast <-
    dplyr::left_join(forecast, forecast_locations, by = "aac")

}
