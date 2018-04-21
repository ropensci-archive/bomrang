
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
#' \dontrun{get_historical(stationid = "023000", type = "max") ## 33,700+ daily records}
#' get_historical(latlon = c(-35.2809, 149.1300), type = "min") ## 3,500+ daily records
get_historical <-
  function(stationid = NULL,
           latlon = NULL,
           type = c("rain", "min", "max", "solar")) {
    if (is.null(stationid) &
        is.null(latlon))
      stop("stationid or latlon must be provided.",
           call. = FALSE)
    if (!is.null(stationid) & !is.null(latlon)) {
      warning("Only one of stationid or latlon may be provided. Using stationid.")
    }
    if (is.null(stationid)) {
      if (!identical(length(latlon), 2L) ||
          !is.numeric(latlon))
        stop("latlon must be a 2-element numeric vector.",
             call. = FALSE)
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
    JSONurl_site_list <- NULL
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
    .get_zip_and_load(zipurl)

  }