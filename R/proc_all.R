#' Calculate Trendecon Main Indices
#'
#' @param path base directory
#' @export
proc_all <- function(path = ".") {

  .Deprecated("proc_trendecon_ch")

  # path <- normalizePath("../data-raw")

  # check if data-raw
  if (!all(c("data", "data-raw") %in% list.files(path))) {
    stop("'data' and 'data-raw' not found in: ", path, ". Make sure the two repositories are in the same folder")
  }


  path <- normalizePath(file.path(path, "data-raw"))


  op <- options(path_trendecon = path)
  on.exit(options(op))

  indices_in_production <- c(
    "clothing"
    "garden",
    "luxury",
    "mobility",
    "social",
    "travel",
    "trendecon",
    "fooddelivery"
  )

  bname <- paste0(indices_in_production, ".R")
  scripts <- list.files(system.file("script", package = "trendecon"), pattern = "\\.[rR]$")
  stopifnot(all(bname %in% scripts))

  for (index in indices_in_production) {
    index_script <- system.file("script", paste0(index, ".R"), package = "trendecon")
    source(index_script, encoding = "UTF-8")
  }

  # copy to data repo (vintage)
  lapply(indices_in_production, function(e) fs::file_copy(path_keyword(e, "sa"), path_trendecon("..", "daily"), overwrite = TRUE))

}
