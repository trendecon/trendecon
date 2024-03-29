#' Calculate Trendecon Main Indices for Germany
#'
#' @export
#'
proc_trendecon_de <- function() {

  kw_inflationrate <- c(
    "inflation",
    "preise",
    "benzinpreis",
    "mietzins"
  )

  kw_trendecon <- c(
    "Wirtschaftskrise",
    "Kurzarbeit",
    "arbeitslos",
    "Insolvenz"
  )

  proc_index(kw_trendecon, "DE", 'trendecon')
  proc_index(kw_inflationrate, "DE", 'inflationrate')

  indices_in_production <- c(
    "inflationrate",
    "trendecon"
  )

  # copy to data/ch
  lapply(indices_in_production, function(e) fs::file_copy(path_keyword(e, "de", "sa"), path_data("de"), overwrite = TRUE))

  # FIXME: also store d, w, m, f in data/de
}


