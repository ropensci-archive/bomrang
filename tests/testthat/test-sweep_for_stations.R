context("Sweep for stations")

test_that("sweep_for_stations returns correct default", {
  DT <- sweep_for_stations()
  expect_equal(DT$name[1], "CANBERRA AIRPORT")
  expect_equal(data.table::last(DT$name), "MAWSON")
})
