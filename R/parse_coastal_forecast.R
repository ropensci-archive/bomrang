
#' Parse local BOM coastal waters forecast XML files
#'
#' Parse local \acronym{BOM} daily coastal waters forecast \acronym{XML} file(s)
#'  and return a data frame for a specified state or territory or all Australia.
#'
#' @param state Required value of an Australian state or territory as full name
#'  or postal code.  Fuzzy string matching via \code{\link[base]{agrep}} is
#'  done.
#'
#' @param filepath A string providing the directory location of the coastal
#'  forecast file(s) to parse. See Details for more.
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
#' @details The \var{filepath} argument will only accept a directory where files
#' are located for parsing. DO NOT supply the full path including the file name.
#' This function will only parse the requested state or all of Australia in the
#' same fashion as `get_coastal_forecast()`, provided that the files are all
#' present in the directory.
#'
#' @return
#' A \code{\link[data.table]{data.table}} of an Australia \acronym{BOM}
#' Coastal Waters Forecast. For full details of fields and units
#' returned see Appendix 5 in the \pkg{bomrang} vignette, use \cr
#' \code{vignette("bomrang", package = "bomrang")} to view.
#'
#' @examples
#' \donttest{
#' # parse the coastal forecast for Queensland
#'
#' #download to tempfile() using basename() to keep original name
#' download.file(url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ11290.xml",
#'               destfile = file.path(tempdir(),
#'               basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ11290.xml")),
#'               mode = "wb")
#'
#' coastal_forecast <- parse_coastal_forecast(state = "QLD",
#'                                            filepath = tempdir())
#' coastal_forecast
#'}
#' @references
#' Forecast data come from Australian Bureau of Meteorology (BOM) Weather Data
#' Services \cr
#' \url{http://www.bom.gov.au/catalogue/data-feeds.shtml}
#'
#' Location data and other metadata come from the \acronym{BOM} anonymous
#' \acronym{FTP} server with spatial data \cr
#' \url{ftp://ftp.bom.gov.au/anon/home/adfd/spatial/}, specifically the
#' \acronym{DBF} file portion of a shapefile, \cr
#' \url{ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00003.dbf}
#'
#' @author Dean Marchiori, \email{deanmarchiori@@gmail.com} and Paul Melloy
#' \email{paul@@melloy.com.au}
#' 
#' @seealso get_coastal_forecast
#' 
#' @export parse_coastal_forecast

parse_coastal_forecast <- function(state = "AUS", filepath) {
  # see internal_functions.R for these functions
  the_state <- .check_states(state)
  location <- .validate_filepath(filepath)
  coastal_out <-
    .return_coastal(file_loc = location, cleaned_state = the_state)
  return(coastal_out)
}
