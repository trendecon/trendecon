# currently, only:
keywords <- c( "Kino", "Theater", "Cinema", "ticketcorner", "starticket",
               "oper","konzert")

# update indicators
lapply(keywords, proc_keyword)

data <- read_keywords(keywords, id = "seas_adj")

# check if they have the same span
smry <- ts_summary(data)
smry
stopifnot(nrow(distinct(smry, start, end)) == 1)

x_prcomp <-
  filter(ts_prcomp(data), id == "PC1") %>%
  # mutate(value = -value) %>%
  select(-id) %>%
  ts_scale()

# this is our main product
write_keyword(x_prcomp, "social", "sa")

ts_dygraphs(x_prcomp)

# copy to data repo
fs::file_copy(path_keyword("social", "sa"), path_data("daily"), overwrite = TRUE)
