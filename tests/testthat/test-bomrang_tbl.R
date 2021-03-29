
test_that("print.bomrang_tbl() returns a proper header", {
  skip_on_cran()
  x <-
    capture.output(get_historical_weather(latlon = c(-35.2809, 149.1300),
                                          type = "min"))
  expect_type(x, "character")
  expect_equal(
    x[[1]],
    crayon::strip_style("  --- Australian Bureau of Meteorology (BOM) Data Resource ---")
  )
  expect_equal(x[[2]],
               crayon::strip_style("  (Original Request Parameters)"))
  expect_equal(x[[3]],
               crayon::strip_style("  Station:\t\tCANBERRA AIRPORT [070351] "))
  expect_equal(x[[4]],
               crayon::strip_style("  Location:\t\tlat: -35.3088, lon: 149.2004"))
  expect_equal(x[[5]],
               crayon::strip_style("  Measurement / Origin:\tMin / Historical"))
})
