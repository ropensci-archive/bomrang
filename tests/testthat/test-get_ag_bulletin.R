# get_ag_bulletin() ------------------------------------------------------------
context("get_ag_bulletin()")

# Test that get_ag_bulletin() returns a data frame with 30 columns
test_that("get_ag_bulletin returns 30 columns", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "QLD")
  expect_equal(ncol(bom_bulletin), 30, info = print(ncol(bom_bulletin)))
  expect_named(
    bom_bulletin,
    c(
      "product_id",
      "state",
      "dist",
      "name",
      "wmo",
      "site",
      "station",
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
      "solr",
      "t5",
      "t10",
      "t20",
      "t50",
      "t1m",
      "wr"
    ),
    info = print(names(bom_bulletin))
  )
  expect_equal(bom_bulletin[["state"]][1], "QLD")
})

# Test that get_ag_bulletin() returns the requested state bulletin
test_that("get_ag_bulletin() returns the bulletin for ACT/NSW", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "NSW")
  expect_equal(bom_bulletin[["state"]][1], "NSW")
})

test_that("get_ag_bulletin() returns the bulletin for NT", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "NT")
  expect_equal(bom_bulletin[["state"]][1], "NT")
})

test_that("get_ag_bulletin() returns the bulletin for SA", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "SA")
  expect_equal(bom_bulletin[["state"]][1], "SA")
})

test_that("get_ag_bulletin() returns the bulletin for TAS", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "TAS")
  expect_equal(bom_bulletin[["state"]][1], "TAS")
})

test_that("get_ag_bulletin() returns the bulletin for VIC", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "VIC")
  expect_equal(bom_bulletin[["state"]][1], "VIC")
})

test_that("get_ag_bulletin() returns the bulletin for WA", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "WA")
  expect_equal(bom_bulletin[["state"]][1], "WA")
})

test_that("get_ag_bulletin() returns the bulletin for AUS", {
  skip_on_cran()
  bom_bulletin <- get_ag_bulletin(state = "AUS")
  state <- na.omit(bom_bulletin[["state"]])
  expect_equal(length(unique(state)), 8)
})

# Test that .validate_state() stops if the state recognised
test_that("get_ag_bulletin() stops if the state is recognised", {
  skip_on_cran()
  state <- "Kansas"
  expect_error(get_ag_bulletin(state))
})

# parse_ag_bulletin() ----------------------------------------------------------
context("parse_ag_bulletin()")

# Test that get_ag_bulletin() returns a data frame with 30 columns
test_that("get_ag_bulletin returns 30 columns", {
  skip_on_cran()
  download.file(
    url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ60604.xml",
    destfile = file.path(
      tempdir(),
      basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ60604.xml")
    ),
    mode = "wb"
  )
  bom_bulletin <-
    parse_ag_bulletin(state = "QLD", filepath = tempdir())
  expect_equal(ncol(bom_bulletin), 30, info = print(ncol(bom_bulletin)))
  expect_named(
    bom_bulletin,
    c(
      "product_id",
      "state",
      "dist",
      "name",
      "wmo",
      "site",
      "station",
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
      "solr",
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

# Test that parse_ag_bulletin() returns the requested state bulletin
test_that("parse_ag_bulletin() returns the bulletin for ACT/NSW", {
  skip_on_cran()
  download.file(
    url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDN65176.xml",
    destfile = file.path(
      tempdir(),
      basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDN65176.xml")
    ),
    mode = "wb"
  )
  bom_bulletin <-
    parse_ag_bulletin(state = "NSW", filepath = tempdir())
  expect_equal(bom_bulletin[["state"]][1], "NSW")
})

test_that("parse_ag_bulletin() returns the bulletin for NT", {
  skip_on_cran()
  download.file(
    url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDD65176.xml",
    destfile = file.path(
      tempdir(),
      basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDD65176.xml")
    ),
    mode = "wb"
  )
  bom_bulletin <-
    parse_ag_bulletin(state = "NT", filepath = tempdir())
  expect_equal(bom_bulletin[["state"]][1], "NT")
})

test_that("parse_ag_bulletin() returns the bulletin for SA", {
  skip_on_cran()
  download.file(
    url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDS65176.xml",
    destfile = file.path(
      tempdir(),
      basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDS65176.xml")
    ),
    mode = "wb"
  )
  bom_bulletin <-
    parse_ag_bulletin(state = "SA", filepath = tempdir())
  expect_equal(bom_bulletin[["state"]][1], "SA")
})

test_that("parse_ag_bulletin() returns the bulletin for TAS", {
  skip_on_cran()
  download.file(
    url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDT65176.xml",
    destfile = file.path(
      tempdir(),
      basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDT65176.xml")
    ),
    mode = "wb"
  )
  bom_bulletin <-
    parse_ag_bulletin(state = "TAS", filepath = tempdir())
  expect_equal(bom_bulletin[["state"]][1], "TAS")
})

test_that("parse_ag_bulletin() returns the bulletin for VIC", {
  skip_on_cran()
  download.file(
    url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDV65176.xml",
    destfile = file.path(
      tempdir(),
      basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDV65176.xml")
    ),
    mode = "wb"
  )
  bom_bulletin <-
    parse_ag_bulletin(state = "VIC", filepath = tempdir())
  expect_equal(bom_bulletin[["state"]][1], "VIC")
})

test_that("parse_ag_bulletin() returns the bulletin for WA", {
  skip_on_cran()
  download.file(
    url = "ftp://ftp.bom.gov.au/anon/gen/fwo/IDW65176.xml",
    destfile = file.path(
      tempdir(),
      basename("ftp://ftp.bom.gov.au/anon/gen/fwo/IDW65176.xml")
    ),
    mode = "wb"
  )
  bom_bulletin <-
    parse_ag_bulletin(state = "WA", filepath = tempdir())
  expect_equal(bom_bulletin[["state"]][1], "WA")
})

test_that("parse_ag_bulletin() returns the bulletin for AUS", {
  skip_on_cran()
  bom_bulletin <-
    parse_ag_bulletin(state = "AUS", filepath = tempdir())
  state <- na.omit(bom_bulletin[["state"]])
  expect_equal(length(unique(state)), 8)
})

# Test that .validate_state() stops if the state recognised
test_that("parse_ag_bulletin() stops if the state is recognised", {
  skip_on_cran()
  state <- "Kansas"
  expect_error(parse_ag_bulletin(state = state, filepath = tempdir()))
})

# Test that parse_ag_bulletin() stops if directory does not exist or file
# not matched
test_that(" Test that parse_ag_bulletin() stops for bad directory", {
  skip_on_cran()
  expect_error(parse_ag_bulletin(state = "AUS", filepath = "xx"))
})

test_that(" Test that parse_ag_bulletin() stops if XML provided", {
  skip_on_cran()
  expect_error(parse_coastal_forecast(state = "AUS", filepath = 
                                        file.path(tempdir(), "IDW65176.xml")))
})
