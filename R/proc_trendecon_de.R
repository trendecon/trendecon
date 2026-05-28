#' Calculate Trendecon Main Indices for Germany
#'
#' Updates every German index from Google Trends and copies the seasonally
#' adjusted series into `data/de`. Indices are processed independently. See
#' [proc_trendecon()] for details.
#'
#' @param backfill_from Optional start date (`YYYY-mm-dd`); see
#'   [proc_trendecon_ch()].
#' @return Invisibly, a per-index status data frame.
#' @export
proc_trendecon_de <- function(backfill_from = NULL) {

  indices <- list(
    trendecon = c(
      "Wirtschaftskrise",
      "Kurzarbeit",
      "arbeitslos",
      "Insolvenz"
    ),
    inflationrate = c(
      "inflation",
      "preise",
      "benzinpreis",
      "mietzins"
    )
  )

  proc_trendecon("DE", indices, backfill_from = backfill_from)
}
