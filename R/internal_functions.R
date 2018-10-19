
`%notin%` <- function(x, table) {
  # Same as !(x %in% table)
  match(x, table, nomatch = 0L) == 0L
}

force_double <- function(v) {
  suppressWarnings(as.double(v))
}

# Distance over a great circle. Reasonable approximation.
haversine_distance <- function(lat1, lon1, lat2, lon2) {
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
  states <- c(
    "ACT",
    "NSW",
    "NT",
    "QLD",
    "SA",
    "TAS",
    "VIC",
    "WA",
    "Canberra",
    "New South Wales",
    "Northern Territory",
    "Queensland",
    "South Australia",
    "Tasmania",
    "Victoria",
    "Western Australia",
    "Australia",
    "AU",
    "AUS",
    "Oz"
  )

  if (state %in% states) {
    the_state <- toupper(state)
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
        "\nA state or territory matching what you entered was not found.",
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
convert_state <- function(state) {
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

#' Parse areas for précis forecasts
#'
#' @param x a précis forecast object
#'
#' @return a data.frame of forecast areas and aac codes
#' @keywords internal
#' @author Adam H Sparks, \email{adamhspark@@s@gmail.com}
#' @noRd

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

#' Get latest historical station metadata
#'
#' Fetches BOM metadata for checking historical record availability. Also can be
#' used to return the metadata if user desires.
#'
#' @md
#'
#' @return A data frame of metadata for BOM historical records
#' @keywords internal
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#' @noRd

.get_ncc <- function() {
  
  # CRAN NOTE avoidance
  site <- name <- lat <- lon <- start_month <- #nocov start
    start_year <- end_month <- end_year <- years <- percent <- AWS <-
    start <- end <- ncc_obs_code <- site <- NULL #nocov end
  
  base_url <- "http://www.bom.gov.au/climate/data/lists_by_element/"
  
  rain <- paste0(base_url, "alphaAUS_136.txt")
  tmax <- paste0(base_url, "alphaAUS_122.txt")
  tmin <- paste0(base_url, "alphaAUS_123.txt")
  solar <- paste0(base_url, "alphaAUS_193.txt")
  
  weather <- c(rain, tmax, tmin, solar)
  names(weather) <- c("rain", "tmax", "tmin", "solar")
  
  ncc_codes <- vector(mode = "list", length = length(weather))
  names(ncc_codes) <- names(weather)
  
  for (i in seq_along(weather)) {
    ncc_obs_code <- substr(weather[i],
                           nchar(weather[i]) - 6,
                           nchar(weather[i]) - 4)

    ncc <-
      readr::read_table(
        weather[i],
        skip = 4,
        col_names = c(
          "site",
          "name",
          "lat",
          "lon",
          "start_month",
          "start_year",
          "end_month",
          "end_year",
          "years",
          "percent",
          "AWS"
        ),
        col_types = c(
          site = readr::col_integer(),
          name = readr::col_character(),
          lat = readr::col_double(),
          lon = readr::col_double(),
          start_month = readr::col_character(),
          start_year = readr::col_character(),
          end_month = readr::col_character(),
          end_year = readr::col_character(),
          years = readr::col_double(),
          percent = readr::col_integer(),
          AWS = readr::col_character()
        ),
        na = ""
      )
    
    # trim the end of the rows off that have extra info that's not in columns
    nrows <- nrow(ncc) - 7
    ncc <- ncc[1:nrows, ]
    
    # unite month and year, convert to a date and add ncc_obs_code
    ncc <- 
      ncc %>% 
      tidyr::unite(start, start_month, start_year, sep = "-") %>% 
      tidyr::unite(end, end_month, end_year, sep = "-") %>% 
      dplyr::mutate(start = lubridate::dmy(paste0("01-", start))) %>% 
      dplyr::mutate(end = lubridate::dmy(paste0("01-", end))) %>% 
      dplyr::mutate(ncc_obs_code = ncc_obs_code)
    
    ncc_codes[[i]] <- ncc
  }
  dplyr::bind_rows(ncc_codes)
}

#' Identify URL of historical observations resources
#'
#' BOM data is available via URL endpoints but the arguments are not (well)
#' documented. This function first obtains an auxilliary data file for the given
#' station/measurement type which contains the remaining value `p_c`. It then
#' constructs the approriate resource URL.
#'
#' @md
#' @param site site ID.
#' @param code measurement type. See internals of [get_historical].
#' @importFrom httr GET content
#'
#' @return URL of the historical observation resource
#' @keywords internal
#' @author Jonathan Carroll, \email{rpkg@@jcarroll.com.au}
#' @noRd
.get_zip_url <- function(site, code = 122) {
  url1 <-
    paste0(
      "http://www.bom.gov.au/jsp/ncc/cdio/weatherData/av?p_stn_num=",
      site,
      "&p_display_type=availableYears&p_nccObsCode=",
      code
    )
  raw <- httr::content(httr::GET(url1), "text")
  if (grepl("BUREAU FOOTER", raw))
    stop("Error in retrieving resource identifiers.")
  pc <- sub("^.*:", "", raw)
  url2 <-
    paste0(
      "http://www.bom.gov.au/jsp/ncc/cdio/weatherData/av?p_display_type=dailyZippedDataFile&p_stn_num=",
      site,
      "&p_c=",
      pc,
      "&p_nccObsCode=",
      code
    )
  url2
}

#' Download a BOM Data .zip File and Load into Session
#'
#' @param url URL of zip file to be downloaded/extracted/loaded.
#'
#' @return data loaded from the zip file
#' @keywords internal
#' @author Jonathan Carroll, \email{rpkg@@jcarroll.com.au}
#' @noRd
.get_zip_and_load <- function(url) {
  tmp <- tempfile(fileext = ".zip")
  curl::curl_download(url, tmp, mode = "wb", quiet = TRUE)
  zipped <- utils::unzip(tmp, exdir = dirname(tmp))
  unlink(tmp)
  datfile <- grep("Data.csv", zipped, value = TRUE)
  message("Data saved as ", datfile)
  dat <- utils::read.csv(datfile, header = TRUE)
  dat
}
