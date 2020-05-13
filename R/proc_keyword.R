# proc_keyword("Insolvenz")

#' @export
proc_keyword <- function(keyword = "Insolvenz", n_windows = 2) {
  if (!exists(".latest_google_date")) .latest_google_date <<- as.Date("2099-01-01")

  # only process once a day

  latest_google_date <- function(keyword) {
    if (fs::file_exists(path_keyword(keyword, "sa"))) {
      max(read_keyword(keyword, "sa")$time)
    } else {
      as.Date("1900-01-01")
    }
  }


  previous_google_date <- latest_google_date(keyword)
  message()

  # if this happens, shift .latest_google_date
  if (previous_google_date > .latest_google_date) .latest_google_date <<- previous_google_date

  message(".latest_google_date: ", .latest_google_date)
  message("previous_google_date: ", previous_google_date)

  if (previous_google_date == .latest_google_date) {
    message("keyword ", keyword, " already processed today. skipping.")
    return(TRUE)
  }

  files_indicator <- grep(keyword, list.files(path_data_raw("indicator")), value = TRUE, fixed = TRUE)

  files_raw <- grep(keyword, list.files(path_data_raw("indicator_raw")), value = TRUE, fixed = TRUE)

  if (length(files_indicator) == 0 & (length(files_indicator) == 0)) {
    stop("No existing files found for keyword '", keyword, "' Have you run proc_keyword_init()?")
  }


  proc_keyword_latest(keyword = keyword, n_windows = n_windows)

  # for now
  proc_aggregate_raw(keyword = keyword)

  proc_combine_freq(keyword = keyword)

  proc_seas_adj(keyword = keyword)

  # store globally: next proc_keyword() run will only update if newer
  .latest_google_date <<- latest_google_date(keyword)
  return(invisible(TRUE))
}
