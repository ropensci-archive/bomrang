context("get_forecast")

# Test that get_forecast returns a data frame with 13 colums -------------------
skip_on_cran()
test_that("get_forecast returns 13 columns", {
  BOM_forecast <- get_forecast(state = "QLD")
  expect_equal(ncol(BOM_forecast), 13)
  expect_named(BOM_forecast, c("aac", "date", "max_temp", "min_temp",
                               "lower_prcp_limit", "upper_prcp_limit", "precis",
                               "prob_prcp", "location", "state", "lon", "lat",
                               "elev"))
})


# Test that get_forecast returns the requested state forecast ------------------
skip_on_cran()

test_that("get_forecast returns the forecast for ACT/NSW", {
  BOM_forecast <- get_forecast(state = "ACT")
  expect_equal(BOM_forecast[13, 1], "NSW")
})

test_that("get_forecast returns the forecast for ACT/NSW", {
  BOM_forecast <- get_forecast(state = "NSW")
  expect_equal(BOM_forecast[13, 1], "NSW")
})

skip_on_cran()
test_that("get_forecast returns the forecast for QLD", {
  BOM_forecast <- get_forecast(state = "QLD")
  expect_equal(BOM_forecast[13, 1], "QLD")
})

skip_on_cran()
test_that("get_forecast returns the forecast for SA", {
  BOM_forecast <- get_forecast(state = "SA")
  expect_equal(BOM_forecast[13, 1], "SA")
})

skip_on_cran()
test_that("get_forecast returns the forecast for TAS", {
  BOM_forecast <- get_forecast(state = "TAS")
  expect_equal(BOM_forecast[13, 1], "TAS")
})

skip_on_cran()
test_that("get_forecast returns the forecast for VIC", {
  BOM_forecast <- get_forecast(state = "VIC")
  expect_equal(BOM_forecast[13, 1], "VIC")
})

skip_on_cran()
test_that("get_forecast returns the forecast for WA", {
  BOM_forecast <- get_forecast(state = "WA")
  expect_equal(BOM_forecast[13, 1], "WA")
})
