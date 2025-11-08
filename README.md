
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sgkveri

<!-- badges: start -->

[![R-CMD-check](https://github.com/emraher/sgkveri/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/emraher/sgkveri/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**sgkveri** provides programmatic access to the Social Security
Institution of Turkey (SGK) data portal at <https://veri.sgk.gov.tr/>.
The package is designed for researchers and analysts who want to
retrieve and work with social security statistics for Turkish provinces
over multiple years and indicators through a concise and user-friendly R
interface.

## Features

- Retrieve social security data for all 81 Turkish provinces
- Access a wide range of indicators (employment, pensions, healthcare,
  etc.)
- Query data across multiple years
- Automatic validation and type conversion
- Session-level caching for faster repeated queries
- Choice of English or Turkish column names
- Built-in search tools for discovering indicators

## Installation

You can install the development version of **sgkveri** from
[GitHub](https://github.com/emraher/sgkveri) with:

``` r
# install.packages("pak")
pak::pak("emraher/sgkveri")
```

Or using **remotes**:

``` r
# install.packages("remotes")
remotes::install_github("emraher/sgkveri")
```

## Quick Start

### Basic Usage

``` r
library(sgkveri)

# Get data for a specific indicator, year, and city
data <- sgk_get_data(
  indicator_id = 90,  # Indicator ID
  period_id = 2023,   # Year
  city_code = 34      # Istanbul (plate code)
)
#> ℹ Fetching data from SGK API...                                ✔ Retrieved 1 rows
#> ℹ Fetching data from SGK API...✔ Fetching data from SGK API... [270ms]

data
#> # A tibble: 1 × 8
#>   city_name city_code indicator_name             category_name geographic_region
#>   <chr>     <chr>     <chr>                      <chr>         <chr>            
#> 1 İstanbul  34        01.Toplam Aktif Sigortalı… Aktif Sigort… Marmara          
#> # ℹ 3 more variables: statistical_region <chr>, unit <chr>, `2023` <dbl>
```

### Exploring Available Data

Before downloading data, it is often useful to see what the API offers:

``` r
# All available indicator categories and indicators
categories <- sgk_get_categories()
head(categories)
#> # A tibble: 6 × 9
#>   category_id category_name      indicator_id indicator_name         tanim birim
#>   <chr>       <chr>              <chr>        <chr>                  <chr> <chr>
#> 1 1           Aktif Sigortalılar 90           01.Toplam Aktif Sigor… "İlg… Kisi 
#> 2 1           Aktif Sigortalılar 91           01.Toplam Aktif Sigor… "551… Kisi 
#> 3 1           Aktif Sigortalılar 92           01.Toplam Aktif Sigor… "\"5… Kisi 
#> 4 1           Aktif Sigortalılar 93           01.Toplam Aktif Sigor… "\"5… Kisi 
#> 5 1           Aktif Sigortalılar 94           01.Toplam Aktif Sigor… "551… Kisi 
#> 6 1           Aktif Sigortalılar 95           01.Toplam Aktif Sigor… "\"K… Kisi 
#> # ℹ 3 more variables: publication_freq <chr>, publication_time <chr>,
#> #   kaynak <chr>

# Available years
years <- sgk_get_years()
head(years)
#> # A tibble: 6 × 2
#>      id   yil
#>   <int> <int>
#> 1  2009  2009
#> 2  2010  2010
#> 3  2011  2011
#> 4  2012  2012
#> 5  2013  2013
#> 6  2014  2014

# List of cities with plate codes
cities <- sgk_get_cities()
head(cities)
#> # A tibble: 6 × 3
#>   city_id city_code city_name     
#>     <int>     <int> <chr>         
#> 1      83         1 Adana         
#> 2      82         2 Adıyaman      
#> 3      81         3 Afyonkarahisar
#> 4      80         4 Ağrı          
#> 5      78         5 Amasya        
#> 6      77         6 Ankara

# Search indicators by keyword (Turkish)
pension_data <- sgk_search_indicators("yaşlılık")      # Old-age pensions
#> ✔ Found 7 indicators matching pattern: "yaşlılık"
head(pension_data)
#> # A tibble: 6 × 9
#>   category_id category_name      indicator_id indicator_name         tanim birim
#>   <chr>       <chr>              <chr>        <chr>                  <chr> <chr>
#> 1 3           Pasif Sigortalılar 57           14.Yaşlılık Aylığı Al… 4/a … Kisi 
#> 2 3           Pasif Sigortalılar 58           14.Yaşlılık Aylığı Al… 4/b … Kisi 
#> 3 3           Pasif Sigortalılar 54           14.Yaşlılık Aylığı Al… Aylı… Kisi 
#> 4 3           Pasif Sigortalılar 59           14.Yaşlılık Aylığı Al… Tarı… Kisi 
#> 5 3           Pasif Sigortalılar 55           14.Yaşlılık Aylığı Al… Aylı… Kisi 
#> 6 3           Pasif Sigortalılar 60           14.Yaşlılık Aylığı Al… 4/b … Kisi 
#> # ℹ 3 more variables: publication_freq <chr>, publication_time <chr>,
#> #   kaynak <chr>

employment_data <- sgk_search_indicators("sigortalı")  # Insured workers
#> ✔ Found 72 indicators matching pattern: "sigortalı"
head(employment_data)
#> # A tibble: 6 × 9
#>   category_id category_name      indicator_id indicator_name         tanim birim
#>   <chr>       <chr>              <chr>        <chr>                  <chr> <chr>
#> 1 1           Aktif Sigortalılar 90           01.Toplam Aktif Sigor… "İlg… Kisi 
#> 2 1           Aktif Sigortalılar 91           01.Toplam Aktif Sigor… "551… Kisi 
#> 3 1           Aktif Sigortalılar 92           01.Toplam Aktif Sigor… "\"5… Kisi 
#> 4 1           Aktif Sigortalılar 93           01.Toplam Aktif Sigor… "\"5… Kisi 
#> 5 1           Aktif Sigortalılar 94           01.Toplam Aktif Sigor… "551… Kisi 
#> 6 1           Aktif Sigortalılar 95           01.Toplam Aktif Sigor… "\"K… Kisi 
#> # ℹ 3 more variables: publication_freq <chr>, publication_time <chr>,
#> #   kaynak <chr>
```

## Common Use Cases

### Multiple Cities

``` r
# Data for several major provinces
major_cities <- sgk_get_data(
  indicator_id = 90,
  period_id = 2023,
  city_code = c(6, 34, 35)  # Ankara, Istanbul, Izmir
)
#> ℹ Fetching data from SGK API...                                ✔ Retrieved 3 rows
#> ℹ Fetching data from SGK API...✔ Fetching data from SGK API... [137ms]

head(major_cities)
#> # A tibble: 3 × 8
#>   city_name city_code indicator_name             category_name geographic_region
#>   <chr>     <chr>     <chr>                      <chr>         <chr>            
#> 1 Ankara    6         01.Toplam Aktif Sigortalı… Aktif Sigort… İç Anadolu       
#> 2 İstanbul  34        01.Toplam Aktif Sigortalı… Aktif Sigort… Marmara          
#> 3 İzmir     35        01.Toplam Aktif Sigortalı… Aktif Sigort… Ege              
#> # ℹ 3 more variables: statistical_region <chr>, unit <chr>, `2023` <dbl>
```

### Multiple Years

``` r
# Simple time-series extraction
time_series <- sgk_get_data(
  indicator_id = 90,
  period_id = 2019:2023,
  city_code = 34
)
#> ℹ Fetching data from SGK API...                                ✔ Retrieved 1 rows
#> ℹ Fetching data from SGK API...✔ Fetching data from SGK API... [79ms]

head(time_series)
#> # A tibble: 1 × 12
#>   city_name city_code indicator_name             category_name geographic_region
#>   <chr>     <chr>     <chr>                      <chr>         <chr>            
#> 1 İstanbul  34        01.Toplam Aktif Sigortalı… Aktif Sigort… Marmara          
#> # ℹ 7 more variables: statistical_region <chr>, unit <chr>, `2019` <dbl>,
#> #   `2020` <dbl>, `2021` <dbl>, `2022` <dbl>, `2023` <dbl>
```

### All Provinces

``` r
# Data for all provinces (default)
nationwide <- sgk_get_data(
  indicator_id = 90,
  period_id = 2023
  # city_code = NULL (default: all provinces)
)
#> ℹ Fetching data from SGK API...                                ✔ Retrieved 82 rows
#> ℹ Fetching data from SGK API...✔ Fetching data from SGK API... [119ms]

head(nationwide)
#> # A tibble: 6 × 8
#>   city_name      city_code indicator_name        category_name geographic_region
#>   <chr>          <chr>     <chr>                 <chr>         <chr>            
#> 1 Adana          1         01.Toplam Aktif Sigo… Aktif Sigort… Akdeniz          
#> 2 Adıyaman       2         01.Toplam Aktif Sigo… Aktif Sigort… Güneydoğu Anadolu
#> 3 Afyonkarahisar 3         01.Toplam Aktif Sigo… Aktif Sigort… Ege              
#> 4 Ağrı           4         01.Toplam Aktif Sigo… Aktif Sigort… Doğu Anadolu     
#> 5 Amasya         5         01.Toplam Aktif Sigo… Aktif Sigort… Karadeniz        
#> 6 Ankara         6         01.Toplam Aktif Sigo… Aktif Sigort… İç Anadolu       
#> # ℹ 3 more variables: statistical_region <chr>, unit <chr>, `2023` <dbl>
```

### Multiple Indicators

``` r
# Compare several indicators for the same city and year
multi_indicator <- sgk_get_data(
  indicator_id = c(90, 91, 92),
  period_id = 2023,
  city_code = 34
)
#> ℹ Fetching data from SGK API...                                ✔ Retrieved 3 rows
#> ℹ Fetching data from SGK API...✔ Fetching data from SGK API... [86ms]

head(multi_indicator)
#> # A tibble: 3 × 8
#>   city_name city_code indicator_name             category_name geographic_region
#>   <chr>     <chr>     <chr>                      <chr>         <chr>            
#> 1 İstanbul  34        01.Toplam Aktif Sigortalı… Aktif Sigort… Marmara          
#> 2 İstanbul  34        01.Toplam Aktif Sigortalı… Aktif Sigort… Marmara          
#> 3 İstanbul  34        01.Toplam Aktif Sigortalı… Aktif Sigort… Marmara          
#> # ℹ 3 more variables: statistical_region <chr>, unit <chr>, `2023` <dbl>
```

### Turkey-wide Totals and Abroad

``` r
# National total using city code 999
turkey_total <- sgk_get_data(
  indicator_id = 90,
  period_id = 2023,
  city_code = 999
)
#> ℹ Fetching data from SGK API...                                ✔ Retrieved 1 rows
#> ℹ Fetching data from SGK API...✔ Fetching data from SGK API... [74ms]

head(turkey_total)
#> # A tibble: 1 × 8
#>   city_name city_code indicator_name             category_name geographic_region
#>   <chr>     <chr>     <chr>                      <chr>         <chr>            
#> 1 Türkiye   999       01.Toplam Aktif Sigortalı… Aktif Sigort… Türkiye          
#> # ℹ 3 more variables: statistical_region <chr>, unit <chr>, `2023` <dbl>
```

## Advanced Features

### Turkish Column Names

``` r
# Preserve original Turkish variable names
data_tr <- sgk_get_data(
  indicator_id = 90,
  period_id = 2023,
  city_code = 34,
  english_names = FALSE
)
#> ℹ Fetching data from SGK API...                                ✔ Retrieved 1 rows
#> ℹ Fetching data from SGK API...✔ Fetching data from SGK API... [74ms]

head(data_tr)
#> # A tibble: 1 × 8
#>   sehirAdi plakaKodu gostergeAdi kategoriAdi cografiBolgeAdi istatistikiBolgeAdi
#>   <chr>    <chr>     <chr>       <chr>       <chr>           <chr>              
#> 1 İstanbul 34        01.Toplam … Aktif Sigo… Marmara         İstanbul           
#> # ℹ 2 more variables: birim <chr>, `2023` <dbl>
```

### Raw String Data

``` r
# Disable automatic numeric conversion for custom parsing
data_raw <- sgk_get_data(
  indicator_id = 90,
  period_id = 2023,
  city_code = 34,
  convert_numeric = FALSE
)
#> ℹ Fetching data from SGK API...                                ✔ Retrieved 1 rows
#> ℹ Fetching data from SGK API...✔ Fetching data from SGK API... [72ms]

head(data_raw)
#> # A tibble: 1 × 8
#>   city_name city_code indicator_name             category_name geographic_region
#>   <chr>     <chr>     <chr>                      <chr>         <chr>            
#> 1 İstanbul  34        01.Toplam Aktif Sigortalı… Aktif Sigort… Marmara          
#> # ℹ 3 more variables: statistical_region <chr>, unit <chr>, `2023` <chr>
```

### Skipping Validation for Speed

``` r
# Skip input validation (faster, but less safe)
data_fast <- sgk_get_data(
  indicator_id = 90,
  period_id = 2023,
  city_code = 34,
  validate = FALSE
)
#> ℹ Fetching data from SGK API...                                ✔ Retrieved 1 rows
#> ℹ Fetching data from SGK API...✔ Fetching data from SGK API... [76ms]

head(data_fast)
#> # A tibble: 1 × 8
#>   city_name city_code indicator_name             category_name geographic_region
#>   <chr>     <chr>     <chr>                      <chr>         <chr>            
#> 1 İstanbul  34        01.Toplam Aktif Sigortalı… Aktif Sigort… Marmara          
#> # ℹ 3 more variables: statistical_region <chr>, unit <chr>, `2023` <dbl>
```

### Cache Management

``` r
# Clear session cache to force fresh API calls
sgk_clear_cache()
#> ✔ Cache cleared

# Bypass cache for a single call
categories <- sgk_get_categories(use_cache = FALSE)
```

## City Codes

Turkish provinces are indexed by standardized plate (city) codes (1–81).
For example:

- 1: Adana
- 6: Ankara
- 34: Istanbul
- 35: Izmir

Special codes:

- `999`: Turkey total (national aggregate)
- `998`: Abroad

Use `sgk_get_cities()` to obtain the full mapping. The API uses internal
`city_id` values; **sgkveri** handles the mapping from plate codes to
API identifiers internally. In regular usage, you should supply **plate
codes** to the R functions.

## Indicators

Indicators are grouped into categories. Typical domains include:

- Employment statistics
- Pension recipients
- Health insurance and healthcare services
- Workplace accidents and occupational risks
- Social assistance and related programs

Use `sgk_get_categories()` to list all categories and indicators, or
`sgk_search_indicators()` to search indicators by keyword.

## Data Structure

By default, **sgkveri** returns a tibble with the following columns:

- `city_code`: Province plate code (1–81 for provinces, 999 for Turkey
  total, 998 for abroad)
- `city_name`: Province name in Turkish
- `category_id`: Indicator category ID
- `indicator_name`: Full indicator description
- Year columns (e.g. `2019`, `2020`, `2021`): Values for each year
  requested

Depending on the specific endpoint and options, additional columns may
be present.

## Error Handling

The package includes defensive checks to make failures informative:

- Invalid category or indicator IDs trigger warnings or errors with
  clear messages
- Invalid or unavailable years are caught during validation
- Transient API errors are retried automatically (with backoff)
- Network and HTTP errors yield informative error messages rather than
  silent failures

## Performance Guidelines

To reduce latency and server load:

1.  Use `validate = FALSE` when you are confident in your inputs and
    need maximum speed.
2.  Request multiple years, cities, or indicators in a single call
    rather than looping over many small calls.
3.  Take advantage of the built-in cache for repeated queries.
4.  Be aware that the API is aggressively rate-limited; avoid rapid,
    unnecessary repeated requests.

## Data Source

All data are obtained from the official SGK API:

- Base endpoint: `https://net.sgk.gov.tr/WS_SgkVeriV2/api/v1`

Please use the service responsibly:

- Avoid excessive or automated high-frequency requests
- Cache and reuse downloaded data where possible
- Follow any current SGK data usage terms and conditions

## Contributing

Bug reports, feature requests, and pull requests are welcome via GitHub:

<https://github.com/emraher/sgkveri>

## License

This package is released under the MIT License. See the `LICENSE` file
for details.

## Citation

To cite **sgkveri** in academic work:

``` r
citation("sgkveri")
#> To cite package 'sgkveri' in publications use:
#> 
#>   Er E (2025). _sgkveri: Programmatic downloads from SGK Veri_. R
#>   package version 0.0.0.9000, <https://github.com/emraher/sgkveri>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {sgkveri: Programmatic downloads from SGK Veri},
#>     author = {Emrah Er},
#>     year = {2025},
#>     note = {R package version 0.0.0.9000},
#>     url = {https://github.com/emraher/sgkveri},
#>   }
```

## Related Resources

- SGK Data Portal: <https://veri.sgk.gov.tr/>
- SGK Official Website: <https://www.sgk.gov.tr/>

## Package Vignette

For more detailed workflows and applied examples, see the introductory
vignette:

``` r
vignette("sgkveri-intro", package = "sgkveri")
#> Warning: vignette 'sgkveri-intro' not found
```
