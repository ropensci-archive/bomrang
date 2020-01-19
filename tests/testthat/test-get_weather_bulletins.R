
context("get_weather_bulletins()")
test_that("get_weather_bulletins() returns a properly formed data.table", {
  skip_on_cran()
  x <- get_weather_bulletin(state = "qld", morning = TRUE)
  expect_true(data.table::is.data.table(x))
  expect_named(x,
               c("stations",
                 "cld8ths",
                 "wind_dir",
                 "wind_speed_kmh",
                 "temp_c_dry",
                 "temp_c_dew",
                 "temp_c_max",
                 "temp_c_min",
                 "temp_c_gr",
                 "barhpa",
                 "rain_mm",
                 "weather",
                 "seastate"
                 ))
})
  
test_that("get_weather_bulletins() stops if 'AUS'' is specfied", {
    skip_on_cran()
    expect_error(get_weather_bulletin(state = "AUS"),
                 regexp = "Weather bulletins can only be extracted*.")
    })
