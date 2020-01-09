
`%notin%` <- function(x, table) {
  match(x, table, nomatch = 0L) == 0L
}

# suppress messages for these special chars used in data.table
.SD <- .N <- .I <- .GRP <- .BY <- .EACHI <- NULL

.force_double <- function(v) {
  suppressWarnings(as.double(v))
}

# Distance over a great circle. Reasonable approximation.
.haversine_distance <- function(lat1, lon1, lat2, lon2) {
  # to radians
  lat1 <- lat1 * pi / 180
  lat2 <- lat2 * pi / 180
  lon1 <- lon1 * pi / 180
  lon2 <- lon2 * pi / 180
  
  delta_lat <- abs(lat1 - lat2)
  delta_lon <- abs(lon1 - lon2)
  
  # radius of earth
  6371 * 2 * asin(sqrt(`+`(
    (sin(delta_lat / 2)) ^ 2,
    cos(lat1) * cos(lat2) * (sin(delta_lon / 2)) ^ 2
  )))
}

#' @noRd
# Check if user enables caching. If so use cache directory, else use tempdir()
.set_cache <- function(cache) {
  if (isTRUE(cache)) {
    if (!dir.exists(manage_cache$cache_path_get())) {
      manage_cache$mkdir()
    }
    cache_dir <- manage_cache$cache_path_get()
  } else {
    cache_dir <- tempdir()
  }
  return(cache_dir)
}


#' @noRd
# Check states for précis and ag bulletin, use fuzzy matching

.check_states <- function(state) {
  state <- toupper(state)
  
  states <- c(
    "ACT",
    "NSW",
    "NT",
    "QLD",
    "SA",
    "TAS",
    "VIC",
    "WA",
    "CANBERRA",
    "NEW SOUTH WALES",
    "NORTHERN TERRITORY",
    "QUEENSLAND",
    "SOUTH AUSTRALIA",
    "TASMANIA",
    "VICTORIA",
    "WESTERN AUSTRALIA",
    "AUSTRALIA",
    "AU",
    "AUS",
    "OZ"
  )
  
  if (state %in% states) {
    the_state <- state
    return(the_state)
  } else {
    likely_states <- agrep(pattern = state,
                           x = states,
                           value = TRUE)
    
    if (length(likely_states) == 1) {
      the_state <- toupper(likely_states)
      message(
        paste0(
          "\nUsing state = ",
          likely_states,
          ".\n",
          "If this is not what you intended, please check your entry."
        )
      )
      return(the_state)
    } else if (length(likely_states) == 0) {
      stop(
        "\nA state or territory matching what you entered was not found. ",
        "Please check and try again.\n"
      )
    }
  }
  
  if (length(likely_states) > 1) {
    message(
      "Multiple states match state.",
      "'\ndid you mean:\n\tstate = '",
      paste(likely_states[1],
            "or",
            likely_states[2],
            "or",
            likely_states[3]),
      "'?"
    )
  }
}

#' convert_state
#'
#' Convert state to standard abbreviation
#' @noRd
.convert_state <- function(state) {
  state <- gsub(" ", "", state)
  state <-
    substring(gsub("[[:punct:]]", "", tolower(state)), 1, 2)
  
  state_code <- c(
    "NSW",
    "NSW",
    "VIC",
    "VIC",
    "QLD",
    "QLD",
    "QLD",
    "WA",
    "WA",
    "WA",
    "SA",
    "SA",
    "SA",
    "TAS",
    "TAS",
    "ACT",
    "NT",
    "NT"
  )
  state_names <- c(
    "ne",
    "ns",
    "vi",
    "v",
    "ql",
    "qe",
    "q",
    "wa",
    "we",
    "w",
    "s",
    "sa",
    "so",
    "ta",
    "t",
    "ac",
    "no",
    "nt"
  )
  state <- state_code[pmatch(state, state_names)]
  
  if (any(is.na(state)))
    stop("Unable to determine state")
  
  return(state)
}

#' Import BOM XML Files from Server Into R Session
#'
#' @param data_loc Location of XML file(s) to be downloaded/parsed/loaded.
#'
#' @return data loaded from the XML file
#' @keywords internal
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#' @noRd
.get_xml <- function(xml_url) {
  tryCatch({
    xml_object <- xml2::read_xml(x = xml_url)
  },
  error = function(x)
    stop(
      "\nThe server with the files is not responding. ",
      "Please retry again later.\n"
    ))
  return(xml_object)
}

#' splits time cols and removes extra chars for forecast XML objects
#'
#' @param x an object containing a BOM forecast object parsed from XML
#'
#' @return cleaned data.table cols of date and time
#' @keywords internal
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#' @importFrom data.table ":="
#' @noRd

.split_time_cols <- function(x) {
  start_time_local <- end_time_local <- NULL
  x[, c("start_time_local",
        "UTC_offset_drop") := data.table::tstrsplit(start_time_local,
                                                    "+",
                                                    fixed = TRUE)]
  
  x[, c("end_time_local",
        "utc_offset") := data.table::tstrsplit(end_time_local,
                                               "+",
                                               fixed = TRUE)]
  
  x[, "UTC_offset_drop" := NULL]
  
  # remove the "T" from time cols
  x[, c("start_time_local",
        "end_time_local",
        "start_time_utc",
        "end_time_utc") := lapply(.SD, gsub, pattern = "T",
                                  replacement = " "),
    .SDcols = c("start_time_local",
                "end_time_local",
                "start_time_utc",
                "end_time_utc")]
  
  # remove the "Z" from UTC cols
  x[, c("start_time_utc", "end_time_utc") := lapply(.SD, gsub, pattern = "Z",
                                                    replacement = ""),
    .SDcols = c("start_time_utc", "end_time_utc")]
  return(x)
}

#' Validate user entered filepath value or return BOM URL
#'
#' @param filepath User provided value for checking
#'
#' @noRd
.validate_filepath <- function(filepath) {
  if (is.null(filepath)) {
    location <- "ftp://ftp.bom.gov.au/anon/gen/fwo"
    return(location)
  } else {
    location <- trimws(filepath)
    if (!file.exists(location)) {
      stop("\nDirector does not exist: ", filepath,
           call. = FALSE)
    } else if (tolower(tools::file_ext(location)) == "xml") {
      stop("\nYou have provided a file, not a directory containing a file.",
           call. = FALSE)
    }
    return(location)
  }
}

#' Create précis forecast XML file paths/URLs
#'
#' @param location File location either a URL or local filepath provided by
#' \code{.validate_filepath()}
#'
#' @noRd
.return_precis <- function(file_loc, the_state) {
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
          the_state == "CANBERRA" ~ paste0(file_loc, "/", AUS_XML[1]),
        the_state == "NSW" |
          the_state == "NEW SOUTH WALES" ~ paste0(file_loc, "/", AUS_XML[1]),
        the_state == "NT" |
          the_state == "NORTHERN TERRITORY" ~ paste0(file_loc, "/", AUS_XML[2]),
        the_state == "QLD" |
          the_state == "QUEENSLAND" ~ paste0(file_loc, "/", AUS_XML[3]),
        the_state == "SA" |
          the_state == "SOUTH AUSTRALIA" ~ paste0(file_loc, "/", AUS_XML[4]),
        the_state == "TAS" |
          the_state == "TASMANIA" ~ paste0(file_loc, "/", AUS_XML[5]),
        the_state == "VIC" |
          the_state == "VICTORIA" ~ paste0(file_loc, "/", AUS_XML[6]),
        the_state == "WA" |
          the_state == "WESTERN AUSTRALIA" ~ paste0(file_loc, "/", AUS_XML[7])
      )
    precis_out <- .parse_forecast(.file_loc = xml_url)
    return(precis_out[])
  } else {
    file_list <- paste0(file_loc, AUS_XML)
    precis_out <- lapply(X = file_list, FUN = .parse_forecast)
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

.parse_forecast <- function(.file_loc) {
  # CRAN note avoidance
  AAC_codes <- # nocov start
    attrs <- end_time_local <- precipitation_range <-
    start_time_local <-
    values <-  .SD <- .N <- .I <- .GRP <- .BY <- .EACHI <-
    state <-
    product_id <- probability_of_precipitation <- start_time_utc <-
    end_time_utc <-
    upper_precipitation_limit <- lower_precipitation_limit <-
    NULL # nocov end
  
  xml_object <- .get_xml(.file_loc)
  
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
  #
  # add state field
  out[, state := gsub("_.*", "", out$aac)]
  
  # add product ID field
  out[, product_id := substr(basename(.file_loc),
                             1,
                             nchar(basename(.file_loc)) - 4)]
  
  # remove unnecessary text from cols
  out[, probability_of_precipitation := gsub("%",
                                             "",
                                             probability_of_precipitation)]
  
  # handle precipitation ranges where they may or may not be present
  if ("precipitation_range" %in% colnames(out))
  {
    # format any values that are only zero to make next step easier
    out[precipitation_range == "0 mm", precipitation_range := "0 to 0 mm"]
    
    # separate the precipitation column into two, upper/lower limit
    out[, c("lower_precipitation_limit",
            "upper_precipitation_limit") :=
          data.table::tstrsplit(precipitation_range,
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
