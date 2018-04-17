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
#' @author Jonathan Carroll, \email{rpkg@jcarroll.com.au}
.get_zip_url <- function(site, code = 122) {
  url1 <- paste0("http://www.bom.gov.au/jsp/ncc/cdio/weatherData/av?p_stn_num=", 
                 site, 
                 "&p_display_type=availableYears&p_nccObsCode=", 
                 code)
  raw <- httr::content(httr::GET(url1), "text")
  pc <- sub("^.*:", "", raw)
  url2 <- paste0("http://www.bom.gov.au/jsp/ncc/cdio/weatherData/av?p_display_type=dailyZippedDataFile&p_stn_num=",
                 site,
                 "&p_c=",
                 pc,
                 "&p_nccObsCode=", 
                 code)
  url2
}

#' Download a BOM Data .zip File and Load into Session
#'
#' @param url URL of zip file to be downloaded/extracted/loaded.
#' @importFrom utils download.file unzip read.csv
#'
#' @return data loaded from the zip file
#' @keywords internal
#' @author Jonathan Carroll, \email{rpkg@jcarroll.com.au}
.get_zip_and_load <- function(url) {
  tmp <- tempfile(fileext = ".zip")
  utils::download.file(url, tmp)
  zipped <- utils::unzip(tmp, exdir = dirname(tmp))
  unlink(tmp)
  datfile <- grep("Data.csv", zipped, value = TRUE)
  message("Data saved as ", datfile)
  dat <- utils::read.csv(datfile, header = TRUE)
  dat
}

#' Obtain Historical BOM Data
#'
#' Retrieves daily observations for a given station.
#'
#' @md
#' @param stationid BOM station ID. See Details.
#' @param latlon Length-2 numeric vector of Latitude/Longitude. See Details.
#' @param type Measurement type, either daily "rain", "min" (temp), "max" (temp), or
#'   "solar" (exposure). Partial matching is performed.
#'
#' @return a complete [data.frame] of historical observations for the chosen
#'   station.
#'
#'   Either `stationid` or `latlon` must be provided, but if both are, then
#'   `stationid` will be used as it is more reliable.
#'
#'   In some cases data is available back to the 1800s, so tens of thousands of
#'   daily records will be returned. Other stations will be newer and will
#'   return fewer observations.
#'
#' @export
#' @author Jonathan Carroll, \email{rpkg@jcarroll.com.au}
#'
#' @examples
#' get_historical(stationid = "023000", type = "max") ## 33,700+ daily records 
get_historical <- function(stationid = NULL, latlon = NULL, type = c("rain", "min", "max", "solar")) {
  
  if (is.null(stationid) & is.null(latlon)) stop("stationid or latlon must be provided.")
  if (!is.null(stationid) & !is.null(latlon)) {
    warning("Only one of stationid or latlon may be provided. Using stationid.")
  }
  if (is.null(stationid)) {
    if (!identical(length(latlon), 2L) || !is.numeric(latlon)) stop("latlon must be a 2-element numeric vector.")
    stationdetails <- sweep_for_stations(latlon = latlon)[1, , drop = TRUE]
    message("Closest station: ", stationdetails$site, " (", stationdetails$name, ")")
    stationid <- stationdetails$site
  } 
  
  ## ensure station is known
  load(system.file("extdata",
                   "JSONurl_site_list.rda",
                   package = "bomrang"))
  if (!stationid %in% JSONurl_site_list$site) stop("Station not recognised.")
  
  type <- match.arg(type)
  obscode <- switch(type,
                    rain = 136,
                    min = 123,
                    max = 122,
                    solar = 193)
  
  zipurl <- .get_zip_url(stationid, obscode)
  .get_zip_and_load(zipurl)
  
}