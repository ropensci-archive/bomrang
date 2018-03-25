context("get_ag_bulletin")

# Test that get_ag_bulletin returns a data frame with 29 columns ---------------
test_that("get_ag_bulletin returns 29 columns", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "QLD")
  expect_equal(ncol(bom_bulletin), 29, info = print(ncol(bom_bulletin)))
  expect_named(
    bom_bulletin,
    c(
      "product_id",
      "state",
      "dist",
      "wmo",
      "site",
      "station",
      "full_name",
      "obs_time_local",
      "obs_time_utc",
      "time_zone",
      "lat",
      "lon",
      "elev",
      "bar_ht",
      "start",
      "end",
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
    ),
    info = print(names(bom_bulletin))
  )
})

# Test that get_ag_bulletin returns the requested state bulletin ---------------
test_that("get_ag_bulletin returns the bulletin for ACT/NSW", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "NSW")
  expect_equal(bom_bulletin[["state"]][1], "NSW")
})

test_that("get_ag_bulletin returns the bulletin for NT", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "NT")
  expect_equal(bom_bulletin[["state"]][1], "NT")
})

test_that("get_ag_bulletin returns the bulletin for QLD", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "QLD")
  expect_equal(bom_bulletin[["state"]][1], "QLD")
})

test_that("get_ag_bulletin returns the bulletin for SA", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "SA")
  expect_equal(bom_bulletin[["state"]][1], "SA")
})

test_that("get_ag_bulletin returns the bulletin for TAS", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "TAS")
  expect_equal(bom_bulletin[["state"]][1], "TAS")
})

test_that("get_ag_bulletin returns the bulletin for VIC", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "VIC")
  expect_equal(bom_bulletin[["state"]][1], "VIC")
})

test_that("get_ag_bulletin returns the bulletin for WA", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "WA")
  expect_equal(bom_bulletin[["state"]][1], "WA")
})

test_that("get_ag_bulletin returns the bulletin for AUS", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "AUS")
  state <- na.omit(bom_bulletin[["state"]])
  expect_equal(length(unique(state)), 8)
})

# Test that .validate_state stops if the state recognised ----------------------
test_that("get_ag_bulletin() stops if the state is recognised", {
  skip_on_cran()
  state <- "Kansas"
  expect_error(get_ag_bulletin(state))
})
