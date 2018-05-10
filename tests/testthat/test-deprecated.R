
context("Deprecated functions")

# test that calling a deprecated function results in a warning -----------------
test_that("test that deprecated functions emit warnings", {
  expect_warning(bomrang_cache_list())
  expect_warning(bomrang_cache_details())
  expect_warning(bomrang_cache_delete())
  expect_warning(bomrang_cache_delete_all())
})
