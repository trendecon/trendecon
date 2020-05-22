#' Processes the data for a single keyword.
#'
#' Processing includes
#' - donwloading the latest data
#' - aggregating
#' - combining
#' - seasonal adjustment

#' @param keyword A single keyword for which to process the data.
#' @param n_windows Number of windows, passed to [ts_gtrends_windows], used
#'     when downloading the latest data.
#'
#' @seealso[ts_gtrends_windows]
#' @export



proc_keyword <- function(keyword = "Insolvenz", n_windows = 2) {
  stop_if_no_data(keyword)

  previous_google_date <- check_when_last_processed(keyword)

  if (previous_google_date == .latest_google_date) {
    message("keyword ", keyword, " already processed today. skipping.")
    return(TRUE)
  } else {

    proc_keyword_latest(keyword = keyword, n_windows = n_windows)

    proc_aggregate(keyword = keyword)

    proc_combine_freq(keyword = keyword)

    proc_seas_adj(keyword = keyword)

    # store globally: next proc_keyword() run will only update if newer
    .latest_google_date <<- latest_google_date(keyword)
    return(invisible(TRUE))
  }
}

stop_if_no_data <- function(keyword) {
  files_indicator <- grep(keyword, list.files(path_data_raw("indicator")), value = TRUE, fixed = TRUE)
  files_indicator_raw <- grep(keyword, list.files(path_data_raw("indicator_raw")), value = TRUE, fixed = TRUE)
  if (length(files_indicator) == 0 & (length(files_indicator_raw) == 0)) {
    stop("No existing files found for keyword '", keyword, "' Have you run proc_keyword_init()?")
  }
}

check_when_last_processed <- function(keyword) {
  if (!exists(".latest_google_date")) .latest_google_date <<- as.Date("2099-01-01")
  previous_google_date <- latest_google_date(keyword)
  message()
  if (previous_google_date > .latest_google_date) .latest_google_date <<- previous_google_date
  message(".latest_google_date: ", .latest_google_date)
  message("previous_google_date: ", previous_google_date)
  return(previous_google_date)
}

latest_google_date <- function(keyword) {
  if (fs::file_exists(path_keyword(keyword, "sa"))) {
    max(read_keyword(keyword, "sa")$time)
  } else {
    as.Date("1900-01-01")
  }
}
