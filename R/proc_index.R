#' Prepare an index.
#'
#' Creates or updates an index using data from already downloaded keywords.
#'
#' This function assumes the data for all keywords exists.
#' Then it proceeds to go through several steps:
#' 1) updates all the keywords by downloading newest Google trends data.
#' 2) combines monthly, weekly, and daily frequencies.
#' 3) runs seasonal adjustment steps.
#' 4) combines all the keywords into one index using principal components.
#' 5) writes the produced index to a file
#'
#' @param keywords A vector of keyword names comprising the index.
#' @param geo A character vector denoting geographic region.
#' @param index_name The name given to the index.
#'
#' @examples
#' \dontrun{
#' keywords <- c("Mango", "Zara", "H&M", "PKZ", "Blue Tomato", "Dosenbach", "Schuhe kaufen", "Ochsner Schuhe")
#' proc_index(keywords, "ch", "clothing")
#' }
#' @export
proc_index <- function(keywords, geo, index_name) {

  lapply(keywords, proc_keyword, geo = geo)

  data <- read_keywords(keywords, geo = geo, id = "seas_adj")

  # make sure all keywords have the same span
  data <- data %>%
    filter(time <= min(ts_summary(data)$end))

  x_prcomp <- filter(ts_prcomp(data), id == "PC1") %>%
    select(-id) %>%
    ts_scale()

  # determine PC sign based on average correlation with actual time series
  values  <- mapply(getElement, split(data, data$keyword), "value")
  corsign <- mean(cor(values, x_prcomp$value))
  if(corsign < 0) {
    x_prcomp$value <- -x_prcomp$value
  }

  # invert main index
  if (index_name == "trendecon") {
    x_prcomp$value <- -x_prcomp$value
  }

  write_keyword(x_prcomp, index_name, geo, "sa")
}
