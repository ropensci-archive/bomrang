context("Historical Observations")

test_that("Error handling", {
  expect_error(get_historical(), regexp = "stationid.*latlon.*provided")
  expect_error(get_historical("sodiuhfosdhfoisdh"),
               regexp = "Station not recognised")
  expect_error(get_historical(1), regexp = "Station not recognised.")
  expect_error(get_historical("1"), regexp = "Station not recognised.")
  expect_error(get_historical("023001"), regexp = "Station not recognised.")
  expect_error(get_historical(latlon = 1), regexp = "2-element")
  expect_error(get_historical(latlon = c("a", "b")), regexp = "2-element")
  expect_warning(get_historical("023000", c(1, 2)),
                 regexp = "Only one.*stationid.*latlon")
  expect_error(get_historical("023000", type = "sodiuhfosdhfoisdh"),
               regexp = "arg.*rain.*solar")
})

test_that("Query stationid = '023000',
          type = 'rain' returns data.frame w/ correct station and some data", {
  skip_on_cran()
  ADLhistrain <- get_historical("023000", type = "rain")
  expect_is(ADLhistrain, "data.frame")
  expect_true(nrow(ADLhistrain) > 0)
  expect_equal(ADLhistrain$Product_code[1], factor("IDCJAC0009"))
  expect_equal(ADLhistrain$Station_number[1], 23000)
})

test_that("Query latlon = c(-34.9285, 138.6007),
          type = 'rain' returns data.frame w/ correct station and some data", {
  skip_on_cran()
  ADLhistrain <- get_historical(latlon = c(-34.9285, 138.6007), type = "rain")
  expect_is(ADLhistrain, "data.frame")
  expect_true(nrow(ADLhistrain) > 0)
  expect_equal(ADLhistrain$Product_code[1], factor("IDCJAC0009"))
  expect_equal(ADLhistrain$Station_number[1], 23000)
})

test_that("Zip file URL is correctly obtained", {
  skip_on_cran()
  expect_error(bomrang:::.get_zip_url("023001", 122),
               regexp = "resource identifiers")
  expect_silent(ADLzipURL <- bomrang:::.get_zip_url("023000", 122))
  expect_match(ADLzipURL, "p_c=[-]+[0-9]*&")
})
