context("get_precis_forecast")

# Test that get_precis_forecast returns a data frame with 17 colums -------------------
test_that("get_precis_forecast returns 17 columns", {
  skip_on_cran()
  BoM_forecast <- get_precis_forecast(state = "QLD")
  expect_equal(ncol(BoM_forecast), 18)
  expect_named(
    BoM_forecast,
    c(
      "aac",
      "index",
      "start_time_local",
      "end_time_local",
      "UTC_offset",
      "start_time_utc",
      "end_time_utc",
      "maximum_temperature",
      "minimum_temperature",
      "lower_prec_limit",
      "upper_prec_limit",
      "precis",
      "probability_of_precipitation",
      "location",
      "state",
      "lon",
      "lat",
      "elev"
    )
  )
})


# Test that get_precis_forecast returns the requested state forecast ------------------
test_that("get_precis_forecast returns the forecast for ACT/NSW", {
  skip_on_cran()
  BoM_forecast <- as.data.frame(get_precis_forecast(state = "ACT"))
  expect_equal(BoM_forecast[1, 15], "NSW")
})

test_that("get_precis_forecast returns the forecast for ACT/NSW", {
  skip_on_cran()
  BoM_forecast <- as.data.frame(get_precis_forecast(state = "NSW"))
  expect_equal(BoM_forecast[1, 15], "NSW")
})

test_that("get_precis_forecast returns the forecast for NT", {
  skip_on_cran()
  BoM_forecast <- as.data.frame(get_precis_forecast(state = "NT"))
  expect_equal(BoM_forecast[1, 15], "NT")
})

test_that("get_precis_forecast returns the forecast for QLD", {
  skip_on_cran()
  BoM_forecast <- as.data.frame(get_precis_forecast(state = "QLD"))
  expect_equal(BoM_forecast[1, 15], "QLD")
})

test_that("get_precis_forecast returns the forecast for SA", {
  skip_on_cran()
  BoM_forecast <- as.data.frame(get_precis_forecast(state = "SA"))
  expect_equal(BoM_forecast[1, 15], "SA")
})

test_that("get_precis_forecast returns the forecast for TAS", {
  skip_on_cran()
  BoM_forecast <- as.data.frame(get_precis_forecast(state = "TAS"))
  expect_equal(BoM_forecast[1, 15], "TAS")
})

test_that("get_precis_forecast returns the forecast for VIC", {
  skip_on_cran()
  BoM_forecast <- as.data.frame(get_precis_forecast(state = "VIC"))
  expect_equal(BoM_forecast[1, 15], "VIC")
})

test_that("get_precis_forecast returns the forecast for WA", {
  skip_on_cran()
  BoM_forecast <- as.data.frame(get_precis_forecast(state = "WA"))
  expect_equal(BoM_forecast[1, 15], "WA")
})

test_that("get_precis_forecast returns the forecast for AUS", {
  skip_on_cran()
  BoM_forecast <- as.data.frame(get_precis_forecast(state = "AUS"))
  expect_equal(unique(BoM_forecast[, 15]),
               c("NT", "NSW", "QLD", "SA", "TAS", "VIC", "WA"))
})

# Test that .validate_state stops if the state recognised ----------------------
test_that("get_precis_forecast() stops if the state is recognised", {
  skip_on_cran()
  state <- "Kansas"
  expect_error(get_precis_forecast(state))
})
