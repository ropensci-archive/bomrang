
#' Get a listing of available BOM radar imagery
#'
#' Fetch a listing of available \acronym{BOM} \acronym{radar} imagery from
#' \url{ftp://ftp.bom.gov.au/anon/gen/radar/} to determine which files are
#' currently available for download.  The files available are the most recent
#' \acronym{radar} imagery for each location, which are updated approximately
#' every 6 to 10 minutes by the \acronym{BOM}.
#'
#' @param radar_id Character. \acronym{BOM} radar \acronym{ID} of interest for
#' which a list of available images will be returned.  Defaults to all images
#' currently available.
#'
#' @details Valid \acronym{BOM} \acronym{radar} ID for each location required.
#'
#' @return
#' A data frame of all selected \acronym{radar} locations with location
#' information and \var{product_ids}.
#'
#' @references
#' Australian Bureau of Meteorology (BOM) radar images 
#' \url{http://www.bom.gov.au/australia/radar/}
#'
#' @examples
#' \donttest{
#' # Check availability radar imagey for Wollongong (radar_id = 3)
#' imagery <- get_available_radar(radar_id = "3")
#' }
#'
#' @author Dean Marchiori, \email{deanmarchiori@@gmail.com}
#'
#' @export get_available_radar

get_available_radar <- function(radar_id = "all") {
  ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/radar/"
  radar_locations <- NULL #nocov
  load(system.file("extdata", "radar_locations.rda", package = "bomrang"))
  list_files <- curl::new_handle()
  curl::handle_setopt(list_files,
                      ftp_use_epsv = TRUE,
                      dirlistonly = TRUE)
  con <- curl::curl(url = ftp_base, "r", handle = list_files)
  files <- readLines(con)
  close(con)
  gif_files <- files[grepl("^.*\\.gif", files)]
  product_id <- substr(gif_files, 1, nchar(gif_files) - 4)
  LocationID <- substr(product_id, 4, 5)
  range <- substr(product_id, 6, 6)
  dat <- cbind.data.frame(product_id,
                          LocationID,
                          range,
                          stringsAsFactors = FALSE) %>%
    dplyr::left_join(radar_locations, by = "LocationID") %>%
    dplyr::mutate(
      range  = dplyr::case_when(
        range == 1 ~ "512km",
        range == 2 ~ "256km",
        range == 3 ~ "128km",
        range == 4 ~ "64km"
      )
    )
  if (radar_id[1] == "all") {
    dat <- dat
  } else if (as.numeric(radar_id) %in% dat$Radar_id) {
    dat <- dat[dat$Radar_id %in% as.numeric(radar_id),]
  } else{
    stop("radar_id not found")
  }
  return(dat)
}

#' Get \acronym{BOM} radar imagery
#'
#' Fetch \acronym{BOM} radar imagery from
#' \url{ftp://ftp.bom.gov.au/anon/gen/radar/} and return a
#' \code{\link[raster]{raster}} layer object.  Files available are the most
#' recent radar snapshot which are updated approximately every 6 to 10 minutes.
#' Suggested to check file availability first by using
#' \code{\link{get_available_radar}}.
#'
#' @param product_id Character. \acronym{BOM} product ID to download and import
#' as a \code{\link[raster]{raster}} object.  Value is required.
#'
#' @param path Character. A character string with the name where the downloaded
#' file is saved. If not provided, the default value \code{NULL} is used which
#' saves the file in a temp directory.
#'
#' @param download_only Logical. Whether the radar image is loaded into the
#' environment as a \code{\link[raster]{raster}} layer, or just downloaded.
#'
#' @details Valid \acronym{BOM} \acronym{Radar} Product IDs for radar imagery
#' can be obtained from \code{\link{get_available_radar}}.
#'
#'@seealso
#'\code{\link{get_available_radar}}
#'
#' @return
#' A raster layer based on the most recent `.gif' \acronym{radar} image snapshot
#' published by the \acronym{BOM}. If \code{download_only = TRUE} there will be
#' a `NULL` return value with the download path printed in the console as a
#' message.
#'
#' @references
#' Australian Bureau of Meteorology (\acronym{BOM}) radar images\cr
#' \url{http://www.bom.gov.au/australia/radar/}
#'
#' @examples
#' \donttest{
#' # Fetch most recent radar image for Wollongong 256km radar
#' library(raster)
#' imagery <- get_radar_imagery(product_id = "IDR032")
#' plot(imagery)
#'
#' # Save imagery to a local path
#' imagery <- get_radar_imagery(product_id = "IDR032", path = "image.gif")
#' }
#'
#' @author Dean Marchiori, \email{deanmarchiori@@gmail.com}
#' @rdname get_radar_imagery
#' @export get_radar_imagery

get_radar_imagery <- get_radar <-
  function(product_id,
           path = NULL,
           download_only = FALSE) {
    if (length(product_id) != 1) {
      stop(
        "\nbomrang only supports working with one Product ID at a time",
        "for radar images\n",
        call. = FALSE
      )
    }
    
    ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/radar"
    fp <- file.path(ftp_base, paste0(product_id, ".gif"))
    
    if (is.null(path)) {
      path <- tempfile(fileext = ".gif", tmpdir = tempdir())
    }
    tryCatch({
      if (download_only == TRUE) {
        curl::curl_download(
          url = fp,
          destfile = path,
          mode = "wb",
          quiet = TRUE
        )
        message("file downloaded to:", path)
      } else {
        curl::curl_download(
          url = fp,
          destfile = path,
          mode = "wb",
          quiet = TRUE
        )
        message("file downloaded to:", path)
        y <- raster::raster(x = path)
        y[is.na(y)] <- 999
        return(y)
      }
    },
    error = function() {
      return(raster::raster(
        system.file("error_images",
                    "image_error_message.png",
                    package = "bomrang")
      ))
    })
  }

# Export raster plot functionality to plot radar imagery
#' @importFrom raster plot
#' @export
raster::plot
