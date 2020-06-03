keywords <- c("coopathome","coop at home","leshop","le shop","farmy",
              "coop online bestellen","migros online bestellen",
              "lebensmittel online bestellen","volg online")

# cat(paste0("- [ ] `proc_keyword_init(\"", keywords, "\")`"), sep = "\n")

# - [ ] `proc_keyword_init("coopathome")`
# - [ ] `proc_keyword_init("coop at home")`
# - [ ] `proc_keyword_init("leshop")`
# - [ ] `proc_keyword_init("le shop")`
# - [ ] `proc_keyword_init("farmy")`
# - [ ] `proc_keyword_init("coop online bestellen")`
# - [ ] `proc_keyword_init("migros online bestellen")`
# - [ ] `proc_keyword_init("lebensmittel online bestellen")`
# - [ ] `proc_keyword_init("volg online")`

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
write_keyword(x_prcomp, "onlinegroceries", "sa")

# copy to data repo
# fs::file_copy(path_keyword("onlinegroceries", "sa"), path_data("daily"), overwrite = TRUE)
