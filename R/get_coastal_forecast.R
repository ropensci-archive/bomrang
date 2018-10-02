#' Get BOM Coastal Waters Forecast
#'
#' Fetch the BOM daily Coastal Waters Forecast and return a tidy data frame of
#' the forecast regions for a specified state or region.
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
#' Tidy \code{\link[base]{data.frame}} of a Australia BOM Coastal Waters
#' Forecast.
#'
#' @examples
#' \donttest{
#' coastal_forecast <- get_coastal_forecast(state = "NSW")
#'}
#' @references
#' Forecast data come from Australian Bureau of Meteorology (BOM) Weather Data
#' Services \cr
#' \url{http://www.bom.gov.au/catalogue/data-feeds.shtml}
#'
#' Location data and other metadata come from
#' the BOM anonymous FTP server with spatial data \cr
#' \url{ftp://ftp.bom.gov.au/anon/home/adfd/spatial/}, specifically the DBF
#' file portion of a shapefile, \cr
#' \url{ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00003.dbf}
#'
#' @author Dean Marchiori, \email{deanmarchiori@@gmail.com}
#' @importFrom magrittr %>%
#' @export
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
    xmlforecast_url <-
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
    out <- .parse_coastal_forecast(xmlforecast_url)
  } else {
    file_list <- paste0(ftp_base, AUS_XML)
    out <- lapply(X = file_list, FUN = .parse_coastal_forecast)
    out <- as.data.frame(data.table::rbindlist(out, fill = TRUE))
  }
  return(out)
}

.parse_coastal_forecast <- function(xmlforecast_url) {
  # CRAN note avoidance
  AAC_codes <- marine_AAC_codes <- attrs <- end_time_local <- # nocov start
    precipitation_range <- start_time_local <- values <- NULL # nocov end

  # download the XML forecast
  tryCatch({
    xmlforecast <- xml2::read_xml(xmlforecast_url)
  },
  error = function(x)
    stop(
      "\nThe server with the forecast is not responding. ",
      "Please retry again later.\n"
    ))

  areas <- xml2::xml_find_all(xmlforecast, ".//*[@type='coast']")
  out <- suppressWarnings(lapply(X = areas, FUN = .parse_areas))
  out <- as.data.frame(do.call("rbind", out))

  out <- tidyr::spread(out, key = attrs, value = values)

  out <- out %>%
    janitor::clean_names(., case = "snake") %>%
    janitor::remove_empty("cols")

  out <- out %>%
    tidyr::separate(
      end_time_local,
      into = c("end_time_local", "UTC_offset"),
      sep = "\\+") %>%
    tidyr::separate(
      start_time_local,
      into = c("start_time_local", "UTC_offset_drop"),
      sep = "\\+")
  
  # drop the "UTC_offset_drop" column
  out <- out[!names(out) %in% "UTC_offset_drop"]

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

  # convert factors to character for left merge, otherwise funny stuff happens
  out[, seq_len(ncol(out))] <-
    lapply(out[, seq_len(ncol(out))], as.character)

  # convert dates to POSIXct format
  out[, c(3:4, 6:7)] <- lapply(out[, c(3:4, 6:7)],
                               function(x)
                                 as.POSIXct(x, origin = "1970-1-1",
                                            format = "%Y-%m-%d %H:%M:%OS"))

  # convert numeric values to numeric
  out[, 2] <- as.numeric(out[,2])

  # Load AAC code/town name list to join with final output
  load(system.file("extdata", "marine_AAC_codes.rda", package = "bomrang")) # nocov

  # return final forecast object -----------------------------------------------
  
  # merge with aac codes for location information
  tidy_df <-
    dplyr::left_join(out,
                     marine_AAC_codes, by = c("aac" = "AAC")) %>% 
    janitor::clean_names(., case = "snake")

  # add product ID field
  tidy_df$product_id <- substr(basename(xmlforecast_url),
                               1,
                               nchar(basename(xmlforecast_url)) - 4)
  
  # some fields only come out on special occasions, if absent, add as NA
  if(!"forecast_swell2" %in% colnames(tidy_df)) {
    tidy_df$forecast_swell2 <- NA
  }
  
  if(!"forecast_caution" %in% colnames(tidy_df)) {
    tidy_df$forecast_caution <- NA
  }
  
  if(!"marine_forecast" %in% colnames(tidy_df)) {
    tidy_df$marine_forecast <- NA
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
  
  # create factors
  tidy_df$index <- as.factor(tidy_df$index)
  
  tidy_df <- tidy_df[c(refcols, setdiff(names(tidy_df), refcols))]
  return(tidy_df)
}
