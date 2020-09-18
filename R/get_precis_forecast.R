
#' Get BOM daily précis forecast for select towns from BOM
#'
#' Fetch the \acronym{BOM} daily précis forecast and return a data frame of the
#' seven-day town forecasts for a specified state or territory.
#'
#' @param state Australian state or territory as full name or postal code.
#' Fuzzy string matching via \code{\link[base]{agrep}} is done.  Defaults to
#' \dQuote{AUS} returning all state bulletins, see Details for more.
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
#' A \code{\link[data.table]{data.table}} of an Australia \acronym{BOM} précis
#' seven day forecasts for \acronym{BOM} selected towns.  For full details of
#' fields and units returned see Appendix 2 in the \CRANpkg{bomrang} vignette,
#' use\cr \code{vignette("bomrang", package = "bomrang")} to view.
#'
#' @examples
#' \donttest{
#' # get the short forecast for Queensland
#' BOM_forecast <- get_precis_forecast(state = "QLD")
#' BOM_forecast
#'}
#' @references
#' Forecast data come from Australian Bureau of Meteorology (\acronym{BOM})
#' Weather Data Services \cr
#' \url{http://www.bom.gov.au/catalogue/data-feeds.shtml}
#'
#' Location data and other metadata for towns come from
#' the \acronym{BOM} anonymous \acronym{FTP} server with spatial data \cr
#' \url{ftp://ftp.bom.gov.au/anon/home/adfd/spatial/}, specifically the
#' \acronym{DBF} file portion of a shapefile, \cr
#' \url{ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf}
#'
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com} and Keith Pembleton,
#'  \email{keith.pembleton@@usq.edu.au} and Paul Melloy,
#'  \email{paul@@melloy.com.au}
#'
#' @seealso \link{parse_precis_forecast}
#'
#' @export get_precis_forecast

get_precis_forecast <- function(state = "AUS") {

  # this is just a placeholder for functionality with parse_precis_forecast()
  filepath <- NULL

  the_state <- .check_states(state)
  location <- .validate_filepath(filepath)
  forecast_out <- .return_precis(location, the_state)

  return(forecast_out)
}


# Précis forecast functions for get() and parse()-------------------------------

#' Create précis forecast XML file paths/URLs
#'
#' @param location File location either a URL or local filepath provided by
#' \code{.validate_filepath()}
#'
#' @noRd
.return_precis <- function(file_loc, cleaned_state) {
  
  product_id <- probability_of_precipitation <- lower_precipitation_limit <- NULL
  
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
  if (cleaned_state != "AUS") {
    xml_url <- .create_bom_file(AUS_XML,
                                .the_state = cleaned_state,
                                .file_loc = file_loc)
    
    precis_out <- .parse_precis_forecast(xml_url)
    if (is.null(precis_out)) {
      return(invisible(NULL))
    }
    return(precis_out[])
  } else {
    file_list <- paste0(file_loc, "/", AUS_XML)
    precis_out <-
      lapply(X = file_list, FUN = .parse_precis_forecast)
    precis_out <- data.table::rbindlist(precis_out, fill = TRUE)
    return(precis_out[])
  }
}

#' extract the values of the precis forecast items
#'
#' @param y précis forecast xml_object
#'
#' @return a data.table of the forecast for cleaning and returning to user
#' @keywords internal
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#' @noRd

.parse_precis_forecast <- function(xml_url) {
  .SD <- #nocov start
    AAC_codes <-
    attrs <-
    end_time_local <-
    precipitation_range <-
    start_time_local <-
    values <-
    .N <-
    .I <-
    .GRP <-
    .BY <-
    .EACHI <-
    state <-
    product_id <-
    probability_of_precipitation <-
    start_time_utc <-
    end_time_utc <-
    upper_precipitation_limit <-
    lower_precipitation_limit <-
    forecast_icon_code <- NULL #nocov end
  
  # load the XML from ftp
  if (substr(xml_url, 1, 3) == "ftp") {
    xml_object <- .get_url(xml_url)
    if (is.null(xml_object)) {
      return(invisible(NULL))
    }
  } else {# load the XML from local
    xml_object <- xml2::read_xml(xml_url)
  }
  
  out <- .parse_precis_xml(xml_object)
  
  data.table::setnames(
    out,
    c("air_temperature_maximum",
      "air_temperature_minimum"),
    c("maximum_temperature",
      "minimum_temperature")
  )
  
  # clean up and split out time cols into offset and remove extra chars
  .split_time_cols(x = out)
  
  # merge with aac codes for location information
  load(system.file("extdata", "AAC_codes.rda", package = "bomrang"))  # nocov
  data.table::setkey(out, "aac")
  out <- AAC_codes[out, on = c("aac", "town")]
  
  # add state field
  out[, state := gsub("_.*", "", out$aac)]
  
  # add product ID field
  out[, product_id := substr(basename(xml_url),
                             1,
                             nchar(basename(xml_url)) - 4)]
  
  # remove unnecessary text from cols
  out[, probability_of_precipitation := gsub("%",
                                             "",
                                             probability_of_precipitation)]
  
  # handle precipitation ranges where they may or may not be present
  if ("precipitation_range" %in% colnames(out)) {
    # format any values that are only zero to make next step easier
    out[precipitation_range == "0 mm", precipitation_range := "0 to 0 mm"]
    
    # separate the precipitation column into two, upper/lower limit
    out[, c("lower_precipitation_limit",
            "upper_precipitation_limit") :=
          data.table::tstrsplit(precipitation_range,
                                "to",
                                fixed = TRUE)]
    
    out[, upper_precipitation_limit := gsub("mm",
                                            "",
                                            upper_precipitation_limit)]
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
    "utc_offset",
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
  # set col classes
  # factors
  out[, c(1, 11) := lapply(.SD, function(x)
    as.factor(x)),
    .SDcols = c(1, 11)]
  
  # numeric
  out[, c(6:8, 14:17, 19) := lapply(.SD, function(x)
    suppressWarnings(as.numeric(x))),
    .SDcols = c(6:8, 14:17, 19)]
  
  # dates
  out[, c(9:10) := lapply(.SD, function(x)
    as.POSIXct(x,
               origin = "1970-1-1",
               format = "%Y-%m-%d %H:%M:%OS")),
    .SDcols = c(9:10)]
  
  out[, c(12:13) := lapply(.SD, function(x)
    as.POSIXct(
      x,
      origin = "1970-1-1",
      format = "%Y-%m-%d %H:%M:%OS",
      tz = "GMT"
    )),
    .SDcols = c(12:13)]
  
  # character
  out[, c(2:5, 18) := lapply(.SD, function(x)
    as.character(x)),
    .SDcols = c(2:5, 18)]
  return(out)
}

#' extract the values of a coastal forecast item
#'
#' @param xml_object précis forecast xml_object
#'
#' @return a data.table of the forecast for further refining
#' @keywords internal
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#' @noRd

.parse_precis_xml <- function(xml_object) {
  forecast_icon_code <- NULL
  
  # get the actual forecast objects
  fp <- xml2::xml_find_all(xml_object, ".//forecast-period")
  
  locations_index <- data.table::data.table(
    # find all the aacs
    aac = xml2::xml_find_first(fp, ".//parent::area") %>%
      xml2::xml_attr("aac"),
    # find the names of towns
    town = xml2::xml_find_first(fp, ".//parent::area") %>%
      xml2::xml_attr("description"),
    # find corecast period index
    index = xml2::xml_attr(fp, "index"),
    start_time_local = xml2::xml_attr(fp, "start-time-local"),
    end_time_local = xml2::xml_attr(fp, "end-time-local"),
    start_time_utc = xml2::xml_attr(fp, "start-time-utc"),
    end_time_utc = xml2::xml_attr(fp, "end-time-utc")
  )
  
  vals <- lapply(fp, function(node) {
    # find names of all children nodes
    childnodes <- node %>%
      xml2::xml_children() %>%
      xml2::xml_name()
    # find the attr value from all child nodes
    names <- node %>%
      xml2::xml_children() %>%
      xml2::xml_attr("type")
    # create columns names based on either node name or attr value
    names <- ifelse(is.na(names), childnodes, names)
    
    # find all values
    values <- node %>%
      xml2::xml_children() %>%
      xml2::xml_text()
    
    # create data frame and properly label the columns
    df <- data.frame(t(values), stringsAsFactors = FALSE)
    names(df) <- names
    df
  })
  
  vals <- data.table::rbindlist(vals, fill = TRUE)
  sub_out <- cbind(locations_index, vals)
  # drop icon code
  sub_out[, forecast_icon_code := NULL]
  return(sub_out)
}
