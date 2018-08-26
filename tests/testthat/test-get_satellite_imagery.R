
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
  unlink(manage_cache$cache_path_get(),
         recursive = TRUE)

  i <- get_available_imagery()
  expect_type(i, "character")
  expect_error(get_satellite_imagery(product_id = c("IDE00425", "IDE00420")))
  j <-
    get_satellite_imagery(product_id = "IDE00425",
                          scans = 1,
                          cache = TRUE)
  expect_is(j, "RasterStack")
  expect_true(dir.exists(manage_cache$cache_path_get()))

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

  #   This product ID doesn't seem to have images associated with it,
  #   in spite of being valid
  #   "IDE00439"

  pid <- "IDE30"
  expect_error(.ftp_images(product_id = pid, ftp_base))
})
