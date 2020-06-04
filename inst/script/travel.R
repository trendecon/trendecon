# currently, only:
keywords <- c("städtetrip","flug buchen", # "ferien buchen",
  "günstige flüge")

# - [ ] `proc_keyword_init("städtetrip")`
# - [ ] `proc_keyword_init("flug buchen")`
# - [ ] `proc_keyword_init("ferien buchen")`
# - [ ] `proc_keyword_init("günstige flüge")`


# update indicators
lapply(keywords, proc_keyword)

data <- read_keywords(keywords, id = "seas_adj")

# check if they have the same span
smry <- ts_summary(data)
smry
stopifnot(nrow(dplyr::distinct(smry, start, end)) == 1)

x_prcomp <- filter(ts_prcomp(data), id == "PC1") %>%
  # mutate(value = -value) %>%
  select(-id) %>%
  ts_scale()

ts_dygraphs(x_prcomp)

# this is our main product
write_keyword(x_prcomp, "travel", "ch", "sa")

# copy to data repo
# fs::file_copy(path_keyword("travel", "sa"), path_data("daily"), overwrite = TRUE)
