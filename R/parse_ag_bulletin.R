#' Parse local BOM agriculture bulletin XML file(s) for select stations
#'
#' Parse local \acronym{BOM} agriculture bulletin \acronym{XML} file(s) and
#' return a data frame for a specified state or territory or all Australia.
#'
#' @param state Required value of an Australian state or territory as full name
#'  or postal code.  Fuzzy string matching via \code{\link[base]{agrep}} is
#'  done.
#'
#' @param filepath A string providing the directory location of the précis
#' file(s) to parse. See Details for more.
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
#' @return A \code{\link[data.table]{data.table}} of Australia \acronym{BOM}
#'  agricultural bulletin information.  For full details of fields and units
#'  returned see Appendix 3 in the \pkg{bomrang} vignette, use \cr
#'  \code{vignette("bomrang", package = "bomrang")} to view.
#'
#' @examples
#' \donttest{
#' # parse the ag bulletin for Queensland
#'
#' # download to tempfile() using basename() to keep original name
#' download.file(url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ60604.xml",
#'               destfile = file.path(tempdir(),
#'               basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ60604.xml")),
#'               mode = "wb")
#'
#' BOM_bulletin <- parse_ag_bulletin(state = "QLD",
#'                                   filepath = tempdir())
#'
#' BOM_bulletin
#'}
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
#' @seealso get_ag_bulletin
#'
#' @export parse_ag_bulletin
#' 
parse_ag_bulletin <- function(state, filepath) {
  the_state <- .check_states(state)
  location <- .validate_filepath(filepath)
  bulletin_out <-
    .return_bulletin(file_loc = location, cleaned_state = the_state)
  return(bulletin_out)
}
