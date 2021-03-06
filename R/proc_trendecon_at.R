#' Calculate Trendecon Main Indices for Germany
#'
#' @export
#'
proc_trendecon_at <- function() {

  kw_trendecon <- c(
    "Wirtschaftskrise",
    "Kurzarbeit",
    "arbeitslos",
    "Insolvenz"
  )

  proc_index(kw_trendecon, "AT", 'trendecon')

  indices_in_production <- c(
    "trendecon"
  )

  # copy to data/ch
  lapply(indices_in_production, function(e) fs::file_copy(path_keyword(e, "at", "sa"), path_data("at"), overwrite = TRUE))

  # FIXME: also store d, w, m, f in data/de
}


