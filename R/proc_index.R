# keywords <- c( "Mango", "Zara", "H&M", "PKZ", "Blue Tomato","Dosenbach", "Schuhe kaufen", "Ochsner Schuhe")
# proc_index(keywords, "ch", "clothing")
proc_index <- function(keywords, geo, index_name) {

  lapply(keywords, proc_keyword, geo = geo)

  data <- read_keywords(keywords, geo = geo, id = "seas_adj")

  # check if they have the same span
  stopifnot(nrow(distinct(ts_summary(data), start, end)) == 1)

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
