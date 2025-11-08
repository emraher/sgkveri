#' Get SGK Veri data
#'
#' @param indicator_id Indicator IDs (character vector or numeric vector). Use sgk_get_categories() to see available indicator_id values.
#' @param period_id Period/year IDs (character vector or numeric vector)
#' @param city_code City plate codes (character vector or numeric vector). Default returns all cities. Use sgk_get_cities() to see available plate codes (1-81 for provinces, 999 for Turkey total, 998 for abroad).
#' @param validate Logical. If TRUE (default), validates indicator_id and period_id against available values.
#' @param convert_numeric Logical. If TRUE (default), converts year columns to numeric values.
#' @param english_names Logical. If TRUE (default), converts Turkish column names to English.
#'
#' @return A [tibble][tibble::tibble-package] with the data
#' @export
#' @examples
#' \dontrun{
#' # Get data for Istanbul and Ankara in 2023
#' data <- sgk_get_data(
#'   indicator_id = 90,
#'   period_id = 2023,
#'   city_code = c(34, 6)
#' )
#'
#' # Get multiple years with automatic numeric conversion
#' data <- sgk_get_data(
#'   indicator_id = c(90, 91),
#'   period_id = c(2021, 2022, 2023),
#'   city_code = 34
#' )
#' }
sgk_get_data <- function(indicator_id,
                         period_id,
                         city_code = NULL,
                         validate = TRUE,
                         convert_numeric = TRUE,
                         english_names = TRUE) {

  # Validate inputs if requested
  if (validate) {
    # Check indicator_id
    categories <- sgk_get_categories()
    invalid_cats <- setdiff(as.character(indicator_id), categories$indicator_id)
    if (length(invalid_cats) > 0) {
      cli::cli_warn("Invalid indicator_id(s): {.val {invalid_cats}}. Use {.fn sgk_get_categories} to see valid IDs.")
    }

    # Check period_id
    years <- sgk_get_years()
    invalid_years <- setdiff(as.integer(period_id), years$yil)
    if (length(invalid_years) > 0) {
      cli::cli_warn("Invalid period_id(s): {.val {invalid_years}}. Use {.fn sgk_get_years} to see valid years.")
    }
  }

  # Get city mapping
  cities <- sgk_get_cities()

  # If city_code is NULL, use all cities
  if (is.null(city_code)) {
    city_id <- cities$city_id
  } else {
    # Convert city_code to city_id by matching with cities data
    matches <- match(city_code, cities$city_code)

    # Check for invalid plate codes
    if (any(is.na(matches))) {
      invalid <- city_code[is.na(matches)]
      stop("Invalid plate code(s): ", paste(invalid, collapse = ", "),
           ". Use sgk_get_cities() to see valid codes.")
    }

    city_id <- cities$city_id[matches]
  }

  # Build request body with proper structure
  # Use jsonlite::unbox() for scalar values to prevent them from becoming arrays
  body_list <- list(
    KategoriId         = as.character(indicator_id),
    CografiBolgeId     = integer(0),
    IstatistikiBolgeId = integer(0),
    DonemId            = as.integer(period_id),
    SehirId            = as.integer(city_id),
    PageIndex          = jsonlite::unbox(0L),
    PageSize           = jsonlite::unbox(1000L)
  )

  # Convert to JSON (auto_unbox = FALSE keeps vector parameters as arrays)
  json_body <- jsonlite::toJSON(body_list, auto_unbox = FALSE)

  # Create request with retry logic
  req <- httr2::request("https://net.sgk.gov.tr/WS_SgkVeriV2/api/v1/veri/list") |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      "Content-Type"  = "application/json",
      "Accept"        = "application/json",
      "Authorization" = "Basic c2drdmVyaXYydXNlcjpzZ2t2ZXJpdjJ1c2Vy"
    ) |>
    httr2::req_body_raw(json_body, type = "application/json") |>
    httr2::req_user_agent("sgkveri (https://github.com/emraher/sgkveri)") |>
    httr2::req_retry(max_tries = 3, backoff = ~ 2)

  # Perform request
  cli::cli_progress_step("Fetching data from SGK API...")
  resp <- httr2::req_perform(req)

  # Check response content type
  content_type <- httr2::resp_content_type(resp)

  # Parse response based on content type
  if (grepl("json", content_type, ignore.case = TRUE)) {
    data <- httr2::resp_body_json(resp, simplifyVector = TRUE)
  } else {
    # If not JSON, print what we got for debugging
    body_text <- httr2::resp_body_string(resp)
    cli::cli_alert_danger("Received {content_type} instead of JSON")
    cli::cli_alert_info("Response body (first 500 chars):")
    cat(substr(body_text, 1, 500), "\n")
    stop("API returned HTML instead of JSON. Check if your IP is blocked or if authentication failed.")
  }

  # Convert to tibble
  if (length(data) == 0) {
    cli::cli_alert_warning("No data returned")
    return(tibble::tibble())
  }

  # Handle tutarlar (amounts) column - it's a nested list
  if ("tutarlar" %in% names(data)) {
    # Extract year columns from tutarlar
    tutarlar_df <- tibble::as_tibble(data$tutarlar)
    # Remove tutarlar column and bind the extracted columns
    data_clean <- data[, names(data) != "tutarlar", drop = FALSE]
    result <- dplyr::bind_cols(tibble::as_tibble(data_clean), tutarlar_df)
  } else {
    result <- tibble::as_tibble(data)
  }

  # Convert Turkish column names to English if requested
  if (english_names && nrow(result) > 0) {
    # Define translation mapping
    name_mapping <- c(
      "sehirAdi" = "city_name",
      "plakaKodu" = "city_code",
      "gostergeAdi" = "indicator_name",
      "kategoriAdi" = "category_name",
      "cografiBolgeAdi" = "geographic_region",
      "istatistikiBolgeAdi" = "statistical_region",
      "birim" = "unit"
    )

    # Rename columns that exist in the data
    for (turkish_name in names(name_mapping)) {
      if (turkish_name %in% names(result)) {
        names(result)[names(result) == turkish_name] <- name_mapping[turkish_name]
      }
    }
  }

  # Convert year/period columns to numeric if requested
  if (convert_numeric && nrow(result) > 0) {
    # Identify year and monthly columns (YYYY or YYYY-MM format)
    period_cols <- names(result)[grepl("^\\d{4}(-\\d{2})?$", names(result))]

    if (length(period_cols) > 0) {
      result <- result %>%
        dplyr::mutate(dplyr::across(
          dplyr::all_of(period_cols),
          ~ suppressWarnings(sgk_parse_number(.))
        ))
    }
  }

  # Sort by city_code if the column exists
  if ("city_code" %in% names(result) && nrow(result) > 0) {
    result <- result %>%
      dplyr::arrange(as.integer(city_code))
  }

  cli::cli_alert_success("Retrieved {nrow(result)} rows")
  result
}
