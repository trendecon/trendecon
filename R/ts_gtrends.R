# online tutorial for analyzing google trends in R:
# https://www.datacareer.ch/blog/analyzing-google-trends-with-r-retrieve-and-plot-with-gtrendsr/

ts_gtrends <- function(keyword = NA, category = "0", geo = "CH", time = "today+5-y",
                       retry = 5, wait = 5, quiet = FALSE) {
  library(tidyverse)
  library(tsbox)
  library(gtrendsR)

  # replace return values like <1
  ensure_numeric <- function(x) {
    if (is.character(x)) {
      x <- gsub("<1", "0", x, fixed = TRUE)
      x <- as.numeric(x)
    }
    x
  }

  get_ts_from_gtrends <- function(x) {
    if (is.null(x$interest_over_time)) {
      return(NULL)
    }
    transmute(x$interest_over_time, time = as.Date(date), value = ensure_numeric(hits))
  }

  if ((length(keyword) > 1) && (length(category) > 1)) {
    stop("cannot supply multiple keyword AND categories (but could be implemented if useful")
  }

  # Use defaults for backing off
  # multiple categories
  if (length(category) > 1) {
    gtrendslist <- setNames(lapply(category, function(e) gtrends_with_backoff(keyword = keyword, category = e, gprop = "web", geo = geo, time = time, onlyInterest = TRUE, retry = retry, wait = wait, quiet = quiet)), category)
    # multiple (or one) keyword(s)
  } else {
    gtrendslist <- setNames(lapply(keyword, function(e) gtrends_with_backoff(keyword = e, category = category, gprop = "web", geo = geo, time = time, onlyInterest = TRUE, retry = retry, wait = wait, quiet = quiet)), keyword)
  }

  # results to tsboxable tibble
  is_null <- sapply(gtrendslist, function(e) is.null(e$interest_over_time))
  if (any(is_null)) {
    message("no results for some ids: ", names(is_null)[is_null])
    gtrendslist <- gtrendslist[!is_null]
  }

  tslist <- lapply(gtrendslist, get_ts_from_gtrends)
  class(tslist) <- "tslist"


  ts_tbl(tslist)
}
