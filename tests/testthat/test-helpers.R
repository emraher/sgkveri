# Integration tests for helper functions - require API access
# These tests are skipped on CRAN and CI

test_that("sgk_search_indicators works correctly", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  # Search should return matching results
  results <- sgk_search_indicators("Aktif")

  expect_s3_class(results, "tbl_df")
  expect_true(nrow(results) > 0)
  expect_true("indicator_id" %in% names(results))
  expect_true("indicator_name" %in% names(results))
})

test_that("sgk_search_indicators handles no matches", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  # Search for something that doesn't exist
  results <- sgk_search_indicators("xyzabc123nonexistent")

  expect_s3_class(results, "tbl_df")
  expect_equal(nrow(results), 0)
})

test_that("sgk_get_latest_year returns a valid year", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  latest <- sgk_get_latest_year()

  expect_type(latest, "integer")
  expect_true(latest >= 2020)  # Should be at least 2020
  expect_true(latest <= as.integer(format(Sys.Date(), "%Y")) + 1)  # Not in far future
})

test_that("sgk_validate_request validates correctly", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  # Valid request should return TRUE
  expect_true(sgk_validate_request(90, 2023, 34))

  # Invalid category should return FALSE
  expect_false(sgk_validate_request(999999, 2023, 34))

  # Invalid year should return FALSE
  expect_false(sgk_validate_request(90, 1900, 34))

  # Invalid city code should return FALSE
  expect_false(sgk_validate_request(90, 2023, 999999))
})
