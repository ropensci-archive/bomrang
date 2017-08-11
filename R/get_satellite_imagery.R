
#' Get a listing of Available BoM Satellite Imagery
#'
#' Fetch a listing of BoM satellite imagery from
#' \url{ftp://ftp.bom.gov.au/anon/gen/gms/} to determine which files are
#' currently available for download.  Files are available at ten minute update
#' frequency with a 24 hour delete time.  Useful to know the most recent files
#' available and then specify in the \code{\link{get_satellite_imagery}}
#' function.
#'
#' @param product_id Character.  BoM product ID to download in GeoTIFF format
#' and import as a \code{\link{raster}} object, either as a single
#' \code{\link[raster]{raster}} layer or \code{\link[raster]{stack}} object.
#' Defaults to all images available for a requested BoM Product ID.
#'
#' @details Valid BoM satellite Product IDs include:
#'\describe{
#'\item{IDE00420}{AHI cloud cover only 2km FD GEOS GIS}
#'\item{IDE00421}{AHI IR (Ch13) greyscale 2km FD GEOS GIS}
#'\item{IDE00422}{AHI VIS (Ch3) greyscale 2km FD GEOS GIS}
#'\item{IDE00423}{AHI IR (Ch13) Zehr 2km FD GEOS GIS}
#'\item{IDE00425}{AHI VIS (true colour) / IR (Ch13 greyscale) composite 1km FD
#' GEOS GIS}
#'\item{IDE00426}{AHI VIS (true colour) / IR (Ch13 greyscale) composite 2km FD
#' GEOS GIS}
#'\item{IDE00427}{AHI WV (Ch8) 2km FD GEOS GIS}
#'\item{IDE00430}{AHI cloud cover only 2km AUS equirect. GIS}
#'\item{IDE00431}{AHI IR (Ch13) greyscale 2km AUS equirect. GIS}
#'\item{IDE00432}{AHI VIS (Ch3) greyscale 2km AUS equirect. GIS}
#'\item{IDE00433}{AHI IR (Ch13) Zehr 2km AUS equirect. GIS}
#'\item{IDE00435}{AHI VIS (true colour) / IR (Ch13 greyscale) composite 1km AUS
#' equirect. GIS}
#'\item{IDE00436}{AHI VIS (true colour) / IR (Ch13 greyscale) composite 2km AUS
#' equirect. GIS}
#'\item{IDE00437}{AHI WV (Ch8) 2km AUS equirect. GIS}
#'\item{IDE00439}{AHI VIS (Ch3) greyscale 0.5km AUS equirect. GIS}
#'}
#'
#' @return
#' A vector of all available files for the requested Product ID.
#'
#' @references
#' Himawari-8 and -9 Facts and Figures,
#' http://www.bom.gov.au/australia/satellite/himawari.shtml
#'
#' @examples
#' \dontrun{
#' Check availability of AHI VIS (true colour) / IR (Ch13 greyscale) composite
#' 1km FD GEOS GIS images
#' imagery <- available_images(product_id = "IDE00425")
#' }
#'
#' @author Adam H Sparks, \email{adamhsparks@gmail.com}
#'
#' @export
get_available_images <- function(product_id = NULL) {
  message("\nThe following files are currently available for download:\n")
  tif_files <- .ftp_images(product_id)
  write(tif_list, file = file.path(tempdir(), "tif_list"))
  print(tif_list)
}

#' Get BoM Satellite Imagery
#'
#' Fetch BoM satellite imagery from \url{ftp://ftp.bom.gov.au/anon/gen/gms/}
#' and return a raster \code{\link[raster]{stack} object of GeoTIFF files.
#' Files are available at ten minute update frequency with a 24 hour delete
#' time. Suggested to check file availability first by using
#' \code{\link{available_images}}.
#'
#' @param product_id Character.  BoM product ID to download in GeoTIFF format
#' and import as a \code{\link{raster}} object, either as a single
#' \code{\link{raster::raster}} layer or \code{\link{raster::stack}} object.
#' Defaults to all images available for a requested BoM Product ID.
#' @param scans Numeric.  Number of scans to download, starting with most recent
#' and progressing backwards, \emph{e.g.}, 1 - the most recent single scan
#' available , 6 - the most recent hour available, 12 - the most recent 2 hours
#' available, etc.. Defaults to 1.
#' @param cache Logical.  Store image files locally for later use?  If
#' \code{FALSE}, the downloaded files are removed when R session is closed. To
#' take advantage of cached files in future sessions, use \code{cache = TRUE}.
#' Defaults to \code{FALSE}.
#'
#' @details Valid BoM satellite Product IDs include:
#'\describe{
#'\item{IDE00420}{AHI cloud cover only 2km FD GEOS GIS}
#'\item{IDE00421}{AHI IR (Ch13) greyscale 2km FD GEOS GIS}
#'\item{IDE00422}{AHI VIS (Ch3) greyscale 2km FD GEOS GIS}
#'\item{IDE00423}{AHI IR (Ch13) Zehr 2km FD GEOS GIS}
#'\item{IDE00425}{AHI VIS (true colour) / IR (Ch13 greyscale) composite 1km FD
#' GEOS GIS}
#'\item{IDE00426}{AHI VIS (true colour) / IR (Ch13 greyscale) composite 2km FD
#' GEOS GIS}
#'\item{IDE00427}{AHI WV (Ch8) 2km FD GEOS GIS}
#'\item{IDE00430}{AHI cloud cover only 2km AUS equirect. GIS}
#'\item{IDE00431}{AHI IR (Ch13) greyscale 2km AUS equirect. GIS}
#'\item{IDE00432}{AHI VIS (Ch3) greyscale 2km AUS equirect. GIS}
#'\item{IDE00433}{AHI IR (Ch13) Zehr 2km AUS equirect. GIS}
#'\item{IDE00435}{AHI VIS (true colour) / IR (Ch13 greyscale) composite 1km AUS
#' equirect. GIS}
#'\item{IDE00436}{AHI VIS (true colour) / IR (Ch13 greyscale) composite 2km AUS
#' equirect. GIS}
#'\item{IDE00437}{AHI WV (Ch8) 2km AUS equirect. GIS}
#'\item{IDE00439}{AHI VIS (Ch3) greyscale 0.5km AUS equirect. GIS}
#'}
#'
#' @return
#' A single raster layer or stack of GeoTIFF images with layers named by time
#' stamp.
#'
#' @references
#' Himawari-8 and -9 Facts and Figures,
#' http://www.bom.gov.au/australia/satellite/himawari.shtml
#'
#' @examples
#' \dontrun{
#' Fetch AHI VIS (true colour) / IR (Ch13 greyscale) composite 1km FD
#' GEOS GIS raster stack for most recent single scan available
#' imagery <- get_satellite_imagery(product_id = "IDE00425", scans = 1)
#' }
#'
#' @references
#'
#' @author Adam H Sparks, \email{adamhsparks@gmail.com}
#'
#' @export
get_satellite_imagery <-
  function(product_id = NULL,
           scans = 1,
           cache = FALSE) {
    if (is.null(product_id)) {
      stop("\nYou must select a valid BoM satellite imagery Product ID\n")
    }

    cache_dir <- .set_cache(cache)

    if (any(grepl("tif_files", list.files(tempdir())))) {
      # read files already checked using available_images()---------------------
      tif_files <- readLines(file.path(tempdir(), "tif_files"))
    } else {
      # check what's on the server ---------------------------------------------
      tif_files <- .ftp_images(product_id)
    }

    # filter by number of scans requested --------------------------------------
    tif_files <- utils::tail(tif_files, scans)

    # check what files are available locally in the cache directory ------------
    local_files <-
      list.files(cache_dir, pattern = "^IDE.*\\tif$")

    # create list of files to download that don't exist locally ----------------
    tif_files <- tif_files[tif_files %notin% local_files]

    # download files from server -----------------------------------------------
    Map(
      function(urls, destination)
        utils::download.file(urls, destination, mode = "wb"),
      tif_files,
      file.path(cache_dir, basename(tif_files))
    )

    # create raster stack object of the GeoTIFF files --------------------------
    files <- list.files(cache_dir, pattern = ".tif$", full.names = TRUE)
    files <- files[tif_files %in% files]
    read_tif <- raster::stack(files)
    return(read_tif)
  }

#'@noRd
.ftp_images <- function(product_id) {
  # setup internal variables ---------------------------------------------------
  ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/gms/"
  list_files <- curl::new_handle()
  curl::handle_setopt(list_files,
                      ftp_use_epsv = TRUE,
                      dirlistonly = TRUE)

  # get file list from FTP server ----------------------------------------------
  con <- curl::curl(url = ftp_base,
                    "r",
                    handle = list_files)
  tif_files <- readLines(con)
  close(con)

  # filter only the GeoTIFF files ----------------------------------------------
  tif_files <- tif_files[grepl("^.*\\.tif", tif_files)]

  # select the Product ID requested from list of files -------------------------
  tif_files <- switch(
    product_id,
    "IDE00420" = {
      paste0(ftp_base,
             tif_files[grepl("IDE00420",
                             tif_files)])
    },
    "IDE00421" = {
      paste0(ftp_base,
             tif_files[grepl("IDE00421",
                             tif_files)])
    },
    "IDE00422" = {
      paste0(ftp_base,
             tif_files[grepl("IDE00422",
                             tif_files)])
    },
    "IDE00423" = {
      paste0(ftp_base,
             tif_files[grepl("IDE00423",
                             tif_files)])
    },
    "IDE00425" = {
      paste0(ftp_base,
             tif_files[grepl("IDE00425",
                             tif_files)])
    },
    "IDE00426" = {
      paste0(ftp_base,
             tif_files[grepl("IDE00426",
                             tif_files)])
    },
    "IDE00427" = {
      paste0(ftp_base,
             tif_files[grepl("IDE00427",
                             tif_files)])
    },
    "IDE00430" = {
      paste0(ftp_base,
             tif_files[grepl("IDE00430",
                             tif_files)])
    },
    "IDE00431" = {
      paste0(ftp_base,
             tif_files[grepl("IDE00431",
                             tif_files)])
    },
    "IDE00432" = {
      paste0(ftp_base,
             tif_files[grepl("IDE00432",
                             tif_files)])
    },
    "IDE00433" = {
      paste0(ftp_base,
             tif_files[grepl("IDE00433",
                             tif_files)])
    },
    "IDE00435" = {
      paste0(ftp_base,
             tif_files[grepl("IDE00435",
                             tif_files)])
    },
    "IDE00436" = {
      paste0(ftp_base,
             tif_files[grepl("IDE00436",
                             tif_files)])
    },
    "IDE00437" = {
      paste0(ftp_base,
             tif_files[grepl("IDE00437",
                             tif_files)])
    },
    paste0(ftp_base,
           tif_files[grepl("IDE00439",
                           tif_files)])
  )

  # check if the Product ID requested provides any files on server -------------
  if (length(tif_files == 1) && basename(tif_files) == "gms") {
    stop(paste0("\nSorry, no files are currently available for ", product_id))
  }
  return(tif_files)
}
