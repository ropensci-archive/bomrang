
#' Get BOM Coastal Waters Forecast
#'
#' Fetch the \acronym{BOM} daily Coastal Waters Forecast and return a tidy data
#' frame of the forecast regions for a specified state or region.
#'
#' @param state Australian state or territory as full name or postal code.
#' Fuzzy string matching via \code{\link[base]{agrep}} is done.  Defaults to
#' "AUS" returning all state forecasts, see details for further information.
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
#'    \item{AUS}{Australia, returns forecast for all states, NT and ACT}
#'  }
#'
#' @return
#' Tidy \code{\link[data.table]{data.table}} of a Australia \acronym{BOM}
#' Coastal Waters Forecast.
#'
#' @examples
#' \donttest{
#' coastal_forecast <- get_coastal_forecast(state = "NSW")
#' coastal_forecast
#'}
#' @references
#' Forecast data come from Australian Bureau of Meteorology (BOM) Weather Data
#' Services \cr
#' \url{http://www.bom.gov.au/catalogue/data-feeds.shtml}
#'
#' Location data and other metadata come from the \acronym{BOM} anonymous
#' \acronym{FTP} server with spatial data \cr
#' \url{ftp://ftp.bom.gov.au/anon/home/adfd/spatial/}, specifically the
#' \acronym{DBF} file portion of a shapefile, \cr
#' \url{ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00003.dbf}
#'
#' @author Dean Marchiori, \email{deanmarchiori@@gmail.com}
#' @importFrom magrittr %>%
#' @export get_coastal_forecast

get_coastal_forecast <- function(state = "AUS") {
  the_state <- .check_states(state) # see internal_functions.R

  # ftp server
  ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/fwo/"

  # create vector of XML files
  AUS_XML <- c(
    "IDN11001.xml", # NSW
    "IDD11030.xml", # NT
    "IDQ11290.xml", # QLD
    "IDS11072.xml", # SA
    "IDT12329.xml", # TAS
    "IDV10200.xml", # VIC
    "IDW11160.xml"  # WA
  )

  if (the_state != "AUS") {
    xml_url <-
      dplyr::case_when(
        the_state == "ACT" |
          the_state == "CANBERRA" ~ paste0(ftp_base, AUS_XML[1]),
        the_state == "NSW" |
          the_state == "NEW SOUTH WALES" ~ paste0(ftp_base, AUS_XML[1]),
        the_state == "NT" |
          the_state == "NORTHERN TERRITORY" ~ paste0(ftp_base, AUS_XML[2]),
        the_state == "QLD" |
          the_state == "QUEENSLAND" ~ paste0(ftp_base, AUS_XML[3]),
        the_state == "SA" |
          the_state == "SOUTH AUSTRALIA" ~ paste0(ftp_base, AUS_XML[4]),
        the_state == "TAS" |
          the_state == "TASMANIA" ~ paste0(ftp_base, AUS_XML[5]),
        the_state == "VIC" |
          the_state == "VICTORIA" ~ paste0(ftp_base, AUS_XML[6]),
        the_state == "WA" |
          the_state == "WESTERN AUSTRALIA" ~ paste0(ftp_base, AUS_XML[7])
      )
    out <- .parse_coastal_forecast(xml_url)
  } else {
    file_list <- paste0(ftp_base, AUS_XML)
    out <- lapply(X = file_list, FUN = .parse_coastal_forecast)
    out <- data.table::rbindlist(out)
  }
  return(out)
}

.parse_coastal_forecast <- function(xml_url) {
  # CRAN note avoidance
  AAC_codes <- marine_AAC_codes <- attrs <- end_time_local <- # nocov start
    precipitation_range <- start_time_local <- values <- product_id <- 
    forecast_swell2 <- forecast_caution <- marine_forecast <- NULL # nocov end

  # download the XML forecast
  xml_object <- .get_xml(xml_url)
  
  areas <- xml2::xml_find_all(xml_object, ".//*[@type='coast']")
  out <- suppressWarnings(lapply(X = areas, FUN = .parse_areas))
  out <- data.table::rbindlist(out)
  names(out) <- gsub("-", "_", names(out))
  
  out <- data.table::dcast(
    out,
    aac + index + start_time_local + end_time_local + start_time_utc +
      end_time_utc  ~ attrs,
    value.var = "values"
  )

  # clean up and split out time cols into offset and remove extra chars
  .split_time_cols(x = out)

  # merge with aac codes for location information ------------------------------
  load(system.file("extdata", "marine_AAC_codes.rda", package = "bomrang"))  # nocov
  data.table::setkey(out, "aac")
  out <- marine_AAC_codes[out, on = "aac"]
  
  # return final forecast object -----------------------------------------------
 
  # add product ID field
  out[, product_id := substr(basename(xml_url),
                             1,
                             nchar(basename(xml_url)) - 4)]
  
  # some fields only come out on special occasions, if absent, add as NA
  if (!"forecast_swell2" %in% colnames(out)) {
    out[, forecast_swell2 := NA]
  }
  
  if (!"forecast_caution" %in% colnames(out)) {
    out[, forecast_caution := NA]
  }
  
  if (!"marine_forecast" %in% colnames(out)) {
    out[, marine_forecast := NA]
  }

  # reorder columns
  refcols <- c(
    "index",
    "product_id",
    "type",
    "state_code",
    "dist_name",
    "pt_1_name",
    "pt_2_name",
    "aac",
    "start_time_local",
    "end_time_local",
    "utc_offset",
    "start_time_utc",
    "end_time_utc",
    "forecast_seas",
    "forecast_weather",
    "forecast_winds",
    "forecast_swell1",
    "forecast_swell2",
    "forecast_caution",
    "marine_forecast"
  )

  data.table::setcolorder(out, refcols)
  
  # set col classes ------------------------------------------------------------
  # factors
  out[, c(1, 11) := lapply(.SD, function(x)
    as.factor(x)),
    .SDcols = c(1, 11)]

  # dates
  out[, c(9:10, 12:13) := lapply(.SD, function(x)
    as.POSIXct(x,
               origin = "1970-1-1",
               format = "%Y-%m-%d %H:%M:%OS")),
    .SDcols = c(9:10, 12:13)]
  
  # character
  out[, c(6:8, 14:20) := lapply(.SD, function(x)
    as.character(x)),
    .SDcols = c(6:8, 14:20)]
  
  return(out)
}
