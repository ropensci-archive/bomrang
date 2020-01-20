
#' Get BOM agriculture bulletin information for select stations
#'
#' Fetch the \acronym{BOM} agricultural bulletin information and return it in a
#' data frame
#'
#' @param state Australian state or territory as full name or postal code.
#'  Fuzzy string matching via \code{\link[base]{agrep}} is done.  Defaults to
#'  "AUS" returning all state bulletins, see Details for more.
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
#'  and units returned see Appendix 3 in the \pkg{bomrang} vignette, use \cr
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
#' @seealso parse_ag_bulletin
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
