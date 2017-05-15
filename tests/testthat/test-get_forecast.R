context("get_forecast")

# Test that get_forecast returns a data frame with 13 colums -------------------
test_that("get_forecast returns 17 columns", {
  skip_on_cran()
  BOM_forecast <- get_forecast(state = "QLD")
  expect_equal(ncol(BOM_forecast), 17)
  expect_named(
    BOM_forecast,
    c(
      "aac",
      "index",
      "start_time_local",
      "end_time_local",
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


# Test that get_forecast returns the requested state forecast ------------------
test_that("get_forecast returns the forecast for ACT/NSW", {
  skip_on_cran()
  BOM_forecast <- as.data.frame(get_forecast(state = "ACT"))
  expect_equal(BOM_forecast[1, 14], "NSW")
})

test_that("get_forecast returns the forecast for ACT/NSW", {
  skip_on_cran()
  BOM_forecast <- as.data.frame(get_forecast(state = "NSW"))
  expect_equal(BOM_forecast[1, 14], "NSW")
})

test_that("get_forecast returns the forecast for NT", {
  skip_on_cran()
  BOM_forecast <- as.data.frame(get_forecast(state = "NT"))
  expect_equal(BOM_forecast[1, 14], "NT")
})

test_that("get_forecast returns the forecast for QLD", {
  skip_on_cran()
  BOM_forecast <- as.data.frame(get_forecast(state = "QLD"))
  expect_equal(BOM_forecast[1, 14], "QLD")
})

test_that("get_forecast returns the forecast for SA", {
  skip_on_cran()
  BOM_forecast <- as.data.frame(get_forecast(state = "SA"))
  expect_equal(BOM_forecast[1, 14], "SA")
})

test_that("get_forecast returns the forecast for TAS", {
  skip_on_cran()
  BOM_forecast <- as.data.frame(get_forecast(state = "TAS"))
  expect_equal(BOM_forecast[1, 14], "TAS")
})

test_that("get_forecast returns the forecast for VIC", {
  skip_on_cran()
  BOM_forecast <- as.data.frame(get_forecast(state = "VIC"))
  expect_equal(BOM_forecast[1, 14], "VIC")
})

test_that("get_forecast returns the forecast for WA", {
  skip_on_cran()
  BOM_forecast <- as.data.frame(get_forecast(state = "WA"))
  expect_equal(BOM_forecast[1, 14], "WA")
})

test_that("get_forecast returns the forecast for AUS", {
  skip_on_cran()
  BOM_forecast <- as.data.frame(get_forecast(state = "AUS"))
  expect_equal(unique(BOM_forecast[, 14]),
               c("NT", "NSW", "QLD", "SA", "TAS", "VIC", "WA"))
})

# Test that .validate_state stops if the state recognised ----------------------
test_that("get_forecast() stops if the state is recognised", {
  skip_on_cran()
  state <- "Kansas"
  expect_error(get_forecast(state))
})
