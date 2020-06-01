#' Construct Index based on Google Trend keywords.
#'
#' Uses the first principal component to construct an index.
#'
#' @inheritParams ts_gtrends
#'
#' @param sadj should the series be seasonally adjusted? Only works if resulting data is monthly.
#' @param ... further arguments, passed to [gtrendsR::gtrends()].
#' @seealso `browseVignettes("intro")`
#' @export
#' @examples
#'
#' tsbox::ts_plot(ts_gtrends_index(c( "Mango", "Zara")))
ts_gtrends_index <- function(keyword, time = paste("2007-01-01", Sys.Date()), ..., sadj = TRUE) {
  res <- ts_gtrends(keyword = keyword, time = time, ...)
  z <- tsbox::ts_pick(tsbox::ts_prcomp(res), "PC1")[, c("time", "value")]

  if (sadj) {
    z <- tsbox::ts_c(
      orig = z,
      sadj = tsbox::ts_tbl(seasonal::final(seasonal::seas(tsbox::ts_ts(z), x11 = "")))
    )
  }

  z
}

