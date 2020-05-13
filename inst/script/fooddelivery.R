keywords <- c("take away","takeaway","pizza bestellen",
              "dieci pizza")

# cat(paste0("- [ ] `proc_keyword_init(\"", keywords, "\")`"), sep = "\n")

# - [ ] `proc_keyword_init("uber eats")`
# - [x] `proc_keyword_init("take away")`
# - [x] `proc_keyword_init("takeaway")`
# - [ ] `proc_keyword_init("essen bestellen")`
# - [x] `proc_keyword_init("pizza bestellen")`
# - [x] `proc_keyword_init("dieci pizza")`
# - [ ] `proc_keyword_init("eat.ch")`
# - [ ] `proc_keyword_init("essen liefern")`

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
write_keyword(x_prcomp, "fooddelivery", "sa")

# copy to data repo
fs::file_copy(path_keyword("fooddelivery", "sa"), path_data("daily"), overwrite = TRUE)
