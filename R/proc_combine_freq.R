# proc_combine_freq("Insolvenz")
proc_combine_freq <- function(keyword = "Insolvenz", geo = "ch") {
  message("combining frequencies of keyword: ", keyword)

  h <- select(read_keyword(keyword, geo, "h"), -n)
  d <- select(read_keyword(keyword, geo, "d"), -n)
  w <- select(read_keyword(keyword, geo, "w"), -n)
  m <- select(read_keyword(keyword, geo, "m"), -n)


  # extend daily data with hourly data
  # to do so - adjust the mean level of hourly data to match overlapping daily values
  message("extend daily data by hourly data for the missing recent days")
  dh <- inner_join(d, h, by="time", suffix=c(".d", ".h"))
  h <- h %>%
    mutate(value = value * mean(dh$value.d) / mean(dh$value.h)) %>%
    mutate(value = if_else(value > 100, 100, value)) %>%
    filter(time > max(d$time))
  d <- rbind(d, h)


  message("align daily data to weekly")
  m_wd <- tempdisagg::td(w ~ d, method = "fast", conversion = "mean")

  # the slope coefficient should be around 1 and significant, otherwise the movement is not copied well
  # summary(m_wd)
  wd <- predict(m_wd)

  # 2. bend daily series (which fullfills weekly constraint) so that monthly
  # values are identical to monthly series
  message("align weekly data to monthly")
  m_mwd <- tempdisagg::td(m ~ wd, method = "fast", conversion = "mean")
  mwd <- predict(m_mwd)

  write_keyword(mwd, keyword, geo, "mwd")

  # mwd_old <- read_keyword(keyword, "mwd")
  # write_csv(ts_c(mwd_old, mwd), "data/indicator_doc/mwd_old.csv")
  # ts_dygraphs(read_csv("data/indicator_doc/mwd_old.csv"))
}
