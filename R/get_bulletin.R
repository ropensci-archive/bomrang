

#' Get BOM Agriculture Bulletin
#'
#'Fetch the BOM agricultural bulletin information
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
#'    \item{AUS}{Australia, returns forecast for all states}
#'  }
#'
#' @return
#' Data frame of a Australia BOM agricultural bulletin information
#'
#'\describe{
#'    # to be updated
#' }
#'
#' @examples
#' \dontrun{
#' ag_bulletin <- get_bulletin(state = "QLD")
#' }
#'
#' @author Adam H Sparks, \email{adamhsparks@gmail.com} and Keith Pembleton \email{keith.pembleton@usq.edu.au}
#'
#' @references
#' Australian Bureau of Meteorology (BOM) Weather Data Services
#' \url{http://www.bom.gov.au/catalogue/data-feeds.shtml}
#'
#' @export
get_bulletin <- function(state = NULL) {
  state <- .validate_state(state)

  # Agricultural Bulletin Station Locations

  stations_meta <-
    readr::read_table(
      "ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/lists_by_element/alpha/alphaAUS_122.txt",
      skip = 4,
      col_names = c(
        "Site",
        "Name",
        "Lat",
        "Lon",
        "Start Month",
        "Start Year",
        "End Month",
        "End Year",
        "Years",
        "%",
        "AWS"
      ),
      col_types = c(
        "Site" = readr::col_integer(),
        "Name" = readr::col_character(),
        "Lat" = readr::col_double(),
        "Lon" = readr::col_double(),
        "`Start Month`" = readr::col_character(),
        "`Start Year`" = readr::col_integer(),
        "`End Month`" = readr::col_character(),
        "`End Year`" = readr::col_integer(),
        "Years" = readr::col_double(),
        "`%`" = readr::col_integer(),
        "AWS" = readr::col_character()
      )
    )

  stations_meta$Site <- as.character(stations_meta$Site)

  # ftp server
  ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/fwo/"

  # State/territory forecast files
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
    Map(
      function(ftp, dest)
        utils::download.file(url = ftp, destfile = dest),
      file_list,
      file.path(tempdir(), basename(file_list))
    )
  } else
    stop(state, " not recognised as a valid state or territory")

  if (state != "AUS") {
    tibble::as_tibble(.parse_bulletin(xmlbulletin, stations_meta))
  }
  else if (state == "AUS") {
    xml_list <-
      list.files(tempdir(), pattern = ".xml$", full.names = TRUE)
    tibble::as_tibble(
      plyr::ldply(
        .data = xml_list,
        .fun = .parse_bulletin,
        stations_meta,
        .progress = "text"
      )
    )
  }
}

#'@nord
.parse_bulletin <- function(xmlbulletin, stations_meta) {
  # load the XML forecast ------------------------------------------------------
  xmlbulletin <- xml2::read_xml(xmlbulletin)
  obs <- xml2::xml_find_all(xmlbulletin, "//obs")

  # get the data from observations ---------------------------------------------
  .get_obs <- function(x) {
    d <- xml2::xml_children(x)
    value <-
      as.numeric(unlist(as.character(xml2::xml_contents(d))))
    attrs <- unlist(as.character(xml2::xml_attrs(d)))

    location <- unlist(t(as.data.frame(xml2::xml_attrs(x))))
    location <-
      location[rep(seq_len(nrow(location)), each = length(value)), ]

    out <- cbind(location, attrs, value)
    row.names(out) <- NULL
    out <- as.data.frame(out)
    out$site <- as.character(out$site)
    out <- tidyr::spread(out, key = attrs, value = value)

    # join locations with lat/lon values ---------------------------------------
    return(out)
  }
  tidy_df <- plyr::ldply(.data = obs, .fun = .get_obs)
  tidy_df <- dplyr::left_join(tidy_df,
                              stations_meta,
                              by = c("site" = "Site"))[-1]

}
