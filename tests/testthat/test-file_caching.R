
context("Cache directory handling")

# test that .set_cache() creates a cache directory if none exists --------------
test_that("test that set_cache creates a cache directory if none exists", {
  skip_on_cran()
  # set up the cache in tempdir() for testing
  manage_cache$cache_path_set("foobar", type = "tempdir")
  cache <- TRUE
  .set_cache(cache)
  expect_true(dir.exists(manage_cache$cache_path_get()))
  # cleanup
  unlink(manage_cache$cache_path_get(),
         recursive = TRUE,
         force = TRUE)
})

# test that .set_cache() does a cache directory if cache is FALSE --------------

test_that("test that set_cache does not create a dir if cache == FALSE", {
  skip_on_cran()
  # set up the cache in tempdir() for testing
  manage_cache$cache_path_set("foobar", type = "tempdir")
  cache <- FALSE
  cache_dir <- .set_cache(cache)
  expect_true(cache_dir == tempdir())
})


test_that("cache directory is created if necessary", {
  # if cache directory exists during testing, remove it
  # clean up before testing
  skip_on_cran()
  if (dir.exists(manage_cache$cache_path_get())) {
    unlink(manage_cache$cache_path_get(),
           recursive = TRUE,
           force = TRUE)
  }
  cache <- TRUE
  cache_dir <- .set_cache(cache)
  expect_true(dir.exists(manage_cache$cache_path_get()))
})

# test that file lists and deletions are properly handled ----------------------

test_that("caching utils list files in cache and delete when asked", {
  skip_on_cran()
  manage_cache$cache_path_set("foobar", type = "tempdir")
  f <-
    raster::raster(system.file("external/test.grd", package = "raster"))
  cache_dir <- manage_cache$cache_path_get()
  raster::writeRaster(f, file.path(cache_dir, "file1.tif"), format = "GTiff")
  raster::writeRaster(f, file.path(cache_dir, "file2.tif"), format = "GTiff")
  
  # test bomrang cache list
  k <- basename(manage_cache$list())
  expect_equal(basename(manage_cache$list()), k)
  
  # file should not exist, expect error
  expect_error(manage_cache$delete("file1.asc"))
  
  # test delete one file
  manage_cache$delete("file1.tif")
  l <- basename(manage_cache$list())
  expect_equal(basename(manage_cache$list()), l)
  
  # test delete all
  manage_cache$delete_all()
  expect_equal(manage_cache$list(),
               character(0))
})
