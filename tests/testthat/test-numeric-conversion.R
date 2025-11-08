test_that("convert_numeric = TRUE converts year columns to numeric", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  data <- sgk_get_data(
    indicator_id = 90,
    period_id = 2023,
    city_code = 34,
    convert_numeric = TRUE
  )

  # Year column should be numeric
  expect_type(data$`2023`, "double")
})

test_that("convert_numeric = FALSE keeps year columns as character", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  data <- sgk_get_data(
    indicator_id = 90,
    period_id = 2023,
    city_code = 34,
    convert_numeric = FALSE
  )

  # Year column should be character
  expect_type(data$`2023`, "character")
})

test_that("numeric conversion handles multiple years", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  data <- sgk_get_data(
    indicator_id = 90,
    period_id = c(2022, 2023),
    city_code = 34,
    convert_numeric = TRUE
  )

  # Both year columns should be numeric
  expect_type(data$`2022`, "double")
  expect_type(data$`2023`, "double")
})

test_that("numeric conversion handles monthly columns", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  data <- sgk_get_data(
    indicator_id = 90,
    period_id = 2024,
    city_code = 34,
    convert_numeric = TRUE
  )

  # Monthly columns should be numeric (2024 returns monthly data)
  monthly_cols <- names(data)[grepl("^\\d{4}-\\d{2}$", names(data))]
  if (length(monthly_cols) > 0) {
    expect_type(data[[monthly_cols[1]]], "double")
  }
})
