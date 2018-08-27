
#' Get a Listing of Available BOM Radar Imagery
#'
#' Fetch a listing of available BOM radar imagery from
#' \url{ftp://ftp.bom.gov.au/anon/gen/radar/} to determine which files are
#' currently available for download.  The files available are the most recent 
#' radar imagery for each location, which are updated approximately every 6 to 
#' 10 minutes by the BOM. 
#'
#' @param radar_id Character.  BOM radar ID of interest for which a list of
#' available images will be returned.  Defaults to all images currently
#' available.
#'
#' @details Valid BOM radar Id for each location required.  
#'
#' @return
#' A data frame of all selected radar locations with location information and
#' product_ids. 
#'
#' @references
#' Australian Bureau of Meteorology (BOM) radar images
#' \url{http://www.bom.gov.au/australia/radar/}
#'
#' @examples
#' \dontrun{
#' Check availability radar imagey for Wollongong (radar_id = 3)
#' imagery <- get_available_radar(radar_id = "3")
#' }
#'
#' @author Dean Marchiori, \email{deanmarchiori@@gmail.com}
#'
#' @export
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
    dat <- dat[dat$Radar_id %in% as.numeric(radar_id), ]
  } else{
    stop("radar_id not found")
  }
  return(dat)
}

#' Get BOM Radar Imagery
#'
#' Fetch BOM radar imagery from
#' \url{ftp://ftp.bom.gov.au/anon/gen/radar/} and return a raster
#' \code{\link[raster]{raster}} object. Files available are the most recent 
#' radar snapshot which are updated approximately every 6 to 10 minutes. 
#' Suggested to check file availability first by using
#' \code{\link{get_available_radar}}.
#'
#' @param product_id Character.  BOM product ID to download and import as a 
#' \code{\link[raster]{raster}} object. Value is required.
#'
#' @details Valid BOM satellite Product IDs for radar imagery can be obtained
#' from \code{\link{get_available_radar}}.
#'
#'@seealso
#'\code{\link{get_available_radar}}
#'
#' @return
#' A raster layer based on the most recent `.gif` radar image snapshot published
#' by the BOM.
#'
#' @references
#' Australian Bureau of Meteorology (BOM) radar images
#' \url{http://www.bom.gov.au/australia/radar/}
#'
#' @examples
#' \dontrun{
#' # Fetch most recent radar image for Wollongong 256km radar
#'
#' imagery <- get_radar_imagery(product_id = "IDR032")  
#' raster::plot(imagery)
#'
#' }
#' 
#' @author Dean Marchiori, \email{deanmarchiori@@gmail.com}
#' @export
get_radar_imagery <- function(product_id = NULL) {
  if (is.null(product_id)) {
    stop("\nYou must select a valid BOM radar imagery Product ID.\n",
         call. = FALSE)
  }
  if (length(product_id) != 1) {
    stop("\nbomrang only supports working with one Product ID at a time",
        "for radar images\n",
         call. = FALSE)
  }
  ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/radar"
  fp <- file.path(ftp_base, paste0(product_id, ".gif"))
  tf <- tempfile(fileext = ".gif", tmpdir = tempdir())
  download.file(url = fp, destfile = tf, mode = "wb") 
  y <- raster::raster(x = tf)
  y[is.na(y)] <- 999
  return(y)
}