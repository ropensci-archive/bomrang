


context("Satellite imagery")

test_that("Error handling", {
  skip_on_cran()
  expect_error(get_available_imagery(product_id = "abcdc"))
  expect_error(get_satellite_imagery(product_id = "abcdc"))
  expect_error(get_satellite_imagery())
})

test_that("get_available_imagery functions properly", {
  skip_on_cran()
  # if cache directory exists during testing, remove it for following tests
  unlink(rappdirs::user_cache_dir(appname = "bomrang",
                                  appauthor = "bomrang"),
         recursive = TRUE)

  i <- get_available_imagery()
  expect_type(i, "character")
  expect_error(get_satellite_imagery(product_id = c("IDE00425", "IDE00420")))
  j <-
    get_satellite_imagery(product_id = "IDE00425",
                          scans = 1,
                          cache = TRUE)
  expect_is(j, "RasterStack")
  expect_true(dir.exists(
    rappdirs::user_cache_dir(appname = "bomrang",
                             appauthor = "bomrang")
  ))

})

test_that("caching utils list files in cache and delete when asked", {
  skip_on_cran()

  # create a second file for more testing in next test
  logo <-
    raster::raster(system.file("external/rlogo.grd", package = "raster"))
  raster::writeRaster(logo,
                      file.path(
                        rappdirs::user_cache_dir(appname = "bomrang",
                                                 appauthor = "bomrang"),
                        "logo.tif"
                      ),
                      format = "GTiff")

  k <- list.files(rappdirs::user_cache_dir(appname = "bomrang",
                                           appauthor = "bomrang"))
  expect_equal(basename(bomrang_cache_list()), k)

  # delete the first file in the list, check bomrang_cache_delete
  bomrang_cache_delete(files = k[1])

  l <- list.files(rappdirs::user_cache_dir(appname = "bomrang",
                                           appauthor = "bomrang"))
  expect_equal(basename(bomrang_cache_list()), k[2])

  # check bomrang_cache_delete_all
  bomrang_cache_delete_all()
  expect_equal(basename(bomrang_cache_list()), character(0))
})

test_that("bomrang_cache_details lists files in cache", {
  k <- list.files(rappdirs::user_cache_dir(appname = "bomrang",
                                           appauthor = "bomrang"))
  expect_equal(bomrang_cache_list(), k)

  # cleanup after testing
  unlink(rappdirs::user_cache_dir(appname = "bomrang",
                                  appauthor = "bomrang"),
         recursive = TRUE)

})


test_that("product ID urls are properly handled", {
  skip_on_cran()
  ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/gms/"

  pid <- "IDE00420"
  x <- .ftp_images(product_id = pid, ftp_base)
  expect_equal(substr(basename(x), 1, 8)[1], pid)

  pid <- "IDE00421"
  x <- .ftp_images(product_id = pid, ftp_base)
  expect_equal(substr(basename(x), 1, 8)[1], pid)

  pid <- "IDE00422"
  x <- .ftp_images(product_id = pid, ftp_base)
  expect_equal(substr(basename(x), 1, 8)[1], pid)

  pid <- "IDE00423"
  x <- .ftp_images(product_id = pid, ftp_base)
  expect_equal(substr(basename(x), 1, 8)[1], pid)

  pid <- "IDE00425"
  x <- .ftp_images(product_id = pid, ftp_base)
  expect_equal(substr(basename(x), 1, 8)[1], pid)

  pid <- "IDE00426"
  x <- .ftp_images(product_id = pid, ftp_base)
  expect_equal(substr(basename(x), 1, 8)[1], pid)

  pid <- "IDE00427"
  x <- .ftp_images(product_id = pid, ftp_base)
  expect_equal(substr(basename(x), 1, 8)[1], pid)

  pid <- "IDE00430"
  x <- .ftp_images(product_id = pid, ftp_base)
  expect_equal(substr(basename(x), 1, 8)[1], pid)

  pid <- "IDE00431"
  x <- .ftp_images(product_id = pid, ftp_base)
  expect_equal(substr(basename(x), 1, 8)[1], pid)

  pid <- "IDE00432"
  x <- .ftp_images(product_id = pid, ftp_base)
  expect_equal(substr(basename(x), 1, 8)[1], pid)

  pid <- "IDE00433"
  x <- .ftp_images(product_id = pid, ftp_base)
  expect_equal(substr(basename(x), 1, 8)[1], pid)

  pid <- "IDE00435"
  x <- .ftp_images(product_id = pid, ftp_base)
  expect_equal(substr(basename(x), 1, 8)[1], pid)

  pid <- "IDE00436"
  x <- .ftp_images(product_id = pid, ftp_base)
  expect_equal(substr(basename(x), 1, 8)[1], pid)

  pid <- "IDE00437"
  x <- .ftp_images(product_id = pid, ftp_base)
  expect_equal(substr(basename(x), 1, 8)[1], pid)

  #   This product ID doesn't seem to have images associated with it, in spite of
  #   being valid
  #   pid <- "IDE00439"
  #   x <- .ftp_images(product_id = pid, ftp_base)
  #   expect_equal(substr(basename(x), 1, 8)[1], pid)

  pid <- "IDE30"
  expect_error(.ftp_images(product_id = pid, ftp_base))
})
