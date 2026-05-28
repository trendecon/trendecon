#' Backfill the daily series of a keyword over a gap
#'
#' The daily Google Trends download in [proc_keyword_latest()] only covers the
#' last ~90 days. After an interruption of the daily run, the stored daily series
#' therefore has a hole: everything between the last pre-outage observation and
#' ~90 days ago is missing. `proc_combine_freq()` uses the daily series as the
#' high-frequency indicator for `tempdisagg::td()`, which cannot disaggregate
#' across a hole and fails. This function refills the daily series over the gap
#' using the same efficient overlapping windows as [proc_keyword_init()], so that
#' the combine and seasonal-adjustment steps work again and the resulting series
#' is fully consistent at daily resolution.
#'
#' Only the daily series needs backfilling: a normal daily run already refreshes
#' the weekly (one year) and monthly (since 2006) series over their full span.
#'
#' @inheritParams proc_keyword_latest
#' @param from Start date (`YYYY-mm-dd`) of the daily backfill. Defaults to one
#'   month before the last existing daily observation, which comfortably covers
#'   the gap.
#'
#' @return Invisibly `TRUE`.
#' @seealso [proc_keyword_latest()], [proc_keyword_init()]
#' @export
proc_keyword_backfill_daily <- function(keyword = "Insolvenz",
                                         geo = "CH",
                                         from = NULL,
                                         wait = 10,
                                         retry = 20) {
  d_old <- dplyr::mutate(read_keyword(keyword, geo, "d"), n = as.integer(n))
  last <- max(d_old$time)

  if (is.null(from)) {
    from <- as.character(last - 30)
  }
  from <- as.Date(from)

  if (from >= Sys.Date()) {
    message("Nothing to backfill for '", keyword, "' (", geo, "): up to date.")
    return(invisible(TRUE))
  }

  message(
    "Backfilling daily '", keyword, "' (", geo, ") from ", from,
    " (last observation: ", last, ")"
  )

  n_windows <- floor(as.numeric(Sys.Date() - from) / 15) + 1L

  d_new <- ts_gtrends_windows(
    keyword = keyword,
    geo = geo,
    from = as.character(from),
    stepsize = "15 days",
    windowsize = "6 months",
    n_windows = n_windows,
    wait = wait,
    retry = retry,
    prevent_window_shrinkage = TRUE
  )

  write_keyword(
    aggregate_averages(d_old, aggregate_windows(d_new)),
    keyword, geo, "d"
  )

  invisible(TRUE)
}
