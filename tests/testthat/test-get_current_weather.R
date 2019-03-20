context("Current weather")

test_that("Error handling", {
  expect_error(get_current_weather(), regexp = "station_name.*latlon")
  expect_error(get_current_weather("sodiuhfosdhfoisdh"),
               regexp = "No station found")
  expect_warning(get_current_weather("Melbourne"),
                 regexp = "Multiple stations match station_name.")
  expect_warning(get_current_weather("Melbourne", latlon = c(-33, 151)),
                 regexp =
                   "Both station_name and latlon provided. Ignoring latlon")
  expect_error(get_current_weather(latlon = 33), regexp = "[Ll]ength")
  expect_error(get_current_weather(latlon = c("-33", "151")),
               regexp = "[Nn]umeric")
  expect_error(get_current_weather("DOME A"),
              regexp = "A station was matched.*not found at bom.gov.au.")
})

test_that("Query 'Melbourne Airport' returns data frame w/ correct station", {
  YMML <- get_current_weather("Melbourne Airport", raw = TRUE)
  expect_is(YMML, "bomrang_tbl")
  expect_equal(YMML$full_name[1], "Melbourne Airport")
})

test_that("Query of 'Melbourne Airport' returns time if cooked.", {
  YMML <- get_current_weather("Melbourne Airport")
  expect_is(YMML, "data.frame")
  expect_equal(YMML$full_name[1], "Melbourne Airport")
  expect_true("POSIXt" %in% class(YMML$aifstime_utc))
})

test_that("Query of 'Sydney' defaults to Observatory Hill", {
  expect_warning(get_current_weather("Sydney"),
                 regexp = "Multiple stations match")
  SYD <- suppressWarnings(get_current_weather("Sydney"))
  expect_equal(unique(SYD$full_name), "Sydney - Observatory Hill")
})

test_that("Query of 'castlem' and friends", {
  # OK
  expect_warning(get_current_weather(station_name = "castlem"))
})

test_that("Strict", {
  expect_error(get_current_weather("Melbourne", strict = TRUE),
               regexp = "strict = TRUE.*Multiple stations match station_name.")
  expect_error(get_current_weather("ESPERANCE AWS", strict = TRUE))
  # Main test is that this is not an error:
  FORREST <- get_current_weather("FORREST", strict = TRUE)
  expect_equal(toupper(FORREST$full_name[1]), "FORREST")
})

test_that("Query c(-27, 149) returns Surat (QLD, b/n Roma and St George).", {
  skip_on_cran()
  expect_message(get_current_weather(latlon = c(-27, 149)), regexp = "SURAT")
  Surat <- get_current_weather(latlon = c(-27, 149), emit_latlon_msg = FALSE)
  expect_equal(unique(Surat$full_name), "Surat")
})

test_that("Data table if requested", {
  YMML <- get_current_weather("Melbourne Airport", as.data.table = TRUE)
  expect_true("data.table" %in% class(YMML))
})
