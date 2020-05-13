aggregate_windows <- function(data) {
  data %>%
    group_by(time) %>%
    summarize(value = mean(value), n = n()) %>%
    ungroup()
}


aggregate_averages <- function(data_1, data_2) {
  data_1 %>%
    full_join(
      rename(data_2, value_2 = value, n_2 = n),
      by = "time"
    ) %>%
    mutate_at(vars(n, n_2), coalesce, 0L) %>%
    mutate_at(vars(value, value_2), coalesce, 0) %>%
    # weigthed average
    transmute(time, value = (value * n + value_2 * n_2) / (n + n_2), n = n + n_2) %>%
    arrange(time)
}
