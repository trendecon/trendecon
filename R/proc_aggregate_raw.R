# may become obsolete. creates aggregated series from raw data.
# in the future, it may be sufficient to store aggregations only.

proc_aggregate_raw <- function(keyword = "Insolvenz") {

  aggregate_raw_one <- function(suffix_start) {

    files <- normalizePath(list.files(path_data_raw("indicator_raw"), pattern = "csv$", full.names = TRUE))
    files <- grep(paste0(keyword, "_", suffix_start), files, fixed = TRUE, value = TRUE)

    datas <- lapply(files, function(e) aggregate_windows(read_csv(e, col_types = cols())))
    ans_based_on_averages <- Reduce(aggregate_averages, datas)

    data <- bind_rows(lapply(files, function(e) read_csv(e, col_types = cols())))
    ans_based_on_raw <- aggregate_windows(data)

    # stopifnot(all.equal(ans_based_on_averages, ans_based_on_raw))

    write_keyword(ans_based_on_averages, keyword, suffix_start)
  }

  aggregate_raw_one("d")
  aggregate_raw_one("w")
  aggregate_raw_one("m")

}
