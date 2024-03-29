# daily seasonal adjustment, using prophet
#
# seas_adj_file("Insolvenz")
proc_seas_adj <- function(keyword = "Insolvenz", geo = "ch") {

  message("seasonal adjustment keyword: ", keyword)

  tsbox::load_suggested("prophet")

  data <- read_keyword(keyword, geo, "mwd")

  # data <- tsbox::ts_tbl(AirPassengers)
  df <- dplyr::rename(data, ds = time, y = value)

  # financial crisis as oultier
  # df[df$ds >= "2008-09-01" & df$ds <= "2009-12-31", 'y'] <- NA

  # hack: prophet does not like to be imported
  generated_holidays <- prophet::generated_holidays
  assign("generated_holidays", prophet::generated_holidays, envir = globalenv())

  m <- prophet::prophet(daily.seasonality = FALSE)
  if (toupper(geo) %in% generated_holidays$country) {
    m <- prophet::add_country_holidays(m, country_name = toupper(geo))
  } else {
    message("no country holidays available for geo: '", geo, "'. Seasonal adjustment will be performed without using holiday information.")
  }
  m <- prophet::fit.prophet(m, df)

  # forecast <- predict(m, df)
  # prophet_plot_components(m, forecast)

  z <- predict(m)

  sa <-
    z %>%
    transmute(time = as.Date(ds), trend, seas_comp = additive_terms) %>% # additive_terms = yhat - trend,
    left_join(data, by = "time") %>%
    rename(orig = value) %>%
    mutate(seas_adj = orig - seas_comp) %>%
    ts_long()

  write_keyword(sa, keyword, geo, "sa")
}
