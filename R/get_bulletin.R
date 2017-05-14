
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
#' @importFrom dplyr %>%
#'
#'
#' @export
get_bulletin <- function(state = NULL) {
  .validate_state(state)

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
    tibble::as_tibble(.parse_forecast(xmlbulletin))
  }
  else if (state == "AUS") {
    xml_list <-
      list.files(tempdir(), pattern = ".xml$", full.names = TRUE)
    tibble::as_tibble(plyr::ldply(
      .data = xml_list,
      .fun = .parse_forecast,
      .progress = "text"
    ))
  }
}

.parse_bulletin <- function(xmlbulletin) {
  # load the XML forecast ------------------------------------------------------
  xmlbulletin <- xml2::read_xml(xmlbulletin)


  # extract locations from forecast --------------------------------------------
  obs <- xml2::xml_find_all(xmlbulletin, "//obs")
  bulletin_locations <-
    dplyr::bind_rows(lapply(xml2::xml_attrs(obs), as.list))

  # join locations with lat/lon values -----------------------------------------
  bulletin_locations <- dplyr::left_join(bulletin_locations,
                                         stations_meta,
                                         by = c("site" = "Site"))

  # get the data from observations ---------------------------------------------
  .get_obs <- function(x) {
    location <- unlist(t(as.data.frame(xml2::xml_attrs(x))))
    d <- xml2::xml_children(x)
    value <-
      as.numeric(unlist(as.character(xml2::xml_contents(d))))
    attrs <- unlist(as.character(xml2::xml_attrs(d)))
    location <-
      location[rep(seq_len(nrow(location)), each = length(value)),]
    out <- cbind(location, attrs, value)
    row.names(out) <- NULL
    return(out)
  }

  out <- plyr::ldply(.data = obs, .fun = .get_obs)

  out <- tidyr::spread(out, key = attrs, value = value)
}
