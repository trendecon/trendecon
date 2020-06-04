# keywords <- c( "Mango", "Zara", "H&M", "PKZ", "Blue Tomato","Dosenbach", "Schuhe kaufen", "Ochsner Schuhe")
# proc_index(keywords, "ch", "clothing")
proc_index <- function(keywords, geo, index_name) {

  lapply(keywords, proc_keyword)

  data <- read_keywords(keywords, id = "seas_adj")

  # check if they have the same span
  stopifnot(nrow(distinct(ts_summary(data), start, end)) == 1)

  x_prcomp <- filter(ts_prcomp(data), id == "PC1") %>%
    select(-id) %>%
    ts_scale()

  write_keyword(x_prcomp, index_name, geo, "sa")
}
