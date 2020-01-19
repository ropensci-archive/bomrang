
context("print.bomrang_tbl()")
test_that("print.bomrang_tbl() returns a proper header", {
  skip_on_cran()
  x <- capture.output(get_historical(latlon = c(-35.2809, 149.1300),
                                     type = "min"))
  expect_type(x, "character")
  expect_equal(x[[1]],
               "  --- Australian Bureau of Meteorology (BOM) Data Resource ---")
  expect_equal(x[[2]],
               "  (Original Request Parameters)")
  expect_equal(x[[3]],
               "  Station:\t\tCANBERRA AIRPORT [070351] ")
  expect_equal(x[[4]],
               "  Location:\t\tlat: -35.3088, lon: 149.2004")
  expect_equal(x[[5]],
               "  Measurement / Origin:\tMin / Historical")
})
