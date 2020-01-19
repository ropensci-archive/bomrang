
`%notin%` <- function(x, table) {
  match(x, table, nomatch = 0L) == 0L
}

# suppress messages for these special chars used in data.table
.SD <- .N <- .I <- .GRP <- .BY <- .EACHI <- NULL

.force_double <- function(v) {
  suppressWarnings(as.double(v))
}

#' Get response from a BOM URL
#'
#' Gets response from a BOM URL, checks for response first, then
#' tries to fetch the data or returns an informatative message, failing
#' gracefully per CRAN policies.
#'
#' @param remote_file file resource being requested from BOM
#'
#' @details Original execution came from
#' <https://community.rstudio.com/t/internet-resources-should-fail-gracefully/49199/12>
#'
#' @author Adam H. Sparks, adamhsparks@@gmail.com
#' @noRd
#'
.get_url <- function(remote_file) {
  try_GET <- function(x, ...) {
    tryCatch({
      response = curl::curl_fetch_memory(url = x,
                                         handle = curl::new_handle())
    },
    error = function(e)
      conditionMessage(e),
    warning = function(w)
      conditionMessage(w))
  }
  # a proper response will return a list class object
  # otherwise a timeout will just be a character string
  is_response <- function(x) {
    class(x) == "list"
  }
  
  # First check internet connection
  if (!curl::has_internet()) {
    message("No Internet connection.")
    return(invisible(NULL))
  }
  
  resp <- try_GET(x = remote_file)
  # Then stop if status > 400
  if (as.integer(resp$status_code) == 404) {
    stop(
      call. = FALSE,
      "\nA file or station was matched. However, a corresponding file was not ",
      "found at bom.gov.au.\n"
    )
  } # Then check for timeout problems
  if (!is_response(resp)) {
    message(resp) # return char string value server provides
    return(invisible(NULL))
  }
  
  if (tools::file_ext(remote_file) == "xml") {
    xml_out <- xml2::read_xml(rawToChar(resp$content))
    return(xml_out)
  }
  if (tools::file_ext(remote_file) == "json") {
    json_out <-
      jsonlite::fromJSON(rawToChar(resp$content))
    return(json_out)
  }
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
    "AUS",
    "AUS",
    "AUS",
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
    "au",
    "oz",
    "as",
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
      stop("\nDirectory does not exist: ", filepath,
           call. = FALSE)
    } else if (tolower(tools::file_ext(location)) == "xml") {
      stop("\nYou have provided a file, not a directory containing a file.",
           call. = FALSE)
    }
    return(location)
  }
}

#' Create the base URL/file location of BOM files for all XML functions
#'
#' Takes the XML file name and creates the full file path or URL
#'
#' @param AUS_XML a vector of XML file names for BOM products
#' @param the_state user provided state argument for requested data
#'
#' @noRd

.create_bom_file <- function(AUS_XML, .the_state, .file_loc) {
  if (.the_state != "AUS") {
    xml_url <-
      dplyr::case_when(
        .the_state == "ACT" |
          .the_state == "CANBERRA" ~ paste0(.file_loc, "/", AUS_XML[1]),
        .the_state == "NSW" |
          .the_state == "NEW SOUTH WALES" ~ paste0(.file_loc, "/", AUS_XML[1]),
        .the_state == "NT" |
          .the_state == "NORTHERN TERRITORY" ~ paste0(.file_loc,
                                                      "/", AUS_XML[2]),
        .the_state == "QLD" |
          .the_state == "QUEENSLAND" ~ paste0(.file_loc, "/", AUS_XML[3]),
        .the_state == "SA" |
          .the_state == "SOUTH AUSTRALIA" ~ paste0(.file_loc, "/", AUS_XML[4]),
        .the_state == "TAS" |
          .the_state == "TASMANIA" ~ paste0(.file_loc, "/", AUS_XML[5]),
        .the_state == "VIC" |
          .the_state == "VICTORIA" ~ paste0(.file_loc, "/", AUS_XML[6]),
        .the_state == "WA" |
          .the_state == "WESTERN AUSTRALIA" ~ paste0(.file_loc, "/", AUS_XML[7])
      )
  }
  return(xml_url)
}

# Précis forecast functions for get() and parse()-------------------------------

#' Create précis forecast XML file paths/URLs
#'
#' @param location File location either a URL or local filepath provided by
#' \code{.validate_filepath()}
#'
#' @noRd
.return_precis <- function(file_loc, cleaned_state) {
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
  # CRAN note avoidance
  AAC_codes <- # nocov start
    attrs <- end_time_local <- precipitation_range <- start_time_local <-
    values <-  .SD <- .N <- .I <- .GRP <- .BY <- .EACHI <- state <-
    product_id <- probability_of_precipitation <- start_time_utc <-
    end_time_utc <- upper_precipitation_limit <- lower_precipitation_limit <-
    NULL # nocov end
  
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
  #
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

# Ag bulletin functions for get() and parse() ----------------------------------
.return_bulletin <- function(file_loc, cleaned_state) {
  # create vector of XML files
  AUS_XML <- c(
    "IDN65176.xml",
    # NSW
    "IDD65176.xml",
    # NT
    "IDQ60604.xml",
    # QLD
    "IDS65176.xml",
    # SA
    "IDT65176.xml",
    # TAS
    "IDV65176.xml",
    # VIC
    "IDW65176.xml"  # WA
  )
  if (cleaned_state != "AUS") {
    xml_url <- .create_bom_file(AUS_XML,
                                .the_state = cleaned_state,
                                .file_loc = file_loc)
    
    bulletin_out <- .parse_bulletin(xml_url)
    if (is.null(bulletin_out)) {
      return(invisible(NULL))
    }
    return(bulletin_out[])
  } else {
    file_list <- paste0(file_loc, "/", AUS_XML)
    bulletin_out <-
      lapply(X = file_list, FUN = .parse_bulletin)
    bulletin_out <- data.table::rbindlist(bulletin_out, fill = TRUE)
    return(bulletin_out[])
  }
}

#' @noRd
.parse_bulletin <- function(xml_url) {
  # CRAN NOTE avoidance
  stations_site_list <-
    site <- obs_time_local <- obs_time_utc <- r <- NULL # nocov
  
  # load the XML from ftp
  if (substr(xml_url, 1, 3) == "ftp") {
    xml_object <- .get_url(xml_url)
    if (is.null(xml_object)) {
      return(invisible(NULL))
    }
  } else {# load the XML from local
    xml_object <- xml2::read_xml(xml_url)
  }
  
  # get definitions (and all possible value fields to check against)
  definition_attrs <- xml2::xml_find_all(xml_object, "//data-def")
  definition_attrs <- xml2::xml_attrs(definition_attrs)
  definition_attrs <-
    lapply(definition_attrs, function(x)
      x[[1]][[1]])
  
  # get the actual observations and create a data table
  observations <- xml2::xml_find_all(xml_object, ".//d")
  
  out <- data.table::data.table(
    obs_time_local = xml2::xml_find_first(observations, ".//ancestor::obs") %>%
      xml2::xml_attr("obs-time-local"),
    obs_time_utc = xml2::xml_find_first(observations, ".//ancestor::obs") %>%
      xml2::xml_attr("obs-time-utc"),
    time_zone = xml2::xml_find_first(observations, ".//ancestor::obs") %>%
      xml2::xml_attr("time-zone"),
    site =  xml2::xml_find_first(observations, ".//ancestor::obs") %>%
      xml2::xml_attr("site"),
    station = xml2::xml_find_first(observations, ".//ancestor::obs") %>%
      xml2::xml_attr("station"),
    observation = observations %>% xml2::xml_attr("t"),
    values = observations %>% xml2::xml_text("t"),
    product_id = substr(basename(xml_url),
                        1,
                        nchar(basename(xml_url)) - 4)
  )
  
  out <- data.table::dcast(
    out,
    product_id + obs_time_local + obs_time_utc + time_zone + site + station ~
      observation,
    value.var = "values"
  )
  
  # check that all fields are present, if not add missing col with NAs
  missing <-
    setdiff(unlist(definition_attrs), names(out[, -c(1:5)]))
  if (length(missing) != 0) {
    out[, eval(missing) := NA]
  }
  
  # remove leading 0 to merge with stations_site_list
  out[, site := gsub("^0{1,2}", "", out$site)]
  
  # merge with AAC codes
  # load AAC code/town name list to join with final output
  load(system.file("extdata", "stations_site_list.rda", # nocov
                   package = "bomrang")) # nocov
  data.table::setDT(stations_site_list)
  data.table::setkey(stations_site_list, "site")
  data.table::setkey(out, "site")
  out <- stations_site_list[out, on = "site"]
  
  # tidy up the cols
  refcols <- c(
    "product_id",
    "state",
    "dist",
    "name",
    "wmo",
    "site",
    "station",
    "obs_time_local",
    "obs_time_utc",
    "time_zone",
    "lat",
    "lon",
    "elev",
    "bar_ht",
    "start",
    "end",
    "r",
    "tn",
    "tx",
    "twd",
    "ev",
    "tg",
    "sn",
    "solr",
    "t5",
    "t10",
    "t20",
    "t50",
    "t1m",
    "wr"
  )
  
  # set col classes
  # factor
  out[, c(1:3, 11:12) := lapply(.SD, function(x)
    as.factor(x)),
    .SDcols = c(1:3, 11:12)]
  
  # dates
  out[, obs_time_local := gsub("T", " ", obs_time_local)]
  out[, obs_time_utc := gsub("T", " ", obs_time_utc)]
  out[, c(13:14) := lapply(.SD, function(x)
    as.POSIXct(x,
               origin = "1970-1-1",
               format = "%Y%m%d %H%M")),
    .SDcols = c(13:14)]
  
  # set "Tce" to 0.01
  out[, r := gsub("Tce", "0.01", r)]
  
  # set numeric cols
  out[, c(4:7, 9:10, 17:30) := lapply(.SD, as.numeric), 
                                     .SDcols = c(4:7, 9:10, 17:30)]
  
  data.table::setcolorder(out, refcols)
  
  # return from main function
  return(out)
}

# Coastal forecast functions for get() and parse()------------------------------

.return_coastal <- function(file_loc, cleaned_state) {
  # create vector of XML files
  AUS_XML <- c(
    "IDN11001.xml",
    # NSW
    "IDD11030.xml",
    # NT
    "IDQ11290.xml",
    # QLD
    "IDS11072.xml",
    # SA
    "IDT12329.xml",
    # TAS
    "IDV10200.xml",
    # VIC
    "IDW11160.xml"  # WA
  )
  if (cleaned_state != "AUS") {
    xml_url <- .create_bom_file(AUS_XML,
                                .the_state = cleaned_state,
                                .file_loc = file_loc)
    
    coastal_out <- .parse_coastal_forecast(xml_url)
    if (is.null(coastal_out)) {
      return(invisible(NULL))
    }
    return(coastal_out[])
  } else {
    file_list <- paste0(file_loc, "/", AUS_XML)
    coastal_out <-
      lapply(X = file_list, FUN = .parse_coastal_forecast)
    coastal_out <- data.table::rbindlist(coastal_out, fill = TRUE)
    return(coastal_out[])
  }
}

.parse_coastal_forecast <- function(xml_url) {
  # CRAN note avoidance
  AAC_codes <-
    marine_AAC_codes <- attrs <- end_time_local <- # nocov start
    precipitation_range <-
    start_time_local <- values <- product_id <-
    forecast_swell2 <- forecast_caution <- marine_forecast <-
    state_code <-
    tropical_system_location <- forecast_waves <- NULL # nocov end
  
  # load the XML from ftp
  if (substr(xml_url, 1, 3) == "ftp") {
    xml_object <- .get_url(xml_url)
    if (is.null(xml_object)) {
      return(invisible(NULL))
    }
  } else {# load the XML from local
    xml_object <- xml2::read_xml(xml_url)
  }
  
  out <- .parse_coastal_xml(xml_object)
  
  # clean up and split out time cols into offset and remove extra chars
  .split_time_cols(x = out)
  
  # merge with aac codes for location information
  load(system.file("extdata",
                   "marine_AAC_codes.rda",
                   package = "bomrang"))  # nocov
  data.table::setkey(out, "aac")
  out <- marine_AAC_codes[out, on = c("aac", "dist_name")]
  
  # add state field
  out[, state_code := gsub("_.*", "", out$aac)]
  
  # return final forecast object
  
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
  
  if (!"tropical_system_location" %in% colnames(out)) {
    out[, tropical_system_location := NA]
  }
  
  if (!"forecast_waves" %in% colnames(out)) {
    out[, forecast_waves := NA]
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
    "marine_forecast",
    "tropical_system_location",
    "forecast_waves"
  )
  
  data.table::setcolorder(out, refcols)
  
  # set col classes
  # factors
  out[, c(1, 11) := lapply(.SD, function(x)
    as.factor(x)),
    .SDcols = c(1, 11)]
  
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
  out[, c(6:8, 14:20) := lapply(.SD, function(x)
    as.character(x)),
    .SDcols = c(6:8, 14:20)]
  
  return(out)
}

#' extract the values of a coastal forecast item
#'
#' @param xml_object coastal forecast xml_object
#'
#' @return a data.table of the forecast for further refining
#' @keywords internal
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#' @noRd

.parse_coastal_xml <- function(xml_object) {
  tropical_system_location <-
    forecast_waves <- synoptic_situation <-  # nocov start
    preamble <- warning_summary_footer <- product_footer <-
    postamble <- NULL  # nocov end
  
  # get the actual forecast objects
  meta <- xml2::xml_find_all(xml_object, ".//text")
  fp <- xml2::xml_find_all(xml_object, ".//forecast-period")
  
  locations_index <- data.table::data.table(
    # find all the aacs
    aac = xml2::xml_parent(meta) %>%
      xml2::xml_find_first(".//parent::area") %>%
      xml2::xml_attr("aac"),
    # find the names of towns
    dist_name = xml2::xml_parent(meta) %>%
      xml2::xml_find_first(".//parent::area") %>%
      xml2::xml_attr("description"),
    # find corecast period index
    index = xml2::xml_parent(meta) %>%
      xml2::xml_find_first(".//parent::forecast-period") %>%
      xml2::xml_attr("index"),
    start_time_local = xml2::xml_parent(meta) %>%
      xml2::xml_find_first(".//parent::forecast-period") %>%
      xml2::xml_attr("start-time-local"),
    end_time_local = xml2::xml_parent(meta) %>%
      xml2::xml_find_first(".//parent::forecast-period") %>%
      xml2::xml_attr("start-time-local"),
    start_time_utc = xml2::xml_parent(meta) %>%
      xml2::xml_find_first(".//parent::forecast-period") %>%
      xml2::xml_attr("start-time-local"),
    end_time_utc = xml2::xml_parent(meta) %>%
      xml2::xml_find_first(".//parent::forecast-period") %>%
      xml2::xml_attr("start-time-local")
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
  
  if ("synoptic_situation" %in% names(sub_out)) {
    sub_out[, synoptic_situation := NULL]
  }
  
  if ("preamble" %in% names(sub_out)) {
    sub_out[, preamble := NULL]
  }
  
  if ("warning_summary_footer" %in% names(sub_out)) {
    sub_out[, warning_summary_footer := NULL]
  }
  
  if ("product_footer" %in% names(sub_out)) {
    sub_out[, product_footer := NULL]
  }
  
  if ("postamble" %in% names(sub_out)) {
    sub_out[, postamble := NULL]
  }
  
  return(sub_out)
}
