context("get_coastal_forecast")

# Test that get_coastal_forecast returns a data frame with 19 colums -------------------
test_that("get_coastal_forecast returns at most 19 columns", {
  skip_on_cran()
  bom_forecast <- get_coastal_forecast(state = "NSW")
  expect_lte(ncol(bom_forecast), 20)
  expect_equal(bom_forecast[["state_code"]][1], "NSW")

  expect_is(bom_forecast$index, "factor")
  expect_is(bom_forecast$product_id, "character")
  expect_is(bom_forecast$type, "character")
  expect_is(bom_forecast$state_code, "character")
  expect_is(bom_forecast$dist_name, "character")
  expect_is(bom_forecast$pt_1_name, "character")
  expect_is(bom_forecast$pt_2_name, "character")
  expect_is(bom_forecast$aac, "character")
  expect_is(bom_forecast$start_time_local, "POSIXct")
  expect_is(bom_forecast$end_time_local, "POSIXct")
  expect_is(bom_forecast$utc_offset, "factor")
  expect_is(bom_forecast$start_time_utc, "POSIXct")
  expect_is(bom_forecast$end_time_utc, "POSIXct")
  expect_is(bom_forecast$forecast_seas, "character")
  expect_is(bom_forecast$forecast_weather, "character")
  expect_is(bom_forecast$forecast_winds, "character")
  expect_is(bom_forecast$forecast_swell1, "character")
})

# Test that get_coastal_forecast returns the requested state forecast ------------------
test_that("get_coastal_forecast returns the forecast for ACT/NSW", {
  skip_on_cran()
  bom_forecast <- get_coastal_forecast(state = "ACT")
  expect_equal(bom_forecast[["state_code"]][1], "NSW")
})

test_that("get_coastal_forecast returns the forecast for ACT/NSW", {
  skip_on_cran()
  bom_forecast <- get_coastal_forecast(state = "NSW")
  expect_equal(bom_forecast[["state_code"]][1], "NSW")
})

test_that("get_coastal_forecast returns the forecast for NT", {
  skip_on_cran()
  bom_forecast <- get_coastal_forecast(state = "NT")
  expect_equal(bom_forecast[["state_code"]][1], "NT")
})

test_that("get_coastal_forecast returns the forecast for SA", {
  skip_on_cran()
  bom_forecast <- get_coastal_forecast(state = "SA")
  expect_equal(bom_forecast[["state_code"]][1], "SA")
})

test_that("get_coastal_forecast returns the forecast for TAS", {
  skip_on_cran()
  bom_forecast <- get_coastal_forecast(state = "TAS")
  expect_equal(bom_forecast[["state_code"]][1], "TAS")
})

test_that("get_coastal_forecast returns the forecast for VIC", {
  skip_on_cran()
  bom_forecast <- get_coastal_forecast(state = "VIC")
  expect_equal(bom_forecast[["state_code"]][1], "VIC")
})

test_that("get_coastal_forecast returns the forecast for WA", {
  skip_on_cran()
  bom_forecast <- get_coastal_forecast(state = "WA")
  expect_equal(bom_forecast[["state_code"]][1], "WA")
})

test_that("get_coastal_forecast returns the forecast for AUS", {
  skip_on_cran()
  bom_forecast <- get_coastal_forecast(state = "AUS")
  expect_equal(unique(bom_forecast[["state_code"]]),
               c("NSW", "NT", "QLD", "SA", "TAS", "VIC", "WA"))
})

# Test that .validate_state stops if the state recognised ----------------------
test_that("get_coastal_forecast() stops if the state is recognised", {
  skip_on_cran()
  state <- "Kansas"
  expect_error(get_coastal_forecast(state))
})
