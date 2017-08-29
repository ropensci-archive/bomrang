
`%notin%` <- Negate("%in%")

force_double <- function(v) {
  suppressWarnings(as.double(v))
}

# Distance over a great circle. Reasonable approximation.
haversine_distance <- function(lat1, lon1, lat2, lon2) {
  # to radians
  lat1 <- lat1 * pi / 180
  lat2 <- lat2 * pi / 180
  lon1 <- lon1 * pi / 180
  lon2 <- lon2 * pi / 180

  delta_lat <- abs(lat1 - lat2)
  delta_lon <- abs(lon1 - lon2)

  # radius of earth
  6371 * 2 * asin(sqrt(`+`(
    (sin(delta_lat / 2)) ^ 2,
    cos(lat1) * cos(lat2) * (sin(delta_lon / 2)) ^ 2
  )))
}

#' @noRd
.set_cache <- function(cache) {
  if (isTRUE(cache)) {
    cache_dir <- rappdirs::user_cache_dir("bomrang")
    if (!dir.exists(cache_dir)) {
      dir.create(
        rappdirs::user_cache_dir(appname = "bomrang",
                                 appauthor = "bomrang"),
        recursive = TRUE
      )
    }
  } else {
    cache_dir <- tempdir()
  }
  return(cache_dir)
}


#' @noRd

# Check states for précis and ag bulletin, use fuzzy matching

.check_states <- function(state) {
  states <- c(
    "ACT",
    "NSW",
    "NT",
    "QLD",
    "SA",
    "TAS",
    "VIC",
    "WA",
    "Canberra",
    "New South Wales",
    "Northern Territory",
    "Queensland",
    "South Australia",
    "Tasmania",
    "Victoria",
    "Western Australia",
    "Australia",
    "AU",
    "AUS",
    "Oz"
  )

  if (state %in% states) {
    the_state <- toupper(state)
    return(the_state)
  } else {
    likely_states <- agrep(pattern = state,
                           x = states,
                           value = TRUE)

    if (length(likely_states) == 1) {
      the_state <- toupper(likely_states)
      message(
        paste0(
          "\nUsing state = ",
          likely_states,
          ".\n",
          "If this is not what you intended, please check your entry."
        )
      )
      return(the_state)
    } else if (length(likely_states) == 0) {
      stop(
        "\nA state or territory matching what you entered was not found.",
        "Please check and try again.\n"
      )
    }
  }

  if (length(likely_states) > 1) {
    message(
      "Multiple states match state.",
      "'\ndid you mean:\n\tstate = '",
      paste(likely_states[1],
            "or",
            likely_states[2],
            "or",
            likely_states[3]),
      "'?"
    )
  }
}

#' convert_state
#'
#' Convert state to standard abbreviation
#' @noRd
convert_state <- function(state) {
  state <- gsub(" ", "", state)
  state <-
    substring(gsub("[[:punct:]]", "", tolower(state)), 1, 2)

  state_code <- c(
    "NSW",
    "NSW",
    "VIC",
    "VIC",
    "QLD",
    "QLD",
    "QLD",
    "WA",
    "WA",
    "WA",
    "SA",
    "SA",
    "SA",
    "TAS",
    "TAS",
    "ACT",
    "NT",
    "NT"
  )
  state_names <- c(
    "ne",
    "ns",
    "vi",
    "v",
    "ql",
    "qe",
    "q",
    "wa",
    "we",
    "w",
    "s",
    "sa",
    "so",
    "ta",
    "t",
    "ac",
    "no",
    "nt"
  )
  state <- state_code[pmatch(state, state_names)]

  if (any(is.na(state)))
    stop("Unable to determine state")

  return(state)
}
