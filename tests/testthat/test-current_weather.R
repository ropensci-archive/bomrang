context("Current weather")

test_that("Error handling", {
  expect_error(current_weather("sodiuhfosdhfoisdh"), regexp = "No station found")
  expect_warning(current_weather("Melbourne"), regexp = "Multiple stations match station_name.")
})

test_that("Query of 'Melbourne Airport' returns data frame with correct station", {
  YMML <- current_weather("Melbourne Airport")
  expect_is(YMML, "data.frame")
  expect_equal(YMML$name[1], "Melbourne Airport")
})

