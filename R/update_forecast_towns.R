
#' Update internal database with latest BOM forecast towns
#'
#' @description
#' Download the latest select forecast towns from the \acronym{BOM} server and
#' update internal database of précis forecast town names and \acronym{AAC}
#' codes used by \code{\link{get_precis_forecast}}.  There is no need to use
#' this unless you know that a forecast town exists in a more current version of
#' the \acronym{BOM} précis forecast town name database that is not available in
#' the database distributed with \pkg{bomrang}.  In fact, for reproducibility
#' purposes, users are discouraged from using this function.
#'
#' @examples
#' \dontrun{
#' update_forecast_towns()
#' }
#' @return Updated database of \acronym{BOM} précis forecast towns
#'
#' @references
#' Data are sourced from: Australian Bureau of Meteorology (\acronym{BOM})
#' webpage, "Weather Data Services",
#' \url{http://www.bom.gov.au/catalogue/data-feeds.shtml}
#'
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#' @export update_forecast_towns

update_forecast_towns <- function() {
  message(
    "This will overwrite the current internal database of forecast towns.\n",
    "If reproducibility is necessary, you may not wish to proceed.\n",
    "Do you understand and wish to proceed (Y/n)?\n"
  )
  
  answer <-
    readLines(con = getOption("bomrang.connection"), n = 1)
  
  answer <- toupper(answer)
  
  if (answer %notin% c("Y", "YES")) {
    stop("Forecast towns were not updated.",
         call. = FALSE)
  }
  
  message("Updating forecast towns.\n")
  
  original_timeout <- options("timeout")[[1]]
  options(timeout = 300)
  on.exit(options(timeout = original_timeout))
  
  # fetch new database from BOM server
  curl::curl_download(
    "ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf",
    destfile = file.path(tempdir(), "AAC_codes.dbf"),
    mode = "wb",
    quiet = TRUE
  )
  
  # import BOM dbf file
  AAC_codes <-
    foreign::read.dbf(file.path(tempdir(), "AAC_codes.dbf"), as.is = TRUE)
  AAC_codes <- AAC_codes[, c(2:3, 7:9)]
  
  # overwrite the existing isd_history.rda file on disk
  message("\nOverwriting existing database of forecast towns and AAC codes.\n")
  fname <-
    system.file("extdata", "AAC_codes.rda", package = "bomrang")
  save(AAC_codes, file = fname, compress = "bzip2")
}
