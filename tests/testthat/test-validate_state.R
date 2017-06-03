context(".validate_state")

# Test that .validate_state stops if the state is not provided -----------------

test_that(".validate_state stops if the state is not provided", {
  state <- NULL
  expect_error(.validate_state(state))
})

# Test that .validate_state returns values in upper case  ----------------------
test_that(".validate_state returns the entered value in upper case", {
  state <- "Qld"
  state <- .validate_state(state)
  expect_equal(state, "QLD")
})
