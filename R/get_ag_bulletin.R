
#' Get BOM Agriculture Bulletin Information for Select Stations
#'
#' Fetch the \acronym{BOM} agricultural bulletin information and return it in a
#' tidy data frame
#'
#' @param state Australian state or territory as full name or postal code.
#' Fuzzy string matching via \code{\link[base]{agrep}} is done.  Defaults to
#' "AUS" returning all state bulletins, see details for more.
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
#' Tidy data frame of a Australia \acronym{BOM} agricultural bulletin
#'  information.  For full details of fields and units returned see Appendix 3
#'  in the
#' \pkg{bomrang} vignette, use \cr
#' \code{vignette("bomrang", package = "bomrang")} to view.
#'
#' @examples
#' \donttest{
#' ag_bulletin <- get_ag_bulletin(state = "QLD")
#' }
#'
#' @references
#' Agricultural observations are retrieved from the Australian Bureau of
#' Meteorology (BOM) Weather Data Services Agriculture Bulletins, \cr
#' \url{http://www.bom.gov.au/catalogue/observations/about-agricultural.shtml}
#'
#'and
#'
#' Australian Bureau of Meteorology (BOM) Weather Data Services Observation of
#' Rainfall, \cr
#' \url{http://www.bom.gov.au/climate/how/observations/rain-measure.shtml}
#'
#' Station location and other metadata are sourced from the Australian Bureau of
#' Meteorology (\acronym{BOM}) webpage, Bureau of Meteorology Site Numbers: \cr
#' \url{http://www.bom.gov.au/climate/cdo/about/site-num.shtml}
#'
#' @author Adam H Sparks, \email{adamhsparks@@gmail.com}
#' @export get_ag_bulletin

get_ag_bulletin <- function(state = "AUS") {
  # CRAN NOTE avoidance
  stations_site_list <- NULL # nocov

  # Load AAC code/town name list to join with final output
  load(system.file("extdata", "stations_site_list.rda", # nocov
                   package = "bomrang")) # nocov

  the_state <- .check_states(state) # see internal_functions.R

  # ftp server
  ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/fwo/"

  # create vector of XML files
  AUS_XML <- c(
    "IDN65176.xml", # NSW
    "IDD65176.xml", # NT
    "IDQ60604.xml", # QLD
    "IDS65176.xml", # SA
    "IDT65176.xml", # TAS
    "IDV65176.xml", # VIC
    "IDW65176.xml"  # WA
  )

  if (the_state != "AUS") {
    xmlbulletin_url <-
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
    out <- .parse_bulletin(xmlbulletin_url, stations_site_list)
  } else {
    file_list <- paste0(ftp_base, AUS_XML)
    out <-
      lapply(X = file_list,
             FUN = .parse_bulletin,
             stations_site_list)
    out <- as.data.frame(data.table::rbindlist(out))
  }
  return(out)
}

#' @noRd
.parse_bulletin <- function(xmlbulletin_url, stations_site_list) {
  # download the XML bulletin --------------------------------------------------

  tryCatch({
    xmlbulletin <- xml2::read_xml(xmlbulletin_url)
  },
  error = function(x)
    stop(
      "\nThe server with the bulletin files is not responding. ",
      "Please retry again later.\n"
    ))

  obs <- xml2::xml_find_all(xmlbulletin, "//obs")

  # create the tidy dataframe --------------------------------------------------
  tidy_df <- lapply(X = obs, FUN = .get_obs)
  tidy_df <- do.call("rbind", tidy_df)
  tidy_df$product_id <- substr(basename(xmlbulletin_url),
                               1,
                               nchar(basename(xmlbulletin_url)) - 4)

  tidy_df <- dplyr::left_join(tidy_df,
                              stations_site_list,
                              by = c("site" = "site"))

  tidy_df$time.zone <- as.character(tidy_df$time.zone)

  names(tidy_df)[c(1:3, 22)] <-
    c("obs_time_local", "obs_time_utc", "time_zone", "name")

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

  tidy_df <- tidy_df[c(refcols, setdiff(names(tidy_df), refcols))]

  # convert dates to POSIXct -------------------------------------------------
  tidy_df[, c("obs_time_local", "obs_time_utc")] <-
    lapply(tidy_df[, c("obs_time_local", "obs_time_utc")], function(x)
      as.POSIXct(x, origin = "1970-1-1", format = "%Y-%m-%d %H:%M:%OS"))

  # return from main function
  return(tidy_df)
}

# get the data from observations -----------------------------------------------
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
  out <- tidyr::spread(data = out,
                       key = attrs,
                       value = value)

  # some stations don't report all values, insert/remove as necessary --------
  if ("<NA>" %in% colnames(out)) {
    out$`<NA>` <- NULL
  }
  if (!"tx" %in% colnames(out)) {
    out$tx <- NA
  }
  if (!"tn" %in% colnames(out)) {
    out$tn <- NA
  }
  if (!"tg" %in% colnames(out)) {
    out$tg <- NA
  }
  if (!"twd" %in% colnames(out)) {
    out$twd <- NA
  }
  if (!"r" %in% colnames(out)) {
    out$r <- NA
  }
  if (!"ev" %in% colnames(out)) {
    out$ev <- NA
  }
  if (!"wr" %in% colnames(out)) {
    out$wr <- NA
  }
  if (!"sn" %in% colnames(out)) {
    out$sn <- NA
  }
  if (!"t5" %in% colnames(out)) {
    out$t5 <- NA
  }
  if (!"t10" %in% colnames(out)) {
    out$t10 <- NA
  }
  if (!"t20" %in% colnames(out)) {
    out$t20 <- NA
  }
  if (!"t50" %in% colnames(out)) {
    out$t50 <- NA
  }
  if (!"t1m" %in% colnames(out)) {
    out$t1m <- NA
  }
  if (!"solr" %in% colnames(out)) {
    out$solr <- NA
  }
  return(out)
}
