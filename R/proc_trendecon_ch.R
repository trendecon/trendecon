#' Calculate Trendecon Main Indices for Switzeland
#'
#' @param path base directory
#' @param test test mode, produces one index only
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

  # TODO Still uses sourced script for trendecon indicator. Change.
  for (index in indices_in_production) {
    if (index != "trendecon"){
      keywords <- read_index_json("../keywords/keywords_ch.json", index)
      proc_index(keywords, "CH", index)
    }
    else{
    index_script <- system.file("script", paste0(index, ".R"), package = "trendecon")
    source(index_script, encoding = "UTF-8")
    }
  }

  # vintage mode, copy to 'daily'
  lapply(indices_in_production, function(e) fs::file_copy(path_keyword(e, "ch", "sa"), path_daily(), overwrite = TRUE))

  # from now, copy to data/ch
  lapply(indices_in_production, function(e) fs::file_copy(path_keyword(e, "ch", "sa"), path_data("ch"), overwrite = TRUE))

  # FIXME also store d, w, m, f in data/ch

}
