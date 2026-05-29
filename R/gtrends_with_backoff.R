#' Query Google Trends with retry and backoff
#'
#' Thin wrapper around [gtrendsR::gtrends()] that retries failed requests using
#' jittered exponential backoff. Google Trends regularly returns transient
#' errors (non-200 responses, HTTP 429 rate limits, 5xx server errors) and the
#' connection itself can fail intermittently; retrying with growing, randomized
#' waits is far more robust than failing on the first hiccup.
#'
#' @inheritParams gtrendsR::gtrends
#' @param retry Maximum number of attempts before giving up on a hard error
#'   (429, 5xx, network, ...).
#' @param empty_retry Maximum attempts for a "no data returned" response before
#'   accepting the window as genuinely empty (zero volume). Kept small: a truly
#'   empty window never recovers, so retrying it the full `retry` ladder just
#'   wastes time; a few quick attempts still let a *transient* rate limit (which
#'   can also surface as "no data") recover. This is the lever that keeps a
#'   rate-limited backfill from grinding for hours.
#' @param wait Base wait in seconds. The wait before attempt `n` grows
#'   exponentially (`wait * 2^(n - 1)`), is capped at `max_wait`, and has random
#'   jitter added to avoid synchronized retries hammering the server.
#' @param max_wait Upper bound (seconds) for a single backoff wait.
#' @param quiet If `TRUE`, suppress progress messages.
#' @param attempt Internal counter, do not set manually.
#'
#' @keywords internal
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
                                 retry = 6,
                                 empty_retry = 4,
                                 wait = 4,
                                 max_wait = 30,
                                 quiet = FALSE,
                                 attempt = 1) {
  msg <- function(...) {
    if (!quiet) {
      message(...)
    }
  }

  # Classify an error message to decide whether (and how) to report it. All
  # classes are retried; unknown errors are retried too (the upstream per-keyword
  # isolation in proc_index() contains the cost), but surfaced so genuine bugs
  # are visible in the logs.
  classify <- function(m) {
    if (grepl("== 200 is not TRUE", m)) {
      "server not accepting requests (non-200)"
    } else if (grepl("code\\s*:?\\s*429", m)) {
      "429 - too many requests"
    } else if (grepl("code\\s*:?\\s*5[0-9][0-9]", m)) {
      "5xx - server error"
    } else if (grepl("widget|quota|rate.?limit", m, ignore.case = TRUE)) {
      "rate / quota limit"
    } else if (grepl(
      "timeout|timed out|Recv failure|Could not resolve|connection|SSL|curl|Empty reply|reset by peer",
      m,
      ignore.case = TRUE
    )) {
      "network / transient"
    } else {
      NA_character_
    }
  }

  if (attempt == 1) {
    msg("Downloading data for ", time)
    # Baseline pacing between distinct queries to stay under Google's rate
    # limiter (set via options(trendecon.query_pause = <seconds>); 0 = off).
    # Pacing prevents rate limits far more reliably than recovering from them,
    # which matters for high-volume bursts such as the gap backfill.
    pause <- getOption("trendecon.query_pause", 0)
    if (is.numeric(pause) && pause > 0) Sys.sleep(pause)
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
      m <- conditionMessage(e)
      reason <- classify(m)
      if (is.na(reason)) {
        msg("Unexpected error: ", m)
        reason <- "unexpected"
      } else {
        msg("Server response: ", reason)
      }

      empty_result <- grepl(
        "No data returned|Consider changing search parameters",
        m,
        ignore.case = TRUE
      )

      # "No data" gets its own, much shorter budget: after a few quick attempts
      # accept the window as genuinely empty (return NULL interest_over_time,
      # which callers already substitute with a zero series). This is what stops
      # a rate-limited run from grinding the full `retry` ladder per query.
      if (empty_result && attempt >= empty_retry) {
        msg("Still no data after ", attempt, " attempts; treating window as empty")
        return(list(interest_over_time = NULL))
      }

      if (!empty_result && attempt >= retry) {
        stop(
          "Retries exhausted after ", attempt, " attempts (last: ",
          reason, " - ", m, ")",
          call. = FALSE
        )
      }

      # jittered exponential backoff, capped at max_wait
      base <- min(max_wait, wait * 2^(attempt - 1))
      t <- base + stats::runif(1, 0, base / 2)
      msg("Waiting for ", round(t), " seconds, then retrying")
      Sys.sleep(t)

      # Error handling by recursion
      gtrends_with_backoff(
        keyword = keyword,
        geo = geo,
        time = time,
        gprop = gprop,
        category = category,
        hl = hl,
        low_search_volume = low_search_volume,
        cookie_url = cookie_url,
        tz = tz,
        onlyInterest = onlyInterest,
        retry = retry,
        empty_retry = empty_retry,
        wait = wait,
        max_wait = max_wait,
        quiet = quiet,
        attempt = attempt + 1
      )
    }
  )
}
