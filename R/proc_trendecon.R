#' Process all indices for one country, tolerant of partial failure
#'
#' Internal worker behind [proc_trendecon_ch()], [proc_trendecon_de()] and
#' [proc_trendecon_at()]. Each index is processed in isolation: if one index
#' (or a keyword within it) fails, the remaining indices still run, and every
#' index that succeeds is copied to `data/<geo>` immediately. This prevents a
#' single bad keyword or a transient Google Trends error from zeroing out the
#' entire daily run.
#'
#' @param geo Two-letter geography, e.g. `"CH"`.
#' @param indices Named list mapping each index name to its keyword vector.
#'   Indices are processed in list order.
#' @param backfill_from Optional start date (`YYYY-mm-dd`) passed to
#'   [proc_index()] / [proc_keyword_backfill_daily()] to fill a daily gap left by
#'   an outage. Use once; leave `NULL` for normal daily runs.
#'
#' @return Invisibly, a data frame with one row per index and columns
#'   `geo`, `index`, `ok`, `error`. Stops with an error only if *every* index
#'   failed.
#' @keywords internal
proc_trendecon <- function(geo, indices, backfill_from = NULL) {

  create_dir_if_needed(path_data(tolower(geo)))

  status <- lapply(names(indices), function(index_name) {
    err <- NA_character_
    ok <- tryCatch(
      {
        proc_index(indices[[index_name]], geo, index_name, backfill_from = backfill_from)
        fs::file_copy(
          path_keyword(index_name, geo, "sa"),
          path_data(tolower(geo)),
          overwrite = TRUE
        )
        TRUE
      },
      error = function(e) {
        err <<- conditionMessage(e)
        message("INDEX FAILED: ", geo, "/", index_name, " - ", err)
        FALSE
      }
    )
    data.frame(
      geo = geo, index = index_name, ok = ok, error = err,
      stringsAsFactors = FALSE
    )
  })

  status <- do.call(rbind, status)

  n_ok <- sum(status$ok)
  message(sprintf("[%s] %d/%d indices updated", geo, n_ok, nrow(status)))
  if (n_ok == 0) {
    stop("All indices failed for geo '", geo, "'", call. = FALSE)
  }

  invisible(status)
}
