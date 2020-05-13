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
    gtrends(keyword, geo, time, gprop, category, hl, low_search_volume, cookie_url, tz, onlyInterest),
    error = function(e) {
      if (grepl("== 200", e)) {
        if (attempt == 1) {
          msg("Oh noes, they don't like us anymore...")
        } else {
          msg("Nope, still nothing...")
        }

        t <- attempt * wait

        # Exponential backoff. Neat but not really suitable here.
        # t <- wait*ceiling(runif(1)*(2^attempt-1))

        msg("Waiting for ", t, " seconds")
        Sys.sleep(t)
        msg("Retrying...")

        # Error handling by recurshian... xD
        # TODO: Could replace this with a while(attemt < retry && !is.tibble(result)) { result <- tryCatch(call, error = function(e) FALSE)}
        # construct. easier on the stack if retry gets large
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
      } else {
        stop(e)
      }
    }
  )
}
