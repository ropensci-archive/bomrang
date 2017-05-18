
#' Get BOM Daily Précis Forecast
#'
#'Fetch the BOM daily précis forecast and return a tidy data frame of the daily
#'forecast
#'
#' @param state Australian state or territory as postal code, see details for
#' instruction.
#'
#' @details Allowed state and territory postal codes, only one state per request
#' or all using \code{AUS}.
#'  \describe{
#'    \item{ACT}{Australian Capital Territory (will return NSW)}
#'    \item{NSW}{New South Wales}
#'    \item{NT}{Northern Territory}
#'    \item{QLD}{Queensland}
#'    \item{SA}{South Australia}
#'    \item{TAS}{Tasmania}
#'    \item{VIC}{Victoria}
#'    \item{WA}{Western Australia}
#'    \item{AUS}{Australia, returns forecast for all states}
#'  }
#'
#' @return
#' Data frame of a Australia BOM daily forecast in a data frame with the
#' following fields.
#'
#'\describe{
#'    \item{aac}{AMOC Area Code, \emph{e.g.}, WA_MW008, a unique identifier for each location}
#'    \item{index}{Index value, day 0 to day 7}
#'    \item{start_time_local}{Start of forecast date and time in local TZ}
#'    \item{end_time_local}{End of forecast date and time in local TZ}
#'    \item{start_time_utc}{Start of forecast date and time in UTC}
#'    \item{end_time_utc}{End of forecast date and time in UTC}
#'    \item{maximum_temperature}{Maximum forecasted temperature (Celsius)}
#'    \item{minimum_temperature}{Minimum forecasted temperature (Celsius)}
#'    \item{lower_prec_limit}{Lower forecasted precipitation limit (millimetres)}
#'    \item{upper_prec_limit}{Upper forecasted precipitation limit (millimetres)}
#'    \item{precis}{Précis forecast (a short summary, less than 30 characters)}
#'    \item{probability_of_precipitation}{Probability of precipitation (percent)}
#'    \item{location}{Named location for forecast}
#'    \item{state}{State name (postal code abbreviation)}
#'    \item{lon}{Longitude of named location (decimal degrees)}
#'    \item{lat}{Latitude of named location (decimal degrees)}
#'    \item{elev}{Elevation of named location (metres)}
#' }
#'
#' @examples
#' \dontrun{
#' BOM_forecast <- get_forecast(state = "QLD")
#' }
#'
#' @author Adam H Sparks, \email{adamhsparks@gmail.com} and Keith Pembleton \email{keith.pembleton@usq.edu.au}
#'
#' @references
#' Australian Bureau of Meteorology (BOM) Weather Data Services
#' \url{http://www.bom.gov.au/catalogue/data-feeds.shtml}
#'
#' @importFrom magrittr %>%
#'
#'
#' @export
get_forecast <- function(state = NULL) {
  state <- .validate_state(state)

  # ftp server
  ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/fwo/"

  # State/territory forecast files
  NSW <- "IDN11060.xml"
  NT  <- "IDD10207.xml"
  QLD <- "IDQ11295.xml"
  SA  <- "IDS10044.xml"
  TAS <- "IDT16710.xml"
  VIC <- "IDV10753.xml"
  WA  <- "IDW14199.xml"

  if (state == "NSW" | state == "ACT") {
    xmlforecast <-
      paste0(ftp_base, NSW) # nsw
  }
  else if (state == "NT") {
    xmlforecast <-
      paste0(ftp_base, NT) # nt
  }
  else if (state == "QLD") {
    xmlforecast <-
      paste0(ftp_base, QLD) # qld
  }
  else if (state == "SA") {
    xmlforecast <-
      paste0(ftp_base, SA) # sa
  }
  else if (state == "TAS") {
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
  } else
    stop(state, " not recognised as a valid state or territory")

  if (state != "AUS") {
    tibble::as_tibble(.parse_forecast(xmlforecast))
  }
  else if (state == "AUS") {
    tibble::as_tibble(plyr::ldply(
      .data = file_list,
      .fun = .parse_forecast,
      .progress = "text"
    ))
  }
}

.parse_forecast <- function(xmlforecast) {
  aac <- location <- state <- lon <- lat <- elev <-
    precipitation_range <- attrs <- values <-
    `c("air_temperature_maximum", "Celsius")` <-
    `start-time-local` <-
    `end-time-local` <- `c("air_temperature_minimum", "Celsius")` <-
    LON <- LAT <- ELEVATION <- `end-time-utc` <-
    `start-time-utc` <- precis <- probability_of_precipitation <-
    PT_NAME <- end_time_local <- end_time_utc <- lower_prec_limit <-
    start_time_local <- start_time_utc <- maximum_temperature <-
    minimum_temperature <- NULL

  # load BOM location data ---------------------------------------------------
  utils::data("AAC_codes", package = "bomrang")
  AAC_codes <- AAC_codes

  # load the XML forecast ----------------------------------------------------
  xmlforecast <- xml2::read_xml(xmlforecast)
  areas <-
    xml2::xml_find_all(xmlforecast, ".//*[@type='location']")
  xml2::xml_find_all(areas, ".//*[@type='forecast_icon_code']") %>%
    xml2::xml_remove()

  out <- plyr::ldply(.data = areas, .fun = .parse_areas)

  # This is the actual returned value for the main function. The functions
  # below chunk the xml into locations and then days, this assembles into
  # the final data frame

  out <- tidyr::spread(out, key = attrs, value = values)
  out <-
    dplyr::rename(
      out,
      maximum_temperature = `c("air_temperature_maximum", "Celsius")`,
      minimum_temperature = `c("air_temperature_minimum", "Celsius")`,
      start_time_local = `start-time-local`,
      end_time_local = `end-time-local`,
      start_time_utc = `start-time-utc`,
      end_time_utc = `end-time-utc`
    )

  out$probability_of_precipitation <-
    gsub("%", "", paste(out$probability_of_precipitation))

  out <-
    out %>%
    dplyr::mutate_each(dplyr::funs(as.character), aac) %>%
    dplyr::mutate_each(dplyr::funs(as.character), precipitation_range)

  # split precipitation forecast values into lower/upper limits --------------

  # format any values that are only zero to make next step easier
  out$precipitation_range[which(out$precipitation_range == "0 mm")] <-
    "0 mm to 0 mm"

  # separate the precipitation column into two, upper/lower limit ------------
  out <-
    out %>%
    tidyr::separate(
      precipitation_range,
      into = c("lower_prec_limit", "upper_prec_limit"),
      sep = "to"
    )

  # remove unnecessary text (mm in prcp cols) --------------------------------
  out <- lapply(out, function(x) {
    gsub(" mm", "", x)
  })

  # merge the forecast with the locations ------------------------------------

  # return final forecast object ---------------------------------------------
  tidy_df <-
    dplyr::left_join(tibble::as_tibble(out),
                     AAC_codes, by = c("aac" = "AAC")) %>%
    dplyr::rename(lon = LON,
                  lat = LAT,
                  elev = ELEVATION) %>%
    dplyr::mutate_each(dplyr::funs(as.character), start_time_local) %>%
    dplyr::mutate_each(dplyr::funs(as.character), start_time_local) %>%
    dplyr::mutate_each(dplyr::funs(as.character), end_time_local) %>%
    dplyr::mutate_each(dplyr::funs(as.character), start_time_utc) %>%
    dplyr::mutate_each(dplyr::funs(as.character), end_time_utc) %>%
    dplyr::mutate_each(dplyr::funs(as.numeric), maximum_temperature) %>%
    dplyr::mutate_each(dplyr::funs(as.numeric), minimum_temperature) %>%
    dplyr::mutate_each(dplyr::funs(as.numeric), lower_prec_limit) %>%
    dplyr::mutate_each(dplyr::funs(as.numeric), lower_prec_limit) %>%
    dplyr::mutate_each(dplyr::funs(as.character), precis) %>%
    dplyr::mutate_each(dplyr::funs(as.character), probability_of_precipitation) %>%
    dplyr::mutate(state = stringr::str_extract(out$aac,
                                               pattern = "[:alpha:]{2,3}")) %>%
    dplyr::rename(location = PT_NAME) %>%
    dplyr::select(aac:location, state, lon, lat, elev)

  return(tidy_df)
}

# get the data from areas --------------------------------------------------
.parse_areas <- function(x) {
  aac <- as.character(xml2::xml_attr(x, "aac"))

  # get xml children for the forecast (there are seven of these for each area)
  forecast_periods <- xml2::xml_children(x)

  sub_out <-
    plyr::ldply(.data = forecast_periods, .fun = .extract_values)

  sub_out <- cbind(aac, sub_out)
  return(sub_out)
}

# extract the values of the forecast items
.extract_values <- function(y) {
  values <- xml2::xml_children(y)
  attrs <- unlist(as.character(xml2::xml_attrs(values)))
  values <- unlist(as.character(xml2::xml_contents(values)))

  time_period <- unlist(t(as.data.frame(xml2::xml_attrs(y))))
  time_period <-
    time_period[rep(seq_len(nrow(time_period)), each = length(attrs)), ]

  sub_out <- cbind(time_period, attrs, values)
  row.names(sub_out) <- NULL
  return(sub_out)
}
