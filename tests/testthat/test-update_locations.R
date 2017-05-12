context("update_locations")

# Timeout options are reset on update_locations() exit -------------------------
test_that("Timeout options are reset on update_locations() exit", {
  skip_on_cran()
  update_locations()
  expect_equal(options("timeout")[[1]], 60)
})
