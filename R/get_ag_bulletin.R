
#' Get BoM Agriculture Bulletin Information for Select Stations
#'
#'Fetch the BoM agricultural bulletin information and return a tidy data frame
#'
#' @param state Australian state or territory as full name or postal code.
#' Fuzzy string matching via \code{base::agrep} is done.  Defaults to "AUS"
#' returning all state bulletins, see details for more.
#'
#' @details Allowed state and territory postal codes, only one state per request
#' or all using \code{AUS}.
#'  \describe{
#'    \item{NSW}{New South Wales}
#'    \item{NT}{Northern Territory}
#'    \item{QLD}{Queensland}
#'    \item{SA}{South Australia}
#'    \item{TAS}{Tasmania}
#'    \item{VIC}{Victoria}
#'    \item{WA}{Western Australia}
#'    \item{AUS}{Australia, returns bulletin for all states and NT}
#'  }
#'
#' @return
#' Tidy data frame of a Australia BoM agricultural bulletin information.  For
#' full details of fields and units returned see Appendix 3 in the
#' \emph{bomrang} vignette, use \code{vignette("bomrang", package = "bomrang")}
#' to view.
#'
#' @examples
#' \dontrun{
#' ag_bulletin <- get_ag_bulletin(state = "QLD")
#' }
#' @author Adam H Sparks, \email{adamhsparks@gmail.com}
#'
#' @references
#' Agricultural observations are retrieved from the Australian Bureau of
#' Meteorology (BoM) Weather Data Services Agriculture Bulletins,
#' \url{http://www.bom.gov.au/catalogue/observations/about-agricultural.shtml}
#'
#'and
#'
#' Australian Bureau of Meteorology (BoM) Weather Data Services Observation of
#' Rainfall,
#' \url{http://www.bom.gov.au/climate/how/observations/rain-measure.shtml}
#'
#' Station location and other metadata are sourced from the Australian Bureau of
#' Meteorology (BoM) webpage, Bureau of Meteorology Site Numbers:
#' \url{http://www.bom.gov.au/climate/cdo/about/site-num.shtml}
#'
#' @export
get_ag_bulletin <- function(state = "AUS") {

  # CRAN NOTE avoidance
  stations_site_list <- NULL

  # Load AAC code/town name list to join with final output
  load(system.file("extdata", "stations_site_list.rda", package = "bomrang"))

  states <- c(
    "NSW",
    "NT",
    "QLD",
    "SA",
    "TAS",
    "VIC",
    "WA",
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

  # If there's an exact match, use it; else, attempt partial match.
  if (state %in% states) {
    the_state <- state
  } else {
    likely_states <- agrep(pattern = state,
                           x = states,
                           value = TRUE)

    if (length(likely_states) == 0) {
      stop(
        "\nA state or territory matching what you entered was not found.",
        "Please check and try again.\n"
      )
    }

    the_state <- likely_states[1]

    if (length(likely_states) > 1) {
      warning(
        "Multiple states match state.",
        "'\ndid you mean:\n\tstate = '",
        paste(
          likely_states[[1]],
          "or",
          likely_states[length(likely_states) - 1],
          "or",
          likely_states[length(likely_states)]
        ),
        "'?"
      )
    }
  }

  # ftp server
  ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/fwo/"

  # State/territory bulletin files
  NT  <- "IDD65176.xml"
  NSW <- "IDN65176.xml"
  QLD <- "IDQ60604.xml"
  SA  <- "IDS65176.xml"
  TAS <- "IDT65176.xml"
  VIC <- "IDV65176.xml"
  WA  <- "IDW65176.xml"

  switch(
    the_state,
    "ACT" = {
      xmlbulletin_url <-
        paste0(ftp_base, NSW) # nsw
    },
    "NSW" = {
      xmlbulletin_url <-
        paste0(ftp_base, NSW) # nsw
    },
    "NT" = {
      xmlbulletin_url <-
        paste0(ftp_base, NT) # nt
    },
    "QLD" = {
      xmlbulletin_url <-
        paste0(ftp_base, QLD) # qld
    },
    "SA" = {
      xmlbulletin_url <-
        paste0(ftp_base, SA) # sa
    },
    "TAS" = {
      xmlbulletin_url <-
        paste0(ftp_base, TAS) # tas
    },
    "VIC" = {
      xmlbulletin_url <-
        paste0(ftp_base, VIC) # vic
    },
    "WA" = {
      xmlbulletin_url <-
        paste0(ftp_base, WA) # wa
    },
    "AUS" = {
      AUS <- list(NT, NSW, QLD, SA, TAS, VIC, WA)
      file_list <- paste0(ftp_base, AUS)
    },
    stop(state, " not recognised as a valid state or territory")
  )

  if (the_state != "AUS") {
    .parse_bulletin(xmlbulletin_url, stations_site_list)
  }

  else if (the_state == "AUS") {
    out <-
      lapply(X = file_list, FUN = .parse_bulletin, stations_site_list)
    out <- as.data.frame(data.table::rbindlist(out))
  }
}

#' @noRd
.parse_bulletin <- function(xmlbulletin_url, stations_site_list) {
  # CRAN NOTE avoidance
  obs.time.utc <- obs.time.local <- time.zone <- site <- r <- tn <-
    tx <- end <- station <- twd <- ev <- obs_time_utc <- obs_time_local <-
    time_zone <- state <- tg <- sn <- t5 <- t10 <- t20 <- t50 <- t1m <- wr <-
    lat <- lon <- attrs <- dist <- start <- elev <- bar_ht <- wmo <-
    product_id <- full_name <- name <- NULL

  # load the XML bulletin ------------------------------------------------------

  tryCatch({
    xmlbulletin <- xml2::read_xml(xmlbulletin_url)
  },
  error = function(x)
    stop(
      "\nThe server with the bulletin files is not responding.",
      "Please retry again later.\n"
    ))
  obs <- xml2::xml_find_all(xmlbulletin, "//obs")

  tidy_df <- lapply(X = obs, FUN = .get_obs)
  tidy_df <- do.call("rbind", tidy_df)
  tidy_df$product_id <- substr(basename(xmlbulletin_url),
                               1,
                               nchar(basename(xmlbulletin_url)) - 4)

  tidy_df <- dplyr::left_join(tidy_df,
                              stations_site_list,
                              by = c("site" = "site"))

  tidy_df <-
    tidy_df %>%
    dplyr::mutate_at(tidy_df, .funs = as.character, .vars = "time.zone") %>%
    dplyr::rename(
      obs_time_local = obs.time.local,
      obs_time_utc = obs.time.utc,
      time_zone = time.zone,
      full_name = name
    )

  tidy_df <-
    dplyr::select(
      tidy_df,
      product_id,
      state,
      dist,
      wmo,
      site,
      station,
      full_name,
      obs_time_local,
      obs_time_utc,
      time_zone,
      lat,
      lon,
      elev,
      bar_ht,
      start,
      end,
      r,
      tn,
      tx,
      twd,
      ev,
      tg,
      sn,
      t5,
      t10,
      t20,
      t50,
      t1m,
      wr
    )

  # convert dates to POSIXct ---------------------------------------------------
  tidy_df[, c("obs_time_local", "obs_time_utc")] <-
    lapply(tidy_df[, c("obs_time_local", "obs_time_utc")], function(x)
      as.POSIXct(x, origin = "1970-1-1", format = "%Y-%m-%d %H:%M:%OS"))

  # return from main function
  return(tidy_df)
}

# get the data from observations ---------------------------------------------
.get_obs <- function(x) {
  d <- xml2::xml_children(x)

  # location/site information
  location <- unlist(t(as.data.frame(xml2::xml_attrs(x))))

  # actual weather related data
  value <- unlist(as.character(xml2::xml_contents(d)))
  value[value == "Tce"] <- 0.01
  value <- as.numeric(value)
  attrs <- unlist(as.character(xml2::xml_attrs(d)))

  # in some cases a station reports nothing
  if (length(value) == 0) {
    value <- NA
  }
  if (length(attrs) == 0) {
    attrs <- NA
  }

  # if there are no observations, keep a single row for the station ID
  if (length(value) > 1) {
    location <-
      trimws(location[rep(seq_len(nrow(location)), each = length(value)), ])
  }

  # if there is only one observation this step means that a data frame is
  # created, otherwise from here the function breaks
  if (is.null(nrow(location))) {
    location <- data.frame(t(location))
  }

  # put everything back together into a data frame ---------------------------
  row.names(location) <- NULL
  out <- data.frame(location, attrs, value)
  row.names(out) <- NULL
  out <- as.data.frame(out)
  out$site <- as.character(out$site)
  out$station <- as.character(out$station)
  out$value <- as.numeric(as.character(out$value))

  # convert dates to POSIXct -------------------------------------------------
  out[, c("obs.time.local", "obs.time.utc")] <-
    apply(out[, c("obs.time.local", "obs.time.utc")], 2, function(x)
      chartr("T", " ", x))

  out[, "obs.time.local"] <- as.POSIXct(out[, "obs.time.local"],
                                        origin = "1970-1-1",
                                        format = "%Y%m%d %H%M",
                                        tz = "")
  out[, "obs.time.utc"] <- as.POSIXct(out[, "obs.time.utc"],
                                      origin = "1970-1-1",
                                      format = "%Y%m%d %H%M",
                                      tz = "GMT")

  # spread from long to wide
  out$row <- 1:nrow(out)
  out <- tidyr::spread(out, key = attrs, value = value)
  out <- subset(out, select = -row)

  # some stations don't report all values, insert/remove as necessary --------
  if ("<NA>" %in% colnames(out)) {
    out$`<NA>` <- NULL
  }
  if (!"tx" %in% colnames(out))
  {
    out$tx <- NA
  }
  if (!"tn" %in% colnames(out))
  {
    out$tn <- NA
  }
  if (!"tg" %in% colnames(out))
  {
    out$tg <- NA
  }
  if (!"twd" %in% colnames(out))
  {
    out$twd <- NA
  }
  if (!"r" %in% colnames(out))
  {
    out$r <- NA
  }
  if (!"ev" %in% colnames(out))
  {
    out$ev <- NA
  }
  if (!"wr" %in% colnames(out))
  {
    out$wr <- NA
  }
  if (!"sn" %in% colnames(out))
  {
    out$sn <- NA
  }
  if (!"t5" %in% colnames(out))
  {
    out$t5 <- NA
  }
  if (!"t10" %in% colnames(out))
  {
    out$t10 <- NA
  }
  if (!"t20" %in% colnames(out))
  {
    out$t20 <- NA
  }
  if (!"t50" %in% colnames(out))
  {
    out$t50 <- NA
  }
  if (!"t1m" %in% colnames(out))
  {
    out$t1m <- NA
  }

  # return from internal function
  return(out)
}
