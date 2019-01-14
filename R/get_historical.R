#' Obtain Historical BOM Data
#'
#' Retrieves daily observations for a given station.
#'
#' @md
#' @param stationid BOM station ID. See Details.
#' @param latlon Length-2 numeric vector of Latitude/Longitude. See Details.
#' @param type Measurement type, either daily "rain", "min" (temp), "max"
#'   (temp), or "solar" (exposure). Partial matching is performed. If not
#'   specified returns the first matching type in the order listed.
#' @return A \code{bomrang_tbl} object (extension of a 
#'   \code{\link[base]{data.frame}}) of historical observations for the chosen 
#'   station/product type, with some subset of the following columns
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
#'   **Quality**:\tab Y, N, or missing. Data which have not yet completed the\cr
#'               \tab routine quality control process are marked accordingly.
#'   }
#'   
#'   The following attributes are set on the data, and these are 
#'   used to generate the heaader
#'      
#'   \tabular{rl}{
#'   **site**:\tab BOM station ID.\cr
#'   **name**:\tab BOM station name.\cr
#'   **lat**:\tab Latitude in decimal degrees.\cr
#'   **lon**:\tab Longitude in decimal degrees.\cr
#'   **start**:\tab Date observations start.\cr
#'   **end**:\tab Date observations end.\cr
#'   **years**:\tab Available number of years data.\cr
#'   **percent**:\tab Percent complete.\cr
#'   **AWS**:\tab Automated weather station?\cr
#'   **type**:\tab Measurement types available for the station.\cr
#'   }
#'
#' @section Caution:
#'   Temperature data prior to 1910 should be used with extreme caution as many
#'   stations, prior to that date, were exposed in non-standard shelters, some
#'   of which give readings which are several degrees warmer or cooler than
#'   those measured according to post-1910 standards.
#'
#'   Daily maximum temperatures usually occur in the afternoon and daily minimum
#'   temperatures overnight or near dawn. Occasionally, however, the lowest
#'   temperature in the 24 hours to prior to 9 AM can occur around 9 AM the
#'   previous day if the night was particularly warm.
#'
#'   Either \var{stationid} or \var{latlon} must be provided, but if both are,
#'   then \var{stationid} will be used as it is more reliable.
#'
#'   In some cases data is available back to the 1800s, so tens of thousands of
#'   daily records will be returned. Other stations will be newer and will
#'   return fewer observations.
#'   
#' @section \code{dplyr} Compatibility: The \code{bomrang_tbl} class is
#'   compatible with \code{\link[dplyr]{dplyr}} as long as the \code{bomrang}
#'   package is on the search path. Common functions
#'   (\code{\link[dplyr]{filter}}, \code{\link[dplyr]{select}},
#'   \code{\link[dplyr]{arrange}}, \code{\link[dplyr]{mutate}},
#'   \code{\link[dplyr]{rename}}, \code{\link[dplyr]{arrange}},
#'   \code{\link[dplyr]{slice}}, \code{\link[dplyr]{group_by}}) are provided
#'   which mask the dplyr versions (but use those internally, maintaining
#'   attributes).
#'
#' @export
#' @author Jonathan Carroll, \email{rpkg@@jcarroll.com.au}
#'
#' @examples
#' \donttest{
#' get_historical(stationid = "023000", type = "max") ## ~48,000+ daily records
#' get_historical(latlon = c(-35.2809, 149.1300),
#'                type = "min") ## 3,500+ daily records
#' }
get_historical <-
  function(stationid = NULL,
           latlon = NULL,
           type = c("rain", "min", "max", "solar")) {
    
    site <- ncc_obs_code <- NULL #nocov
    
    if (is.null(stationid) & is.null(latlon))
      stop("stationid or latlon must be provided.",
           call. = FALSE)
    if (!is.null(stationid) & !is.null(latlon)) {
      warning("Only one of stationid or latlon may be provided. ",
              "Using stationid.")
    }
    if (is.null(stationid)) {
      if (!identical(length(latlon), 2L) || !is.numeric(latlon))
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
    ncc_list <- .get_ncc()
    
    if (suppressWarnings(all(is.na(as.numeric(stationid)) |
              as.numeric(stationid) %notin% ncc_list$site)))
      stop("\nStation not recognised.\n",
           call. = FALSE)
    
    type <- match.arg(type)
    obscode <- switch(
      type,
      rain = 136,
      min = 123,
      max = 122,
      solar = 193
    )
    
    ncc_list <- dplyr::filter(ncc_list, c(site == as.numeric(stationid) &
                                            ncc_obs_code == obscode))
    
    if (obscode %notin% ncc_list$ncc_obs_code)
      stop(call. = FALSE,
           "\n`type` ", type, " is not available for `stationid` ",
           stationid, "\n")
    
    zipurl <- .get_zip_url(stationid, obscode)
    dat <- .get_zip_and_load(zipurl)
    
    names(dat) <- c("Product_code",
                    "Station_number",
                    "Year",
                    "Month",
                    "Day",
                    switch(type,
                           min = c("Min_temperature",
                                   "Accum_days_min",
                                   "Quality"),
                           max = c("Max_temperature",
                                   "Accum_days_max",
                                   "Quality"),
                           rain = c("Rainfall",
                                    "Period",
                                    "Quality"),
                           solar = c("Solar_exposure")
                    ))

    return(structure(dat, 
                     class = union("bomrang_tbl", class(dat)),
                     station = stationid,
                     type = type,
                     origin = "historical",
                     location = ncc_list$name,
                     lat = ncc_list$lat,
                     lon = ncc_list$lon,
                     start = ncc_list$start,
                     end = ncc_list$end,
                     years = ncc_list$years,
                     ncc_list = ncc_list
                     ))
  }

