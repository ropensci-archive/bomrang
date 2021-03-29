
#' Get BOM agriculture bulletin information for select stations
#'
#' Fetch the \acronym{BOM} agricultural bulletin information and return it in a
#' data frame
#'
#' @param state Australian state or territory as full name or postal code.
#'  Fuzzy string matching via \code{\link[base]{agrep}} is done.  Defaults to
#'  \dQuote{AUS} returning all state bulletins, see Details for more.
#'
#' @details Allowed state and territory postal codes, only one state per request
#' or all using \code{AUS}.
#'  \describe{
#'    \item{ACT}{Australian Capital Territory (will return NSW)}
#'    \item{NSW}{New South Wales}
#'    \item{NT}{Northern Territory}
#'    \item{QLD}{Queensland}
#'    \item{SA}{South Australia}
#'    \item{TAS}{Tasmania}
#'    \item{VIC}{Victoria}
#'    \item{WA}{Western Australia}
#'    \item{AUS}{Australia, returns forecast for all states, NT and ACT}
#'  }
#'
#' @return
#'  A data frame as a \code{\link[data.table]{data.table}} object of Australia
#'  \acronym{BOM} agricultural bulletin information.  For full details of fields
#'  and units returned see Appendix 3 in the \CRANpkg{bomrang} vignette, use \cr
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
#' Meteorology (\acronym{BOM}) Weather Data Services Agriculture Bulletins, \cr
#' \url{http://www.bom.gov.au/catalogue/observations/about-agricultural.shtml}
#'
#' and
#'
#' Australian Bureau of Meteorology (\acronym{BOM})) Weather Data Services
#' Observation of Rainfall, \cr
#' \url{http://www.bom.gov.au/climate/how/observations/rain-measure.shtml}
#'
#' Station location and other metadata are sourced from the Australian Bureau of
#' Meteorology (\acronym{BOM}) webpage, Bureau of Meteorology Site Numbers: \cr
#' \url{http://www.bom.gov.au/climate/cdo/about/site-num.shtml}
#'
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com} and Paul Melloy
#' \email{paul@@melloy.com.au}
#'
#' @seealso \link{parse_ag_bulletin}
#'
#' @export get_ag_bulletin

get_ag_bulletin <- function(state = "AUS") {
  # this is just a placeholder for functionality with parse_ag_bulletin()
  filepath <- NULL

  # see internal_functions.R for these functions
  the_state <- .check_states(state)
  location <- .validate_filepath(filepath)
  bulletin_out <-
    .return_bulletin(file_loc = location, cleaned_state = the_state)
  return(bulletin_out)
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
    site <- obs_time_local <- obs_time_utc <- r <- .SD <- NULL # nocov
  # load the XML from ftp
  if (substr(xml_url, 1, 3) == "ftp") {
    xml_object <- .get_url(remote_file = xml_url)
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
