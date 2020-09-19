context("Historical Observations")

test_that("Error handling", {
  skip_on_cran()
  expect_error(get_historical_weather(), regexp = "stationid.*latlon.*provided")
  expect_error(get_historical_weather("sodiuhfosdhfoisdh"),
               regexp = "Station not recognised")
  expect_error(get_historical_weather(2), regexp = "Station not recognised.")
  expect_error(get_historical_weather("2"), regexp = "Station not recognised.")
  expect_error(get_historical_weather(latlon = 1), regexp = "2-element")
  expect_error(get_historical_weather(latlon = c("a", "b")),
               regexp = "2-element")
  x <-
    evaluate_promise(get_historical_weather(
      stationid = "023000",
      latlon = c(1, 2),
      type = "max"
    ))
  expect_equal(
    x$warnings[1],
    "\nOnly one of `stationid` or `latlon` may be provided. \nUsing `stationid`\n."
  )
  # expect_equal(
  #   x$warnings[2],
  #   "The list of available stations for `type = rain` is currently empty.\nThis is likely a temporary error in the Bureau of Meteorology's\ndatabase and may cause requests for rain station data to fail."
  # )
  expect_error(get_historical_weather("023000", type = "sodiuhfosdhfoisdh"),
               regexp = "arg.*rain.*solar")
})

test_that(
  "Query stationid = '023000',
          type = 'rain' returns bomrang_tbl w/ correct station and some data",
  {
    skip_on_cran()
    ADLhistrain <- get_historical_weather("023000", type = "rain")
    expect_is(ADLhistrain, "bomrang_tbl")
    expect_true(nrow(ADLhistrain) > 0)
    expect_equal(ncol(ADLhistrain), 8)
    expect_equal(ADLhistrain$product_code[1], factor("IDCJAC0009"))
    expect_equal(ADLhistrain$station_number[1], 23000)
    expect_equal(attr(ADLhistrain, "station"), "023000")
  }
)


test_that("Query stationid = '023000'", {
  skip_on_cran()
  ADLhistmax <-
    get_historical_weather("023000", type = "max")
  expect_is(ADLhistmax, "bomrang_tbl")
  expect_equal(attr(ADLhistmax, "station"), "023000")
  expect_true(nrow(ADLhistmax) > 0)
  expect_equal(ncol(ADLhistmax), 8)
})

test_that(
  "Query latlon = c(-34.9285, 138.6007),
          type = 'rain' returns bomrang_tbl w/ correct station and some data",
  {
    skip_on_cran()
    ADLhistrain <-
      get_historical_weather(latlon = c(-34.9285, 138.6007),
                             type = "rain")
    expect_is(ADLhistrain, "bomrang_tbl")
    expect_true(nrow(ADLhistrain) > 0)
    expect_equal(ncol(ADLhistrain), 8)
    expect_equal(ADLhistrain$product_code[1], factor("IDCJAC0009"))
    expect_equal(ADLhistrain$station_number[1], 23000)
    expect_equal(attr(ADLhistrain, "station"), "023000")
  }
)

test_that("Zip file URL is correctly obtained", {
  skip_on_cran()
  expect_error(bomrang:::.get_zip_url("023001", 122),
               regexp = "resource identifiers")
  expect_silent(ADLzipURL <- bomrang:::.get_zip_url("023000", 122))
  expect_match(ADLzipURL, "p_c=[-]+[0-9]*&")
})
