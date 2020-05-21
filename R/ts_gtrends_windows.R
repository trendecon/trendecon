#' Get approximate daily series over a large window
#'
#' This function downloads
#' @inheritParams ts_gtrends
#'
#' @param from start of timeframe in YYYY-mm-dd form
#' @param prevent_window_shrinkage TODO
#' @param stepsize Number of days (integer) between the start days of the respective time-windows.
#' @param windowsize Number of days (integer) from start date to end date of each window.
#' @param n_windows Number (integer) of time-windows.
#'
#' @return A tibble of time series with columns *window*, *time*, *value*,  where *window* is the time window
#' indicated by start and end date of the window.
#'
#' @section Notes:
#' Time-windows may overlap - and will do so if `stepsize` < `windowsize`.



ts_gtrends_windows <- function(keyword = NA,
                               category = "0",
                               geo = "CH",
                               from = "2019-01-01",
                               prevent_window_shrinkage = FALSE,
                               stepsize = 7,
                               windowsize = 80,
                               n_windows = 12,
                               quiet = FALSE,
                               wait = 60,
                               retry = 5) {
  library(tidyverse)

  tbl <- start_end_tbl(from, n_windows, stepsize, windowsize)

    # truncate end date to Sys.Date() to avoid google errors
    tbl <- tbl[1:nrow(tbl),] %>% mutate(end_date = if_else(end_date > Sys.Date(), Sys.Date(), end_date)) %>%
    (function(x) {
      if (prevent_window_shrinkage) {
        distinct(x, end_date, .keep_all = TRUE)
      } else {
        x
      }
    }) %>%
    # Make sure the last window is large enough to yield the desired frequency
    rowwise() %>%
    mutate(start_date = ifelse(prevent_window_shrinkage & end_date == Sys.Date(), seq(start_date, length.out = 2, by = paste0("-", windowsize))[1], start_date)) %>%
    ungroup() %>%
    transmute(
      # Using as.Date because the different variations of if(_)else each have their problems
      window = sprintf("%s %s", as.Date(start_date, origin = "1970-01-01"), as.Date(end_date, origin = "1970-01-01"))
    ) %>%
    rowwise() %>%
    mutate(trend_data = list(ts_gtrends(keyword, category, geo, window, retry, wait, quiet))) %>%
    unnest(cols = trend_data) %>%
    ungroup()

  # TODO: The problem to solve:
  #       Every time 100 appears within stepsize of the start/end of a chunk
  #       a wild rescaling
}

start_end_tbl <- function(from, n_windows, stepsize, windowsize)
  tbl <- tibble(
  start_date = seq(as.Date(from), by = stepsize, length.out = n_windows)
  ) %>%
  rowwise() %>%
  mutate(end_date = seq(start_date, length.out = 2, by = windowsize)[2]) %>%
  ungroup()
  return(tbl)