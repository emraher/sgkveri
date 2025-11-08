# Mock-based tests that can run on CRAN/CI
# These tests use httptest2 to mock API responses

test_that("package can be loaded", {
  expect_true(requireNamespace("sgkveri", quietly = TRUE))
})

# Skip mock tests if httptest2 is not available
skip_if_no_httptest2 <- function() {
  skip_if_not_installed("httptest2")
}

test_that("sgk_parse_number is available and works", {
  # This is a unit test that doesn't need mocking
  expect_equal(sgk_parse_number("1.234,56"), 1234.56)
  expect_equal(sgk_parse_number("1,234.56"), 1234.56)
})

test_that("sgk_clear_cache is available and works", {
  # This is a unit test that doesn't need mocking
  expect_invisible(sgk_clear_cache())
})

# Note: Full mock-based tests would require creating httptest2 fixtures
# by running the real API calls once with httptest2::capture_requests()
# For now, we ensure the package loads and basic functions work
# Run integration tests locally with devtools::test() when NOT on CRAN/CI
