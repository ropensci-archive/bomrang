
context("Cache directory handling")

# test that .set_cache() creates a cache directory if none exists --------------
test_that("test that set_cache creates a cache directory if none exists", {
  skip_on_cran()
  unlink(rappdirs::user_cache_dir("bomrang"), recursive = TRUE)
  cache <- TRUE
  .set_cache(cache)
  expect_true(file.exists(file.path(rappdirs::user_cache_dir("bomrang"))))
  # cleanup
  unlink(rappdirs::user_cache_dir(appname = "bomrang",
                                  appauthor = "bomrang"))
})

# test that .set_cache() does a cache directory if cache is FALSE --------------

test_that("test that set_cache does not create a dir if cache == FALSE", {
  cache <- FALSE
  cache_dir <- .set_cache(cache)
  expect_true(cache_dir == tempdir())
})


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

# test that file lists and deletions are properly handled ----------------------

test_that("caching utils list files in cache and delete when asked", {
  skip_on_cran()
  unlink(rappdirs::user_cache_dir(appname = "bomrang",
                                  appauthor = "bomrang"))
  f <- raster::raster(system.file("external/test.grd", package = "raster"))
  cache_dir <- rappdirs::user_cache_dir(appname = "bomrang",
                                        appauthor = "bomrang")
  raster::writeRaster(f, file.path(cache_dir, "file1.tif"), format = "GTiff")
  raster::writeRaster(f, file.path(cache_dir, "file2.tif"), format = "GTiff")

  # test bomrang cache list
  k <- list.files(rappdirs::user_cache_dir(appname = "bomrang",
                                           appauthor = "bomrang"))
  expect_equal(basename(bomrang_cache_list()), k)

  # file should not exist, expect error
  expect_error(bomrang_cache_delete("file1.asc"))

  # test delete one file
  bomrang_cache_delete("file1.tif")
  l <- list.files(rappdirs::user_cache_dir(appname = "bomrang",
                                           appauthor = "bomrang"))
  expect_equal(basename(bomrang_cache_list()), l)

  # test delete all
  bomrang_cache_delete_all()
  expect_equal(list.files(rappdirs::user_cache_dir(appname = "bomrang",
                                                   appauthor = "bomrang")
  ),
  character(0))
}
)
