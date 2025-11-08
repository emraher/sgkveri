test_that("catalog functions use caching", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  # Clear cache first
  sgk_clear_cache()

  # First call should fetch from API
  start_time <- Sys.time()
  categories1 <- sgk_get_categories(use_cache = TRUE)
  first_duration <- as.numeric(Sys.time() - start_time)

  # Second call should be faster (cached)
  start_time <- Sys.time()
  categories2 <- sgk_get_categories(use_cache = TRUE)
  second_duration <- as.numeric(Sys.time() - start_time)

  # Cached call should be much faster
  expect_true(second_duration < first_duration / 2)

  # Results should be identical
  expect_identical(categories1, categories2)
})

test_that("use_cache = FALSE bypasses cache", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline()

  # Get cached version
  categories1 <- sgk_get_categories(use_cache = TRUE)

  # Force fresh fetch
  categories2 <- sgk_get_categories(use_cache = FALSE)

  # Should return same data structure
  expect_identical(names(categories1), names(categories2))
  expect_equal(nrow(categories1), nrow(categories2))
})
