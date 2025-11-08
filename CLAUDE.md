# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**sgkveri** is an R package that provides programmatic access to SGK Veri (Turkish Social Security Institution data) via API. The package retrieves social security statistics for Turkish provinces across multiple years and indicators.

## Development Commands

### Testing
```r
# Run all tests
devtools::test()

# Run a single test file
testthat::test_file("tests/testthat/test-api.R")

# Run tests with coverage
covr::package_coverage()
```

### Package Checks
```r
# Standard R CMD check (matches CI build args)
devtools::check(args = c("--no-manual", "--compact-vignettes=gs+qpdf"))

# Quick check without vignettes/manual
devtools::check(vignettes = FALSE, manual = FALSE)

# Build the package
devtools::build()
```

### Documentation
```r
# Update documentation from roxygen comments
devtools::document()

# Preview README (knit from README.Rmd)
devtools::build_readme()

# Build vignettes
devtools::build_vignettes()
```

### Installation
```r
# Install from source
devtools::install()

# Install with vignettes
devtools::install(build_vignettes = TRUE)
```

### RStudio Project Settings
- Uses 2 spaces for indentation (not tabs)
- UTF-8 encoding required for Turkish characters
- Auto-appends newlines and strips trailing whitespace
- LaTeX engine: XeLaTeX (for vignette builds)

## Architecture

### API Client Structure

The package follows a layered architecture:

1. **Catalog Layer** (`R/catalog.R`): Fetches metadata (categories/indicators, cities, years) with memoization
   - Uses internal `.sgk_fetch_*()` functions wrapped by memoized versions
   - Public functions: `sgk_get_categories()`, `sgk_get_cities()`, `sgk_get_years()`
   - Cache can be cleared with `sgk_clear_cache()`

2. **Data Retrieval Layer** (`R/api.R`): Main function `sgk_get_data()`
   - Handles API authentication via Basic Auth (hardcoded in headers)
   - Converts user-friendly plate codes to internal city IDs
   - Supports vectorized inputs for indicator_id, period_id, and city_code
   - Default behavior retrieves all 81 provinces when `city_code` is NULL

3. **Helper Layer** (`R/helpers.R`): Utility functions
   - `sgk_search_indicators()`: Pattern matching in indicator names
   - `sgk_validate_request()`: Pre-flight validation
   - `sgk_parse_number()`: Robust number parsing for European/US formats

### API Details

- **Base URL**: `https://net.sgk.gov.tr/WS_SgkVeriV2/api/v1`
- **Authentication**: Basic Auth with hardcoded credentials
- **Endpoints**:
  - `/kategori/list` - Categories and indicators
  - `/sehir/list` - Cities/provinces
  - `/donem/list` - Available years
  - `/veri/list` - Data retrieval (POST)
- **Retry Logic**: 3 attempts with exponential backoff (via `httr2::req_retry()`)

### Data Transformation Pipeline

When `sgk_get_data()` is called:
1. Input validation (if `validate = TRUE`)
2. City codes → City IDs mapping via `sgk_get_cities()`
3. JSON request body construction with proper array/scalar handling
4. API request with retry logic
5. Response parsing:
   - Extract nested `tutarlar` (amounts) list into columns
   - Column name translation (Turkish → English if `english_names = TRUE`):
     - `plakaKodu` → `city_code`
     - `sehirAdi` → `city_name`
     - `gostergeAdi` → `indicator_name`
     - `kategoriAdi` → `category_name`
   - Number parsing for year columns (if `convert_numeric = TRUE`)
6. Results sorted by city_code

### Memoization Strategy

Catalog functions use `memoise::memoise()` for session-level caching:
- Reduces API calls for frequently accessed metadata
- Cache persists within R session only
- User can bypass cache with `use_cache = FALSE` or clear with `sgk_clear_cache()`

### Number Parsing Logic

`sgk_parse_number()` handles international number formats:
- Detects decimal/thousands separators contextually
- Supports Turkish (dot thousands, comma decimal), US (comma thousands, dot decimal)
- Handles edge cases: space separators, scientific notation, signed numbers
- Uses smart detection: rightmost separator in ambiguous cases is treated as decimal

## Testing Strategy

Tests are split into two categories:

### Unit Tests (Run on CRAN/CI)
- `test-package.R`: Package loading
- `test-parse-number.R`: Number parsing logic (no API)
- `test-mocked-api.R`: Basic smoke tests

These tests run fast (<5 seconds) and don't require network access.

### Integration Tests (Skipped on CRAN/CI)
All integration tests use `skip_on_cran()` and `skip_on_ci()`:
- `test-api.R`: API requests and error handling
- `test-catalog.R`: Catalog functions
- `test-caching.R`: Caching behavior
- `test-numeric-conversion.R`: Numeric conversion with real API data
- `test-column-names.R`: Column name translation
- `test-helpers.R`: Validation helpers

Integration tests make real API calls and are skipped in automated environments to:
- Avoid network dependencies in CI/CRAN
- Prevent rate limiting or IP blocking
- Keep builds fast

When adding new tests:
- Pure logic tests → Unit test file (no skip)
- API-dependent tests → Integration test file (with skip_on_cran/skip_on_ci)
- Use `skip_if_offline()` for graceful handling of network issues
- Mock fixtures via `httptest2` can be added in the future for faster CI testing

## Special Considerations

### City Code Mapping
- Users provide standard Turkish city codes/plate codes (1-81, plus 999 for Turkey total, 998 for abroad)
- Package internally converts to SGK's city_id system via lookup table
- Invalid city codes throw informative errors
- When `city_code = NULL` (default), all 82 entities are returned (81 provinces + Turkey total)
- The returned data uses `city_code` column (not `plate_code`) to match the function parameter name

### Turkish Character Encoding
- Column names and data contain Turkish characters (ğ, ü, ş, ı, ö, ç)
- Default behavior translates column names to English for easier programming
- UTF-8 encoding must be preserved

### Global Variables
- `R/utils-globals.R` declares global variables used in dplyr/tidyr chains
- Prevents R CMD check NOTEs about undefined variables
- Includes Turkish API field names (plakaKodu, sehirAdi, etc.) and tidy eval variables

### Package Options
- `sgkveriR.download_dir`: Set in `.onLoad()` hook (defaults to tempdir)
- Created automatically if doesn't exist
- Used for potential future file caching (currently only in-memory memoization)

### GitHub Actions
- R-CMD-check runs on push/PR to main/master
- **Fast configuration**: Only runs on `ubuntu-latest` with R `release`
  - Reduced from 5 OS/R combinations to 1 for speed
  - Typical run time: ~3-5 minutes
- Sets `NOT_CRAN=false` to simulate CRAN environment
- Only unit tests run (integration tests are skipped)
- Build arguments: `--no-manual --compact-vignettes=gs+qpdf`

## Code Style

- Function naming: `sgk_*` prefix for all exported functions
- Internal functions: `.sgk_*` prefix with leading dot
- Use tidyverse patterns: pipes (`|>`), dplyr, tibble
- CLI messages via `cli` package for user feedback
- roxygen2 documentation with markdown support
- 2-space indentation (enforced by .Rproj settings)

## Common Workflows

### Adding a New Exported Function
1. Write function in appropriate `R/*.R` file
2. Add roxygen2 documentation with `@export` tag
3. Add any non-standard evaluation variables to `R/utils-globals.R`
4. Run `devtools::document()` to update NAMESPACE and man pages
5. Write tests:
   - Pure logic/no API → `tests/testthat/test-parse-number.R` or new unit test file
   - Requires API → New file with `skip_on_cran()` and `skip_on_ci()`
6. Run `devtools::check()` to verify

### Modifying API Behavior
- API authentication is hardcoded in headers (Basic Auth)
- Retry logic configured in `httr2::req_retry(max_tries = 3, backoff = ~ 2)`
- User agent identifies package: `"sgkveri (https://github.com/emraher/sgkveri)"`
- All API functions should handle both JSON and HTML responses (IP blocking detection)

### Debugging API Issues
- Check if API returned HTML instead of JSON (indicates IP block or auth failure)
- Verify response content-type before parsing
- Test with `validate = FALSE` to skip catalog lookups
- Use `sgk_clear_cache()` if catalog data seems stale
