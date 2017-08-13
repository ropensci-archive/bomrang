context("Satellite imagery")

test_that("Error handling", {
  expect_error(get_available_imagery(product_id = "abcdc"))
  expect_error(get_satellite_imagery(product_id = "abcdc"))
  expect_error(get_satellite_imagery())
})

test_that("get_available_imagery functions properly", {
  i <- get_available_imagery()
  expect_type(i, "character")
  j <- get_satellite_imagery(i[1], scans = 1, cache = TRUE)
  expect_is(j, "RasterStack")
  expect_true(dir.exists(
    rappdirs::user_cache_dir(appname = "bomrang",
                             appauthor = "bomrang")
  ))
})

# test_that("product ID urls are properly handled", {
#   ftp_base <- "ftp://ftp.bom.gov.au/anon/gen/gms/"
#
#   pid <- "IDE00420"
#    <- .ftp_images(product_id = pid)
#   expect_equal(,
#                paste0("ftp://ftp.bom.gov.au/anon/gen/gms/", pid))
#
#   pid <- "IDE00421"
#   expect_equal(.ftp_images(product_id = pid),
#                paste0("ftp://ftp.bom.gov.au/anon/gen/gms/", pid))
#
#   pid <- "IDE00422"
#   expect_equal(.ftp_images(product_id = pid),
#                paste0("ftp://ftp.bom.gov.au/anon/gen/gms/", pid))
#
#   pid <- "IDE00423"
#   expect_equal(.ftp_images(product_id = pid),
#                paste0("ftp://ftp.bom.gov.au/anon/gen/gms/", pid))
#
#   pid <- "IDE00425"
#   expect_equal(.ftp_images(product_id = pid),
#                paste0("ftp://ftp.bom.gov.au/anon/gen/gms/", pid))
#
#   pid <- "IDE00426"
#   expect_equal(.ftp_images(product_id = pid),
#                paste0("ftp://ftp.bom.gov.au/anon/gen/gms/", pid))
#
#   pid <- "IDE00427"
#   expect_equal(.ftp_images(product_id = pid),
#                paste0("ftp://ftp.bom.gov.au/anon/gen/gms/", pid))
#
#   pid <- "IDE00430"
#   expect_equal(.ftp_images(product_id = pid),
#                paste0("ftp://ftp.bom.gov.au/anon/gen/gms/", pid))
#
#   pid <- "IDE00431"
#   expect_equal(.ftp_images(product_id = pid),
#                paste0("ftp://ftp.bom.gov.au/anon/gen/gms/", pid))
#
#   pid <- "IDE00432"
#   expect_equal(.ftp_images(product_id = pid),
#                paste0("ftp://ftp.bom.gov.au/anon/gen/gms/", pid))
#
#   pid <- "IDE00433"
#   expect_equal(.ftp_images(product_id = pid),
#                paste0("ftp://ftp.bom.gov.au/anon/gen/gms/", pid))
#
#   pid <- "IDE00435"
#   expect_equal(.ftp_images(product_id = pid),
#                paste0("ftp://ftp.bom.gov.au/anon/gen/gms/", pid))
#
#   pid <- "IDE00436"
#   expect_equal(.ftp_images(product_id = pid),
#                paste0("ftp://ftp.bom.gov.au/anon/gen/gms/", pid))
#
#   pid <- "IDE00437"
#   expect_equal(.ftp_images(product_id = pid),
#                paste0("ftp://ftp.bom.gov.au/anon/gen/gms/", pid))
#
#   rm(pid)
#   expect_equal(.ftp_images(product_id = pid),
#                paste0("ftp://ftp.bom.gov.au/anon/gen/gms/", "IDE00439"))
# })
