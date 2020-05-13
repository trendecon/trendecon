#' @export
proc_all <- function(path = ".") {

  # path <- normalizePath("../data-raw")

  path <- normalizePath(path)

  # check if data-raw
  if (!all(c("data", "data-raw") %in% list.files(path))) {
    stop("'data' and 'data-raw' not found in: ", path, ". Make sure the two repositories are in the same folder")
  }

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

  bname <- paste0(indices_in_production, ".R")
  scripts <- list.files(system.file("script", package = "gtrendecon"), pattern = "\\.[rR]$")
  stopifnot(all(bname %in% scripts))

  library(gtrendecon)
  for (index in indices_in_production) {
    index_script <- system.file("script", paste0(index, ".R"), package = "gtrendecon")
    source(index_script, encoding = "UTF-8")
  }

}


