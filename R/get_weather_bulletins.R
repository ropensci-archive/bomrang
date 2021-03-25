
#' Get BOM 0900 or 1500 weather bulletin
#'
#' Fetch the daily \acronym{BOM} 0900 or 1500 weather bulletins and return a
#' data frame for a specified state or territory.
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
#' single call. Rainfall figures for the 9am bulletin are generally for the
#' preceding 24 hours, while those for the 3pm bulletin are for the preceding 6
#' hours since 9am. Note that values are manually entered into the bulletins and
#' sometimes contain typographical errors which may lead to warnings about
#' \code{"NAs introduced by coercion"}.
#'
#' @return
#' Data frame as a \code{\link[data.table]{data.table}} object of Australian 9am
#' or 3pm weather observations for a state.  For full details of fields and
#' units returned see Appendix 4, "Appendix 4 - Output from
#' get_weather_bulletin()" in the \CRANpkg{bomrang} vignette, use \cr
#' \code{vignette("bomrang", package = "bomrang")} to view.
#'
#' @examples
#' \donttest{
#' qld_weather <- get_weather_bulletin(state = "QLD", morning = FALSE)
#' qld_weather
#'}
#' @references
#' Daily observation data come from Australian Bureau of Meteorology (BOM)
#' website. The 3pm bulletin for Queensland is, for example, \cr
#' \url{http://www.bom.gov.au/qld/observations/3pm_bulletin.shtml}
#'
#' @author Mark Padgham, \email{mark.padgham@@email.com}
#' @export get_weather_bulletin

get_weather_bulletin <- function(state = "qld", morning = TRUE) {

  na_if <- NULL
  
  the_state <- .convert_state(state) # see internal_functions.R
  if (the_state == "AUS") {
    stop(call. = FALSE,
         "Weather bulletins can only be extracted for individual states.")
  }

  if (morning) {
    url_suffix <- "9am_bulletin.shtml"
  } else {
    url_suffix <- "3pm_bulletin.shtml"
  }

  # http server
  http_base <- "http://www.bom.gov.au/"
  wb_url <- paste0(http_base,
                   tolower(the_state),
                   "/observations/",
                   url_suffix)

  dat <- xml2::read_html(wb_url) %>%
    rvest::html_table(fill = TRUE)
  # WA includes extra tables of rainfall stats (9am) and daily extrema (3pm)
  if (the_state == "WA") {
    dat[[length(dat)]] <- NULL
  }

  dat <- lapply(dat, tidy_bulletin_header) %>%
    dplyr::bind_rows() %>%
    janitor::clean_names(case = "old_janitor") %>%
    janitor::remove_empty("cols")

  names(dat) <- gsub("\\_nbsp", "", names (dat))
  names(dat) <- gsub ("rainmm", "rain_mm", names (dat))

  if (the_state %notin% c("WA", "SA")) {
    # vars for subsequent tidying:
    vars <-
      c(
        "cld8ths",
        "temp_c_dry",
        "temp_c_dew",
        "temp_c_max",
        "temp_c_min",
        "temp_c_gr",
        "barhpa",
        "rain_mm"
      )
    vars <- vars[vars %in% names(dat)]
  } else {
    charvars <- c(
      "location",
      "stations",
      "current_details_weather",
      "current_details_winddir_spdkm_h"
    )
    vars <- setdiff(names(dat), charvars)
  }
  windvar <- grep("wind", names(dat))

  # Final manual cleaning:
  # bind_rows inserts NAs in all extra rows, so
  i <- grep("seastate", names (dat))
  dat[, i][is.na(dat[, i])] <- ""
  # cld8ths can have "#" to indicate fog so no cloud obs possible
  i <- grep("cld8ths", names(dat))
  dat[, i][dat[, i] == "#"] <- ""
  # A valid rain value is "Tce" for "Trace", which is here converted to 0.1
  i <- grep("rain", names(dat))
  dat[, i][dat[, i] == "Tce"] <- "0.1"

  # Then just the tidy stuff:
  out <- tidyr::separate(
    dat,
    windvar,
    into = c("wind_dir", "wind_speed_kmh"),
    sep = "\\s+",
    fill = "right",
    convert = TRUE
  ) %>%
    dplyr::mutate_at(.funs = as.numeric,
                     .vars = vars) %>%
    dplyr::mutate_all(list(~dplyr::na_if(., "")))
  

  names(out) <- sub("current_details_", "", names(out))
  names(out) <- sub("x24_hour_details_", "", names(out))
  names(out) <- sub("x6_hour_details_", "", names(out))

  out <- data.table::setDT(out)

  # DT auto-coverts most var types, but fails on these.
  # The code is written to avoid DT warnings on NA conversion
  col_convert <- function (x, colname, fn) {
      i <- grep (colname, names (x))
      nm <- names (x) [i]
      val <- do.call (fn, list (x [, get (nm)]))
      x [, i] <- val
      return (x)
  }

  out <- col_convert (out, "cld8ths", as.integer)
  out <- col_convert (out, "rain_mm", as.numeric)

  return (out)
}

#' tidy_bulletin_header
#'
#' @param bull A \code{data.frame} containing a single page of potentially
#' multi-page daily weather bulletins for a given state.
#'
#' @return Same \code{data.frame} with header tidied up through removal of
#' extraneous first rows.
#'
#' @noRd
tidy_bulletin_header <- function(bull) {
  if (nrow(bull) <= 1) {
    return(NULL)
  }

  # remove filled rows containing district names only:
  bull <- bull[apply(bull, 1, function(i)
                     any(i != i[1])), ]

  bull <- merge_first_two_rows (bull)
  bull <- merge_header_plus_row (bull)

  return (bull)
}

pad_white <- function(x) {
  x[nzchar(x)] <- paste0(" ", x[nzchar(x)])
  return(x)
}

# The headers for some bulletins like WA are read as colunm names PLUS the first
# TWO rows of the table. This function checks if the first 2 rows are parts of
# column names, and merges them into one row
merge_first_two_rows <- function(x) {

    if (x [1, 1, drop = TRUE] != x [2, 1, drop = TRUE])
        return (x)

    row1 <- unname (unlist (x [1, ]))
    row2 <- unname (unlist (x [2, ]))
    row2 [row2 == row1] <- ""
    row2 [which (row2 != "")] <- paste0 (" ", row2 [which (row2 != "")])

    row1 <- paste0 (row1, row2)

    x <- x [-2, ]
    for (r in seq_along (row1))
        x [1, r] <- row1 [r]

    return (x)
}

merge_header_plus_row <- function (x) {

    if (sum(x[,1] == names(x)[1]) != 1)
        return (x)

    cnms <- names (x)
    row1 <- unname (unlist (x [1, ]))
    row1 [row1 == cnms] <- ""
    row1 [row1 != ""] <- paste0 (" ", row1 [row1 != ""])

    names (x) <- paste0 (cnms, row1)
    x <- x [-1, ]
}

convert_var_types <- function (x) {

    intvars <- c ("cld8ths",
                  "wind_speed",
                  "bar")
    dblvars <- c ("temp_c")

    for (i in intvars) {
        index <- grep (i, names (x))
        x [, index] <- as.integer (x [, index, drop = TRUE])
    }
    for (i in dblvars) {
        index <- grep (i, names (x))
        x [, index] <- as.numeric (x [, index])
    }
}
