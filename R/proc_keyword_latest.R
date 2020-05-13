# proc functions work on the file system
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
  write_csv(d, path_data_raw("indicator_raw", sprintf("%s_d_%s.csv", keyword, today)))


  message("Downloading weekly data")
  w <- ts_gtrends_windows(
    keyword = keyword,
    from = seq(today, length.out = 2, by = "-1 year")[2],
    stepsize = "1 week", windowsize = "1 year",
    n_windows = n_windows, wait = 20, retry = 20,
    prevent_window_shrinkage = FALSE
  )
  write_csv(w, path_data_raw("indicator_raw", sprintf("%s_w_%s.csv", keyword, today)))

  message("Downloading monthly data")
  m <- ts_gtrends_windows(
    keyword = keyword,
    from = "2006-01-01",
    stepsize = "1 month", windowsize = "20 years",
    n_windows = n_windows, wait = 20, retry = 20,
    prevent_window_shrinkage = FALSE
  )
  write_csv(m, path_data_raw("indicator_raw", sprintf("%s_m_%s.csv", keyword, today)))
}
