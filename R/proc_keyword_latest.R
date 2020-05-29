#' Download latest data
#'
#' Downloads latest daily, weekly, and monthly data.
#'
#' @inheritParams ts_gtrends_windows
#' @param keyword A single keyword for which to process the data.
#' @seealso [ts_gtrends_windows]
#'
#' @section Daily data:
#'     Downloads data for the last 90 days in two windows, with the same end
#'    date (today) but start date shifted by one day. File saved as
#'    `{keyword}_d_{today}.csv` in folder `data-raw/indicator_raw`.
#'
#' @section Weekly data:
#'     Downloads weekly data for two windows, first window starts 1 year ago,
#'     second window offset by one week, both windows end today. File saved
#'     as `{keyword}_w_{today}.csv` in folder `data-raw/indicator_raw`.
#'
#' @section Monthly data:
#'     Downloads monthly data for two windows, first window starts at
#'     2006-01-01, second window offset by  1 month, both windows end today.
#'     File saved as `{keyword}_m_{today}.csv` in folder
#'     `data-raw/indicator_raw`.
#'
proc_keyword_latest <- function(keyword = "Insolvenz", n_windows = 12) {
  today <- Sys.Date()

  message("Downloading keyword: ", keyword)
  message("Downloading daily data")
  d <- ts_gtrends_windows(
    keyword = keyword,
    from = seq(today, length.out = 2, by = "-90 days")[2],
    stepsize = "1 day", windowsize = "3 months",
    n_windows = n_windows, wait = 20, retry = 20,
    prevent_window_shrinkage = FALSE
  )
  write_csv(d, path_draws(sprintf("%s_d_%s.csv", keyword, today)))


  message("Downloading weekly data")
  w <- ts_gtrends_windows(
    keyword = keyword,
    from = seq(today, length.out = 2, by = "-1 year")[2],
    stepsize = "1 week", windowsize = "1 year",
    n_windows = n_windows, wait = 20, retry = 20,
    prevent_window_shrinkage = FALSE
  )
  write_csv(w, path_draws(sprintf("%s_w_%s.csv", keyword, today)))

  message("Downloading monthly data")
  m <- ts_gtrends_windows(
    keyword = keyword,
    from = "2006-01-01",
    stepsize = "1 month", windowsize = "20 years",
    n_windows = n_windows, wait = 20, retry = 20,
    prevent_window_shrinkage = FALSE
  )
  write_csv(m, path_draws(sprintf("%s_m_%s.csv", keyword, today)))
}
