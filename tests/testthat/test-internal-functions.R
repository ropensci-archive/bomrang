context("Internal functions")

# bankstown to sydney airports approximately 17628m
test_that("Bankstown airport to Sydney airport approximately 17628m", {
  expect_lt(
    .haversine_distance(
      -33 - 56 / 60 - 46 / 3600,
      151 + 10 / 60 + 38 / 3600,
      -33 - 55 / 60 - 28 / 3600,
      150 + 59 / 60 + 18 / 3600
    ) / 17.628 - 1,
    0.01
  )
})

test_that("Broken Hill airport to Sydney airport approximately 932158", {
  expect_lt(
    .haversine_distance(
      -33 - 56 / 60 - 46 / 3600,
      151 + 10 / 60 + 38 / 3600,
      -32 - 00 / 60 - 05 / 3600,
      141 + 28 / 60 + 18 / 3600
    ) / 932.158 - 1,
    0.01
  )
})
