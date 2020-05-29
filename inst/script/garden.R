# currently, only:
keywords <- c("Heim+Hobby", "Bau+Hobby", "Do it + Garden",
 "Do it Migros", "Jumbo", "Landi", "Gartencenter", "Bauhaus", "Hornbach"
 )


# - [ ] `proc_keyword_init("Heim+Hobby")`
# - [ ] `proc_keyword_init("Bau+Hobby")`
# - [ ] `proc_keyword_init("Do it + Garden")`
# - [ ] `proc_keyword_init("Do it Migros")`
# - [ ] `proc_keyword_init("Jumbo")`
# - [ ] `proc_keyword_init("Landi")`
# - [ ] `proc_keyword_init("Gartencenter")`
# - [ ] `proc_keyword_init("Bauhaus")`
# - [ ] `proc_keyword_init("günstige flüge")`


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
write_keyword(x_prcomp, "garden", "sa")

# copy to data repo
# fs::file_copy(path_keyword("garden", "sa"), path_data("daily"), overwrite = TRUE)
