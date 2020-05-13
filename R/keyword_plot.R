keyword_plot <- function(keyword = NULL, x = NULL, target = NULL, invert = FALSE, freq = "quarter") {
  if (!is.null(keyword)) {
    x <- ts_frequency(ts_gtrends(keyword = keyword, time = "2007-01-01 2020-04-05"), freq)
  } else {
    keyword <- "Series"
  }

  if (invert) (x$value <- -x$value)

  library(dataseries)

  x_seas <- ts_seas(x, x11 = "", outlier = NULL)

  library(seasonal)
  m <- seasonal::seas(ts_ts(x), x11 = "", outlier = NULL)
  x_seas <- seasonal::final(m)
  x_trend <- seasonal::trend(m)

  op <- options(
    tsbox.lwd = c(1, 2, 1, 1),
    tsbox.col = c("red", "red", "grey", "blue"),
    tsbox.lty = c("solid", "solid", "dashed", "solid")
  )

  ind <- ts_c(
    orig = x,
    seas = x_seas,
    trend = x_trend
  )

  if (!is.null(target)) ind <- ts_c(ind, target)

  dta <- ts_scale(ind)

  ts_plot(dta, title = paste("Keyword:", keyword))

  options(op) # restore defaults
}
