#' Download approximate daily series over a sequence of time-windows
#'
#' Downloads approximate daily series over a sequence of time-windows by first
#' constructing the appropriate time windows and then downloading daily data
#' for each time-window using [trendecon::ts_gtrends()].
#'
#' @inheritParams ts_gtrends
#'
#' @param from Start of timeframe in YYYY-mm-dd form.
#' @param prevent_window_shrinkage If `TRUE`, ensures that the last time-window
#'     is large enough to yield the desired frequency. Default is `FALSE`.
#' @param stepsize Number of days (integer) between the start days of the
#'     respective time-windows.
#' @param windowsize Number of days (integer) from start date to end date of
#'     each window.
#' @param n_windows Number (integer) of time-windows.
#'
#' @return A tibble of time series with columns *window*, *time*, *value*,
#'     where *window* is the time window
#' indicated by start and end date of the window.
#'
#' @section Notes:
#' Time-windows may overlap - and will do so if `stepsize` < `windowsize`.
#'
#' @seealso [trendecon::ts_gtrends()]
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

  tbl <- prepare_windows_tbl(
    from,
    n_windows,
    prevent_window_shrinkage,
    stepsize,
    windowsize
  )
  tbl <- tbl %>%
    mutate(trend_data = list(ts_gtrends(
      keyword,
      category,
      geo,
      window,
      retry,
      wait,
      quiet
    ))) %>%
    unnest(cols = trend_data) %>%
    ungroup()

  return(tbl)
  # TODO: The problem to solve:
  #       Every time 100 appears within stepsize of the start/end of a chunk
  #       a wild rescaling
}


prepare_windows_tbl <- function(from,
                                n_windows,
                                prevent_window_shrinkage,
                                stepsize,
                                windowsize) {
  # prepare tibble with single column *windows* which for each time-window
  # contains a string with start-date and end-date

  # get current date in UTC timezone
  # NOTE: this is necessary for filtering-out windows that are in the future.
  current_date_utc <- Sys.time()
  attr(current_date_utc, "tzone") <- "UTC"
  current_date_utc <- as.Date(current_date_utc)

  tbl <- tibble(
    start_date = seq(as.Date(from), by = stepsize, length.out = n_windows)
  ) %>%
    rowwise() %>%
    filter(start_date <= current_date_utc) %>%
    mutate(end_date = seq(start_date, length.out = 2, by = windowsize)[2]) %>%
    ungroup() %>%
    mutate(end_date = as.Date(as.numeric(end_date), origin = "1970-01-01")) %>%
    mutate(end_date = if_else(end_date > current_date_utc, current_date_utc, end_date)) %>%
    (function(x) {
      if (prevent_window_shrinkage) {
        dplyr::distinct(x, end_date, .keep_all = TRUE)
      } else {
        x
      }
    }) %>%
    # Make sure the last window is large enough to yield the desired frequency
    rowwise() %>%
    mutate(start_date = ifelse(prevent_window_shrinkage & end_date == current_date_utc,
      seq(start_date,
        length.out = 2,
        by = paste0("-", windowsize)
      )[1],
      start_date
    )) %>%
    ungroup() %>%
    transmute(
      # Using as.Date because the different variations of if(_)else each have
      # their problems
      window = sprintf(
        "%s %s", as.Date(start_date, origin = "1970-01-01"),
        as.Date(end_date, origin = "1970-01-01")
      )
    ) %>%
    rowwise()


  return(tbl)
}
