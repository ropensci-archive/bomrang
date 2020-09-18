context("Subdaily Historical Observations")

test_that("Error handling", {
  skip_on_cran()
  expect_error(get_subdaily_weather(), regexp = "*stationid.*name")
  expect_error(get_subdaily_weather("sodiuhfosdhfoisdh"),
               regexp =
                 "You have requested a station that is not present in the BOM network.")
  expect_error(get_subdaily_weather(2),
               regexp =
                 "You have requested a station that is not present in the BOM network.")
  expect_error(get_subdaily_weather("2"),
               regexp =
                 "You have requested a station that is not present in the BOM network.")
  
  x <-
    evaluate_promise(get_subdaily_weather(
      stationid = "080128",
      name = "CHARLTON",
      years = 2007
    ))
  expect_equal(x$warnings[1],
               "You have provided both a `stationid` and `name`, using `name`.")
})

test_that(
  "Query stationid = '080128',
          hourly = TRUE, returns tibble w/ correct station and some data",
  {
    skip_on_cran()
    Charlton <- tryCatch({
      get_subdaily_weather("080128", hourly = TRUE, years = 2018)
      expect_is(Charlton, "tbl_df")
      expect_true(nrow(Charlton) > 0)
      expect_equal(ncol(Charlton), 10)
      expect_equal(Charlton$id[1], "948390-99999")
      expect_true(lubridate::is.POSIXct(Charlton$time[1]))
      expect_true(is.numeric(Charlton$temp[1]), 19.5)
      expect_equal(
        names(Charlton),
        c(
          "id",
          "time",
          "temp",
          "wd" ,
          "ws" ,
          "atmos_pres" ,
          "dew_point" ,
          "rh" ,
          "ceil_hgt",
          "visibility"
        )
      )
      
    })
  }
)
