# currently, only:
keywords <- c("christ","bucherer","uhren","uhr","swarovski","rhomberg","juwelier")

# - [x] `proc_keyword_init("christ")`
# - [x] `proc_keyword_init("bucherer")`
# - [x] `proc_keyword_init("uhren")`
# - [x] `proc_keyword_init("uhr")`
# - [x] `proc_keyword_init("swarovski")`
# - [x] `proc_keyword_init("rhomberg")`
# - [x] `proc_keyword_init("juwelier")`

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

ts_dygraphs(x_prcomp)

# this is our main product
write_keyword(x_prcomp, "luxury", "sa")

# copy to data repo
fs::file_copy(path_keyword("luxury", "sa"), path_data("daily"), overwrite = TRUE)
