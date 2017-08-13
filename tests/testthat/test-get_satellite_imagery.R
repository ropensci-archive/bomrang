context("Satellite imagery")

test_that("Error handling", {
  expect_error(get_available_imagery(product_id = "abcdc"))
  expect_error(get_satellite_imagery(product_id = "abcdc"))
  expect_error(get_satellite_imagery())
})

test_that("get_available_imagery() returns proper classes", {
  i <- get_available_imagery()
  expect_type(i, "character")
  expect_type(get_satellite_imagery(product_id = i[[3]], scans = 1),
              "S4")
})
