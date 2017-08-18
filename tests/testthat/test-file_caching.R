
context("Cache directory handling")

test_that("cache directory is created if necessary", {
  skip_on_cran()
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

  # clean up on the way out
  unlink(rappdirs::user_cache_dir(appname = "bomrang",
                                  appauthor = "bomrang"),
         recursive = TRUE)
})
