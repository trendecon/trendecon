proc_aggregate <- function(keyword = "Insolvenz") {
  aggregate_one <- function(suffix_start) {
    files <- normalizePath(list.files(path_data_raw("indicator_raw"), pattern = "csv$", full.names = TRUE))
    files <- grep(paste0(keyword, "_", suffix_start), files, fixed = TRUE, value = TRUE)

    datas <- lapply(files, function(e) aggregate_windows(read_csv(e, col_types = cols())))
    ans_based_on_averages <- Reduce(aggregate_averages, datas)

    # proc_aggregate performs aggregation on averages. With every update a
    # weigthed average of the existing and the new series is calculated. The
    # number of draws are used as weights.

    # to verify, the following code produces an average of the raw data:
    # data <- bind_rows(lapply(files, function(e) read_csv(e, col_types = cols())))
    # ans_based_on_raw <- aggregate_windows(data)

    # In principle, this should yield the same results
    # stopifnot(all.equal(ans_based_on_averages, ans_based_on_raw))

    write_keyword(ans_based_on_averages, keyword, suffix_start)
  }

  aggregate_one("d")
  aggregate_one("w")
  aggregate_one("m")
}
