
"%||%" <- function(a, b) if (!is.null(a)) a else b

`%notin%` <- function(x, table) {
  match(x, table, nomatch = 0L) == 0L
}

.force_double <- function(v) {
  suppressWarnings(as.double(v))
}

#' Get response from a BOM URL
#'
#' Gets response from a BOM URL, checks the server for response first, then
#' tries to fetch the file or returns an informative message.
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
  
  USERAGENT <- paste0("{bomrang} R package (",
                      utils::packageVersion("bomrang"),
                      ") https://github.com/ropensci/bomrang")
  # set a custom user-agent, restore original settings on exit
  # required for #130 - BOM returns 403 for RStudio
  op <- options()
  on.exit(options(op))
  options(HTTPUserAgent = USERAGENT)
  
  # BOM's FTP server can timeout too quickly
  # Also, BOM's http server sometimes sends a http response of 200, "all good",
  # but then will not actually serve the requested file, so we want to set a max
  # time limit for the complete process to complete as well.
  h <- curl::new_handle()
  curl::handle_setopt(
    handle = h,
    FTP_RESPONSE_TIMEOUT = 60L,
    CONNECTTIMEOUT = 60L,
    TIMEOUT = 120L,
    USERAGENT = USERAGENT
  )
  
  try_GET <- function(x, ...) {
    tryCatch({
      response = curl::curl_fetch_memory(url = x, handle = h)
    },
    error = function(e)
      conditionMessage(e),
    warning = function(w)
      conditionMessage(w))
  }
  
  # a proper response will return a list class object
  # otherwise a timeout will just be a character string
  is_response <- function(x) {
    inherits(x, "list")
  }
  
  # First check Internet connection
  if (!curl::has_internet()) {
    stop(call. = FALSE,
         "No Internet connection.")
  }
  
  resp <- try_GET(x = remote_file)
  
  # check for possible timeout message and stop if that's the case
  if (!is_response(resp)) {
    stop(call. = FALSE,
         resp) # return char string value server provides
  }
  
  # Then stop if status indicates file not found
  if (as.integer(resp$status_code) == 404 |
      as.integer(resp$status_code) == 550) {
    stop(
      call. = FALSE,
      "\nA file or station was matched. However, a corresponding file was not ",
      "found at bom.gov.au.\n"
    )
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
  if (grepl(pattern = "dailyZippedDataFile", x = remote_file)) {
    csv_out <-
      data.table::fread(input = remote_file,
                        header = TRUE,
                        stringsAsFactors = TRUE)
    return(csv_out)
  }
}

# Distance over a great circle. Reasonable approximation.
.haversine_distance <- function(lat1, lon1, lat2, lon2) {
  # to radians
  lat1 <- lat1 * 0.01745
  lat2 <- lat2 * 0.01745
  lon1 <- lon1 * 0.01745
  lon2 <- lon2 * 0.01745
  
  delta_lat <- abs(lat1 - lat2)
  delta_lon <- abs(lon1 - lon2)
  
  # radius of earth
  12742 * asin(sqrt(`+`(
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
  .SD <- start_time_local <- end_time_local <- NULL
  
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
