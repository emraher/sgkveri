#' Download data from SGK Veri
#'
#' @return A data frame (tibble)
#'
#' @export
sgkveri <- function(){
  headers <- c(
    "sec-ch-ua" = '"Not A(Brand";v="99", "Microsoft Edge";v="121", "Chromium";v="121"',
    "Accept" = "application/json, text/plain, */*",
    "Content-Type" = "application/json",
    "DNT" = "1",
    "sec-ch-ua-mobile" = "?0",
    "User-Agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0",
    "sec-ch-ua-platform" = '"macOS"',
    "Sec-Fetch-Site" = "same-site",
    "Sec-Fetch-Mode" = "cors",
    "Sec-Fetch-Dest" = "empty",
    "host" = "veribackend.sgk.gov.tr"
  )

  body <- '{
  "year": [],
  "city": [],
  "category": [],
  "indicator": []
}'

  res <- httr::VERB("POST",
                    url = "https://veribackend.sgk.gov.tr/data/statistic",
                    body = body,
                    httr::add_headers(headers)
  )

  rawdat <- httr::content(res, "text") %>%
    jsonlite::fromJSON(
      simplifyDataFrame = TRUE,
      simplifyVector = TRUE,
      flatten = TRUE
    )


  raw_data <- tibble::tibble(rawdat$data) %>%
    dplyr::mutate(d = purrr::map(.data$values, ~ tibble::tibble(date = unlist(rawdat$dates),
                                                                value = .x))) %>%
    dplyr::select(-.data$values) %>%
    tidyr::unnest(.data$d) %>%
    tidyr::separate_wider_delim(.data$date,
                                delim = ".",
                                names = c("year", "month"),
                                too_few = "align_start") %>%
    dplyr::mutate(dplyr::across(.data$id:.data$unit, as.factor),
           year = as.numeric(.data$year),
           month = as.numeric(.data$month))


return(raw_data)
}
