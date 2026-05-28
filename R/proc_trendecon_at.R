#' Calculate Trendecon Main Indices for Austria
#'
#' Updates every Austrian index from Google Trends and copies the seasonally
#' adjusted series into `data/at`. See [proc_trendecon()] for details.
#'
#' @param backfill_from Optional start date (`YYYY-mm-dd`); see
#'   [proc_trendecon_ch()].
#' @return Invisibly, a per-index status data frame.
#' @export
proc_trendecon_at <- function(backfill_from = NULL) {

  indices <- list(
    trendecon = c(
      "Wirtschaftskrise",
      "Kurzarbeit",
      "arbeitslos",
      "Insolvenz"
    )
  )

  proc_trendecon("AT", indices, backfill_from = backfill_from)
}
