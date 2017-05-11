
#' Get BOM Forecast
#'
#'Fetch the BOM forecast and create a tidy data frame of the six day forecast
#'
#' @param state Australian state or territory as postal code, see details for
#' instruction.
#'
#' @details Allowed state and territory postal codes, only one state per request
#' or all using \code{AUS}.
#'  \itemize{
#'    \item{ACT - Australian Capital Territory}
#'    \item{NSW - New South Wales}
#'    \item{NT - Northern Territory}
#'    \item{QLD - Queensland}
#'    \item{SA - South Australia}
#'    \item{TAS - Tasmania}
#'    \item{VIC - Tasmania}
#'    \item{WA - Western Australia}
#'    \item{AUS - Australia, returns forecast for all states}
#'  }
#'
#' @return
#' Data frame of a Australia BOM forecast for max temperature, min temperature
#' and corresponding locations with lat/lon values for the next six days.
#'
#' @examples
#' \dontrun{
#' BOM_forecast <- get_forecast(state = "QLD")
#' }
#'
#' @importFrom dplyr %>%
#'
#'
#' @export
get_forecast <- function(state) {
  .validate_state(state)

  # ftp server
  ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/fwo/"

  # State/territory forecast files
  NT  <- "IDD10207.xml"
  NSW <- "IDN11060.xml"
  QLD <- "IDN11060.xml"
  SA  <- "IDS10044.xml"
  TAS <- "IDT16710.xml"
  VIC <- "IDV10753.xml"
  WA  <- "IDW14199.xml"

  if (state == "NT") {
    xmlforecast <-
      paste0(ftp_base, NT) # nt
  }
  else if (state == "NSW" | state == "ACT") {
    xmlforecast <-
      paste0(ftp_base, NSW) # nsw
  }
  else if (state == "QLD") {
    xmlforecast <-
      paste0(ftp_base, QLD) # qld
  }
  else if (state == "SA") {
    xmlforecast <-
      paste0(ftp_base, SA) # sa
  }
  else if (state == "TAS")
  {
    xmlforecast <-
      paste0(ftp_base, TAS) # tas
  }
  else if (state == "VIC") {
    xmlforecast <-
      paste0(ftp_base, VIC) # vic
  }
  else if (state == "WA") {
    xmlforecast <-
      paste0(ftp_base, WA) # wa
  }
  else if (state == "AUS") {
    AUS <- list(NT, NSW, QLD, SA, TAS, VIC, WA)
    file_list <- paste0(ftp_base, AUS)
    Map(
      function(ftp, dest)
        utils::download.file(url = ftp, destfile = dest),
      file_list,
      file.path(tempdir(), basename(file_list))
    )

  } else
    stop(state, " not recognised as a valid state or territory")

  if (state != "AUS") {
    tibble::as_tibble(.parse_forecast(xmlforecast))
  }
  else if (state == "AUS") {
    xml_list <-
      list.files(tempdir(), pattern = ".xml$", full.names = TRUE)
    tibble::as_tibble(plyr::ldply(.data = xml_list,
                .fun = .parse_forecast,
                .progress = "text"))
  }
}

.parse_forecast <- function(xmlforecast) {

  # Load BOM location data
  utils::data("AAC_codes", package = "BOMRang")
  AAC_codes <- AAC_codes

  xmlforecast <- xml2::read_xml(xmlforecast)

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

#' @noRd
.validate_state <-
  function(state) {
    if (!is.null(state)) {
      state <- toupper(trimws(state))
    } else
      stop("\nPlease provide a valid 2 or 3 letter state or territory postal code abbreviation")
  }
