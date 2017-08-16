
context("Cache directory handling")
skip_on_cran()

test_that("cache directory is created if necessary", {
  # if cache directory exists during testing, remove it
  unlink(rappdirs::user_cache_dir(appname = "bomrang",
                                  appauthor = "bomrang"),
         recursive = TRUE)
  cache <- TRUE
  cache_dir <- .set_cache(cache)
  expect_true(dir.exists(
    rappdirs::user_cache_dir(appname = "bomrang",
                             appauthor = "bomrang")
  ))
})

test_that("caching utils list files in cache and delete when asked", {
  skip_on_cran()

  cache <- TRUE
  cache_dir <- .set_cache(cache)
  f <- raster::raster(system.file("external/test.grd", package = "raster"))
  cache_dir <- rappdirs::user_cache_dir(appname = "bomrang",
                           appauthor = "bomrang")
  raster::writeRaster(f, file.path(cache_dir, "file1.tif"), format = "GTiff")
  raster::writeRaster(f, file.path(cache_dir, "file2.tif"), format = "GTiff")

  # test bomrang cache list
  k <- list.files(rappdirs::user_cache_dir(appname = "bomrang",
                                           appauthor = "bomrang"))
  expect_equal(basename(bomrang_cache_list()), k)

  # test delete one file
  bomrang_cache_delete("file1.tif")
  l <- list.files(rappdirs::user_cache_dir(appname = "bomrang",
                                           appauthor = "bomrang"))
  expect_equal(basename(bomrang_cache_list()), l)

  # test delete all
  bomrang_cache_delete_all()
  expect_equal(basename(bomrang_cache_list()), character(0))

  # clean up on the way out
  unlink(rappdirs::user_cache_dir(appname = "bomrang",
                                  appauthor = "bomrang"),
         recursive = TRUE)
})
