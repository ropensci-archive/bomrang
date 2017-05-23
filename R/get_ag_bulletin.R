
#' Get BOM Agriculture Bulletin
#'
#'Fetch the BOM agricultural bulletin information and return a tidy data frame
#'
#' @param state Australian state or territory as postal code, see details for
#' instruction.
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
#'    \item{AUS}{Australia, returns bulletin for all states}
#'  }
#'
#' @return
#' Data frame of a Australia BOM agricultural bulletin information
#'
#'\describe{
#'    \item{obs-time-utc}{Observation time (Time in UTC)}
#'    \item{time-zone}{Time zone for observation}
#'    \item{site}{Unique BOM identifier for each station}
#'    \item{name}{BOM station name}
#'    \item{r}{Rain to 9am (millimetres). \strong{Trace will be reported as 0.01}}
#'    \item{tn}{Minimum temperature (Celsius)}
#'    \item{tx}{Maximum temperature (Celsius)}
#'    \item{twd}{Wetbulb depression (Celsius)}
#'    \item{ev}{Evaporation (millimetres)}
#'    \item{tg}{Terrestrial minimum temperature (Celsius)}
#'    \item{sn}{Sunshine (Hours)}
#'    \item{t5}{5cm soil temperature (Celsius)}
#'    \item{t10}{10cm soil temperature (Celsius)}
#'    \item{t20}{20cm soil temperature (Celsius)}
#'    \item{t50}{50cm soil temperature (Celsius)}
#'    \item{t1m}{1m soil temperature (Celsius)}
#'    \item{wr}{Wind run (kilometres)}
#'    \item{state}{State name (postal code abbreviation)}
#'    \item{lat}{Latitude (decimal degrees)}
#'    \item{lon}{Longitude (decimal degrees)}
#' }
#'
#' @examples
#' \dontrun{
#' ag_bulletin <- get_ag_bulletin(state = "QLD")
#' }
#'
#' @author Adam H Sparks, \email{adamhsparks@gmail.com}
#'
#' @references
#' Australian Bureau of Meteorology (BOM) Weather Data Services Agriculture Bulletins
#' \url{http://www.bom.gov.au/catalogue/observations/about-agricultural.shtml}
#'
#' Australian Bureau of Meteorology (BOM) Weather Data Services Observation of Rainfall
#' \url{http://www.bom.gov.au/climate/how/observations/rain-measure.shtml}
#'
#' @export
get_ag_bulletin <- function(state = NULL) {
  state <- .validate_state(state)

  # Agricultural Bulletin Station Locations

  stations_meta <-
    readr::read_table(
      "ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/lists_by_element/alpha/alphaAUS_122.txt",
      skip = 4,
      col_names = c("site",
                    "name",
                    "lat",
                    "lon"),
      col_types = readr::cols_only(
        "site" = readr::col_character(),
        "name" = readr::col_character(),
        "lat" = readr::col_double(),
        "lon" = readr::col_double()
      )
    )

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

  if (state == "NSW") {
    xmlbulletin <-
      paste0(ftp_base, NSW) # nsw
  }
  else if (state == "NT") {
    xmlbulletin <-
      paste0(ftp_base, NT) # nt
  }
  else if (state == "QLD") {
    xmlbulletin <-
      paste0(ftp_base, QLD) # qld
  }
  else if (state == "SA") {
    xmlbulletin <-
      paste0(ftp_base, SA) # sa
  }
  else if (state == "TAS") {
    xmlbulletin <-
      paste0(ftp_base, TAS) # tas
  }
  else if (state == "VIC") {
    xmlbulletin <-
      paste0(ftp_base, VIC) # vic
  }
  else if (state == "WA") {
    xmlbulletin <-
      paste0(ftp_base, WA) # wa
  }
  else if (state == "AUS") {
    AUS <- list(NT, NSW, QLD, SA, TAS, VIC, WA)
    file_list <- paste0(ftp_base, AUS)
  } else
    stop(state, " not recognised as a valid state or territory")

  if (state != "AUS") {
    tibble::as_tibble(.parse_bulletin(xmlbulletin, stations_meta))
  }
  else if (state == "AUS") {
    tibble::as_tibble(
      plyr::ldply(
        .data = file_list,
        .fun = .parse_bulletin,
        stations_meta,
        .progress = "text"
      )
    )
  }
}

#' @noRd
.parse_bulletin <- function(xmlbulletin, stations_meta) {
  obs.time.utc <- obs.time.local <- time.zone <- site <- name <- r <- tn <-
    tx <- twd <- ev <- obs_time_utc <- obs_time_local <- time_zone <- state <-
    tg <- sn <- t5 <- t10 <- t20 <- t50 <- t1m <- wr <- lat <- lon <- attrs <-
    `rep(bulletin_state, nrow(tidy_df))` <- NULL

  # load the XML bulletin ------------------------------------------------------
  xmlbulletin <- xml2::read_xml(xmlbulletin)
  obs <- xml2::xml_find_all(xmlbulletin, "//obs")

  bulletin_state <-
    xml2::xml_find_first(xmlbulletin, ".//*['name']")
  bulletin_state <- xml2::xml_attr(bulletin_state, "name")
  bulletin_state <- stringr::str_sub(bulletin_state, start = 40)

  if (bulletin_state == "New South Wales") {
    bulletin_state <- "NSW"
  } else if (bulletin_state == "Queensland") {
    bulletin_state <- "QLD"
  } else if (bulletin_state == "Northern Territory") {
    bulletin_state <- "NT"
  } else if (bulletin_state == "South Australia") {
    bulletin_state <- "SA"
  } else if (bulletin_state == "Tasmania") {
    bulletin_state <- "TAS"
  } else if (bulletin_state == "Victoria") {
    bulletin_state <- "VIC"
  } else if (bulletin_state == "Western Australia") {
    bulletin_state <- "WA"
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

    # put everything back together into a data frame
    row.names(location) <- NULL
    out <- data.frame(location, attrs, value)
    row.names(out) <- NULL
    out <- as.data.frame(out)
    out$site <- as.character(out$site)
    out$value <- as.numeric(as.character(out$value))

    # spread from long to wide
    out <- tidyr::spread(out, key = attrs, value = value)

    # some stations don't report all values, insert/remove as necessary
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

    # join locations with lat/lon values ---------------------------------------
    return(out)
  }
  tidy_df <- plyr::ldply(.data = obs, .fun = .get_obs)

  tidy_df <- dplyr::left_join(tidy_df,
                              stations_meta,
                              by = c("site" = "site"))

  tidy_df <- cbind(tidy_df, rep(bulletin_state, nrow(tidy_df)))

  tidy_df <-
    tidy_df %>%
    dplyr::rename(
      obs_time_local = obs.time.local,
      obs_time_utc = obs.time.utc,
      time_zone = time.zone,
      state = `rep(bulletin_state, nrow(tidy_df))`
    ) %>%
    dplyr::mutate_each(dplyr::funs(as.character), state) %>%
    dplyr::mutate_each(dplyr::funs(as.character), obs_time_utc) %>%
    dplyr::mutate_each(dplyr::funs(as.character), time_zone)

  tidy_df <- tibble::as_tibble(
    dplyr::select(
      tidy_df,
      obs_time_local,
      obs_time_utc,
      time_zone,
      site,
      name,
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
      wr,
      state,
      lat,
      lon
    )
  )
}
