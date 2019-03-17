
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
#'  Tidy \code{\link[data.table]{data.table}} of Australia \acronym{BOM} 
#'  agricultural bulletin information.  For full details of fields and units
#'  returned see Appendix 3 in the \pkg{bomrang} vignette, use \cr
#'  \code{vignette("bomrang", package = "bomrang")} to view.
#'
#' @examples
#' \donttest{
#' ag_bulletin <- get_ag_bulletin(state = "QLD")
#' ag_bulletin
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
#' @importFrom magrittr "%>%"
#' @export get_ag_bulletin

get_ag_bulletin <- function(state = "AUS") {
  # CRAN NOTE avoidance
  stations_site_list <- NULL # nocov
  
  the_state <- .check_states(state) # see internal_functions.R
  
  # ftp server
  ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/fwo/"
  
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
  
  if (the_state != "AUS") {
    xml_url <-
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
    out <- .parse_bulletin(xml_url)
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
.parse_bulletin <- function(xml_url) {
  # see internal functions for .get_xml() shared function
  xml_object <- .get_xml(xml_url)
  
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
      xml_attr("obs-time-local"),
    obs_time_utc = xml2::xml_find_first(observations, ".//ancestor::obs") %>%
      xml_attr("obs-time-utc"),
    time_zone = xml2::xml_find_first(observations, ".//ancestor::obs") %>%
      xml_attr("time-zone"),
    site =  xml2::xml_find_first(observations, ".//ancestor::obs") %>%
      xml_attr("site"),
    station = xml2::xml_find_first(observations, ".//ancestor::obs") %>%
      xml_attr("station"),
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
    out[missing] <- NA
  }
  
  # set col classes ------------------------------------------------------------
  # factor
  out[, c(4:5) := lapply(.SD, function(x)
    as.factor(x)),
    .SDcols = c(4:5)]
  
  # dates
  out[, c(1:2) := lapply(.SD, function(x)
    as.POSIXct(x,
               origin = "1970-1-1",
               format = "%Y-%m-%d %H:%M:%OS")),
    .SDcols = c(1:2)]
  
  # numeric
  out[, c(11:15) := lapply(.SD, function(x)
    as.numeric(x)),
    .SDcols = c(11:15)]
  
  # merge with AAC codes -------------------------------------------------------
  # load AAC code/town name list to join with final output
  load(system.file("extdata", "stations_site_list.rda", # nocov
                   package = "bomrang")) # nocov
  
  data.table::setDT(stations_site_list)
  data.table::setkey(stations_site_list, "site")
  data.table::setkey(out, "site")
  
  out <- stations_site_list[out, on = "site"]
  
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
  
  data.table::setcolorder(out, refcols)
  
  # return from main function
  return(out)
}
