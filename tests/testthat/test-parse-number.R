# Unit tests for sgk_parse_number - these run on CRAN/CI
# No API calls, pure parsing logic

test_that("sgk_parse_number handles European format", {
  # Thousands separator: dot
  expect_equal(sgk_parse_number("70.586.256"), 70586256)

  # Decimal separator: comma
  expect_equal(sgk_parse_number("87.000,563"), 87000.563)

  # Both separators
  expect_equal(sgk_parse_number("1.234.567,8"), 1234567.8)
})

test_that("sgk_parse_number handles US format", {
  # Thousands separator: comma
  expect_equal(sgk_parse_number("1,234,567"), 1234567)

  # Decimal separator: dot
  expect_equal(sgk_parse_number("1234.56"), 1234.56)

  # Both separators
  expect_equal(sgk_parse_number("1,234,567.8"), 1234567.8)
})

test_that("sgk_parse_number handles edge cases", {
  # NA and empty strings
  expect_true(is.na(sgk_parse_number(NA)))
  expect_true(is.na(sgk_parse_number("")))
  expect_true(is.na(sgk_parse_number("  ")))

  # Simple numbers
  expect_equal(sgk_parse_number("123"), 123)

  # Vector input
  result <- sgk_parse_number(c("1.234", "5,678", "9.876,54"))
  expect_equal(result, c(1234, 5678, 9876.54))
})

test_that("sgk_parse_number handles space separators", {
  # Space as thousands separator (Turkish/European)
  expect_equal(sgk_parse_number("1 234 567"), 1234567)
  expect_equal(sgk_parse_number("1 234 567,89"), 1234567.89)
  expect_equal(sgk_parse_number("1 234 567.89"), 1234567.89)
})

test_that("sgk_parse_number handles signs", {
  # Negative numbers
  expect_equal(sgk_parse_number("-1.234,56"), -1234.56)
  expect_equal(sgk_parse_number("-1,234.56"), -1234.56)

  # Positive sign
  expect_equal(sgk_parse_number("+1234.56"), 1234.56)
})

test_that("sgk_parse_number handles scientific notation", {
  expect_equal(sgk_parse_number("1e6"), 1e6)
  expect_equal(sgk_parse_number("1.5e3"), 1500)
})

test_that("sgk_clear_cache works", {
  # This should run without error
  expect_invisible(sgk_clear_cache())
})
