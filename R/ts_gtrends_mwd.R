#' Robust and Consistent Time Series from Google Trends
#'
#' Construct a robust and consistent daily Time Series from Google Trends data.
#' Daily, weekly and monthly Data is downloaded and consistently aggregated, using the Chow-Lin methodology.
#'
#' See the working paper for details on the methodology.
#'
#' @inheritParams ts_gtrends
#' @export
ts_gtrends_mwd <- function(keyword = "Insolvenz", geo = "CH") {

  if (length(keyword) > 1) stop("Only a single keyword is allowed.")

  from <- "2006-01-01"

  # download daily series
  d <- ts_gtrends_windows(
    keyword = keyword,
    geo = geo,
    from = from, stepsize = "15 days", windowsize = "6 months",
    n_windows = floor(as.numeric(Sys.Date() - as.Date(from)) / 15),
    wait = 20, retry = 10,
    prevent_window_shrinkage = TRUE
  )
  d2 <- ts_gtrends_windows(
    keyword = keyword,
    geo = geo,
    from = seq(Sys.Date(), length.out = 2, by = "-90 days")[2],
    stepsize = "1 day", windowsize = "3 months",
    n_windows = 12, wait = 20, retry = 10,
    prevent_window_shrinkage = FALSE
  )
  dd <- aggregate_averages(aggregate_windows(d), aggregate_windows(d2))

  # download weekly series
  w <- ts_gtrends_windows(
    keyword = keyword,
    geo = geo,
    from = from, stepsize = "11 weeks", windowsize = "5 years",
    n_windows = floor(as.numeric(Sys.Date() - as.Date(from)) / (11 * 7)),
    wait = 20, retry = 10,
    prevent_window_shrinkage = TRUE
  )
  w2 <- ts_gtrends_windows(
    keyword = keyword,
    geo = geo,
    from = seq(Sys.Date(), length.out = 2, by = "-2 year")[2],
    stepsize = "1 week", windowsize = "2 year",
    n_windows = 24, wait = 20, retry = 10,
    prevent_window_shrinkage = FALSE
  )
  ww <- aggregate_averages(aggregate_windows(w), aggregate_windows(w2))

  # download monthly series
  m <- ts_gtrends_windows(
    keyword = keyword,
    geo = geo,
    from = from, stepsize = "1 month", windowsize = "15 years",
    n_windows = ceiling(as.numeric(Sys.Date() - as.Date(from)) / (15 * 365) * 12),
    wait = 20, retry = 10,
    prevent_window_shrinkage = FALSE
  )
  m2 <- ts_gtrends_windows(
    keyword = keyword,
    geo = geo,
    from = from,
    stepsize = "1 month", windowsize = "20 years",
    n_windows = 12, wait = 20, retry = 10,
    prevent_window_shrinkage = FALSE
  )
  mm <- aggregate_averages(aggregate_windows(m), aggregate_windows(m2))


  dd <- select(dd, -n)
  ww <- select(ww, -n)
  mm <- select(mm, -n)

  # bend to weekly
  wd <- tempdisagg::td(ww ~ dd, method = "fast", conversion = "mean")
  wd <- predict(wd)

  # bend to monthly
  mwd <- tempdisagg::td(mm ~ wd, method = "fast", conversion = "mean")
  mwd <- predict(mwd)

  mwd
}
