
#' Parse local BOM daily précis forecast XML file(s) for select towns
#'
#' Parse local \acronym{BOM} daily précis forecast \acronym{XML} file(s) and
#' return a data frame of the seven-day town forecasts for a specified state or
#' territory or all Australia.
#'
#' @param state Required value of an Australian state or territory as full name
#'  or postal code.  Fuzzy string matching via \code{\link[base]{agrep}} is
#'  done.
#'
#' @param filepath A string providing the directory location of the précis
#'  file(s) to parse. See Details for more.
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
#' same fashion as `get_precis_forecast()`, provided that the files are all
#' present in the directory.
#'
#' @return
#' A \code{\link[data.table]{data.table}} of Australia \acronym{BOM} précis
#' seven day forecasts for \acronym{BOM} selected towns.  For full details of
#' fields and units returned see Appendix 2 in the \pkg{bomrang} vignette,
#' use\cr
#' \code{vignette("bomrang", package = "bomrang")} to view.
#'
#' @examples
#' \donttest{
#' # parse the short forecast for Queensland
#'
#' # download to tempfile() using basename() to keep original name
#' download.file(url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ11295.xml",
#'               destfile = file.path(tempdir(),
#'               basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ11295.xml")),
#'               mode = "wb")
#'
#' BOM_forecast <- parse_precis_forecast(state = "QLD",
#'                                       filepath = tempdir())
#'
#' BOM_forecast
#'}
#'
#' @references
#' Forecast data come from Australian Bureau of Meteorology (\acronym{BOM})
#' Weather Data Services \cr
#' \url{http://www.bom.gov.au/catalogue/data-feeds.shtml}
#'
#' Location data and other metadata for towns come from
#' the \acronym{BOM} anonymous \acronym{FTP} server with spatial data \cr
#' \url{ftp://ftp.bom.gov.au/anon/home/adfd/spatial/}, specifically the
#' \acronym{DBF} file portion of a shapefile, \cr
#' \url{ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf}
#'
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com} and Keith Pembleton,
#'  \email{keith.pembleton@@usq.edu.au} and Paul Melloy,
#'  \email{paul@@melloy.com.au}
#'  
#' @seealso get_precis_forecast
#'  
#' @export parse_precis_forecast
#'

parse_precis_forecast <- function(state, filepath) {
  the_state <- .check_states(state)
  location <- .validate_filepath(filepath)
  forecast_out <-
    .return_precis(file_loc = location, cleaned_state = the_state)
  return(forecast_out[])
}
