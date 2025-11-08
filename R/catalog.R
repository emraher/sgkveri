# Internal function to fetch categories (for memoization)
.sgk_fetch_categories <- function(base_url = "https://net.sgk.gov.tr/WS_SgkVeriV2/api/v1") {
  req <- httr2::request(paste0(base_url, "/kategori/list")) |>
    httr2::req_headers(
      "Accept" = "application/json",
      "Authorization" = "Basic c2drdmVyaXYydXNlcjpzZ2t2ZXJpdjJ1c2Vy"
    ) |>
    httr2::req_user_agent("sgkveri (https://github.com/emraher/sgkveri)") |>
    httr2::req_retry(max_tries = 3, backoff = ~ 2)

  resp <- httr2::req_perform(req)
  data <- httr2::resp_body_json(resp, simplifyVector = TRUE)

  # Flatten the nested structure
  result <- data %>%
    dplyr::select(category_id = id, category_name = kategoriAdi, children) %>%
    tidyr::unnest(children) %>%
    dplyr::rename(
      indicator_id        = id,
      indicator_name      = label,
      publication_freq    = yayinlanmaSikligi,
      publication_time    = yayinlanmaZamani
    ) %>%
    dplyr::select(-type)

  result
}

# Memoized version
.sgk_get_categories_cached <- memoise::memoise(.sgk_fetch_categories)

#' Get list of available categories/indicators
#'
#' @param base_url Base URL for the API
#' @param use_cache Logical. If TRUE (default), uses cached results within the session.
#'   Set to FALSE to force a fresh API call.
#' @return A [tibble][tibble::tibble-package] with category information
#' @export
#' @examples
#' \dontrun{
#' # Get all categories (cached)
#' categories <- sgk_get_categories()
#'
#' # Force fresh data
#' categories <- sgk_get_categories(use_cache = FALSE)
#' }
sgk_get_categories <- function(base_url = "https://net.sgk.gov.tr/WS_SgkVeriV2/api/v1",
                                use_cache = TRUE) {
  if (use_cache) {
    .sgk_get_categories_cached(base_url)
  } else {
    .sgk_fetch_categories(base_url)
  }
}

# Internal function to fetch cities (for memoization)
.sgk_fetch_cities <- function(base_url = "https://net.sgk.gov.tr/WS_SgkVeriV2/api/v1") {
  req <- httr2::request(paste0(base_url, "/sehir/list")) |>
    httr2::req_headers(
      "Accept" = "application/json",
      "Authorization" = "Basic c2drdmVyaXYydXNlcjpzZ2t2ZXJpdjJ1c2Vy"
    ) |>
    httr2::req_user_agent("sgkveri (https://github.com/emraher/sgkveri)") |>
    httr2::req_retry(max_tries = 3, backoff = ~ 2)

  resp <- httr2::req_perform(req)
  data <- httr2::resp_body_json(resp, simplifyVector = TRUE)

  tibble::as_tibble(data) |>
    dplyr::rename(
      city_id = id,
      city_code = plakaKodu,
      city_name = sehirAdi
    ) |>
    dplyr::arrange(city_code)
}

# Memoized version
.sgk_get_cities_cached <- memoise::memoise(.sgk_fetch_cities)

#' Get list of available cities/provinces
#'
#' @param base_url Base URL for the API
#' @param use_cache Logical. If TRUE (default), uses cached results within the session.
#'   Set to FALSE to force a fresh API call.
#' @return A [tibble][tibble::tibble-package] with city information
#' @export
#' @examples
#' \dontrun{
#' # Get all cities (cached)
#' cities <- sgk_get_cities()
#'
#' # Force fresh data
#' cities <- sgk_get_cities(use_cache = FALSE)
#' }
sgk_get_cities <- function(base_url = "https://net.sgk.gov.tr/WS_SgkVeriV2/api/v1",
                            use_cache = TRUE) {
  if (use_cache) {
    .sgk_get_cities_cached(base_url)
  } else {
    .sgk_fetch_cities(base_url)
  }
}

# Internal function to fetch years (for memoization)
.sgk_fetch_years <- function(base_url = "https://net.sgk.gov.tr/WS_SgkVeriV2/api/v1") {
  req <- httr2::request(paste0(base_url, "/donem/list")) |>
    httr2::req_headers(
      "Accept" = "application/json",
      "Authorization" = "Basic c2drdmVyaXYydXNlcjpzZ2t2ZXJpdjJ1c2Vy"
    ) |>
    httr2::req_user_agent("sgkveri (https://github.com/emraher/sgkveri)") |>
    httr2::req_retry(max_tries = 3, backoff = ~ 2)

  resp <- httr2::req_perform(req)
  data <- httr2::resp_body_json(resp, simplifyVector = TRUE)

  tibble::as_tibble(data)
}

# Memoized version
.sgk_get_years_cached <- memoise::memoise(.sgk_fetch_years)

#' Get list of available years
#'
#' @param base_url Base URL for the API
#' @param use_cache Logical. If TRUE (default), uses cached results within the session.
#'   Set to FALSE to force a fresh API call.
#' @return A [tibble][tibble::tibble-package] with year information
#' @export
#' @examples
#' \dontrun{
#' # Get all years (cached)
#' years <- sgk_get_years()
#'
#' # Force fresh data
#' years <- sgk_get_years(use_cache = FALSE)
#' }
sgk_get_years <- function(base_url = "https://net.sgk.gov.tr/WS_SgkVeriV2/api/v1",
                           use_cache = TRUE) {
  if (use_cache) {
    .sgk_get_years_cached(base_url)
  } else {
    .sgk_fetch_years(base_url)
  }
}
