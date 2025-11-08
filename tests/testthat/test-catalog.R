test_that("sgk_get_categories returns a tibble with expected columns", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  categories <- sgk_get_categories()

  expect_s3_class(categories, "tbl_df")
  expect_true(nrow(categories) > 0)

  # Check that key columns exist
  expect_true("category_id" %in% names(categories))
  expect_true("category_name" %in% names(categories))
  expect_true("indicator_id" %in% names(categories))
  expect_true("indicator_name" %in% names(categories))
  expect_true("publication_freq" %in% names(categories))
  expect_true("publication_time" %in% names(categories))

  # Check column types
  expect_type(categories$category_id, "character")
  expect_type(categories$indicator_id, "character")
  expect_type(categories$category_name, "character")
  expect_type(categories$indicator_name, "character")
})

test_that("sgk_get_cities returns a tibble with expected columns", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  cities <- sgk_get_cities()

  expect_s3_class(cities, "tbl_df")
  expect_true(nrow(cities) > 0)

  # Check that key columns exist
  expect_true("city_id" %in% names(cities))
  expect_true("city_code" %in% names(cities))
  expect_true("city_name" %in% names(cities))

  # Check column types
  expect_type(cities$city_id, "integer")
  expect_type(cities$city_code, "integer")
  expect_type(cities$city_name, "character")
})

test_that("sgk_get_cities returns expected city codes", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  cities <- sgk_get_cities()

  # Check for major cities (city_code is integer)
  expect_true(34 %in% cities$city_code)  # Istanbul
  expect_true(6 %in% cities$city_code)   # Ankara
  expect_true(35 %in% cities$city_code)  # Izmir
  expect_true(999 %in% cities$city_code) # Turkey total
})

test_that("sgk_get_years returns a tibble", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  years <- sgk_get_years()

  expect_s3_class(years, "tbl_df")
  expect_true(nrow(years) > 0)
})
