
#' Get BOM Daily Précis Forecast for Select Towns
#'
#' Fetch the \acronym{BOM} daily précis forecast and return a tidy data frame of the seven
#' day town forecast for a specified state or territory.
#'
#' @param state Australian state or territory as full name or postal code.
#' Fuzzy string matching via \code{\link[base]{agrep}} is done.  Defaults to
#' "AUS" returning all state bulletins, see details for further information.
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
#' Tidy \code{\link[data.table]{data.table}} of a Australia \acronym{BOM} précis
#' seven day forecasts for BOM selected towns.  For full details of fields and
#' units returned see Appendix 2 in the \pkg{bomrang} vignette, use \cr
#' \code{vignette("bomrang", package = "bomrang")} to view.
#'
#' @examples
#' \donttest{
#' # get the short forecast for Queensland
#' BOM_forecast <- get_precis_forecast(state = "QLD")
#'}
#' @references
#' Forecast data come from Australian Bureau of Meteorology (BOM) Weather Data
#' Services \cr
#' \url{http://www.bom.gov.au/catalogue/data-feeds.shtml}
#'
#' Location data and other metadata for towns come from
#' the \acronym{BOM} anonymous \acronym{FTP} server with spatial data \cr
#' \url{ftp://ftp.bom.gov.au/anon/home/adfd/spatial/}, specifically the
#' \acronym{DBF} file portion of a shapefile, \cr
#' \url{ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf}
#'
#' @author Adam H Sparks, \email{adamhsparks@@gmail.com} and Keith Pembleton,
#' \email{keith.pembleton@@usq.edu.au}
#' @importFrom data.table ":="
#' @export get_precis_forecast_dt

get_precis_forecast_dt <- function(state = "AUS") {
  the_state <- .check_states(state) # see internal_functions.R
  
  # ftp server
  ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/fwo/"
  
  # create vector of XML files
  AUS_XML <- c(
    "IDN11060.xml",
    # NSW
    "IDD10207.xml",
    # NT
    "IDQ11295.xml",
    # QLD
    "IDS10044.xml",
    # SA
    "IDT16710.xml",
    # TAS
    "IDV10753.xml",
    # VIC
    "IDW14199.xml"  # WA
  )
  
  if (the_state != "AUS") {
    xml_url <-
      lest::case_when(
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
    out <- .parse_forecast(xml_url)
  } else {
    file_list <- paste0(ftp_base, AUS_XML)
    out <- lapply(X = file_list, FUN = .parse_forecast)
    out <- as.data.frame(data.table::rbindlist(out))
  }
  return(out)
}

.parse_forecast <- function(xml_url) {
  # CRAN note avoidance
  AAC_codes <- # nocov start
    attrs <- end_time_local <- precipitation_range <- 
    start_time_local <- values <-  .SD <- .N <- .I <- .GRP <- .BY <- .EACHI <- 
    NULL # nocov end
  
  xml_object <- .get_xml(xml_url)
  
  areas <-
    xml2::xml_find_all(xml_object, ".//*[@type='location']")
  xml2::xml_remove(xml2::xml_find_all(areas,
                                      ".//*[@type='forecast_icon_code']"))
  
  out <- lapply(X = areas, FUN = .parse_areas)
  out <- data.table::setDT(as.data.frame(do.call("rbind", out)))
  names(out) <- gsub("-", "_", names(out))
  
  out <- data.table::dcast(
    out,
    aac + index + start_time_local + end_time_local + start_time_utc +
      end_time_utc  ~ attrs,
    value.var = "values"
  )
  
  setnames(out,
           c(1, 7:8),
           c(
             "AAC",
             "maximum_temperature",
             "minimum_temperature"
           ))
  
  out[, c("end_time_local",
          "UTC_offset") := data.table::tstrsplit(end_time_local,
                                                 "+",
                                                 fixed = TRUE)]
  out[, c("start_time_local",
          "UTC_offset_drop") := data.table::tstrsplit(start_time_local,
                                                      "+",
                                                      fixed = TRUE)]
  out[, "UTC_offset_drop" := NULL]
  
  # merge with aac codes for location information ------------------------------
  load(system.file("extdata", "AAC_codes.rda", package = "bomrang"))  # nocov
  data.table::setDT(AAC_codes)
  data.table::setkey(AAC_codes, "AAC")
  data.table::setkey(out, "AAC")
  
  out <- AAC_codes[out, on = "AAC"]
  
  # set names to match précis forecast -----------------------------------------
  data.table::setnames(out,
                       c(1:5),
                       c("aac", "town", "lon", "lat", "elev"))
  
  # add state field
  out[, state := gsub("_.*", "", out$aac)]
  
  # add product ID field
  out[, product_id := substr(basename(xml_url),
                             1,
                             nchar(basename(xml_url)) - 4)]
  
  # remove unnecessary text from cols ------------------------------------------
  out[, probability_of_precipitation := gsub("%",
                                             "",
                                             probability_of_precipitation)]
  out[, start_time_local := gsub("T", " ", start_time_local)]
  out[, end_time_local := gsub("T", " ", end_time_local)]
  out[, start_time_utc := gsub("T", " ", start_time_utc)]
  out[, end_time_utc := gsub("T", " ", end_time_utc)]
  
  # set col classes ------------------------------------------------------------
  # factors
  out[, c(1:3, 16:18) := lapply(.SD, function(x)
    as.factor(x)),
    .SDcols = c(1:3, 16:18)]
  
  # numeric
  out[, c(11:15) := lapply(.SD, function(x)
    as.numeric(x)),
    .SDcols = c(11:15)]
  
  # convert dates to POSIXct format
  out[, c(7:10) := lapply(.SD, function(x)
    as.POSIXct(x,
               origin = "1970-1-1",
               format = "%Y-%m-%d %H:%M:%OS")),
    .SDcols = c(7:10)]
  
  # handle precipitation ranges where they may or may not be present -----------
  if ("precipitation_range" %in% colnames(out))
  {
    # format any values that are only zero to make next step easier
    out$precipitation_range[which(out$precipitation_range == "0 mm")] <-
      "0 mm to 0 mm"
    
    # separate the precipitation column into two, upper/lower limit ------------
    out[, c("lower_precipitation_limit",
            "upper_precipitation_limit") := data.table::tstrsplit(precipitation_range, 
                                                                  "to",
                                                                  fixed = TRUE)]
    
    out[, upper_precipitation_limit := gsub("mm", "", upper_precipitation_limit)]
    out[, precipitation_range := NULL]
    
  } else {
    # if the columns don't exist insert as NA
    out[, lower_precipitation_limit := NA]
    out[, upper_precipitation_limit := NA]
  }
  
  refcols <- c(
    "index",
    "product_id",
    "state",
    "town",
    "aac",
    "lat",
    "lon",
    "elev",
    "start_time_local",
    "end_time_local",
    "UTC_offset",
    "start_time_utc",
    "end_time_utc",
    "minimum_temperature",
    "maximum_temperature",
    "lower_precipitation_limit",
    "upper_precipitation_limit",
    "precis",
    "probability_of_precipitation"
  )
  data.table::setcolorder(out, refcols)
  return(out)
}

# internal functions for get_precise_forecast ----------------------------------
#' Parse areas for précis forecasts
#'
#' @param x a précis forecast object
#'
#' @return a data.frame of forecast areas and aac codes
#' @keywords internal
#' @author Adam H Sparks, \email{adamhspark@@s@gmail.com}
#' @noRd

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

#' extract the values of the forecast items
#'
#' @param y précis forecast values
#'
#' @return a data.frame of forecast values
#' @keywords internal
#' @author Adam H Sparks, \email{adamhsparks@gmail.com}
#' @noRd

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
