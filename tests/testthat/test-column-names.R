test_that("english_names = TRUE returns English column names", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  data <- sgk_get_data(
    indicator_id = 90,
    period_id = 2023,
    city_code = 34,
    english_names = TRUE
  )

  # Check for English column names
  expect_true("city_name" %in% names(data))
  expect_true("city_code" %in% names(data))
  expect_true("indicator_name" %in% names(data))
  expect_true("category_name" %in% names(data))

  # Turkish names should not be present
  expect_false("sehirAdi" %in% names(data))
  expect_false("plakaKodu" %in% names(data))
})

test_that("english_names = FALSE returns Turkish column names", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  data <- sgk_get_data(
    indicator_id = 90,
    period_id = 2023,
    city_code = 34,
    english_names = FALSE
  )

  # Check for Turkish column names
  expect_true("sehirAdi" %in% names(data))
  expect_true("plakaKodu" %in% names(data))
  expect_true("gostergeAdi" %in% names(data))
  expect_true("kategoriAdi" %in% names(data))
})
