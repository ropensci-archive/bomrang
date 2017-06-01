context("get_ag_bulletin")

# Test that get_ag_bulletin returns a data frame with 20 columns ---------------
test_that("get_ag_bulletin returns 27 columns", {
  skip_on_cran()
  BOM_bulletin <- get_ag_bulletin(state = "QLD")
  expect_equal(ncol(BOM_bulletin), 27)
  expect_named(
    BOM_bulletin,
    c(
      "obs_time_local",
      "obs_time_utc",
      "time_zone",
      "site",
      "dist",
      "station",
      "start",
      "end",
      "state",
      "lat",
      "lon",
      "elev",
      "bar_ht",
      "WMO",
      "r",
      "tn",
      "tx",
      "twd",
      "ev",
      "tg",
      "sn",
      "t5",
      "t10",
      "t20",
      "t50",
      "t1m",
      "wr"
    )
  )
})


# Test that get_ag_bulletin returns the requested state bulletin ---------------
test_that("get_ag_bulletin returns the bulletin for ACT/NSW", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "NSW"))
  expect_equal(BOM_bulletin[1, 9], "NSW")
})

test_that("get_ag_bulletin returns the bulletin for NT", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "NT"))
  expect_equal(BOM_bulletin[1, 9], "NT")
})

test_that("get_ag_bulletin returns the bulletin for QLD", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "QLD"))
  expect_equal(BOM_bulletin[1, 9], "QLD")
})

test_that("get_ag_bulletin returns the bulletin for SA", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "SA"))
  expect_equal(BOM_bulletin[1, 9], "SA")
})

test_that("get_ag_bulletin returns the bulletin for TAS", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "TAS"))
  expect_equal(BOM_bulletin[1, 9], "TAS")
})

test_that("get_ag_bulletin returns the bulletin for VIC", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "VIC"))
  expect_equal(BOM_bulletin[1, 9], "VIC")
})

test_that("get_ag_bulletin returns the bulletin for WA", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "WA"))
  expect_equal(BOM_bulletin[1, 9], "WA")
})

test_that("get_ag_bulletin returns the bulletin for AUS", {
  skip_on_cran()
  BOM_bulletin <- as.data.frame(get_ag_bulletin(state = "AUS"))
  expect_equal(unique(BOM_bulletin[, 9]),
               c("NT", "NSW", "QLD", "SA", "TAS", "VIC", "WA", NA))
})

# Test that .validate_state stops if the state recognised ----------------------
test_that("get_ag_bulletin() stops if the state is recognised", {
  skip_on_cran()
  state <- "Kansas"
  expect_error(get_ag_bulletin(state))
})
