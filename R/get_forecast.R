
#' Get BOM Forecast
#'
#'Fetch the BOM forecast and create a tidy data frame of the daily forecast
#'
#' @param state Australian state or territory as postal code, see details for
#' instruction.
#'
#' @details Allowed state and territory postal codes, only one state per request
#' or all using \code{AUS}.
#'  \describe{
#'    \item{ACT}{Australian Capital Territory}
#'    \item{NSW}{New South Wales}
#'    \item{NT}{Northern Territory}
#'    \item{QLD}{Queensland}
#'    \item{SA}{South Australia}
#'    \item{TAS}{Tasmania}
#'    \item{VIC}{Victoria}
#'    \item{WA}{Western Australia}
#'    \item{AUS}{Australia, returns forecast for all states}
#'  }
#'
#' @return
#' Data frame of a Australia BOM daily forecast in a data frame with the
#' following fields.
#'
#'\describe{
#'    \item{aac}{AMOC Area Code, e.g. WA_MW008, a unique identifier for each location}
#'    \item{date}{Date (YYYY-MM-DD)}
#'    \item{max_temp}{Maximum forecasted temperature (degrees Celsius)}
#'    \item{min_temp}{Minimum forecasted temperature (degrees Celsius)}
#'    \item{lower_prcp_limit}{Lower forecasted precipitation limit (millimetres)}
#'    \item{upper_prcp_limit}{Upper forecasted precipitation limit (millimetres)}
#'    \item{precis}{Précis forecast (a short summary, less than 30 characters)}
#'    \item{prob_prcp}{Probability of precipitation (percent)}
#'    \item{location}{Named location for forecast}
#'    \item{state}{State name  (postal code abbreviation)}
#'    \item{lon}{Longitude of named location (decimal Degrees)}
#'    \item{lat}{Latitude of named location (decimal Degrees)}
#'    \item{elev}{Elevation of named location (metres)}
#' }
#'
#' @examples
#' \dontrun{
#' BOM_forecast <- get_forecast(state = "QLD")
#' }
#'
#' @author Adam H Sparks, \email{adamhsparks@gmail.com} and Keith Pembleton \email{keith.pembleton@usq.edu.au}
#'
#' @references
#' Australian Bureau of Meteorology (BOM) Weather Data Services
#' \url{http://www.bom.gov.au/catalogue/data-feeds.shtml}
#'
#' @importFrom dplyr %>%
#'
#'
#' @export
get_forecast <- function(state = NULL) {
  .validate_state(state)

  # ftp server
  ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/fwo/"

  # State/territory forecast files
  NT  <- "IDD10207.xml"
  NSW <- "IDN11060.xml"
  QLD <- "IDQ11295.xml"
  SA  <- "IDS10044.xml"
  TAS <- "IDT16710.xml"
  VIC <- "IDV10753.xml"
  WA  <- "IDW14199.xml"

  if (state == "NT") {
    xmlforecast <-
      paste0(ftp_base, NT) # nt
  }
  else if (state == "NSW" | state == "ACT") {
    xmlforecast <-
      paste0(ftp_base, NSW) # nsw
  }
  else if (state == "QLD") {
    xmlforecast <-
      paste0(ftp_base, QLD) # qld
  }
  else if (state == "SA") {
    xmlforecast <-
      paste0(ftp_base, SA) # sa
  }
  else if (state == "TAS") {
    xmlforecast <-
      paste0(ftp_base, TAS) # tas
  }
  else if (state == "VIC") {
    xmlforecast <-
      paste0(ftp_base, VIC) # vic
  }
  else if (state == "WA") {
    xmlforecast <-
      paste0(ftp_base, WA) # wa
  }
  else if (state == "AUS") {
    AUS <- list(NT, NSW, QLD, SA, TAS, VIC, WA)
    file_list <- paste0(ftp_base, AUS)
    Map(
      function(ftp, dest)
        utils::download.file(url = ftp, destfile = dest),
      file_list,
      file.path(tempdir(), basename(file_list))
    )
  } else
    stop(state, " not recognised as a valid state or territory")

  if (state != "AUS") {
    tibble::as_tibble(.parse_forecast(xmlforecast))
  }
  else if (state == "AUS") {
    xml_list <-
      list.files(tempdir(), pattern = ".xml$", full.names = TRUE)
    tibble::as_tibble(plyr::ldply(
      .data = xml_list,
      .fun = .parse_forecast,
      .progress = "text"
    ))
  }
}

.parse_forecast <- function(xmlforecast) {
  type <-
    description <- aac <- location <- state <- lon <- lat <- elev <-
    precipitation_range <- `parent-aac` <- LON <- LAT <- ELEVATION <- NULL

    # load BOM location data ---------------------------------------------------
    utils::data("AAC_codes", package = "BOMRang")
    AAC_codes <- AAC_codes

    # load the XML forecast ----------------------------------------------------
    xmlforecast <- xml2::read_xml(xmlforecast)

    # remove today's data ------------------------------------------------------
    xml2::xml_find_all(xmlforecast, ".//*[@index='0']") %>%
      xml2::xml_remove()

    # extract locations from forecast ------------------------------------------
    areas <- xml2::xml_find_all(xmlforecast, ".//*[@type='location']")
    forecast_locations <-
      dplyr::bind_rows(lapply(xml2::xml_attrs(areas), as.list)) %>%
      dplyr::select(-type)

    # join locations with lat/lon values ---------------------------------------
    forecast_locations <- dplyr::left_join(forecast_locations,
                                           AAC_codes,
                                           by = c("aac" = "AAC",
                                                  "description" = "PT_NAME"))

    # unlist and add the locations aac code ------------------------------------
    forecasts <-
      lapply(xml2::xml_find_all(xmlforecast, ".//*[@type='location']"),
             xml2::as_list)

    forecasts <- plyr::llply(forecasts, unlist)
    names(forecasts) <- forecast_locations$aac

    # get all the <element> and <text> tags (the forecast) ---------------------
    eltext <- xml2::xml_find_all(xmlforecast, "//element | //text")

    # extract and clean (if needed) (the labels for the forecast) --------------
    labs <- trimws(xml2::xml_attrs(eltext, "type"))

    # use a loop to turn list of named character elements into a list ----------
    # of dataframes with the location aac code for each line of the data frame
    y <- vector("list")
    for (i in unique(names(forecasts))) {
      x <- data.frame(
        keyName = names(forecasts[[i]]),
        value = forecasts[[i]],
        row.names = NULL
      )
      z <- names(forecasts[i])
      x <- data.frame(rep(as.character(z), nrow(x)), x)
      y[[i]] <- x
    }

    # combine list into a single dataframe -
    y <- data.table::rbindlist(y, fill = TRUE)

    # add the forecast description to the dataframe ----------------------------
    forecast <-
      data.frame(y[, -2], labs) # drop keyName colum from "y"
    names(forecast) <- c("aac", "value", "labs")

    # how many days are in the forecast? It may be 6 or 7 ----------------------
    indices <- xml2::xml_find_all(xmlforecast, "//forecast-period")
    indices <- trimws(xml2::xml_attrs(indices, "index"))
    days <- as.numeric(max(stringr::str_sub(indices, 4, 4)))

    # add dates to forecast ----------------------------------------------------
    forecast$date <-  c(rep(seq(
      lubridate::ymd(Sys.Date() + 1),
      lubridate::ymd(Sys.Date() + days),
      by = "1 day"
    ),
    each = 6))

    # spread columns -----------------------------------------------------------
    forecast <-
      forecast %>%
      reshape2::dcast(aac + date ~ labs, value.var = "value")

    # split precipitation forecast values into lower/upper limits --------------

    # format any values that are only zero to make next step easier
    forecast$precipitation_range[which(forecast$precipitation_range == "0 mm")] <-
      "0 mm to 0 mm"

    # separate the precipitation column into two, upper/lower limit ------------
    forecast <-
      forecast %>%
      tidyr::separate(
        precipitation_range,
        into = c("lower_prec_limit", "upper_prec_limit"),
        sep = "to"
      )

    # remove unnecessary text (mm in prcp cols) --------------------------------
    forecast <- lapply(forecast, function(x) {
      gsub(" mm", "", x)
    })

    # rename columns -----------------------------------------------------------
    forecast <- forecast[-5] # drop forecast_icon_code column

    names(forecast) <-
      c(
        "aac",
        "date",
        "max_temp",
        "min_temp",
        "lower_prcp_limit",
        "upper_prcp_limit",
        "precis",
        "prob_prcp"
      )

    # merge the forecast with the locations ------------------------------------

    # convert forecast_locations$aac to factor for merging
    forecast$aac <- as.character(forecast$aac)

    # return final forecast object ---------------------------------------------
    forecast  <-
      dplyr::left_join(tibble::as_tibble(forecast),
                       forecast_locations, by = "aac") %>%
      dplyr::select(-`parent-aac`) %>%
      dplyr::rename(lon = LON,
                    lat = LAT,
                    elev = ELEVATION) %>%
      dplyr::mutate(state = stringr::str_extract(forecast$aac,
                                                 pattern = "[:alpha:]{2,3}")) %>%
      dplyr::rename(location = description) %>%
      dplyr::select(aac:location, state, lon, lat, elev)
}

#' @noRd
.validate_state <-
  function(state) {
    if (!is.null(state)) {
      state <- toupper(trimws(state))
    } else
      stop("\nPlease provide a valid 2 or 3 letter state or territory postal code abbreviation")
  }
