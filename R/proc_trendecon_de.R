#' Calculate Trendecon Main Indices for Germany
#'
#' @export
proc_trendecon_de <- function() {
  keywords <- c("Wirtschaftskrise", "Kurzarbeit", "arbeitslos", "Insolvenz")
  proc_index(keywords, "de", "desi")
}

