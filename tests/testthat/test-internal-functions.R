context("Internal functions")

# bankstown to sydney airports approximately 17628m
test_that("Bankstown airport to Sydney airport approximately 17628m", {
  expect_lt(haversine_distance(-33 - 56/60 - 46/3600, 151 + 10/60 + 38/3600,
                               -33 - 55/60 - 28/3600, 150 + 59/60 + 18/3600) / 17.628 - 1,
            0.01)
})

test_that("Broken Hill airport to Sydney airport approximately 932158", {
  expect_lt(haversine_distance(-33 - 56/60 - 46/3600, 151 + 10/60 + 38/3600,
                               -32 - 00/60 - 05/3600, 141 + 28/60 + 18/3600) / 932.158 - 1,
            0.01)
})

test_that("station list is properly formatted and contains correct information", {
  stations_meta <- .get_station_metadata()
  expect_is(stations_meta, "data.frame")
  expect_equal(ncol(stations_meta), 14)
  expect_equal(stations_meta$end[1], "2017")
  expect_equal(unique(stations_meta$state), c("WA", "NSW", "NT", "SA", "QLD", "VIC", "TAS", "ANT"))

  # check for known station url, Bourke Airport
  Bourke <- subset(stations_meta, name == "BOURKE AIRPORT AWS")
  expect_match(Bourke$url, regexp = "http://www.bom.gov.au/fwo/IDN60801/IDN60801.94703.json")

  # check for known station with no url, LEARMONTH SOLAR OBSERVATORY
  Learmonth <- subset(stations_meta, name == "LEARMONTH SOLAR OBSERVATORY")
  expect_equal(is.na(Learmonth$url), TRUE)
})
