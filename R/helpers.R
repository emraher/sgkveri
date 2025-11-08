#' Search for indicators by keyword
#'
#' @param pattern Character string or regular expression to search for in indicator names and descriptions.
#' @param ignore_case Logical. If TRUE (default), case is ignored during matching.
#'
#' @return A [tibble][tibble::tibble-package] with matching indicators
#' @export
#' @examples
#' \dontrun{
#' # Find all indicators related to "yaşlılık" (old age)
#' yaslilik_indicators <- sgk_search_indicators("yaşlılık")
#'
#' # Case-sensitive search
#' sgk_search_indicators("Aktif", ignore_case = FALSE)
#' }
sgk_search_indicators <- function(pattern, ignore_case = TRUE) {
  categories <- sgk_get_categories()

  # Search in both indicator_name and category_name
  matches <- grepl(pattern, categories$indicator_name, ignore.case = ignore_case) |
             grepl(pattern, categories$category_name, ignore.case = ignore_case)

  result <- categories[matches, ]

  if (nrow(result) == 0) {
    cli::cli_alert_warning("No indicators found matching pattern: {.val {pattern}}")
  } else {
    cli::cli_alert_success("Found {nrow(result)} indicator{?s} matching pattern: {.val {pattern}}")
  }

  result
}

#' Get the most recent available year
#'
#' @return Integer with the most recent year available in the SGK API
#' @export
#' @examples
#' \dontrun{
#' latest_year <- sgk_get_latest_year()
#' }
sgk_get_latest_year <- function() {
  years <- sgk_get_years()
  max(years$yil, na.rm = TRUE)
}

#' Validate SGK API request parameters
#'
#' @param indicator_id Indicator IDs to validate
#' @param period_id Period/year IDs to validate
#' @param city_code City plate codes to validate
#'
#' @return Logical. TRUE if all parameters are valid, FALSE otherwise.
#'   Prints informative messages about invalid parameters.
#' @export
#' @examples
#' \dontrun{
#' # Validate parameters before making request
#' if (sgk_validate_request(90, 2023, 34)) {
#'   data <- sgk_get_data(90, 2023, 34)
#' }
#' }
sgk_validate_request <- function(indicator_id, period_id, city_code = NULL) {
  all_valid <- TRUE

  # Validate indicator_id
  categories <- sgk_get_categories()
  invalid_cats <- setdiff(as.character(indicator_id), categories$indicator_id)
  if (length(invalid_cats) > 0) {
    cli::cli_alert_danger("Invalid indicator_id(s): {.val {invalid_cats}}")
    cli::cli_alert_info("Use {.fn sgk_get_categories} to see valid IDs")
    all_valid <- FALSE
  } else {
    cli::cli_alert_success("All indicator_id values are valid")
  }

  # Validate period_id
  years <- sgk_get_years()
  invalid_years <- setdiff(as.integer(period_id), years$yil)
  if (length(invalid_years) > 0) {
    cli::cli_alert_danger("Invalid period_id(s): {.val {invalid_years}}")
    cli::cli_alert_info("Use {.fn sgk_get_years} to see valid years")
    all_valid <- FALSE
  } else {
    cli::cli_alert_success("All period_id values are valid")
  }

  # Validate city_code if provided
  if (!is.null(city_code)) {
    cities <- sgk_get_cities()
    invalid_codes <- setdiff(as.integer(city_code), cities$city_code)
    if (length(invalid_codes) > 0) {
      cli::cli_alert_danger("Invalid city_code(s): {.val {invalid_codes}}")
      cli::cli_alert_info("Use {.fn sgk_get_cities} to see valid plate codes")
      all_valid <- FALSE
    } else {
      cli::cli_alert_success("All city_code values are valid")
    }
  }

  invisible(all_valid)
}

#' Clear cached catalog data
#'
#' @description
#' Clears the in-memory cache for categories, cities, and years.
#' Useful when you want to force fresh data retrieval.
#'
#' @return NULL (invisibly)
#' @export
#' @examples
#' \dontrun{
#' # Clear all cached data
#' sgk_clear_cache()
#'
#' # Next call will fetch fresh data
#' categories <- sgk_get_categories()
#' }
sgk_clear_cache <- function() {
  memoise::forget(.sgk_get_categories_cached)
  memoise::forget(.sgk_get_cities_cached)
  memoise::forget(.sgk_get_years_cached)
  cli::cli_alert_success("Cache cleared")
  invisible(NULL)
}


#' Parse numbers with mixed decimal and thousands separators
#'
#' @description
#' Robustly converts character strings to numeric values, handling various
#' international number formats with different decimal and thousands separators.
#'
#' @param x Character vector of numbers to parse
#' @param na_invalid Logical. If TRUE (default), invalid strings return NA.
#'   If FALSE, triggers a warning for invalid formats.
#'
#' @return Numeric vector with parsed values (unnamed). Invalid inputs return NA.
#'
#' @details
#' The function handles multiple number formats:
#' \itemize{
#'   \item European format with dot as thousands: "70.586.256" -> 70586256
#'   \item European format with space as thousands: "70 586 256" -> 70586256
#'   \item European format with comma as decimal: "87.000,563" -> 87000.563
#'   \item US format with comma as thousands: "1,234,567.8" -> 1234567.8
#'   \item Negative/positive numbers: "-1.234,56" -> -1234.56
#'   \item Scientific notation: "1e6" -> 1000000
#' }
#'
#' **Smart Detection Logic:**
#' \enumerate{
#'   \item If both separators present: rightmost is decimal, other is thousands
#'   \item If only one separator with pattern like "12.345.678": thousands only
#'   \item If space present: treated as thousands separator
#'   \item Otherwise: attempts standard numeric conversion
#' }
#'
#' @export
#' @examples
#' \dontrun{
#' # European formats
#' sgk_parse_number("70.586.256")        # 70586256
#' sgk_parse_number("87.000,563")        # 87000.563
#' sgk_parse_number("1 234 567,89")      # 1234567.89
#'
#' # US format
#' sgk_parse_number("1,234,567.8")       # 1234567.8
#'
#' # Edge cases
#' sgk_parse_number("-1.234,56")         # -1234.56
#' sgk_parse_number("1e6")               # 1000000
#'
#' # Vector input
#' sgk_parse_number(c("1.234", "5,678", "9.876,54"))
#' }
sgk_parse_number <- function(x, na_invalid = TRUE) {
  # Input validation
  if (!is.character(x) && !is.factor(x)) {
    # Handle numeric input
    if (is.numeric(x)) {
      return(as.numeric(x))
    }
    # Handle NA (logical or character)
    if (all(is.na(x))) {
      return(rep(NA_real_, length(x)))
    }
    cli::cli_abort("{.arg x} must be a character vector, not {.cls {class(x)}}")
  }

  # Convert factor to character
  if (is.factor(x)) {
    x <- as.character(x)
  }

  .parse_single <- function(s) {
    # Handle NA and empty
    if (is.na(s)) return(NA_real_)
    s_orig <- trimws(s)
    if (s_orig == "") return(NA_real_)

    # Preserve sign and work with unsigned version
    sign <- ""
    s <- s_orig
    if (grepl("^[+-]", s)) {
      sign <- substr(s, 1, 1)
      s <- substring(s, 2)
      s <- trimws(s)  # Trim again after removing sign
    }

    # Handle space as thousands separator (Turkish/European)
    if (grepl(" ", s)) {
      # Check if it's a valid space-separated number
      if (grepl("^\\d{1,3}( \\d{3})+([.,]\\d+)?$", s)) {
        s <- gsub(" ", "", s, fixed = TRUE)  # Remove spaces
        # Continue with normal parsing (may have decimal separator)
      } else {
        return(NA_real_)
      }
    }

    has_dot <- grepl(".", s, fixed = TRUE)
    has_comma <- grepl(",", s, fixed = TRUE)

    # Case 1: Both separators present - rightmost is decimal
    if (has_dot && has_comma) {
      # Find rightmost separator
      pos <- gregexpr("[.,]", s)[[1]]
      last_pos <- max(pos)
      last_sep <- substr(s, last_pos, last_pos)

      if (last_sep == ".") {
        # US format: comma = thousands, dot = decimal
        s_clean <- gsub(",", "", s, fixed = TRUE)
      } else {
        # European format: dot = thousands, comma = decimal
        s_clean <- gsub("\\.", "", s)
        s_clean <- gsub(",", ".", s_clean, fixed = TRUE)
      }
      result <- suppressWarnings(as.numeric(paste0(sign, s_clean)))
      return(if (is.na(result) && !na_invalid) {
        cli::cli_warn("Invalid number format: {.val {s_orig}}")
        NA_real_
      } else {
        result
      })
    }

    # Case 2: Only one kind of separator
    # Thousands-only pattern: groups of exactly 3 digits throughout
    if (grepl("^\\d{1,3}([.,]\\d{3})+$", s)) {
      s_clean <- gsub("[.,]", "", s)
      return(suppressWarnings(as.numeric(paste0(sign, s_clean))))
    }

    # Case 3: Single separator - treat as decimal
    if (has_comma || has_dot) {
      s_clean <- gsub(",", ".", s, fixed = TRUE)
      result <- suppressWarnings(as.numeric(paste0(sign, s_clean)))
      return(result)
    }

    # Case 4: No separators - simple number or scientific notation
    result <- suppressWarnings(as.numeric(paste0(sign, s)))
    return(result)
  }

  # Use unname() to remove names from vapply output
  unname(vapply(x, .parse_single, numeric(1), USE.NAMES = FALSE))
}
