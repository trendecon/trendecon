#' Download daily, weekly and monthly Google Trends data for a keyword.
#'
#' Downloads daily, weekly and monthly Google Trends data for a keyword
#' and writes the data to csv files.
#'
#' By default, the data is stored in
#' folders `data-raw/indicator_raw` and `data-raw/indicator`. File suffixes
#' are `_d` for daily, `_w` for weekly, and `_m` for monthly data.
#'
#' - `data-raw/indicator_raw` contains time series in time-windows, as returned
#'     by [trendecon::ts_gtrends_windows].
#' - `data-raw/indicator` contains aggregated time series.
#'
#' @param keyword A single keyword to query Google Trends.
#' @param geo A character vector denoting the geographic region.
#'     Default is "CH".
#' @param from Start of timeframe in YYYY-mm-dd form. Should be before
#'     "2014-01-01", since otherwise creates an issue with aligning different
#'      frequencies in later steps.
#' @param indicator_raw store individual downloads. If `FALSE`, only the
#'     averages are stored.
#' @seealso [ts_gtrends_windows]
#' @export
#'
#' @examples
#' \dontrun{
#' proc_keyword_init(keyword = "Insolvenz", from = "2006-01-01")
#' }
#'
proc_keyword_init <- function(keyword = "Insolvenz",
                              geo = "CH",
                              from = "2006-01-01",
                              indicator_raw = FALSE) {
  if (length(keyword) > 1) stop("Only a single keyword is allowed.")

  if (as.Date(from) > as.Date("2014-01-01")){
    stop("If `from` is more recent than '2014-01-01', will run into this
    issue: https://github.com/trendecon/trendecon/issues/16" )
  }

  create_data_dirs()
  message("Downloading keyword: ", keyword)
  message("Downloading daily data")
  d <- ts_gtrends_windows(
    keyword = keyword,
    geo = geo,
    from = from, stepsize = "15 days", windowsize = "6 months",
    n_windows = 348, wait = 20, retry = 10,
    prevent_window_shrinkage = TRUE
  )

  # for now, we store all windows
  # (if we are confident that storing the averages is sufficient, we can stop that)
  if (indicator_raw) write_csv(d, path_draws(tolower(geo), paste0(keyword, "_d.csv")))
  write_keyword(aggregate_windows(d), keyword, geo, "d")

  message("Downloading weekly data")
  w <- ts_gtrends_windows(
    keyword = keyword,
    geo = geo,
    from = from, stepsize = "11 weeks", windowsize = "5 years",
    n_windows = 68, wait = 20, retry = 10,
    prevent_window_shrinkage = TRUE
  )
  if (indicator_raw) write_csv(w, path_draws(tolower(geo), paste0(keyword, "_w.csv")))
  write_keyword(aggregate_windows(w), keyword, geo, "w")

  message("Downloading monthly data")
  m <- ts_gtrends_windows(
    keyword = keyword,
    geo = geo,
    from = from, stepsize = "1 month", windowsize = "15 years",
    n_windows = 12, wait = 20, retry = 10,
    prevent_window_shrinkage = FALSE
  )
  if (indicator_raw) write_csv(m, path_draws(tolower(geo), paste0(keyword, "_m.csv")))
  write_keyword(aggregate_windows(m), keyword, geo, "m")
}
