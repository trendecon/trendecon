gtrends_with_backoff <- function(keyword = NA,
                                 geo = "ch",
                                 time = "today+5-y",
                                 gprop = "web",
                                 category = "0",
                                 hl = "en-US",
                                 low_search_volume = FALSE,
                                 cookie_url = "http://trends.google.com/Cookies/NID",
                                 tz = 0,
                                 onlyInterest = FALSE,
                                 retry = 5,
                                 wait = 5,
                                 quiet = FALSE,
                                 attempt = 1) {
  msg <- function(...) {
    if (!quiet) {
      message(...)
    }
  }

  if (attempt > retry) {
    stop("Retries exhausted!")
  }

  if (attempt == 1) {
    msg("Downloading data for ", time)
  } else {
    msg("Attempt ", attempt, "/", retry)
  }
  tryCatch(
    gtrends(
      keyword = keyword, geo = geo, time = time, gprop = gprop,
      category = category, hl = hl,
      low_search_volume = low_search_volume, cookie_url = cookie_url,
      tz = tz, onlyInterest = onlyInterest
    ),
    error = function(e) {
      if (grepl("== 200 is not TRUE", e)) {
        msg("Server is not accepting requests")
      } else if (grepl("code\\:429", e)) {
        msg("Server response: 429 - too many requests")
      } else if (grepl("code\\:500", e)) {
        msg("Server response: 500 - internal server error")
      } else {
        stop(e)
      }

      t <- attempt * wait

      msg("Waiting for ", t, " seconds")
      Sys.sleep(t)
      msg("Retrying...")

      # Error handling by recursion
      gtrends_with_backoff(
        keyword,
        geo,
        time,
        gprop,
        category,
        hl,
        low_search_volume,
        cookie_url,
        tz,
        onlyInterest,
        retry,
        wait,
        quiet,
        attempt + 1
      )
    }
  )
}
