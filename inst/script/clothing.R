keywords <- c( "Mango", "Zara", "H&M", "PKZ", "Blue Tomato","Dosenbach", "Schuhe kaufen", "Ochsner Schuhe")

library(tsbox)
library(dplyr)
library(tibble)

# update indicators
lapply(keywords, proc_keyword)

data <- read_keywords(keywords, id = "seas_adj")

# check if they have the same span
smry <- ts_summary(data)
smry
stopifnot(nrow(distinct(smry, start, end)) == 1)

x_prcomp <- filter(ts_prcomp(data), id == "PC1") %>%
  # mutate(value = -value) %>%
  select(-id) %>%
  ts_scale()

# ts_dygraphs(x_prcomp)

# this is our main product
write_keyword(x_prcomp, "clothing", "ch", "sa")

# copy to data repo
# fs::file_copy(path_keyword("clothing", "sa"), path_data("daily"), overwrite = TRUE)
