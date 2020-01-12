context("Historical Observations")

test_that("Error handling", {
  skip_on_cran()
  expect_error(get_historical(), regexp = "stationid.*latlon.*provided")
  expect_error(get_historical("sodiuhfosdhfoisdh"),
               regexp = "Station not recognised")
  expect_error(get_historical(2), regexp = "Station not recognised.")
  expect_error(get_historical("2"), regexp = "Station not recognised.")
  expect_error(get_historical(latlon = 1), regexp = "2-element")
  expect_error(get_historical(latlon = c("a", "b")), regexp = "2-element")
  expect_warning(get_historical(stationid = "023000", latlon = c(1, 2)),
                 regexp = "Only one.*stationid.*latlon")
  expect_error(get_historical("023000", type = "sodiuhfosdhfoisdh"),
               regexp = "arg.*rain.*solar")
})

test_that("Query stationid = '023000',
          type = 'rain' returns bomrang_tbl w/ correct station and some data", {
  skip_on_cran()
  ADLhistrain <- get_historical("023000", type = "rain")
  expect_is(ADLhistrain, "bomrang_tbl")
  expect_true(nrow(ADLhistrain) > 0)
  expect_equal(ncol(ADLhistrain), 8)
  expect_equal(ADLhistrain$product_code[1], factor("IDCJAC0009"))
  expect_equal(ADLhistrain$station_number[1], 23000)
})

test_that("Query stationid = '023000'", {
            skip_on_cran()
            ADLhistmax <- get_historical("023000", type = "max")
            expect_is(ADLhistmax, "bomrang_tbl")
            expect_equal(attr(ADLhistmax, "station"), "023000")
            expect_true(nrow(ADLhistmax) > 0)
            expect_equal(ncol(ADLhistmax), 8)
          })

test_that("Query latlon = c(-34.9285, 138.6007),
          type = 'rain' returns bomrang_tbl w/ correct station and some data", {
  skip_on_cran()
  ADLhistrain <- get_historical(latlon = c(-34.9285, 138.6007), type = "rain")
  expect_is(ADLhistrain, "bomrang_tbl")
  expect_true(nrow(ADLhistrain) > 0)
  expect_equal(ncol(ADLhistrain), 8)
  expect_equal(ADLhistrain$product_code[1], factor("IDCJAC0009"))
  expect_equal(ADLhistrain$station_number[1], 23000)
  expect_equal(attr(ADLhistrain, "station"), "023000")
})

test_that("Zip file URL is correctly obtained", {
  skip_on_cran()
  expect_error(bomrang:::.get_zip_url("023001", 122),
               regexp = "resource identifiers")
  expect_silent(ADLzipURL <- bomrang:::.get_zip_url("023000", 122))
  expect_match(ADLzipURL, "p_c=[-]+[0-9]*&")
})
