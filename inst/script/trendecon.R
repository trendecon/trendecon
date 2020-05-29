# trendecon main indicator

keywords <- c("Wirtschaftskrise", "Kurzarbeit", "arbeitslos", "Insolvenz")

# update indicators
lapply(keywords, proc_keyword)

data <- read_keywords(keywords, id = "seas_adj")

# check if they have the same span
smry <- ts_summary(data)
smry
stopifnot(nrow(dplyr::distinct(smry, start, end)) == 1)

seas_adj <- filter(ts_prcomp(data), id == "PC1") %>%
  mutate(value = -value) %>%
  select(-id) %>%
  ts_scale()


pca <- prcomp(ts_ts(data), scale = TRUE)

# PC2 is some kind of labor market indicator?
# library(ggfortify)
# autoplot(pca, loadings = TRUE, loadings.colour = 'blue', loadings.label = TRUE)

w_pc1 <- enframe(pca$rotation[, 'PC1'], "keyword", "weight")

# replicate 'seas_adj' from scratch
# data %>%
#   ts_scale() %>%
#   left_join(w_pc1) %>%
#   group_by(time) %>%
#   summarize(value = sum(value * weight)) %>%
#   ungroup()

# ts_dygraphs(x_prcomp)


# using weights from pca to calculate orig
orig <- read_keywords(keywords, id = "orig") %>%
  ts_scale() %>%
  left_join(w_pc1, by = "keyword") %>%
  group_by(time) %>%
  summarize(value = -sum(value * weight)) %>%
  ungroup() %>%
  ts_scale()


# ts_dygraphs(ts_c(
#   sa = select(read_keywords("Kurzarbeit", id = "seas_adj"), -keyword),
#   orig = select(read_keywords("Kurzarbeit", id = "orig"), -keyword)
# ))


ans <- ts_c(seas_adj, orig, seas_comp = orig  %ts-% seas_adj)
# ts_dygraphs(ans)


# ts_dygraphs(ts_pick(ans, "seas_comp"))


# this is our main product
write_keyword(seas_adj, "trendecon", "sa")
write_keyword(ans, "trendecon", "all")

# copy to data repo
# fs::file_copy(path_keyword("trendecon", "sa"), path_data("daily"), overwrite = TRUE)
# fs::file_copy(path_keyword("trendecon", "all"), path_data("daily"), overwrite = TRUE)

# store all keywords (disscuss w Angelica)
# write_csv(read_keywords(keywords), "../data/daily/trendecon_keywords.csv")
