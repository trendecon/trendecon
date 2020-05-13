# daily seasonal adjustment, using prophet
#
# seas_adj_file("Insolvenz")
proc_seas_adj <- function(keyword = "Insolvenz") {
  message("seasonal adjustment keyword: ", keyword)

  library(prophet)

  data <- read_keyword(keyword, "mwd")

  # to include user defined holidays
  # holidays <- tibble(
  #   holiday = "Christoph's Birthday",
  #   ds = data$time[lubridate::month(data$time) == 3 & lubridate::day(data$time) == 28],
  #   lower_window = 0,
  #   upper_window = 1
  # )

  df <- rename(data, ds = time, y = value)

  # financial crisis as oultier
  # df[df$ds >= "2008-09-01" & df$ds <= "2009-12-31", 'y'] <- NA

  m <-
    # prophet(holidays = holidays, daily.seasonality = FALSE) %>%
    prophet(daily.seasonality = FALSE) %>%
    add_country_holidays(country_name = "CH") %>%
    fit.prophet(df)

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

  write_keyword(sa, keyword, "sa")
}
