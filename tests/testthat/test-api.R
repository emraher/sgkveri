test_that("sgk_get_data returns data for all cities by default", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  data <- sgk_get_data(
    indicator_id = 90,
    period_id = 2023
  )

  expect_s3_class(data, "tbl_df")
  expect_true(nrow(data) > 80)  # Should have all provinces + Turkey total
  expect_true("2023" %in% names(data))
})

test_that("sgk_get_data filters by city_code correctly", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  # Test with specific cities
  data <- sgk_get_data(
    indicator_id = 90,
    period_id = 2023,
    city_code = c(34, 6, 35)  # Istanbul, Ankara, Izmir
  )

  expect_s3_class(data, "tbl_df")
  expect_equal(nrow(data), 3)
  expect_true("2023" %in% names(data))
})

test_that("sgk_get_data handles multiple years", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  data <- sgk_get_data(
    indicator_id = 90,
    period_id = c(2022, 2023),
    city_code = 34  # Istanbul only
  )

  expect_s3_class(data, "tbl_df")
  expect_true("2022" %in% names(data))
  expect_true("2023" %in% names(data))
})

test_that("sgk_get_data handles multiple indicators", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  data <- sgk_get_data(
    indicator_id = c(90, 91),
    period_id = 2023,
    city_code = 34  # Istanbul only
  )

  expect_s3_class(data, "tbl_df")
  expect_true(nrow(data) >= 2)
})

test_that("sgk_get_data throws error for invalid city_code", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  expect_error(
    sgk_get_data(
      indicator_id = 90,
      period_id = 2023,
      city_code = 999999  # Invalid code
    ),
    "Invalid plate code"
  )
})

test_that("sgk_get_data returns expected column names", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  data <- sgk_get_data(
    indicator_id = 90,
    period_id = 2023,
    city_code = 34
  )

  # By default, should return English column names
  expect_true("city_name" %in% names(data))
  expect_true("city_code" %in% names(data))
  expect_true("indicator_name" %in% names(data))
  expect_true("category_name" %in% names(data))
})

test_that("sgk_get_data returns data sorted by city_code", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  data <- sgk_get_data(
    indicator_id = 90,
    period_id = 2023
  )

  # Check that data is sorted by city_code
  city_codes <- as.integer(data$city_code)
  expect_true(all(city_codes == sort(city_codes)))

  # First row should be city code 1 (Adana)
  expect_equal(data$city_code[1], "1")

  # Last row should be city code 999 (Türkiye)
  expect_equal(data$city_code[nrow(data)], "999")
})
