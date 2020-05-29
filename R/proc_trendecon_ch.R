#' Calculate Trendecon Main Indices for Switzeland
#'
#' @param path base directory
#' @export
proc_trendecon_ch <- function(path = ".", test = FALSE) {

  # path <- normalizePath("../data-raw")

  path <- normalizePath(path)

  op <- options(path_trendecon = path)
  on.exit(options(op))

  indices_in_production <- c(
    "clothing",
    "garden",
    "luxury",
    "mobility",
    "social",
    "travel",
    "trendecon",
    "fooddelivery"
  )

  # so it takes less time to test
  if (test) {
    indices_in_production <- c(
      "clothing"
    )
  }

  bname <- paste0(indices_in_production, ".R")
  scripts <- list.files(system.file("script", package = "trendecon"), pattern = "\\.[rR]$")
  stopifnot(all(bname %in% scripts))

  for (index in indices_in_production) {
    index_script <- system.file("script", paste0(index, ".R"), package = "trendecon")
    source(index_script, encoding = "UTF-8")
  }


  lapply(indices_in_production, function(e) fs::file_copy(path_keyword(e, "sa"), path_daily(), overwrite = TRUE))

}
