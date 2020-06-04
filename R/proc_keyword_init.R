#' Download daily, weekly and monthly Google Trends data for a keyword.
#'
#' Downloads daily, weekly and monthly Google Trends data for a keyword
#' and writes the data to csv files.
#'
#' By default, the data is stored in folders `data` and `raw`. Each folder
#'   contains a subdirectory of each country.
#'
#' @param keyword A single keyword to query Google Trends.
#' @param geo A character vector denoting the geographic region.
#'     Default is "CH".
#' @param from Start of timeframe in YYYY-mm-dd form. Should not be changed from
#'       the the default.
#' @param indicator_raw store individual downloads. If `FALSE`, only the
#'     averages are stored.
#' @seealso [ts_gtrends_windows]
#' @export
#'
#' @examples
#' \dontrun{
#' # run once
#' proc_keyword_init(keyword = "Insolvenz", "AT")
#' # run every day
#' proc_keyword_latest(keyword = "Insolvenz", "AT")
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
