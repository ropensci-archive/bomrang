


#' BoM daily précis forecast
#'
#'Fetch the BoM daily précis forecast and return a tidy data frame of the daily
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
#' Data frame of a Australia BoM daily forecast in a tidy data frame.  For
#' more details see the vignette "Précis Forecast Fields":
#' \code{vignette("Précis Forecast Fields", package = "bomrang")}
#' for a complete list of fields and units.
#'
#' @examples
#' \dontrun{
#' BoM_forecast <- get_precis_forecast(state = "QLD")
#'}
#' @author Adam H Sparks, \email{adamhsparks@gmail.com} and Keith Pembleton, \email{keith.pembleton@usq.edu.au}
#'
#' @references
#' Australian Bureau of Meteorology (BoM) Weather Data Services
#' \url{http://www.bom.gov.au/catalogue/data-feeds.shtml}
#'
#' @importFrom magrittr %>%
#'
#' @export
get_precis_forecast <- function(state = NULL) {
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
    out <- .parse_forecast(xmlforecast)
  }
  else if (state == "AUS") {
    out <- lapply(X = file_list, FUN = .parse_forecast)
    out <- as.data.frame(data.table::rbindlist(out))
  }
  return(out)
}


.parse_forecast <- function(xmlforecast) {
  #CRAN NOTE avoidance
  aac <- location <- state <- lon <- lat <- elev <-
    precipitation_range <- attrs <- values <-
    `c("air_temperature_maximum", "Celsius")` <-
    `start-time-local` <-
    `end-time-local` <- `c("air_temperature_minimum", "Celsius")` <-
    LON <- LAT <- ELEVATION <- `end-time-utc` <-
    `start-time-utc` <- precis <- probability_of_precipitation <-
    PT_NAME <- end_time_local <- end_time_utc <- lower_prec_limit <-
    start_time_local <- start_time_utc <- maximum_temperature <-
    minimum_temperature <- UTC_offset_drop <- NULL

  # load the XML forecast ----------------------------------------------------
  tryCatch({
    xmlforecast <- xml2::read_xml(xmlforecast)
  },
  error = function(x)
    stop(
      "\nThe server with the forecast is not responding. Please retry again later.\n"
    ))

  areas <-
    xml2::xml_find_all(xmlforecast, ".//*[@type='location']")
  xml2::xml_find_all(areas, ".//*[@type='forecast_icon_code']") %>%
    xml2::xml_remove()

  out <- lapply(X = areas, FUN = .parse_areas)
  out <- as.data.frame(do.call("rbind", out))

  # This is the actual returned value for the main function. The functions
  # below chunk the xml into locations and then days, this assembles into
  # the final data frame

  out <- tidyr::spread(out, key = attrs, value = values)
  out <-
    out %>%
    dplyr::rename(
      maximum_temperature = `c("air_temperature_maximum", "Celsius")`,
      minimum_temperature = `c("air_temperature_minimum", "Celsius")`,
      start_time_local = `start-time-local`,
      end_time_local = `end-time-local`,
      start_time_utc = `start-time-utc`,
      end_time_utc = `end-time-utc`
    ) %>%
    dplyr::mutate_at(.funs = as.character,
                     .vars = c("aac",
                               "precipitation_range")) %>%
    tidyr::separate(end_time_local,
                    into = c("end_time_local", "UTC_offset"),
                    sep = "\\+") %>%
    tidyr::separate(
      start_time_local,
      into = c("start_time_local", "UTC_offset_drop"),
      sep = "\\+"
    ) %>%
    dplyr::select(-UTC_offset_drop)

  out$probability_of_precipitation <-
    gsub("%", "", paste(out$probability_of_precipitation))

  # remove the "T" from the date/time columns
  out[, c(3:4, 6:7)] <-
    apply(out[, c(3:4, 6:7)], 2, function(x)
      chartr("T", " ", x))

  # remove the "Z" from start_time_utc
  out[, 6:7] <-
    apply(out[, 6:7], 2, function(x)
      chartr("Z", " ", x))

  # convert dates to POSIXct ---------------------------------------------------
  out[, c(3:4, 6:7)] <-
    lapply(out[, c(3:4, 6:7)], function(x)
      as.POSIXct(x, origin = "1970-1-1", format = "%Y-%m-%d %H:%M:%OS"))

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
      sep = "to",
      fill = "left"
    )

  # remove unnecessary text (mm in prcp cols) --------------------------------
  out <- as.data.frame(lapply(out, function(x) {
    gsub(" mm", "", x)
  }))

  # merge the forecast with the locations ------------------------------------

  out$aac <- as.character(out$aac)
  # return final forecast object
  tidy_df <-
    dplyr::left_join(out,
                     AAC_codes, by = c("aac" = "AAC")) %>%
    dplyr::rename(lon = LON,
                  lat = LAT,
                  elev = ELEVATION) %>%
    dplyr::mutate_at(
      .funs = as.character,
      .vars = c(
        "start_time_local",
        "end_time_local",
        "start_time_utc",
        "end_time_utc",
        "precis",
        "probability_of_precipitation"
      )
    ) %>%
    dplyr::mutate_at(
      .funs = as.numeric,
      .vars = c(
        "maximum_temperature",
        "minimum_temperature",
        "lower_prec_limit",
        "lower_prec_limit"
      )
    ) %>%
    dplyr::rename(location = PT_NAME)

  # add state field
  tidy_df$state <- gsub("_.*", "", tidy_df$aac)
  tidy_df <-
    dplyr::select(.data = tidy_df, aac:location, state, lon, lat, elev)
  return(tidy_df)

  return(tidy_df)
}

# get the data from areas --------------------------------------------------
.parse_areas <- function(x) {
  aac <- as.character(xml2::xml_attr(x, "aac"))

  # get xml children for the forecast (there are seven of these for each area)
  forecast_periods <- xml2::xml_children(x)

  sub_out <-
    lapply(X = forecast_periods, FUN = .extract_values)
  sub_out <- do.call(rbind, sub_out)
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
    time_period[rep(seq_len(nrow(time_period)), each = length(attrs)),]

  sub_out <- cbind(time_period, attrs, values)
  row.names(sub_out) <- NULL
  return(sub_out)
}
