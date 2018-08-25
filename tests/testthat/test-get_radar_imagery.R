
context("Radar imagery")

test_that("Error handling works", {
  skip_on_cran()
  expect_error(expect_warning(get_available_radar(radar_id = "abc")))
  expect_error(expect_warning(get_radar_imagery(product_id = "abc")))
  expect_error(expect_warning(get_radar_imagery()))
})


# get avail radar works
test_that("get_available_radar functions properly", {
  skip_on_cran()
  
  x <- get_available_radar(radar_id = "all")
  expect_is(x, "data.frame")
  expect_gt(nrow(x), 0)
  
  xx <- get_available_radar()
  expect_is(xx, "data.frame")
  expect_gt(nrow(xx), 0)
  expect_equal(xx, get_available_radar(radar_id = "all"))
  
  xxx <- get_available_radar(radar_id = "1")
  expect_is(xxx, "data.frame")
  expect_gt(nrow(xxx), 0)
  expect_lt(nrow(xxx), 5)
  expect_equal(unique(xxx$Radar_id) , 1)
  })


test_that("get_radar_imagery functions properly", {
  skip_on_cran()
  y <- get_radar_imagery(product_id = "IDR022")
  expect_is(y, "RasterLayer")
})
