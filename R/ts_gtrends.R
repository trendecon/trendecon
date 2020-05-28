#' Download Google Trend Data
#'
#' Wrapper around [gtrendsR::gtrends()] that modifies the original function by
#' a) vectorizing it, b) converting the result to tsboxable tibble and c)
#' retries if no result is returned.
#'
#' @param keyword A character vector with the actual Google Trends query
#'  keywords. Contrary to [gtrendsR::gtrends()], if different keywords are used,
#'  mulitple queries are sent to Google, and each series is individually
#'  normalized.
#'
#' @param category A character vector, listing the categories, defaults to
#'   `"0"`. Passed to [gtrendsR::gtrends()]
#'
#' @param geo A character vector denoting geographic regions for the query,
#'   default is `"CH"`. Passed to [gtrendsR::gtrends()]
#'
#' @param time A string specifying the time span of the query.
#'   Passed to [gtrendsR::gtrends()].
#'
#' @param retry Number of attempts, in case the query request does not succeed.
#'
#' @param wait Seconds to wait between attempts, where waiting time is `attempt * wait`.
#'
#' @param quiet If TRUE won't display messages related to server interactions. Default is FALSE.
#'
#' @return A tibble of time series for the different keywords or categories. If only a single keyword and a single
#'      category are specified, the tibble has columns *time* and *value*. If either more
#'      than one keyword, or more than one category are given, an additional column *id* indicates
#'      either the keyword, or the category.
#'
#' @section Notes:
#' - The function takes the id's as strings, not the names. For example, "Arts & Entertainment" has to be specified as "2".
#' - Multiple keywords or multiple categories can be specified, but not both.
#'
#' @seealso [gtrendsR::gtrends()], `browseVignettes("intro")`
#' @seealso [Online tutorial for analyzing google trends in R](https://www.datacareer.ch/blog/analyzing-google-trends-with-r-retrieve-and-plot-with-gtrendsr/)
#' @export
#' @examples
#'
#' x <- ts_gtrends("Rezession")
#' x
#' tsbox::ts_plot(x)
#' @import dplyr tidyr tsbox gtrendsR readr tempdisagg
ts_gtrends <- function(keyword = NA,
                       category = "0",
                       geo = "CH",
                       time = "today+5-y",
                       retry = 5,
                       wait = 5,
                       quiet = FALSE) {

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

    # hourly data
    if (median(as.numeric(diff(x$interest_over_time$date))) == 1) {
      z <- transmute(x$interest_over_time, time = date, value = ensure_numeric(hits))
      # otherwise, convert to date
    } else {
      z <- transmute(x$interest_over_time, time = as.Date(date), value = ensure_numeric(hits))
    }
    z
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
    # download a dummy result that always exist (search for 'google')
    tbl_dummy <- gtrends_with_backoff(keyword = "google", category = category, gprop = "web", geo = geo, time = time, onlyInterest = TRUE, retry = retry, wait = wait, quiet = quiet)
    tbl_dummy$interest_over_time$hits <- 0
    message("no results for some ids: ", names(is_null)[is_null])
    gtrendslist[is_null] <- lapply(gtrendslist[is_null], function(e) tbl_dummy)
  }

  tslist <- lapply(gtrendslist, get_ts_from_gtrends)
  class(tslist) <- "tslist"


  ts_tbl(tslist) %>% mutate(time = as.Date(time))
}
