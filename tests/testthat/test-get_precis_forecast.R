# get_precis_forecast() --------------------------------------------------------

context("get_precis_forecast()")

# Test that get_precis_forecast() returns a data frame with 19 columns
test_that("get_precis_forecast() returns 19 columns and min < max", {
  skip_on_cran()
  bom_forecast <- get_precis_forecast(state = "QLD")
  expect_equal(ncol(bom_forecast), 19)
  expect_equal(bom_forecast[["state"]][1], "QLD")
  expect_named(
    bom_forecast,
    c(
      "index",
      "product_id",
      "state",
      "town",
      "aac",
      "lat",
      "lon",
      "elev",
      "start_time_local",
      "end_time_local",
      "utc_offset",
      "start_time_utc",
      "end_time_utc",
      "minimum_temperature",
      "maximum_temperature",
      "lower_precipitation_limit",
      "upper_precipitation_limit",
      "precis",
      "probability_of_precipitation"
    )
  )

  expect_is(bom_forecast$index, "factor")
  expect_is(bom_forecast$product_id, "character")
  expect_is(bom_forecast$state, "character")
  expect_is(bom_forecast$town, "character")
  expect_is(bom_forecast$aac, "character")
  expect_is(bom_forecast$lat, "numeric")
  expect_is(bom_forecast$lon, "numeric")
  expect_is(bom_forecast$elev, "numeric")
  expect_is(bom_forecast$start_time_local, "POSIXct")
  expect_is(bom_forecast$end_time_local, "POSIXct")
  expect_is(bom_forecast$utc_offset, "factor")
  expect_is(bom_forecast$start_time_utc, "POSIXct")
  expect_is(bom_forecast$end_time_local, "POSIXct")
  expect_is(bom_forecast$minimum_temperature, "numeric")
  expect_is(bom_forecast$maximum_temperature, "numeric")
  expect_is(bom_forecast$lower_precipitation_limit, "numeric")
  expect_is(bom_forecast$upper_precipitation_limit, "numeric")
  expect_is(bom_forecast$precis, "character")
  expect_is(bom_forecast$probability_of_precipitation, "numeric")
  expect_lt(mean(bom_forecast$minimum_temperature, na.rm = TRUE),
            mean(bom_forecast$maximum_temperature, na.rm = TRUE))
})

# Test that get_precis_forecast() returns the requested state forecast
test_that("get_precis_forecast() returns the forecast for ACT/NSW", {
  skip_on_cran()
  bom_forecast <- get_precis_forecast(state = "ACT")
  expect_equal(bom_forecast[["state"]][1], "NSW")
})

test_that("get_precis_forecast() returns the forecast for ACT/NSW", {
  skip_on_cran()
  bom_forecast <- get_precis_forecast(state = "NSW")
  expect_equal(bom_forecast[["state"]][1], "NSW")
})

test_that("get_precis_forecast() returns the forecast for NT", {
  skip_on_cran()
  bom_forecast <- get_precis_forecast(state = "NT")
  expect_equal(bom_forecast[["state"]][1], "NT")
})

test_that("get_precis_forecast() returns the forecast for SA", {
  skip_on_cran()
  bom_forecast <- get_precis_forecast(state = "SA")
  expect_equal(bom_forecast[["state"]][1], "SA")
})

test_that("get_precis_forecast() returns the forecast for TAS", {
  skip_on_cran()
  bom_forecast <- get_precis_forecast(state = "TAS")
  expect_equal(bom_forecast[["state"]][1], "TAS")
})

test_that("get_precis_forecast() returns the forecast for VIC", {
  skip_on_cran()
  bom_forecast <- get_precis_forecast(state = "VIC")
  expect_equal(bom_forecast[["state"]][1], "VIC")
})

test_that("get_precis_forecast() returns the forecast for WA", {
  skip_on_cran()
  bom_forecast <- get_precis_forecast(state = "WA")
  expect_equal(bom_forecast[["state"]][1], "WA")
})

test_that("get_precis_forecast() returns the forecast for AUS", {
  skip_on_cran()
  bom_forecast <- get_precis_forecast(state = "AUS")
  expect_equal(unique(bom_forecast[["state"]]),
               c("NSW", "NT", "QLD", "SA", "TAS", "VIC", "WA"))
})

# Test that .validate_state() stops if the state recognised
test_that("get_precis_forecast() stops if the state is recognised", {
  skip_on_cran()
  state <- "Kansas"
  expect_error(get_precis_forecast(state = state))
})

# parse_precis_forecast() ------------------------------------------------------

context("parse_precis_forecast()")

# Test that parse_precis_forecast() returns a data frame with 19 columns
test_that("parse_precis_forecast() returns 19 columns and min < max", {
  skip_on_cran()
  download.file(
    url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ11295.xml",
    destfile = file.path(
      tempdir(),
      basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ11295.xml")
    ),
    mode = "wb"
  )
  bom_forecast <- parse_precis_forecast(state = "QLD", filepath = tempdir())
  expect_equal(ncol(bom_forecast), 19)
  expect_equal(bom_forecast[["state"]][1], "QLD")
  expect_named(
    bom_forecast,
    c(
      "index",
      "product_id",
      "state",
      "town",
      "aac",
      "lat",
      "lon",
      "elev",
      "start_time_local",
      "end_time_local",
      "utc_offset",
      "start_time_utc",
      "end_time_utc",
      "minimum_temperature",
      "maximum_temperature",
      "lower_precipitation_limit",
      "upper_precipitation_limit",
      "precis",
      "probability_of_precipitation"
    )
  )
  
  expect_is(bom_forecast$index, "factor")
  expect_is(bom_forecast$product_id, "character")
  expect_is(bom_forecast$state, "character")
  expect_is(bom_forecast$town, "character")
  expect_is(bom_forecast$aac, "character")
  expect_is(bom_forecast$lat, "numeric")
  expect_is(bom_forecast$lon, "numeric")
  expect_is(bom_forecast$elev, "numeric")
  expect_is(bom_forecast$start_time_local, "POSIXct")
  expect_is(bom_forecast$end_time_local, "POSIXct")
  expect_is(bom_forecast$utc_offset, "factor")
  expect_is(bom_forecast$start_time_utc, "POSIXct")
  expect_is(bom_forecast$end_time_local, "POSIXct")
  expect_is(bom_forecast$minimum_temperature, "numeric")
  expect_is(bom_forecast$maximum_temperature, "numeric")
  expect_is(bom_forecast$lower_precipitation_limit, "numeric")
  expect_is(bom_forecast$upper_precipitation_limit, "numeric")
  expect_is(bom_forecast$precis, "character")
  expect_is(bom_forecast$probability_of_precipitation, "numeric")
  expect_lt(mean(bom_forecast$minimum_temperature, na.rm = TRUE),
            mean(bom_forecast$maximum_temperature, na.rm = TRUE))
})

# Test that parse_precis_forecast() returns the requested state forecast
test_that("parse_precis_forecast() returns the forecast for ACT/NSW", {
  skip_on_cran()
  download.file(
    url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDN11060.xml",
    destfile = file.path(
      tempdir(),
      basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDN11060.xml")
    ),
    mode = "wb"
  )
  bom_forecast <- parse_precis_forecast(state = "ACT", filepath = tempdir())
  expect_equal(bom_forecast[["state"]][1], "NSW")
})

test_that("parse_precis_forecast() returns the forecast for ACT/NSW", {
  skip_on_cran()
  download.file(
    url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDN11060.xml",
    destfile = file.path(
      tempdir(),
      basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDN11060.xml")
    ),
    mode = "wb"
  )
  bom_forecast <- parse_precis_forecast(state = "NSW", filepath = tempdir())
  expect_equal(bom_forecast[["state"]][1], "NSW")
})

test_that("parse_precis_forecast() returns the forecast for NT", {
  skip_on_cran()
  download.file(
    url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDD10207.xml",
    destfile = file.path(
      tempdir(),
      basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDD10207.xml")
    ),
    mode = "wb"
  )
  bom_forecast <- parse_precis_forecast(state = "NT", filepath = tempdir())
  expect_equal(bom_forecast[["state"]][1], "NT")
})

test_that("parse_precis_forecast() returns the forecast for SA", {
  skip_on_cran()
  download.file(
    url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDS10044.xml",
    destfile = file.path(
      tempdir(),
      basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDS10044.xml")
    ),
    mode = "wb"
  )
  bom_forecast <- parse_precis_forecast(state = "SA", filepath = tempdir())
  expect_equal(bom_forecast[["state"]][1], "SA")
})

test_that("parse_precis_forecast() returns the forecast for TAS", {
  skip_on_cran()
  download.file(
    url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDT16710.xml",
    destfile = file.path(
      tempdir(),
      basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDT16710.xml")
    ),
    mode = "wb"
  )
  bom_forecast <- parse_precis_forecast(state = "TAS", filepath = tempdir())
  expect_equal(bom_forecast[["state"]][1], "TAS")
})

test_that("parse_precis_forecast() returns the forecast for VIC", {
  skip_on_cran()
  download.file(
    url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDV10753.xml",
    destfile = file.path(
      tempdir(),
      basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDV10753.xml")
    ),
    mode = "wb"
  )
  bom_forecast <- parse_precis_forecast(state = "VIC", filepath = tempdir())
  expect_equal(bom_forecast[["state"]][1], "VIC")
})

test_that("parse_precis_forecast() returns the forecast for WA", {
  skip_on_cran()
  download.file(
    url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDW14199.xml",
    destfile = file.path(
      tempdir(),
      basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDW14199.xml")
    ),
    mode = "wb"
  )
  bom_forecast <- parse_precis_forecast(state = "WA", filepath = tempdir())
  expect_equal(bom_forecast[["state"]][1], "WA")
})

test_that("parse_precis_forecast() returns the forecast for AUS", {
  skip_on_cran()
  bom_forecast <- parse_precis_forecast(state = "AUS", filepath = tempdir())
  expect_equal(unique(bom_forecast[["state"]]),
               c("NSW", "NT", "QLD", "SA", "TAS", "VIC", "WA"))
})

# Test that .validate_state() stops if the state recognised
test_that("parse_precis_forecast() stops if the state is recognised", {
  skip_on_cran()
  state <- "Kansas"
  expect_error(parse_precis_forecast(state = state, filepath = tempdir()))
})

# Test that parse_precis_forecast() stops if directory does not exist or file
# not matched
test_that(" Test that parse_precis_forecast() stops for bad directory", {
  skip_on_cran()
  expect_error(parse_precis_forecast(state = "AUS", filepath = "xx"))
})

test_that(" Test that parse_precis_forecast() stops if XML provided", {
  skip_on_cran()
  expect_error(parse_precis_forecast(state = "AUS", filepath = 
                                       file.path(tempdir(), "IDW14199.xml")))
})
