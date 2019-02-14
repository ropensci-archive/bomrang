
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
#' Tidy \code{\link[base]{data.frame}} of a Australia \acronym{BOM} précis seven
#' day forecasts for select towns.  For full details of fields and units
#' returned see Appendix 2 in the \pkg{bomrang} vignette, use \cr
#' \code{vignette("bomrang", package = "bomrang")} to view.
#'
#' @examples
#' \donttest{
#' # get the short forecast for Queensland
#' BOM_forecast <- get_precis_forecast(state = "QLD")
#' BOM_forecast
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
#' @importFrom magrittr %>%
#' @export get_precis_forecast

get_precis_forecast <- function(state = "AUS") {
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
  AAC_codes <- attrs <- end_time_local <- precipitation_range <- # nocov start
    start_time_local <- values <- NULL # nocov end
  
  xml_object <- .get_xml(xml_url)
  
  areas <-
    xml2::xml_find_all(xml_object, ".//*[@type='location']")
  xml2::xml_find_all(areas, ".//*[@type='forecast_icon_code']") %>%
    xml2::xml_remove()
  
  out <- lapply(X = areas, FUN = .parse_areas)
  out <- as.data.frame(do.call("rbind", out))
  
  # This is the actual returned value for the main function. The functions
  # below chunk the xml into locations and then days, this assembles into
  # the final data frame
  
  out <- tidyr::spread(out, key = attrs, value = values)
  
  # tidy up names
  names(out) <- gsub("c\\(", "", names(out))
  names(out) <- gsub("\\)", "", names(out))
  
  out <- out %>%
    janitor::clean_names() %>%
    janitor::remove_empty("cols")
  
  out <-
    out %>%
    tidyr::separate(end_time_local,
                    into = c("end_time_local", "UTC_offset"),
                    sep = "\\+") %>%
    tidyr::separate(
      start_time_local,
      into = c("start_time_local", "UTC_offset_drop"),
      sep = "\\+"
    )
  
  # drop the "UTC_offset_drop" column
  out <- out[!names(out) %in% "UTC_offset_drop"]
  
  out$probability_of_precipitation <-
    gsub("%", "", paste(out$probability_of_precipitation))
  
  # remove the "T" from the date/time columns
  out[, c("start_time_local",
          "end_time_local",
          "start_time_utc",
          "end_time_utc")] <-
    apply(out[, c("start_time_local",
                  "end_time_local",
                  "start_time_utc",
                  "end_time_utc")], 2, function(x)
                    chartr("T", " ", x))
  
  # remove the "Z" from start_time_utc
  out[, c("start_time_utc",
          "end_time_utc")] <-
    apply(out[, c("start_time_utc",
                  "end_time_utc")], 2, function(x)
                    chartr("Z", " ", x))
  
  if ("precipitation_range" %in% colnames(out))
  {
    out[, "precipitation_range"] <-
      as.character(out[, "precipitation_range"])
    # format any values that are only zero to make next step easier
    out$precipitation_range[which(out$precipitation_range == "0 mm")] <-
      "0 mm to 0 mm"
    
    # separate the precipitation column into two, upper/lower limit ------------
    out <-
      out %>%
      tidyr::separate(
        precipitation_range,
        into = c(
          "lower_precipitation_limit",
          "upper_precipitation_limit"
        ),
        sep = "to",
        fill = "left"
      )
  } else {
    # if the columns don't exist insert as NA
    out$lower_precipitation_limit <- NA
    out$upper_precipitation_limit <- NA
    out <- out[, c(1:9, 13, 12, 10, 11)]
  }
  
  # remove unnecessary text (mm in prcp cols) ----------------------------------
  out <- as.data.frame(lapply(out, function(x) {
    gsub(" mm", "", x)
  }))
  
  # convert factors to character for left merge, otherwise funny stuff happens
  out[, seq_len(ncol(out))] <-
    lapply(out[, seq_len(ncol(out))], as.character)
  
  # convert dates to POSIXct format
  out[, c("start_time_local",
          "end_time_local",
          "start_time_utc",
          "end_time_utc")] <- lapply(out[, c("start_time_local",
                                             "end_time_local",
                                             "start_time_utc",
                                             "end_time_utc")],
                                     function(x)
                                       as.POSIXct(x,
                                                  origin = "1970-1-1",
                                                  format = "%Y-%m-%d %H:%M:%OS")
                                     )
  
  # convert numeric values to numeric
  out[, c(
    "type_air_temperature_maximum_units_celsius",
    "type_air_temperature_minimum_units_celsius",
    "lower_precipitation_limit",
    "upper_precipitation_limit",
    "probability_of_precipitation"
  )] <- lapply(out[, c(
    "type_air_temperature_maximum_units_celsius",
    "type_air_temperature_minimum_units_celsius",
    "lower_precipitation_limit",
    "upper_precipitation_limit",
    "probability_of_precipitation"
  )],
  as.numeric)
  
  # Load AAC code/town name list to join with final output
  load(system.file("extdata", "AAC_codes.rda", package = "bomrang"))  # nocov
  
  # return final forecast object -----------------------------------------------
  # merge with aac codes for location information
  tidy_df <-
    dplyr::left_join(out,
                     AAC_codes, by = c("aac" = "AAC"))
  
  # set names to match précis forecast
  names(tidy_df)[15:17] <- c("lon", "lat", "elev")
  
  # add state field
  tidy_df$state <- gsub("_.*", "", tidy_df$aac)
  
  # add product ID field
  tidy_df$product_id <- substr(basename(xml_url),
                               1,
                               nchar(basename(xml_url)) - 4)
  
  if (getRversion() < "3.5.0") {
    data.table::setnames(
      tidy_df,
      old = c(
        "PT_NAME",
        "air_temperature_maximum_celsius",
        "air_temperature_minimum_celsius"
      ),
      new = c("town",
              "maximum_temperature",
              "minimum_temperature")
    )
  } else {
    data.table::setnames(
      tidy_df,
      old = c(
        "PT_NAME",
        "type_air_temperature_maximum_units_celsius",
        "type_air_temperature_minimum_units_celsius"
      ),
      new = c("town",
              "maximum_temperature",
              "minimum_temperature")
    )
  }
  
  # reorder columns
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
  tidy_df <- tidy_df[c(refcols, setdiff(names(tidy_df), refcols))]
  
  # set factors
  tidy_df[, c(1, 11)] <- lapply(tidy_df[, c(1, 11)], as.factor)
  
  return(tidy_df)
}
