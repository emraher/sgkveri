
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sgkveri

<!-- badges: start -->

[![R-CMD-check](https://github.com/emraher/sgkveri/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/emraher/sgkveri/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of sgkveri is to download data from <https://veri.sgk.gov.tr/>

## Installation

You can install the development version of sgkveri from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("emraher/sgkveri")
```

## Example

There is only one function in the package which downloads all data

``` r
sgkdata <- sgkveri::sgkveri()

head(sgkdata)
#> # A tibble: 6 × 9
#>   id    category           city  region  indicator      unit   year month  value
#>   <fct> <fct>              <fct> <fct>   <fct>          <fct> <dbl> <dbl>  <int>
#> 1 73    Aktif Sigortalılar Adana Akdeniz Sigortalı, Ak… Kişi   2009    NA 331826
#> 2 73    Aktif Sigortalılar Adana Akdeniz Sigortalı, Ak… Kişi   2010    NA 359501
#> 3 73    Aktif Sigortalılar Adana Akdeniz Sigortalı, Ak… Kişi   2011    NA 395819
#> 4 73    Aktif Sigortalılar Adana Akdeniz Sigortalı, Ak… Kişi   2012    NA 409450
#> 5 73    Aktif Sigortalılar Adana Akdeniz Sigortalı, Ak… Kişi   2013    NA 431585
#> 6 73    Aktif Sigortalılar Adana Akdeniz Sigortalı, Ak… Kişi   2014    NA 454816
```
