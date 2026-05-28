# trendecon 0.3.1

## Rate-limit resilience

* `gtrends_with_backoff()` now paces queries via
  `options(trendecon.query_pause = <seconds>)` to stay under Google's rate
  limiter (off by default). Pacing prevents rate limits far more reliably than
  recovering from them, which matters for high-volume bursts like the gap
  backfill.
* A query that still returns "no data" after exhausting retries is treated as a
  genuinely empty (zero-volume) window instead of aborting the keyword. Retries
  first give a transient rate limit - which can also present as "no data" - a
  chance to recover. This stops a single low-volume keyword from freezing an
  entire index (which truncates to its weakest keyword's last date).
* `proc_keyword_backfill_daily()` retries more generously by default.

# trendecon 0.3.0

## Resilience

* `proc_trendecon_ch()`, `proc_trendecon_de()` and `proc_trendecon_at()` now
  process each index independently. If one index (or a single keyword within it)
  fails, the remaining indices still run and every index that succeeds is written
  to `data/<geo>` immediately. Previously a single failed query aborted the whole
  daily run and committed nothing. The three functions now delegate to a shared
  internal `proc_trendecon()` worker and return a per-index status data frame.

* `proc_index()` isolates each keyword download in a `tryCatch()`, so a keyword
  whose retries are exhausted no longer aborts its index; the index is rebuilt
  from whatever data exists on disk (fresh where the download worked, previous
  values otherwise).

* `gtrends_with_backoff()` now uses jittered exponential backoff (capped) instead
  of linear waits, retries more times by default, and treats a broader set of
  errors as transient (any 5xx, rate/quota limits, and network/curl failures, in
  addition to the previous non-200 and 429 cases).

## Tests

* Added tests covering the backoff retry/give-up behaviour and the per-index
  failure isolation.
