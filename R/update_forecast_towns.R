
#' Update bomrang Internal Database with Latest BOM Forecast Towns
#'
#' @description
#' Download the latest select forecast towns from the BOM server and update
#' bomrang's internal database of précis forecast town names and
#' AAC codes used by \code{\link{get_precis_forecast}}.  There is
#' no need to use this unless you know that a forecast town exists in a
#' more current version of the BOM précis forecast town name database that is
#' not available in the database distributed with [bomrang].
#'
#' @examples
#' \dontrun{
#' update_forecast_towns()
#' }
#' @return Updated database of BOM précis forecast towns
#'
#' @references
#' Data are sourced from: Australian Bureau of Meteorology (BOM) webpage,
#' "Weather Data Services",
#' \url{http://www.bom.gov.au/catalogue/data-feeds.shtml}
#'
#' @author Adam H Sparks, \email{adamhsparks@@gmail.com}
#' @export
#'
update_forecast_towns <- function() {
  original_timeout <- options("timeout")[[1]]
  options(timeout = 300)
  on.exit(options(timeout = original_timeout))

  # fetch new database from BOM server
  curl::curl_download(
    "ftp://ftp2.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf",
    destfile = file.path(tempdir(), "AAC_codes.dbf"),
    mode = "wb"
  )

  # import BOM dbf file
  AAC_codes <-
    foreign::read.dbf(file.path(tempdir(), "AAC_codes.dbf"), as.is = TRUE)
  AAC_codes <- AAC_codes[, c(2:3, 7:9)]

  # overwrite the existing isd_history.rda file on disk
  message("\nOverwriting existing database of forecast towns and AAC codes.\n")
  fname <- system.file("extdata", "AAC_codes.rda", package = "bomrang")
  save(AAC_codes, file = fname, compress = "bzip2")
}
