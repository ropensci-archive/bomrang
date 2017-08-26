#' get_weather_bulletin
#'
#' Fetch the daily BoM 0900 or 1500 weather bulletins and return a tidy data
#' frame for a specified state or territory.
#'
#' @param state Australian state or territory as full name or postal code.
#' Fuzzy string matching via \code{\link[base]{agrep}} is done.
#' @param morning If \code{TRUE}, return the 9am bulletin for the nominated
#' state; otherwise return the 3pm bulletin.
#'
#' @details Allowed state and territory postal codes:
#'  \describe{
#'    \item{ACT}{Australian Capital Territory (will return NSW)}
#'    \item{NSW}{New South Wales}
#'    \item{NT}{Northern Territory}
#'    \item{QLD}{Queensland}
#'    \item{SA}{South Australia}
#'    \item{TAS}{Tasmania}
#'    \item{VIC}{Victoria}
#'    \item{WA}{Western Australia}
#'  }
#' It is not possible to return weather bulletins for the entire country in a
#' single call. Rainfall figures for the 9am bulletin are for the preceding 24
#' hours, while those for the 3pm bulletin are for the preceding 6 hours since
#' 9am.
#'
#' @return
#' Tidy data frame of Australian BoM daily observations.  For full details of
#' fields and units returned see Appendix 2 in the \emph{bomrang} vignette, use
#' \code{vignette("bomrang", package = "bomrang")} to view.
#'
#' @examples
#' \dontrun{
#' qld_weather <- get_weather_bulletin (state = "QLD", morning = FALSE)
#'}
#' @references
#' Daily observation data come from Australian Bureau of Meteorology (BoM)
#' webite. The 3pm bulletin for Queensland is, for example,
#' \url{http://www.bom.gov.au/qld/observations/3pm_bulletin.shtml}
#'
#' @author Mark Padgham, \email{mark.padgham@email.com}
#' @export
get_weather_bulletin <- function(state = "qld", morning = TRUE) {
  the_state <- convert_state (state) # see internal_functions.R
  if (the_state == "AUS")
    stop ("Weather bulletins can only be extracted for individual states")

  url_suffix <- "9am_bulletin.shtml"
  if (!is.logical (morning) | !morning)
    url_suffix <- "3pm_bulletin.shtml"

  # http server
  http_base <- "http://www.bom.gov.au/"
  wb_url <-
    paste0 (http_base, tolower (the_state), "/observations/",
            url_suffix)

  dat <- xml2::read_html (wb_url) %>%
    rvest::html_table (fill = TRUE)
  # WA includes extra tables of rainfall stats (9am) and daily extrema (3pm)
  if (the_state == "WA")
    dat [[length (dat)]] <- NULL
  dat <- lapply (dat, tidy_bulletin_header) %>%
    dplyr::bind_rows ()

  # much easier than dplyr::rename, and names vary between 9am and 3pm bulletins
  dat <- janitor::clean_names (dat)
  if (!the_state %in% c ("WA", "SA"))
  {
    names (dat) [which (grepl ("rain", names (dat)))] <- "rain_mm"
    # vars for subsequent tidying:
    vars <-
      c (
        "cld8ths",
        "temp_c_dry",
        "temp_c_dew",
        "temp_c_max",
        "temp_c_min",
        "temp_c_gr",
        "barhpa",
        "rain_mm"
      )
    vars <- vars [which (vars %in% names (dat))]
  } else
  {
    charvars <- c (
      "location",
      "stations",
      "current_details_weather",
      "current_details_winddir_spdkm_h"
    )
    vars <- names (dat) [which (!names (dat) %in% charvars)]
  }
  windvar <- names (dat) [which (grepl ("wind", names (dat)))]

  # bind_rows inserts NAs in all extra rows, so
  if ("seastate" %in% names (dat))
    dat$seastate [is.na (dat$seastate)] <- ""

  # Final manual cleaning:
  # cld8ths can have "#" to indicate fog so no cloud obs possible
  i <- which (grepl ("cld8ths", names (dat)))
  dat [, i] [dat [, i] == "#"] <- ""
  # A valid rain value is "Tce" for "Trace", which is here converted to 0.1
  i <- which (grepl ("rain", names (dat)))
  dat [, i] [dat [, i] == "Tce"] <- 0.1

  # Then just the tidy stuff:
  out <- tidyr::separate (
    dat,
    windvar,
    into = c("wind_dir", "wind_speed_kmh"),
    sep = "\\s+",
    fill = "right",
    convert = TRUE
  ) %>%
    dplyr::mutate_at(.funs = as.numeric,
                     .vars = vars)

  return (out)
}

#' tidy_bulletin_header
#'
#' @param bull A \code{data.frame} containing a single page of potentially
#' multi-page daily weather bulletin for a given state.
#' @return Same \code{data.frame} with header tidied up through removal of
#' extraneous first rows.
#'
#' @note This is the only bit that is a bit messy because the headers do not
#' conform to the structure of the actual table, and lots of header text gets
#' dumped in the first data.frame row. This function re-combines the
#' auto-generated names with the contents of the first row.
#'
#' @noRd
tidy_bulletin_header <- function(bull) {
  if (nrow (bull) <= 1) {
    return(NULL)
  }

  # remove filled rows containing district names only:
  bull <-
    bull[apply(bull, 1, function(i) any(i != i[1])), ]

  # Then tidy column names - the only really messy bit!
  r1 <- names(bull)
  r2 <- as.character(bull[1, ])
  if (sum(bull[, 1] == names(bull)[1]) == 1) {
    # Values of r2 need to be re-aligned through removing "TEMP (C)" and inserting
    # an additional empty value at the end
    r2 <- r2 [which (!grepl ("TEMP", r2))]
    if ("gr" %in% r2) {
      i <- which(r2 == "gr") # last former "TEMP (C)" value
      r2 <- r2[c(1:i, i:length(r2), length(r2))]
    } else if ("min" %in% r2 & "WEATHER" %notin% r2) {
      # nt only [STATIONS, CLD8THS, dir spd, dry, dew, max, min, 24hr/days
      # tas has same but with "WEATHER" as well
      i <- which (r2 == "min") # HP: As far as I can see this line is not used.
      r2 <- c(r2, data.table::last(r2))
    }
    r2[duplicated (r2)] <- ""
    r2[r2 == r1] <- ""
    r2 <- pad_white(r2)
    r2[grepl("nbsp", r2)] <- ""
    #names (bull) <- paste0 (r1, r2)
    nms <- paste0(r1, r2)
    names(bull) <- gsub(" %", "%", nms) # 9am & 3pm differ here
    bull <- bull[2:nrow(bull), ]
  } else if (sum(bull[, 1] == names(bull)[1]) == 2) {
    all_NA <- vapply(bull, function(i) all(is.na(i)), FALSE)
    if (any(all_NA)) {
      # SA 3pm
      i <- which(all_NA)
      indx <- setdiff(seq_along(bull), i)
      nms <- names(bull)[indx]
      bull <- bull[, indx]
      names(bull) <- nms
      r1 <- names(bull)
      r2 <- as.character(bull[1, ])
    }
    r3 <- as.character(bull [2, ])
    r2[is.na(r2)] <- ""
    r3[is.na(r3)] <- ""
    r3 <- c(r3[!grepl("TEMP ", r3, ignore.case = TRUE)], "")
    r3[r3 == r2] <- ""
    r2[r2 == r1] <- ""
    r3[r3 %in% c("LOCATION", "STATIONS")] <- ""
    r2 <- pad_white(r2)
    r3 <- pad_white(r3)
    names(bull) <- paste0(r1, r2, r3)
    bull <- bull[3:nrow(bull), ]
  } else {
    stop("Weather bulletin has unrecognised format")
  }

  return (bull)
}

pad_white <- function(x) {
  x[nzchar(x)] <- paste0(" ", x[nzchar(x)])
  return(x)
}
