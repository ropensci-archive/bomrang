context(".validate_state")

# Test that .validate_dsn stops if the dsn is not provided ---------------------

test_that(".validate_state stops if the state is not provided", {
  state <- NULL
  expect_error(.validate_dsn(dsn))
})

test_that(".validate_state stops if the state is properly formatted/recognised", {
  state <- "Australia"
  expect_error(.validate_dsn(dsn))
})
