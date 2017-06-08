context("Current weather")

test_that("Error handling", {
  expect_error(get_current_weather(), regexp = "station_name.*latlon")
  expect_error(get_current_weather("sodiuhfosdhfoisdh"), regexp = "No station found")
  expect_warning(get_current_weather("Melbourne"), regexp = "Multiple stations match station_name.")
  expect_warning(get_current_weather("Melbourne", latlon = c(-33, 151)),
                 regexp = "Both station_name and latlon provided. Ignoring latlon")
  expect_error(get_current_weather(latlon = 33), regexp = "[Ll]ength")
  expect_error(get_current_weather(latlon = c("-33", "151")), regexp = "[Nn]umeric")
})

test_that("Query of 'Melbourne Airport' returns data frame with correct station", {
  YMML <- get_current_weather("Melbourne Airport", raw = TRUE)
  expect_is(YMML, "data.frame")
  expect_equal(YMML$name[1], "Melbourne Airport")
})

test_that("Query of 'Melbourne Airport' returns time if cooked.", {
  YMML <- get_current_weather("Melbourne Airport")
  expect_is(YMML, "data.frame")
  expect_equal(YMML$name[1], "Melbourne Airport")
  expect_true("POSIXt" %in% class(YMML$aifstime_utc))
})

test_that("latlon: Query of c(-27, 149) returns Surat (QLD, between Roma and St George).", {
  expect_message(get_current_weather(latlon = c(-27, 149)), regexp = "SURAT")
  Surat <- get_current_weather(latlon = c(-27, 149), emit_latlon_msg = FALSE)
  expect_equal(unique(Surat$name), "Surat")
})

test_that("Data table if requested", {
  YMML <- get_current_weather("Melbourne Airport", as.data.table = TRUE)
  expect_true("data.table" %in% class(YMML))
})

