#' Download daily, weekly and monthly Google Trends data for a keyword.
#'
#' Downloads daily, weekly and monthly Google Trends data for a keyword
#' and writes the raw data to csv files.
#' TODO where are these files stored
#'
#' @inheritParams ts_gtrends_windows
#
# proc functions work on the file system
#' @export
proc_keyword_init <- function(keyword = "Insolvenz", from = "2006-01-01") {
  message("Downloading keyword: ", keyword)
  message("Downloading daily data")
  d <- ts_gtrends_windows(
    keyword = keyword,
    from = from, stepsize = "15 days", windowsize = "6 months",
    n_windows = 348, wait = 20, retry = 10,
    prevent_window_shrinkage = TRUE
  )
  # for now, we store all windows
  # (if we are confident that storing the averages is sufficient, we can stop that)
  write_csv(d, path_data_raw("indicator_raw", paste0(keyword, "_d.csv")))
  write_keyword(aggregate_windows(d), keyword, "d")

  message("Downloading weekly data")
  w <- ts_gtrends_windows(
    keyword = keyword,
    from = from, stepsize = "11 weeks", windowsize = "5 years",
    n_windows = 68, wait = 20, retry = 10,
    prevent_window_shrinkage = TRUE
  )
  write_csv(w, path_data_raw("indicator_raw", paste0(keyword, "_w.csv")))
  write_keyword(aggregate_windows(w), keyword, "w")

  message("Downloading monthly data")
  m <- ts_gtrends_windows(
    keyword = keyword,
    from = from, stepsize = "1 month", windowsize = "15 years",
    n_windows = 12, wait = 20, retry = 10,
    prevent_window_shrinkage = FALSE
  )
  write_csv(m, path_data_raw("indicator_raw", paste0(keyword, "_m.csv")))
  write_keyword(aggregate_windows(m), keyword, "m")
}
