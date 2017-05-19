context("Current weather")

test_that("Error handling", {
  expect_error(current_weather("sodiuhfosdhfoisdh"), regexp = "No station found")
  expect_warning(current_weather("Melbourne"), regexp = "Multiple stations match station_name.")
  expect_warning(current_weather("Melbourne", latlon = c(-33, 151)),
                 regexp = "Both station_name and latlon provided. Ignoring latlon")
  expect_error(current_weather(latlon = 33), regexp = "[Ll]ength")
  expect_error(current_weather(latlon = c("-33", "151")), regexp = "[Nn]umeric")
  expect_warning(current_weather(latlon = c(0, 0)), regexp = "unlikely")
  expect_warning(current_weather(latlon = c(-33, -151)), regexp = "unlikely")
})

test_that("Query of 'Melbourne Airport' returns data frame with correct station", {
  YMML <- current_weather("Melbourne Airport")
  expect_is(YMML, "data.frame")
  expect_equal(YMML$name[1], "Melbourne Airport")
})

test_that("latlon: Query of c(-27, 149) returns Surat (QLD, between Roma and St George).", {
  expect_message(current_weather(latlon = c(-27, 149)), regexp = "Surat")
  Surat <- current_weather(latlon = c(-27, 149), emit_latlon_msg = FALSE)
  expect_equal(unique(Surat$name), "Surat")
})

