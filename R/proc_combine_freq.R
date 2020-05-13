# proc_combine_freq("Insolvenz")
proc_combine_freq <- function(keyword = "Insolvenz") {

  message("combining frequencies of keyword: ", keyword)

  library(tempdisagg)

  d <- select(read_keyword(keyword, "d"), -n)
  w <- select(read_keyword(keyword, "w"), -n)
  m <- select(read_keyword(keyword, "m"), -n)

  message("align daily data to weekly")
  m_wd <- td(w ~ d, method = "fast", conversion = "mean")

  # the slope coefficient should be around 1 and significant, otherwise the movement is not copied well
  # summary(m_wd)
  wd <- predict(m_wd)

  #' 2. bend daily series (which fullfills weekly constraint) so that monthly
  #' values are identical to monthy series
  message("align weekly data to monthy")
  m_mwd <- td(m ~ wd, method = "fast", conversion = "mean")
  mwd <- predict(m_mwd)

  write_keyword(mwd, keyword, "mwd")

  # mwd_old <- read_keyword(keyword, "mwd")
  # write_csv(ts_c(mwd_old, mwd), "data/indicator_doc/mwd_old.csv")
  # ts_dygraphs(read_csv("data/indicator_doc/mwd_old.csv"))

}
