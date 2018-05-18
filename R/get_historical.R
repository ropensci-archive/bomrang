
#' Obtain Historical BOM Data
#'
#' Retrieves daily observations for a given station.
#'
#' @md
#' @param stationid BOM station ID. See Details.
#' @param latlon Length-2 numeric vector of Latitude/Longitude. See Details.
#' @param type Measurement type, either daily "rain", "min" (temp), "max"
#'   (temp), or "solar" (exposure). Partial matching is performed.
#'
#' @return a complete [data.frame] of historical observations for the chosen
#'   station, with some subset of the following columns
#'
#'   \tabular{rl}{
#'   **Product_code**:\tab BOM internal code.\cr
#'   **Station_number**:\tab BOM station ID.\cr
#'   **Year**:\tab Year of observation (YYYY).\cr
#'   **Month**:\tab Month of observation (1-12).\cr
#'   **Day**:\tab Day of observation (1-31).\cr
#'   **Min_temperature**:\tab Minimum daily recorded temperature (degrees C).\cr
#'   **Max_temperature**:\tab Maximum daily recorded temperature (degrees C).\cr
#'   **Accum_days_min**:\tab Accumulated number of days of minimum temperature.\cr
#'   **Accum_days_max**:\tab Accumulated number of days of maximum temperature.\cr
#'   **Rainfall**:\tab Daily recorded rainfall in mm.\cr
#'   **Period**:\tab Period over which rainfall was measured.\cr
#'   **Solar_exposure**:\tab Daily global solar exposure in MJ/m^2.\cr
#'   **Quality**:\tab Y, N, or missing. Data which have not yet completed the
#'   routine quality control process are marked accordingly.
#'   }
#'
#'   Temperature data prior to 1910 should be used with extreme caution as many
#'   stations, prior to that date, were exposed in non-standard shelters, some
#'   of which give readings which are several degrees warmer or cooler than
#'   those measured according to post-1910 standards.
#'
#'   Daily maximum temperatures usually occur in the afternoon and daily minimum
#'   temperatures overnight or near dawn. Occasionally, however, the lowest
#'   temperature in the 24 hours to prior to 9 am can occur around 9 am the
#'   previous day if the night was particularly warm.
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
#' \dontrun{
#' get_historical(stationid = "023000", type = "max") ## ~48,000+ daily records
#' get_historical(latlon = c(-35.2809, 149.1300),
#'                type = "min") ## 3,500+ daily records
#' }
get_historical <-
  function(stationid = NULL,
           latlon = NULL,
           type = c("rain", "min", "max", "solar")) {
    if (is.null(stationid) & is.null(latlon)) {
      stop("stationid or latlon must be provided.",
           call. = FALSE)
    }
    if (!is.null(stationid) & !is.null(latlon)) {
      warning("Only one of stationid or latlon may be provided. ",
              "Using stationid.")
    }
    if (is.null(stationid)) {
      if (!identical(length(latlon), 2L) || !is.numeric(latlon)) {
        stop("latlon must be a 2-element numeric vector.",
             call. = FALSE)
      }
        stationdetails <-
          sweep_for_stations(latlon = latlon)[1, , drop = TRUE]
        message("Closest station: ",
                stationdetails$site,
                " (",
                stationdetails$name,
                ")")
        stationid <- stationdetails$site
      }
    ## ensure station is known
    # CRAN NOTE avoidance
    JSONurl_site_list <- NULL # nocov
    load(system.file("extdata",
                     "JSONurl_site_list.rda",
                     package = "bomrang"))
    if (!stationid %in% JSONurl_site_list$site)
      stop("Station not recognised.",
           call. = FALSE)

    type <- match.arg(type)
    obscode <- switch(
      type,
      rain = 136,
      min = 123,
      max = 122,
      solar = 193
    )

    zipurl <- .get_zip_url(stationid, obscode)
    dat <- .get_zip_and_load(zipurl)

    names(dat) <- switch(type,
                         min = c("Product_code",
                                 "Station_number",
                                 "Year",
                                 "Month",
                                 "Day",
                                 "Min_temperature",
                                 "Accum_days_min",
                                 "Quality"),
                         max = c("Product_code",
                                 "Station_number",
                                 "Year",
                                 "Month",
                                 "Day",
                                 "Max_temperature",
                                 "Accum_days_max",
                                 "Quality"),
                         rain = c("Product_code",
                                  "Station_number",
                                  "Year",
                                  "Month",
                                  "Day",
                                  "Rainfall",
                                  "Period",
                                  "Quality"),
                         solar = c("Product_code",
                                   "Station_number",
                                   "Year",
                                   "Month",
                                   "Day",
                                   "Solar_exposure")
    )
    dat
  }
