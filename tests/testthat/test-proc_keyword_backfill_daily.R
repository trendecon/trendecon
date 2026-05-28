test_that("backfill fills a daily gap and merges with existing data", {
  tmp <- withr::local_tempdir()
  withr::local_options(path_trendecon = tmp)
  dir.create(file.path(tmp, "raw", "ch"), recursive = TRUE)

  # existing daily series that stops on 2025-01-31 (the "outage")
  old <- data.frame(
    time = seq(as.Date("2025-01-01"), as.Date("2025-01-31"), by = "day"),
    value = 1,
    n = 1L
  )
  readr::write_csv(old, file.path(tmp, "raw", "ch", "kw_d.csv"))

  # the download returns continuous daily data overlapping the old end and
  # reaching up to today
  fake_dl <- data.frame(
    window = "w",
    time = seq(as.Date("2025-01-20"), Sys.Date(), by = "day"),
    value = 2
  )
  local_mocked_bindings(
    ts_gtrends_windows = function(...) fake_dl,
    .package = "trendecon"
  )

  proc_keyword_backfill_daily("kw", "CH", from = "2025-01-15")

  d <- readr::read_csv(
    file.path(tmp, "raw", "ch", "kw_d.csv"),
    show_col_types = FALSE
  )

  expect_equal(min(d$time), as.Date("2025-01-01"))
  expect_equal(max(d$time), Sys.Date())
  # gap-free: every consecutive day present
  expect_equal(max(as.numeric(diff(sort(d$time)))), 1)
})

test_that("backfill is a no-op when already up to date", {
  tmp <- withr::local_tempdir()
  withr::local_options(path_trendecon = tmp)
  dir.create(file.path(tmp, "raw", "ch"), recursive = TRUE)

  old <- data.frame(
    time = seq(Sys.Date() - 10, Sys.Date(), by = "day"),
    value = 1,
    n = 1L
  )
  readr::write_csv(old, file.path(tmp, "raw", "ch", "kw_d.csv"))

  local_mocked_bindings(
    ts_gtrends_windows = function(...) stop("should not be called"),
    .package = "trendecon"
  )

  expect_true(proc_keyword_backfill_daily("kw", "CH", from = Sys.Date() + 1))
})
