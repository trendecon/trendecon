test_that("retries a transient error, then returns the successful result", {
  calls <- 0L
  fake <- function(...) {
    calls <<- calls + 1L
    if (calls < 3L) stop("the condition has code:429 - too many requests")
    list(interest_over_time = data.frame(date = Sys.Date(), hits = 1))
  }
  local_mocked_bindings(gtrends = fake, .package = "trendecon")

  res <- gtrends_with_backoff(
    "x", wait = 0.001, max_wait = 0.002, retry = 5, quiet = TRUE
  )

  expect_equal(calls, 3L)
  expect_false(is.null(res$interest_over_time))
})

test_that("gives up with an informative error after `retry` attempts", {
  calls <- 0L
  fake <- function(...) {
    calls <<- calls + 1L
    stop("code:500 internal server error")
  }
  local_mocked_bindings(gtrends = fake, .package = "trendecon")

  expect_error(
    gtrends_with_backoff(
      "x", wait = 0.001, max_wait = 0.002, retry = 4, quiet = TRUE
    ),
    "Retries exhausted"
  )
  expect_equal(calls, 4L)
})

test_that("unexpected (non-classified) errors are retried too", {
  calls <- 0L
  fake <- function(...) {
    calls <<- calls + 1L
    if (calls < 2L) stop("something totally unexpected happened")
    list(interest_over_time = data.frame(date = Sys.Date(), hits = 1))
  }
  local_mocked_bindings(gtrends = fake, .package = "trendecon")

  res <- gtrends_with_backoff(
    "x", wait = 0.001, max_wait = 0.002, retry = 5, quiet = TRUE
  )

  expect_equal(calls, 2L)
})
