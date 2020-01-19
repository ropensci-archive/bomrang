
#' Get BOM coastal waters forecast
#'
#' Fetch the \acronym{BOM} daily Coastal Waters Forecast and return a data frame
#' of the forecast regions for a specified state or region.
#'
#' @param state Australian state or territory as full name or postal code.
#'  Fuzzy string matching via \code{\link[base]{agrep}} is done.  Defaults to
#'  "AUS" returning all state forecasts, see details for further information.
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
#' A \code{\link[data.table]{data.table}} of an Australia \acronym{BOM}
#' Coastal Waters Forecast. For full details of fields and units
#' returned see Appendix 5 in the \pkg{bomrang} vignette, use \cr
#' \code{vignette("bomrang", package = "bomrang")} to view.
#'
#' @examples
#' \donttest{
#' coastal_forecast <- get_coastal_forecast(state = "NSW")
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
#' @seealso parse_coastal_forecast()
#' 
#' @export get_coastal_forecast

get_coastal_forecast <- function(state = "AUS") {
  # this is just a placeholder for functionality with parse_coastal_forecast()
  filepath <- NULL
  
  # see internal_functions.R for these functions
  the_state <- .check_states(state)
  location <- .validate_filepath(filepath)
  coastal_out <-
    .return_coastal(file_loc = location, cleaned_state = the_state)
  return(coastal_out)
}
